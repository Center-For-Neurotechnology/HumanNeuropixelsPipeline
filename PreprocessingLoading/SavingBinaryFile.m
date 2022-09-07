%% Saves the data into a simple binary file to run the remaining pipeline 
% Just need to create a channel x sample matrix of the data under 'data'
MainDir='R:\Dropbox (Partners HealthCare)\MotionCorrectionWithNeuropixels\data\NeuropixelsHumanData\';
resaved_file = [MainDir,'Pt04\raw\Pt04.imec0.lf.bin'];
fid_target = fopen(resaved_file,'w');
fwrite(fid_target, data, 'int16' );
fclose(fid_target)
