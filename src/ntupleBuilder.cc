// -*- C++ -*-
// //
// // Package:    ntupleBuilder
// // Class:      ntupleBuilder

#include <iostream>
#include <memory>

#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/PatCandidates/interface/PackedGenParticle.h"
#include "DataFormats/Candidate/interface/Candidate.h"
#include "DataFormats/HepMCCandidate/interface/GenParticle.h"

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

  // Tokens
  edm::EDGetTokenT<pat::TauCollection> t_taus;
};

ntupleBuilder::ntupleBuilder(const edm::ParameterSet &iConfig) {
  edm::Service<TFileService> fs;

  tree = fs->make<TTree>("Events", "Events");

  // Event information
  tree->Branch("run", &v_run);
  tree->Branch("luminosityBlock", &v_lumi_block);
  tree->Branch("event", &v_event);

  // Consumers
  t_taus = consumes<pat::TauCollection>(edm::InputTag("slimmedTaus", "", "PAT"));
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
  iEvent.getByToken(t_taus, taus);

  for (auto tau = taus->begin(); tau != taus->end(); tau++) {
      std::cout << tau->pt() << std::endl;
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
