%% Code to quickly plot the data to identify what channels are outside the brain versus inside
% and to identify time ranges for further processing and motion tracking. 


Pt=01;

MainDir=['E:\DataForNatProtocol\Pt' num2str(Pt) '\'];
target_fileLFP = [MainDir,'rawPt' num2str(Pt) '.imec0.lf.bin']; %LFP, can replace this with .dat from OpenEphys
fid_source = fopen(target_fileLFP,'r');
dataLFP = fread (fid_source,[385,Inf],'int16'); %This is a matrix of channel x time, LFP
load([MainDir '\Pt' num2str(Pt) '_ChannelMap.mat'])
 
%% Example code to plot the LFP data to identify the recording in the brain
TIME=(1:size(dataLFP,2))/2500;
Cha=1:4:384;
clf
imagesc(TIME, ...
    ycoords(Cha),...
    dataLFP(Cha,:))
% xlim([540 550]) % uncomment to select a timing range
caxis([-250 250])
xlabel('time (sec)')
ylabel('depth')
axis xy
%% Per step time points
clf
for ti=330:10:960
imagesc((1:size(dataLFP,2))/2500, ...
    ycoords(Cha),...
    dataLFP(Cha,:))
xlim([ti ti+10])
caxis([-250 250])
axis xy
pause
clf
end
