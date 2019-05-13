#!/bin/bash

# Exit on error
set -e

echo "### Configuration"

ID=$1
echo "ID:" $ID

TYPE=$2
echo "Type:" $TYPE

MASS=$3
echo "Mass:" $MASS

NUM_EVENTS=$4
echo "Number of events:" $RUNDIR

RUNDIR=$PWD
echo "Rundir:" $RUNDIR

export HOME=$PWD
echo "HOME:" $HOME

EOS_HOME=/eos/user/s/swunsch
echo "EOS home:" $EOS_HOME

OUTPUTDIR=${EOS_HOME}/mass_regression/
echo "Outputdir:" $OUTPUTDIR

SCRAM_ARCH=slc6_amd64_gcc530
echo "SCRAM arch:" $SCRAM_ARCH

echo "### System"

echo "Hostname:" `hostname`

echo "How am I?" `id`

echo "Where am I?" `pwd`

echo "What is my system?" `uname -a`

echo "### Begin of job"

echo "Start job at" `date`

echo "### Go to rundir"

cd $RUNDIR

echo "### Set up CMSSW"

source /cvmfs/cms.cern.ch/cmsset_default.sh
scram project CMSSW CMSSW_9_2_10
cd CMSSW_9_2_10/src
eval `scramv1 runtime -sh`

echo "### Add Configuration/Generator"

git config --global user.name 'Foo'
git config --global user.email 'foo@bar.ch'
git config --global user.github 'foo'

git cms-addpkg Configuration/Generator

echo "### Add ntupleBuilder"

mkdir -p workspace
git clone https://github.com/stwunsch/ntupleBuilder workspace/ntupleBuilder --depth 1

PDG_ID=-1
if [ $TYPE = "GGH" ]; then
    PDG_ID=25
fi

if [ $TYPE = "QQH" ]; then
    PDG_ID=25
fi
if [ $TYPE = "DY" ]; then
    PDG_ID=23
fi

sed -i "s,PDG_ID,"$PDG_ID",g" workspace/ntupleBuilder/src/ntupleBuilder.cc

echo "### Copy generator snipplet and set properties"

cp workspace/ntupleBuilder/python/generatorSnipplet_${TYPE}_cfi.py Configuration/Generator/python

sed -i "s,MASS,"$MASS",g" Configuration/Generator/python/generatorSnipplet_cfi.py
sed -i "s,MASS_MIN,"$(expr $MASS + 1)",g" Configuration/Generator/python/generatorSnipplet_cfi.py
sed -i "s,MASS_MAX,"$(expr $MASS - 1)",g" Configuration/Generator/python/generatorSnipplet_cfi.py

echo "### Build CMSSW"

scram b

echo "### Create AODSIM with pile-up"

ERA="Run2_25ns"
CONDITIONS="auto:run2_mc"
BEAMSPOT="Realistic25ns13TeVEarly2017Collision"

cmsDriver.py MinBias_13TeV_pythia8_TuneCUETP8M1_cfi \
    --conditions ${CONDITIONS} \
    --fast \
    -n ${NUM_EVENTS} \
    --era ${ERA} \
    --eventcontent FASTPU \
    -s GEN,SIM,RECOBEFMIX,DIGI:pdigi_valid,RECO \
    --datatier GEN-SIM-RECO \
    --beamspot ${BEAMSPOT} \
    --no_exec

# Set random seed with job id
sed -i "s/Services_cff')/Services_cff'); process.RandomNumberGeneratorService.generator.initialSeed = "${ID}"/g" MinBias_13TeV_pythia8_TuneCUETP8M1_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO.py

cmsRun MinBias_13TeV_pythia8_TuneCUETP8M1_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO.py

echo "### Create AODSIM with target process and PU mixing"

cmsDriver.py generatorSnipplet_cfi \
        --conditions ${CONDITIONS} \
        --fast \
        -n ${NUM_EVENTS} \
        --era ${ERA} \
        --eventcontent AODSIM \
        -s GEN,SIM,RECOBEFMIX,DIGI:pdigi_valid,RECO \
        --datatier AODSIM \
        --beamspot ${BEAMSPOT} \
        --pileup_input file:MinBias_13TeV_pythia8_TuneCUETP8M1_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO.root \
        --pileup AVE_35_BX_25ns \
        --no_exec

# Set random seed with job id
sed -i "s/Services_cff')/Services_cff'); process.RandomNumberGeneratorService.generator.initialSeed = "${ID}"/g" generatorSnipplet_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO_PU.py

cmsRun generatorSnipplet_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO_PU.py

echo "### Create MiniAOD"

cmsDriver.py miniAOD-prod \
        -s PAT \
        --eventcontent MINIAODSIM \
        --runUnscheduled \
        --mc \
        --fast \
        -n ${NUM_EVENTS} \
        --filein file://generatorSnipplet_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO_PU.root \
        --conditions ${CONDITIONS} \
        --era ${ERA} \
        --customise_commands 'del process.patTrigger; del process.selectedPatTrigger' \
        --no_exec

cmsRun miniAOD-prod_PAT.py

echo "### Run ntupleBuilder analyzer on MiniAOD"

sed -i -e "s,^files =,files = ['file:miniAOD-prod_PAT.root'] #,g" workspace/ntupleBuilder/python/run_cfi.py
cmsRun workspace/ntupleBuilder/python/run_cfi.py

echo "### Copy files to output folder"

# Trigger auto mount of EOS
ls -la $EOS_HOME

mkdir -p $OUTPUTDIR
#xrdcp -f miniAOD-prod_PAT.root root://eosuser.cern.ch/${OUTPUTDIR}/MiniAOD_id${ID}_mass${MASS}_events${NUM_EVENTS}.root
xrdcp -f output.root root://eosuser.cern.ch/${OUTPUTDIR}/ntuple_id${ID}_type${TYPE}_mass${MASS}_events${NUM_EVENTS}.root

echo "### End of job"

echo "End job at" `date`
