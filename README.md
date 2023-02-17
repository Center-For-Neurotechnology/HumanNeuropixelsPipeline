## HumanNeuropixelsPipeline
Pipeline and code for analyzing human Neuropixels data
The code included here is for use in processing human Neuropixels data which includes deidentification, saving into a common format along with meta-information, integrating depth and other information for re-saving the data. 

#### Data
Running the processing with this code can be done with the following data sets:
* Dryad- raw and processed data sets: https://datadryad.org/stash/dataset/doi:10.5061/dryad.d2547d840
* DANDI- raw and processed data sets in NWB format: https://dandiarchive.org/dandiset/000397
* Further detailed information is included in a spreadsheet (ExampleNeuropixelsRecordingInformation (csv or xlsx)) per recording

#### Code
The code included here includes a series of steps with the associated code: 
 1. re-save de-identified Neuropixels neural recording data (either SpikeGLX or OpenEphys) into an int16 binary file for later processing 
    * Code used: **/PreprocessingLoading/ExampleFileDeID.m**
    * Input file formats: SpikeGLX .bin files or OpenEphys .dat files with metadata files
    * Output file formats: XXXXXX.ap.bin and XXXXXX.lf.bin files (int16)
 2. re-save needed meta-information from the raw data
    * Code used: 
      - OpenEphys channel information extracted with **/PreprocessingLoading/ElectrodeLocationsImportSaveOpenEphys.py** using https://github.com/SpikeInterface/probeinterface/ followed by **/PreprocessingLoading/readingChannelPositionsOpenEphysJson.m** to read channel map information into Matlab
      - SpikeGLX channel information extracted with **/PreprocessingLoading/SGLXMetaToCoords.m**
    * Input file formats: SpikeGLX META files or OpenEphys metadata files
    * Output file formats: XXXXXX_ChannelMap.mat
 4. integrating depth and other information from a tabulated spreadsheet
    * Code used: none, manual entry, use **RelevantDataExamples/PlotingLFP.m code** to visualize the LFP voltage to identify the time ranges and channel ranges to use
    * Input file formats: none, manual entry
    * Output file formats: excel or .csv file including relevant information
 5. re-save the neural data to include only the contacts in the brain and time range with clean recordings for performing motion registration using DREDge
    * Code used: **/PreprocessingLoading/savingBinaryFilesorMotionRegistraton.m**
    * Input file formats: excel (or CSV) spreadsheet indicating experimental details, raw binary files, channel map (.mat) files
    * Output file formats: Binary file with modified channel map including only the time range and electrode range indicated
 6. perform the DREDge tracking through time to get the tracked motion
    * Code used: https://github.com/evarol/dredge 
    * Input file formats: All*.lf.bin (LFP files) and channel map (AllinBrain*_ChannelMap.mat) file including recording details
    * Output file formats: DepthMicronsTracking.csv tracked motion 
 7. perform the Interpolation of the data to correct for the motion 
    * Code used: Interpolation code (https://github.com/williamunoz/DREDge_Interpolation) 
      - Code to perform the interpolation and realigning using Kilosort 2.5 code: **DREDge_Interpolation/Scripts/Realignment/RealignWithDredge_Wrapper.m**
    * Input file formats: *.ap.bin files saved with only the time range of the motion tracked data, chanMap files, and the .csv DREDge motion tracking files
    * Output file formats: interpolated continuous .dat files adjusted for motion 


Dependencies include from the below code:

## Useful code (either used in this pipeline or optional code):

SpikeGLX import and processing code: https://billkarsh.github.io/SpikeGLX/#post-processing-tools

Probe Interface (used for getting the channel map from the OpenEphys files): 
* https://probeinterface.readthedocs.io/en/main/installation
* https://github.com/SpikeInterface/probeinterface/
 
readNPY and readNPYHeader from npy-matlab package from kwik-team: https://github.com/kwikteam/npy-matlab

Open Ephys loading code: load_open_ephys_binary: https://github.com/open-ephys/analysis-tools

## Motion Registration and Interpolation code

DREDge (Decentralized Registration of Electrophysiology Data) Motion registration code (python version used in this processing):
https://github.com/evarol/dredge

Interpolation code- One optional approach for interpolating the code following DREDge motion tracking:
https://github.com/williamunoz/DREDge_Interpolation

Alternately, motion correction software in SpikeInterface (https://github.com/SpikeInterface/spikeinterface ), specifically the Motion correction function (https://spikeinterface.readthedocs.io/en/latest/api.html#module-spikeinterface.sortingcomponents.motion_correction ) 

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

