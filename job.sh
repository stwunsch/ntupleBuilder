#!/bin/bash

# Exit on error
set -e

echo "### Configuration"

ID=0
echo "ID:" $ID

MASS=125
echo "Mass:" $MASS

NUM_EVENTS=100
echo "Number of events:" $RUNDIR

RUNDIR=$PWD
echo "Rundir:" $RUNDIR

OUTPUTDIR=/ceph/wunsch/foo/
echo "Outputdir:" $OUTPUTDIR

echo "### System"

echo "Hostname:" `hostname`

echo "How am I?" `id`

echo "Where am I?" `pwd`

echo "What is my system?" `uname -a`

echo "### Begin of job"

echo "### Go to rundir"

cd $RUNDIR

echo "### Set up CMSSW"

source /cvmfs/cms.cern.ch/cmsset_default.sh
scram project CMSSW CMSSW_9_2_10
cd CMSSW_9_2_10/src
eval `scramv1 runtime -sh`

echo "### Add Configuration/Generator"

git cms-addpkg Configuration/Generator

echo "### Add ntupleBuilder"

mkdir -p workspace
git clone https://github.com/stwunsch/ntupleBuilder workspace/ntupleBuilder --depth 1

echo "### Copy generator snipplet and set mass"

cp workspace/ntupleBuilder/python/generatorSnipplet_cfi.py Configuration/Generator/python

sed -i "s,MASS,"$MASS",g" Configuration/Generator/python/generatorSnipplet_cfi.py

echo "### Build CMSSW"

scram b

echo "### Run simulation and create AODSIM"

ERA="Run2_25ns"
CONDITIONS="auto:run2_mc"
cmsDriver.py generatorSnipplet_cfi \
        --conditions ${CONDITIONS} \
        --fast \
        -n ${NUM_EVENTS} \
        --era ${ERA} \
        --eventcontent AODSIM \
        -s GEN,SIM,RECOBEFMIX,DIGI:pdigi_valid,RECO \
        --datatier GEN-SIM-DIGI-RECO \
        --beamspot Realistic25ns13TeVEarly2017Collision

echo "### Create MiniAOD"

cmsDriver.py miniAOD-prod \
        -s PAT \
        --eventcontent MINIAODSIM \
        --runUnscheduled \
        --mc \
        --fast \
        -n ${NUM_EVENTS} \
        --filein file://generatorSnipplet_cfi_GEN_SIM_RECOBEFMIX_DIGI_RECO.root \
        --conditions ${CONDITIONS} \
        --era ${ERA} \
        --customise_commands 'del process.patTrigger; del process.selectedPatTrigger'

echo "### Run ntupleBuilder analyzer on MiniAOD"

sed -i -e "s,^files =,files = ['file:miniAOD-prod_PAT.root'] #,g" workspace/ntupleBuilder/python/run_cfi.py
cmsRun workspace/ntupleBuilder/python/run_cfi.py

echo "### Copy files to output folder"

mkdir -p $OUTPUTDIR
cp miniAOD-prod_PAT.root $OUTPUTDIR/MiniAOD_id${ID}_mass${MASS}_events${NUM_EVENTS}.root
cp output.root $OUTPUTDIR/ntuple_id${ID}_mass${MASS}_events${NUM_EVENTS}.root

echo "### End of job"
