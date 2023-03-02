%% Code for reading 

clf
clear

Information=readtable(['E:\ExampleNeuropixelsRecordingInformation.xlsx']);
PtDesig=table2array(Information(:,1));
ChannelsSaved=table2array(Information(:,16));
DepthTop=table2array(Information(:,17));
StartTime=table2array(Information(:,12));
EndTime=table2array(Information(:,13));

for ns=1:4


         FileNA=FileNA1{ns};
        Directory=['E:\DataForNatProtocol\',FileNA1{ns},'\'];
        load(['E:\DataForNatProtocol\',FileNA1{ns},'\',FileNA1{ns},'_ChannelMap.mat'],'xcoords','ycoords')
      

    for wi=1:length(PtDesig)
        if isempty(PtDesig{wi})==0
            if contains(FileNA,PtDesig{wi})==1
                ChanTot=ChannelsSaved(wi);
                DepthTopPer=DepthTop(wi);
                TimeRange1=StartTime(wi);
                TimeRange2=EndTime(wi);
                pt3=PtDesig(wi)
                %             pause
            end
        end
    end
    xcoordsBase=xcoords;
    ycoordsBase=ycoords;
    LFPBinary=dir([Directory,'*lf.bin']);

    SaveDirectory=[Directory,'DREDgeFiles\'];
    mkdir([SaveDirectory])

    copyfile([Directory,'\',LFPBinary(1).name],[SaveDirectory,LFPBinary(1).name])

    target_fileLFP = [Directory,'\',LFPBinary(1).name]; %LFP, can replace this with .dat from OpenEphys
    fid_source = fopen(target_fileLFP,'r');
    dataLFP = fread (fid_source,[ChanTot,Inf],'int16'); %This is a matrix of channel x time, LFP
    fclose(fid_source)

        SaveDirectory=[Directory,'\'];
        %     mkdir([SaveDirectory])

        %     copyfile([Directory,'\',LFPBinary(1).name],[SaveDirectory,LFPBinary(1).name])

        target_fileLFP = [Directory,'\',LFPBinary(1).name]; %LFP, can replace this with .dat from OpenEphys
        fid_source = fopen(target_fileLFP,'r');
        dataLFP = fread (fid_source,[ChanTot,Inf],'int16'); %This is a matrix of channel x time, LFP
        fclose(fid_source)
        dataLFPPer=[];
        dataLFPPer=dataLFP(ycoordsBase<=DepthTopPer,:);
        xcoords=xcoordsBase(ycoordsBase<=DepthTopPer);
        ycoords=ycoordsBase(ycoordsBase<=DepthTopPer);
        ChannelsChosen=find(ycoordsBase<=DepthTopPer);
        
        NumberOfChannels=length(ChannelsChosen);
        resaved_file = [SaveDirectory,'AllinBrain','_',FileNA,'.imec0.lf.bin'];
        fid_target = fopen(resaved_file,'w');
        fwrite(fid_target, dataLFPPer, 'int16' );
        fclose(fid_target)
        save([SaveDirectory,'AllinBrain_',FileNA,'_ChannelMap.mat'],'xcoords','ycoords',...
            'ChannelsChosen','NumberOfChannels',...
            'TimeRange1','TimeRange2','FileNA')

        save([SaveDirectory,'All_',FileNA,'_ChannelMap.mat'],'xcoords','ycoords',...
            'ChannelsChosen','NumberOfChannels',...
            'TimeRange1','TimeRange2','FileNA','ChanTot')

        clear xcoords ycoords dataLFP dataLFPPer xcoordsbase ycoordsbase
        

% Uncomment to plot the data
    %     scatter(xcoords,...
    %         ycoords,48,"black",'marker','s')
    %     hold on
    % %     text(xcoords,...
    % %         ycoords,...
    % %         num2str((1:length(xcoords))'))
    %     xcoords=xcoords';
    %     ycoords=ycoords';
    %     title(FileNA{ns})
    %     ylim([0 8000])
    %     set(gca,'fontsize',12)
    %     if ns==1
    %     ylabel('depth (microns), with 0 the deepest contact')
    %     end
%     pause
end

