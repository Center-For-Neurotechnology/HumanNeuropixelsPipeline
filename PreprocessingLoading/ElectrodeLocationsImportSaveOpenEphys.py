

## Dependency: need the https://probeinterface.readthedocs.io/en/main/ installation
## Also here: https://github.com/SpikeInterface/probeinterface/blob/main/doc/index.rst
## Also here on our server: W:\DeidentifiedNeuropixelsData\probeinterface-main

%matplotlib inline

import numpy as np
import csv
import pandas as pd

from probeinterface.io import read_openephys
from probeinterface.io import write_csv
from probeinterface.io import write_BIDS_probe
from probeinterface.io import write_probeinterface


probe=read_openephys('Y:/IntraOp_Micro/NeuropixelDBS12/NeuropixelsPhaseTestREC_10-59-10OE_Ver6/Record Node 106/settings.xml')
print(probe)

write_probeinterface('W:/DeidentifiedNeuropixelsData/Pt09/Pt09positions.json', probe)
