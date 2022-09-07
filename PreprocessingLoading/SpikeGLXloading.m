%% SpikeGLX loading (using the Matlab package: DemoReadSGLXDataBkgrndRun ):

MainDir='R:\Dropbox (Partners HealthCare)\MotionCorrectionWithNeuropixels\data\NeuropixelsHumanData\';

FileLoad= dir([MainDir,'\*','Pt02.imec0.ap.bin*']);  %AP
binName=FileLoad(1).name;
DemoReadSGLXDataBkgrndRun

FileLoad= dir([MainDir,'\*','Pt02.imec0.lf.bin*']);  %LFP
binName=FileLoad(1).name;
DemoReadSGLXDataBkgrndRun
