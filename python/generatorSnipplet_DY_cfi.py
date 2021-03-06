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
            'WeakSingleBoson:all = off',
            'WeakSingleBoson:ffbar2gmZ = on',
            'WeakZ0:gmZmode = 2',
            '23:onMode = off',
            '23:onIfMatch = 15 -15',
            '23:m0 = MASS',
            '23:mMin = MASS_MIN',
            '23:mMax = MASS_MAX',
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

