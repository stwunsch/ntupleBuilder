// -*- C++ -*-
// //
// // Package:    ntupleBuilder
// // Class:      ntupleBuilder

#include <iostream>
#include <memory>

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

#include "DataFormats/PatCandidates/interface/Tau.h"

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

  // Event information
  tree->Branch("run", &v_run);
  tree->Branch("luminosityBlock", &v_lumi_block);
  tree->Branch("event", &v_event);
}

ntupleBuilder::~ntupleBuilder() {}

void ntupleBuilder::analyze(const edm::Event &iEvent,
                            const edm::EventSetup &iSetup) {

  // Event information
  v_run = iEvent.run();
  v_lumi_block = iEvent.luminosityBlock();
  v_event = iEvent.id().event();

  // Taus
  edm::Handle<pat::TauCollection> taus;
  iEvent.getByLabel(edm::InputTag("slimmedTaus"), taus);

  for (auto tau = taus->begin(); tau != taus->end(); tau++) {
  }

  /*
  // GenParticles
  edm::Handle<reco::GenParticleCollection> gens;
  iEvent.getByLabel(edm::InputTag("prunedGenParticles", "", "PAT"), gens);

  for (auto gen = gens->begin(); gen != gens->end(); gen++) {
  }
  */

  // Fill event
  tree->Fill();
}

void ntupleBuilder::beginJob() {}

void ntupleBuilder::endJob() {}

DEFINE_FWK_MODULE(ntupleBuilder);
