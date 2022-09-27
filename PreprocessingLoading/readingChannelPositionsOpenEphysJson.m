clf
clear
FileNA={'Pt04','Pt05','Pt06','Pt07','Pt08','Pt09'}

for ns=2:length(FileNA)
    fname = ['W:\DeidentifiedNeuropixelsData\',FileNA{ns},'\',FileNA{ns},'positions.json'];
    fid = fopen(fname);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    val = jsondecode(str);

    xcoords1=val.probes.contact_positions(:,1);
    ycoords1=val.probes.contact_positions(:,2);

    if length(xcoords1)==383 && contains(fname,'Pt06')==0 &&...
            contains(fname,'Pt07')==0
        xcoords=[xcoords1(1:191);43;xcoords1(192:383)];
        ycoords=[ycoords1(1:191);1900;ycoords1(192:383)];
    elseif length(xcoords1)==383 && contains(fname,'Pt06')==1
        xcoords=[xcoords1(1:191);43;xcoords1(192:383)];
        ycoords=[ycoords1(1:191);5740;ycoords1(192:383)];
    elseif length(xcoords1)==383 && contains(fname,'Pt07')==1
        xcoords=[xcoords1(1:191);43;xcoords1(192:383)];
        ycoords=[ycoords1(1:191);5740;ycoords1(192:383)];
    else
        xcoords=[xcoords1];
        ycoords=[ycoords1];
    end

    plot(xcoords,...
        ycoords,'.')
    hold on
    text(xcoords,...
        ycoords,...
        num2str((1:length(xcoords))'))
    xcoords=xcoords';
    ycoords=ycoords';
    save(['W:\DeidentifiedNeuropixelsData\',FileNA{ns},'\',FileNA{ns},'_ChannelMap.mat'],'xcoords','ycoords')
    save(['E:\',FileNA{ns},'\',FileNA{ns},'_ChannelMap.mat'],'xcoords','ycoords')
end

