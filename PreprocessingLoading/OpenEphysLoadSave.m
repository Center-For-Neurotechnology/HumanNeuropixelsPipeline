%% Example loading of files from OpenEphys 
%This function requires the functions readNPY and readNPYHeader 
%from npy-matlab package from kwik-team
%(https://github.com/kwikteam/npy-matlab)

% and load_open_ephys_binary
% from: (https://github.com/open-ephys/analysis-tools)

%% OpenEphys loading:
jsonFile='E:\DataForNatProtocol\Record Node 106\experiment1\recording1\structure.oebin';
addpath(genpath('E:\DataForNatProtocol\HumanNeuropixelsPipeline-main')) % for the Numpy file read

DAP=load_open_ephys_binary(jsonFile,'continuous',1,'mmap'); %choose 2 for LFP or 1 for AP

DLFP=load_open_ephys_binary(jsonFile,'continuous',2,'mmap'); %choose 2 for LFP or 1 for AP

% save([SaveDirectory,'ExtractedAPData'],'D') %saving the raw data

%% Saving the LFP (OpenEphys):

dataLFP=DLFP.Data.Data(1).mapped;
fs=2500;
save([SaveDirectory,'ExtractedLFPData'],'LFP','fs')
%% Saving the AP band:
dataAP=DAP.Data.Data(1).mapped;
fs=30000;
save([SaveDirectory,'ExtractedAPData'],'APMatrix','fs')
