// -*- C++ -*-
// //
// // Package:    ntupleBuilder
// // Class:      ntupleBuilder

#include <memory>
#include <iostream>

#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/Frameworkfwd.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "CommonTools/UtilAlgos/interface/TFileService.h"
#include "DataFormats/Common/interface/Ref.h"
#include "FWCore/Framework/interface/ESHandle.h"
#include "FWCore/Framework/interface/EventSetup.h"
#include "FWCore/MessageLogger/interface/MessageLogger.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "math.h"

#include "TFile.h"
#include "TTree.h"

class ntupleBuilder : public edm::EDAnalyzer {
public:
  explicit ntupleBuilder(const edm::ParameterSet &);
  ~ntupleBuilder();

private:
  virtual void beginJob();
  virtual void analyze(const edm::Event &, const edm::EventSetup &);
  virtual void endJob();
  bool providesGoodLumisection(const edm::Event &iEvent);
  bool isData;

  TTree *tree;

  // Event information
  Int_t v_run;
  UInt_t v_lumi_block;
  ULong64_t v_event;
};

ntupleBuilder::ntupleBuilder(const edm::ParameterSet &iConfig) {
  edm::Service<TFileService> fs;

  tree = fs->make<TTree>("Events", "Events");
}

ntupleBuilder::~ntupleBuilder() {}

void ntupleBuilder::analyze(const edm::Event &iEvent,
                             const edm::EventSetup &iSetup) {

  // Event information
  v_run = iEvent.run();
  v_lumi_block = iEvent.luminosityBlock();
  v_event = iEvent.id().event();
  std::cout << v_run << ", " << v_lumi_block << std::endl;

  // Fill event
  tree->Fill();
}

void ntupleBuilder::beginJob() {}

void ntupleBuilder::endJob() {}

DEFINE_FWK_MODULE(ntupleBuilder);
