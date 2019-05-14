import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.Pythia8CUEP8M1Settings_cfi import *



generator = cms.EDFilter("Pythia8GeneratorFilter",
                         comEnergy = cms.double(13000.0),
                         crossSection = cms.untracked.double(6.44),
                         filterEfficiency = cms.untracked.double(1),
                         maxEventsToPrint = cms.untracked.int32(1),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         pythiaPylistVerbosity = cms.untracked.int32(1),
                         PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CUEP8M1SettingsBlock,
        processParameters = cms.vstring(
            'HiggsSM:all = off',
            'HiggsSM:ffbar2H = on',
            '25:onMode = off',
            '25:onIfMatch = 15 -15',
            '25:m0 = MASS',
            '25:mMin = MASS_MIN',
            '25:mMax = MASS_MAX',
            #'PhaseSpace:mHatMin = MASS_MIN',
            #'PhaseSpace:mHatMax = MASS_MAX',
            '15:onMode = off',
            '15:onIfAny = 111 211',
            ),
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CUEP8M1Settings',
                                    'processParameters',
                                    )
        )
                         )

ProductionFilterSequence = cms.Sequence(generator)

