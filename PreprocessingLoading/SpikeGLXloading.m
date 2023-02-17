%% SpikeGLX loading (using the Matlab package: DemoReadSGLXDataBkgrndRun ):

MainDir='E:\DataForNatProtocol\Pt02\';

FileLoad= dir([MainDir,'\*','Pt02.imec0.ap.bin*']);  %AP
binName=FileLoad(1).name;
DemoReadSGLXDataBkgrndRun

FileLoad= dir([MainDir,'\*','Pt02.imec0.lf.bin*']);  %LFP
binName=FileLoad(1).name;
DemoReadSGLXDataBkgrndRun
