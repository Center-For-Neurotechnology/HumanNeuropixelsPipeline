clf
clear
FileNA1={'Pt01','Pt02','Pt03','Pt04','Pt05','Pt06','Pt07','Pt08','Pt09'}
FileNA2={'NP03_B02_g0_t0',...
    'NP04_B2_g0_t0',...
    'NP10_B2_g0_t0',...
    'NP10_B3_g0_t0',...
    'NP10_B4_g0_t0',...
    'NP11_B4_g0_t0',...
    'NP13_B2_g0_t0',...
    'NP14_B2_g0_t0',...
    'NP14_B3_g0_t0',...
    'NP15_B2_g0_t0'};

Information=readtable(['W:\DeidentifiedNeuropixelsData\DatabasesSpreadsheets\NeuropixelsRecordingInfoAll.xlsx']);
PtDesig=table2array(Information(:,4));
ChannelsSaved=table2array(Information(:,15));
DepthTop=table2array(Information(:,16));
StartTime=table2array(Information(:,11));
EndTime=table2array(Information(:,12));

for ns=10:19
% for ns=1:1

    % subplot(1,10,ns)
    if ns<10
         FileNA=FileNA1{ns};
        Directory=['W:\DeidentifiedNeuropixelsData\',FileNA1{ns},'\'];
        load(['W:\DeidentifiedNeuropixelsData\',FileNA1{ns},'\',FileNA1{ns},'_ChannelMap.mat'],'xcoords','ycoords')
       
    else
         FileNA=FileNA2{ns-9};
        Directory=['W:\DeidentifiedNeuropixelsData\Chang_data\',FileNA2{ns-9},'\'];
        load(['W:\DeidentifiedNeuropixelsData\Chang_data\',FileNA2{ns-9},'\',FileNA(1:end-6),'_ChannelMap.mat'],'xcoords','ycoords')
    end

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

    PerColumn=unique(xcoordsBase);
    for column=1:4
        dataLFPPer=dataLFP(xcoordsBase==PerColumn(column),:);
        resaved_file = [SaveDirectory,'Column',num2str(column),'_',FileNA,'.imec0.lf.bin'];
        fid_target = fopen(resaved_file,'w');
        fwrite(fid_target, dataLFPPer, 'int16' );
        fclose(fid_target)
        xcoords=xcoordsBase(xcoordsBase==PerColumn(column));
        ycoords=ycoordsBase(xcoordsBase==PerColumn(column));
        ChannelsChosen=find(xcoordsBase==PerColumn(column));
        NumberOfChannels=length(ChannelsChosen);
        save([SaveDirectory,'Column',num2str(column),'_',FileNA,'_ChannelMap.mat'],'xcoords','ycoords',...
            'ChannelsChosen','NumberOfChannels',...
            'TimeRange1','TimeRange2','FileNA')
        column
    end

    for DepthRange=1:2
        if DepthRange==1
            dataLFPPer=dataLFP(ycoordsBase<DepthTopPer/2,:);
            xcoords=xcoordsBase(ycoordsBase<DepthTopPer/2);
            ycoords=ycoordsBase(ycoordsBase<DepthTopPer/2);
            ChannelsChosen=find(ycoordsBase<DepthTopPer/2);
            NumberOfChannels=length(ChannelsChosen);
        elseif DepthRange==2
            dataLFPPer=dataLFP(ycoordsBase>=DepthTopPer/2,:);
            xcoords=xcoordsBase(ycoordsBase>=DepthTopPer/2);
            ycoords=ycoordsBase(ycoordsBase>=DepthTopPer/2);
            ChannelsChosen=find(ycoordsBase>=DepthTopPer/2);
            NumberOfChannels=length(ChannelsChosen);
        end
        resaved_file = [SaveDirectory,'DepthRange',num2str(DepthRange),'_',FileNA,'.imec0.lf.bin'];
        fid_target = fopen(resaved_file,'w');
        fwrite(fid_target, dataLFPPer, 'int16' );
        fclose(fid_target)

        save([SaveDirectory,'DepthRange',num2str(DepthRange),'_',FileNA,'_ChannelMap.mat'],'xcoords','ycoords',...
            'ChannelsChosen',...
            'NumberOfChannels',...
            'TimeRange1','TimeRange2','FileNA')
        DepthRange
    end

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

