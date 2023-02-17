%% Example loading of files from OpenEphys
%This function requires the functions readNPY and readNPYHeader
%from npy-matlab package from kwik-team
%(https://github.com/kwikteam/npy-matlab)

% and load_open_ephys_binary
% from: (https://github.com/open-ephys/analysis-tools)
clear all
restoredefaultpath
addpath(genpath('Y:\IntraOp_Micro\CodeNeuropixels\SpikeCode')) % for the Numpy file read
addpath(genpath('Y:\IntraOp_Micro\CodeNeuropixels\HumanNeuropixelsPipeline-main')) % for the Numpy file read

Ta=readtable(['W:\DeidentifiedNeuropixelsData\DatabasesSpreadsheets\ExampleNeuropixelsRecordingInformation.xlsx']);
PtDesig=table2cell(Ta(:,4));
RecordingSystem=table2cell(Ta(:,16));
DirectoriesAPLF=table2cell(Ta(:,19));
DirectoriesDAQ=table2cell(Ta(:,20));
resave=1;
for Fi=35
    if isempty(PtDesig{Fi})==0
        %         pause

        mkdir(['E:\',PtDesig{Fi},'\'])
        SaveDirectory=['E:\',PtDesig{Fi},'\'];
        %% OpenEphys loading:
        if contains(RecordingSystem{Fi},'OpenEphys')==1

            jsonFile=[DirectoriesAPLF{Fi},'\structure.oebin'];
            jsonFileDAQ=[DirectoriesDAQ{Fi},'\structure.oebin'];

            DAP=load_open_ephys_binary(jsonFile,'continuous',1,'mmap'); %choose 2 for LFP or 1 for AP

            DLFP=load_open_ephys_binary(jsonFile,'continuous',2,'mmap'); %choose 2 for LFP or 1 for AP

            DAQ=load_open_ephys_binary(jsonFileDAQ,'continuous',1,'mmap'); %1 for high frequency sampling
             
            if resave==1
                %% Saving the LFP (OpenEphys):
                dataLFP=DLFP.Data.Data(1).mapped;
                fs=DLFP.Header.sample_rate;
            % Uncomment if you want to save a .mat version of the LFP data
%                 save([SaveDirectory,'ExtractedLFPData'],'dataLFP','fs')

                HeaderInfoDLFP=DLFP.Header;

                %% Saving the AP band:
                dataAP=DAP.Data.Data(1).mapped;
                fs=DAP.Header.sample_rate;
            % Uncomment if you want to save a .mat version of the AP data
%                  save([SaveDirectory,'ExtractedAPData'],'dataAP','fs')

                HeaderInfoDAP=DAP.Header;

                save([SaveDirectory,'HeaderInfoLFPAP'],'HeaderInfoDLFP','HeaderInfoDAP')

                %% Saving the DAQ:
                dataDAQ=DAQ.Data.Data(1).mapped;
                fs=DAQ.Header.sample_rate;
                 % Uncomment if you want to save a .mat version of the
                 % trigger information
%                 save([SaveDirectory,'ExtractedDAQData'],'dataDAQ','fs')

                HeaderInfoDAQ=DAQ.Header;
            end
        elseif contains(RecordingSystem{Fi},'SpikeGLX')==1
            %% SpikeGLX or OpenEphys loading (simple binary read):

            MainDir=DirectoriesAPLF{Fi};
            target_fileAP = [MainDir,'.ap.bin']; %AP, can replace this with .dat from OpenEphys
            fid_source = fopen(target_fileAP,'r');
            dataAP = fread (fid_source,[385,Inf],'int16'); %This is a matrix of channel x time, AP
            fclose(fid_source)

            target_fileLFP = [MainDir,'.lf.bin']; %LFP, can replace this with .dat from OpenEphys
            fid_source = fopen(target_fileLFP,'r');
            dataLFP = fread (fid_source,[385,Inf],'int16'); %This is a matrix of channel x time, LFP
            fclose(fid_source)

            % Uncomment if you want to save a .mat version of the data
            %             fs=30000;
            %             save([SaveDirectory,'ExtractedAPData'],'dataAP','fs')
            %             fs=2500;
            %             save([SaveDirectory,'ExtractedAPData'],'dataLFP','fs')
        end

        if resave==1
            %% Saves the data into a simple binary file to run the remaining pipeline
            % Just need to create a channel x sample matrix of the data under 'data'

            resaved_file = [SaveDirectory,'raw',PtDesig{Fi},'.imec0.lf.bin'];
            fid_target = fopen(resaved_file,'w');
            fwrite(fid_target, dataLFP, 'int16' );
            fclose(fid_target)

            resaved_file = [SaveDirectory,'raw',PtDesig{Fi},'.imec0.ap.bin'];
            fid_target = fopen(resaved_file,'w');
            fwrite(fid_target, dataAP, 'int16' );
            fclose(fid_target)

            resaved_file = [SaveDirectory,'raw',PtDesig{Fi},'.imec0.nidaq.bin'];
            fid_target = fopen(resaved_file,'w');
            fwrite(fid_target, dataDAQ, 'int16' );
            fclose(fid_target)
        end
        clear dataAP dataLFP dataDAQ
    end
end


