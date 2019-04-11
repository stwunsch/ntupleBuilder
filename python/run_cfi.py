import FWCore.ParameterSet.Config as cms
import FWCore.Utilities.FileUtils as FileUtils

process = cms.Process("ntupleBuilder")
process.load("Configuration.Geometry.GeometryIdeal_cff")
process.load("Configuration.StandardSequences.MagneticField_cff")
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.load("FWCore.MessageLogger.MessageLogger_cfi")
process.MessageLogger.cerr.threshold = "WARNING"
process.MessageLogger.categories.append("ntupleBuilder")
process.MessageLogger.cerr.INFO = cms.untracked.PSet(
            limit=cms.untracked.int32(-1))
process.options = cms.untracked.PSet(wantSummary=cms.untracked.bool(True))

# Set the maximum number of events to be processed (-1 processes all events)
process.maxEvents = cms.untracked.PSet(input=cms.untracked.int32(10))

# Define files of dataset
#files = FileUtils.loadListFromFile("filelist.txt")
files = ["file:/home/wunsch/workspace/fastsim/CMSSW_9_2_10/src/miniAOD-prod_PAT.root"]
#files = ["file:/home/jbechtel/F2283B5C-6044-E811-B61D-0025905B859A.root"]

process.source = cms.Source(
            "PoolSource", fileNames=cms.untracked.vstring(*files))

# Set global tag
#process.GlobalTag.globaltag = "START53_V27::All"

# Number of events to be skipped (0 by default)
process.source.skipEvents = cms.untracked.uint32(0)

# Register fileservice for output file
process.ntupleBuilder = cms.EDAnalyzer("ntupleBuilder")
process.TFileService = cms.Service(
            "TFileService", fileName=cms.string("output.root"))

process.p = cms.Path(process.ntupleBuilder)
