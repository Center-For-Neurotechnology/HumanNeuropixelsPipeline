%% Saves the data into a simple binary file to run the remaining pipeline 
% Just need to create a channel x sample matrix of the data under 'data'
MainDir='E:\DataForNatProtocol\';
resaved_file = [MainDir,'Pt01\rawPt01.imec0.lf.bin'];
fid_target = fopen(resaved_file,'w');
fwrite(fid_target, data, 'int16' );
fclose(fid_target)
