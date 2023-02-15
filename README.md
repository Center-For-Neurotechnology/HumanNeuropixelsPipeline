## HumanNeuropixelsPipeline
Pipeline and code for analyzing human Neuropixels data
The code included here is for use in processing human Neuropixels data which includes deidentification, saving into a common format along with meta-information, integrating depth and other information for re-saving the data. 

The code included here includes a series of steps with the associated code: 
 1. re-save de-identified Neuropixels neural recording data (either SpikeGLX or OpenEphys) into an int16 binary file for later processing
   
 2. re-save needed meta-information from the raw data
 3. integrating depth and other information from a tabulated spreadsheet
 4. re-save the neural data to include only the contacts in the brain and time range with clean recordings for performing motion registration using DREDge
 5. perform the DREDge tracking through time to get the tracked motion
 6. perform the Interpolation of the data to correct for the motion 


Dependencies include from the below code:

## Useful code (either used in this pipeline or optional code):

SpikeGLX import and processing code: https://billkarsh.github.io/SpikeGLX/#post-processing-tools

Probe Interface (used for getting the channel map from the OpenEphys files): 
* https://probeinterface.readthedocs.io/en/main/installation
* https://github.com/SpikeInterface/probeinterface/
 
readNPY and readNPYHeader from npy-matlab package from kwik-team: https://github.com/kwikteam/npy-matlab

Open Ephys loading code: load_open_ephys_binary: https://github.com/open-ephys/analysis-tools

## For overall neural data analysis and anatomical processing:
MATLAB: https://www.mathworks.com/products/matlab.html

Freesurfer: https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall

Fieldtrip: https://www.fieldtriptoolbox.org/ 

MMVT-lite: https://github.com/pelednoam/mmvt_lite

## For de-identification:
Fieldtrip: https://www.fieldtriptoolbox.org/ 

## For standardizing the data in iEEG BIDS format: 
BIDS starter kit WIKI: https://bids-standard.github.io/bids-starter-kit/

BIDS starter kit GitHub: https://github.com/bids-standard/bids-starter-kit 

