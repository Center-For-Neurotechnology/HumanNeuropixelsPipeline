%% SpikeGLX or OpenEphys loading (simple binary read):

MainDir='E:\DataForNatProtocol\';
target_fileAP = [MainDir,'Pt01\raw\Pt01.imec0.ap.bin']; %AP, can replace this with .dat from OpenEphys
fid_source = fopen(target_file,'r');
dataAP = fread (fid_source,[385,Inf],'int16'); %This is a matrix of channel x time, AP 
fclose(fid_source)

target_fileLFP = [MainDir,'Pt01\raw\Pt01.imec0.lf.bin']; %LFP, can replace this with .dat from OpenEphys
fid_source = fopen(target_file,'r');
dataLFP = fread (fid_source,[385,Inf],'int16'); %This is a matrix of channel x time, LFP 
fclose(fid_source)
