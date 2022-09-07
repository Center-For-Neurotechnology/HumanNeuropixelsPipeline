

%% Interpolation step with normalization between channels
% MEreg=nanmean(resampLFP(1:383,5*10^5:7*10^5),2);
% MEstd=nanstd(resampLFP(1:383,5*10^5:7*10^5),[],2);
MEreg=nanmean(resampLFP(1:383,2*10^5:3*10^5),2);
MEstd=nanstd(resampLFP(1:383,2*10^5:3*10^5),[],2);
clf
for TIMRG=1:50000:size(resampLFP,2)
     TiRange=TIMRG:1:TIMRG+50000-1;
    InterpLFPChunk=NaN*ones(1911,25,size(TiRange,2));
    
    for ti=TiRange
        ti
        [xq,yq] = meshgrid(11:2:59, 20:2:3840);
        vq = griddata(xloc,yloc, (resampLFP(1:383,ti)-MEreg)./MEstd,xq,yq); %Interpolation 
        InterpLFPChunk(:,:,ti-TiRange(1)+1)=vq;
    end
%             save([Direc,'\InterpLFPLoc\NormInterpLFPLoc',num2str(TIMRG)],'InterpLFPChunk','TiRange','FSnew','Chanmap','xloc','yloc')
pause
end

%% Taking a motion track and moving through the interpolated data to create virtual channels
Add=ceil(range(scl2*BlenderCurveY));
% Add=ceil(range(16*BlenderCurveY));
resetInterp1=NaN*ones(1911+Add+Add,25,23000);
resetInterp2=NaN*ones(1911+Add+Add,25,23000);
for HHN=1:length(TiRange)/1
%    TI= find(TimeAdjust>TiRange(HHN)/1000-.0001 & TimeAdjust<TiRange(HHN)/1000+.0001);
%    if isempty(TI)==0
%    TI= find(TimeAdjust>TiRange(HHN)/1000-.0005 & TimeAdjust<TiRange(HHN)/1000+.0005);
       TI = dsearchn(TimeAdjust,TiRange(HHN)/1000);
%    end
    resetInterp1(floor(Add+(1:1911)-scl1*BlenderCurveY(TI(1))),:,HHN)=...
        InterpLFPChunk(floor((1:1911)+0*BlenderCurveY(TI(1))),:,HHN);
    
        resetInterp2(floor(Add+(1:1911)-scl2*BlenderCurveY(TI(1))),:,HHN)=...
        InterpLFPChunk(floor((1:1911)+0*BlenderCurveY(TI(1))),:,HHN);
    HHN
end
