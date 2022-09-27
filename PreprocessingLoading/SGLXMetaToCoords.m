%
% Write out coordinates for a Neuropixels 3A, 1.0 or 2.0 metadata file.
%
% Format selected with the outType variable
%     0 for tab delimited text coordinate file:
%       chan index, x in um, y in um, shank index
%     1 for Kilosort or Kilosort2 channel map file;
%     2 for strings to paste into JRClust .prm file
%
% File is saved in current working directory
%
% Jennifer Colonell, Janelia Research Campus
%
% function SGLXMetaToCoords()


% Output selection:
outType = 1;

% Ask user for metadata file
% [metaName,path] = uigetfile('*.meta', 'Select Metadata File');

% Shank separation for multishank
shankSep = 250;

% Parse in file to get the metadata structure
% meta = ReadMeta(metaName, path);

if isfield(meta, 'imDatPrb_type')
    pType = str2num(meta.imDatPrb_type);
else
    pType = 0; % 3A probe
end

if pType <= 1 || pType == 1100 || pType == 1300  % type 1100 = UHD probe with one bank, 1300 = OPTO

    % Neuropixels 1.0 or 3A probe
    [elecInd, connected] = NP10_ElecInd(meta);

    % Get saved channels
    chans = OriginalChans(meta);
    [AP,LF,SY] = ChannelCountsIM(meta);
    chans = chans(1:AP);        % 1-based channel numbers

    % Trim elecInd and shankInd to include only saved channels
    elecInd = elecInd(chans);
    shankind = zeros(size(elecInd));

    % Get XY coords for saved channels
    if pType == 0
        [xcoords, ycoords] = XYCoord10(meta, elecInd);
    elseif pType == 1100
        [xcoords, ycoords] = XYCoord1100(meta, elecInd);
    elseif pType == 1300
        [xcoords, ycoords] = XYCoord1300(meta, elecInd);
    end

else

    % Parse imro table for shank and electrode indicies
    [elecInd, shankind, bankMask, connected] = NP20_ElecInd(meta);

    % Get saved channels
    chans = OriginalChans(meta);
    [AP,LF,SY] = ChannelCountsIM(meta);
    chans = chans(1:AP);        % 1-based channel numbers

    % Trim elecInd and shankInd to include only saved channels
    elecInd = elecInd(chans);
    shankind = shankind(chans);

    % Get XY coords for saved channels
    [xcoords, ycoords] = XYCoord20(meta, elecInd, bankMask, shankind);

end

% Build output name and write out file
% [~,fname,~] = fileparts(metaName);
fname=binName;

switch outType
    case 0      % tab delimited, chan, x, y, shank
        newName = [fname,'-siteCoords.txt'];
        fid = fopen( newName, 'w');
        for i = 1:numel(elecInd)
            currX = shankind(i)*shankSep + xcoords(i);
            fprintf( fid, '%d\t%d\t%d\t%d\n', chans(i)-1, currX, ycoords(i), shankind(i));
        end
        fclose(fid);

    case 1     % KS2 *.mat
        newName = [fname,'_kilosortChanMap.mat'];
        chanMap = (1:numel(chans))';
        chanMap0ind = chanMap - 1;
        connected = logical(connected);
        xcoords = shankind*shankSep + xcoords;   % KS2 not yet using kcoords, so x coord includes shank sep
        kcoords = shankind + 1;     % KS1 uses kcoords to force templates to be on one shank
        name = fname;
        save( newName, 'chanMap', 'chanMap0ind', 'connected', 'name', 'xcoords', 'ycoords', 'kcoords' );

    case 2  % strings to copy into JRC prm file
       newName = [fname,'_forJRCprm.txt'];
       nchan = numel(chans);
       fid = fopen( newName, 'w' );
       fprintf( fid, 'shankMap = [' );
       for i = 1:nchan-1
           fprintf( fid, '%d,', shankind(i) + 1 ); % switch to 1-based for MATLAB
       end
       fprintf( fid, '%d];\n',shankind(nchan) + 1 );

       xcoords = shankind*shankSep + xcoords;

       fprintf( fid, 'siteLoc = [' );
       for i = 1:nchan-1
           fprintf(fid, '%d,%d;', xcoords(i), ycoords(i));
       end
       fprintf( fid, '%d,%d];\n', xcoords(nchan), ycoords(nchan) );

       fprintf( fid, 'siteMap = [' );
       for i = 1:nchan-1
           fprintf( fid, '%d,', chans(i) );
       end
       fprintf( fid, '%d];\n', chans(nchan) );
       fclose(fid);
end

% end


function [meta] = ReadMeta(metaName, path)

    % Parse ini file into cell entries C{1}{i} = C{2}{i}
    fid = fopen(fullfile(path, metaName), 'r');
% -------------------------------------------------------------
%    Need 'BufSize' adjustment for MATLAB earlier than 2014
%    C = textscan(fid, '%[^=] = %[^\r\n]', 'BufSize', 32768);
    C = textscan(fid, '%[^=] = %[^\r\n]');
% -------------------------------------------------------------
    fclose(fid);

    % New empty struct
    meta = struct();

    % Convert each cell entry into a struct entry
    for i = 1:length(C{1})
        tag = C{1}{i};
        if tag(1) == '~'
            % remake tag excluding first character
            tag = sprintf('%s', tag(2:end));
        end
        meta = setfield(meta, tag, C{2}{i});
    end
end % ReadMeta


% =========================================================
% Return shank and electrode number for NP2.0.
%
% Index into these with original (acquired) channel IDs.
%
function [elecInd, shankInd, bankMask, connected] = NP20_ElecInd(meta)
    pType = str2num(meta.imDatPrb_type);
    if pType == 21
        % Single shank probe
        % imro table entries: (channel, bank, refType, electrode #)
        C = textscan(meta.imroTbl, '(%d %d %*s %d', ...
            'EndOfLine', ')', 'HeaderLines', 1 );
        chan = double(cell2mat(C(1)));
        elecInd = int32(cell2mat(C(3)));
        bankMask = int32(cell2mat(C(2)));
        shankInd = zeros(size(elecInd));

    else
        % 4 shank probe
        % imro table entries: (channel, shank, bank, refType, electrode #)
        C = textscan(meta.imroTbl, '(%d %d %d %*s %d', ...
            'EndOfLine', ')', 'HeaderLines', 1 );
        chan = double(cell2mat(C(1)));
        elecInd = int32(cell2mat(C(4)));
        bankMask = int32(cell2mat(C(3)));
        shankInd = double(cell2mat(C(2)));

    end
    connected = findDisabled(meta);

end % NP20_ElecInd


% =========================================================
% Return shank and electrode number for NP1.0.
%
% Index into these with original (acquired) channel IDs.
%
function [elecInd, connected] = NP10_ElecInd(meta)

    % 3A or 3B data?
    % 3A metadata has field "typeEnabled" which was replaced
    % with "typeImEnabled" and "typeNiEnabled" in 3B.
    % The 3B imro table has an additional field for the
    % high pass filter enabled/disabled
    % Note that the textscan funtion places line breaks at each
    % instance of the 'EndofLine' character -- here, ')'
    % 'HeaderLines' = 1 skips the initial entry in the table with
    % the probe type and number of entries.
    if isfield(meta,'typeEnabled')
        % 3A data
        C = textscan(meta.imroTbl, '(%d %d %*s %*s %*s', ...
            'EndOfLine', ')', 'HeaderLines', 1 );
        exChan = findDisabled(meta);
        % exChan = [36, 75, 112, 151, 188, 227, 264, 303, 340, 373];
    else
        % 3B data
        C = textscan(meta.imroTbl, '(%d %d %*s %*s %*s %*s', ...
            'EndOfLine', ')', 'HeaderLines', 1 );
        exChan = findDisabled(meta);
        % exChan = [191];

    end
    chan = double(cell2mat(C(1)));
    bank = double(cell2mat(C(2)));
    elecInd = bank*384 + chan;
    connected = findDisabled(meta);


end % NP10_ElecInd

% =========================================================
% Read shank map for any probe type and return list
% of channels that are disabled. This will include the
% reference channels
%
% Note that the textscan funtion places line breaks at each
% instance of the 'EndofLine' character -- here, ')'
% 'HeaderLines' = 1 skips the initial entry in the table with
% the number of shanks, columns, and rows
function [connected] = findDisabled(meta)
    % read in the shank map
    C = textscan(meta.snsShankMap, '(%d:%d:%d:%d', ...
            'EndOfLine', ')', 'HeaderLines', 1 );
    enabled = double(cell2mat(C(4)));
    % There's an entry in the shank map for each saved channel,
    % so connected is just that set of enabled flags.
    connected = enabled;

end % findDisabled

% =========================================================
% Return x y coords for electrode index for 2.0 probes
%
%
function [xCoord, yCoord] = XYCoord20(meta, elecInd, bankMask, shankind)

    pType = str2num(meta.imDatPrb_type);

    nElec = 1280;   % per shank; pattern repeats for the four shanks
    vSep  = 15;     % in um
    hSep  = 32;

    elecPos = zeros(nElec, 2);

    elecPos(1:2:end,1) = 0;         % sites 0,2,4...
    elecPos(2:2:end,1) = hSep;      % sites 1,3,5...

    % fill in y values
    viHalf = (0:(nElec/2-1))';                % row numbers
    elecPos(1:2:end,2) = viHalf * vSep;       % sites 0,2,4...
    elecPos(2:2:end,2) = elecPos(1:2:end,2);  % sites 1,3,5...

    xCoord = elecPos(elecInd+1,1);
    yCoord = elecPos(elecInd+1,2);

    if pType == 21
        % single shank probe. Plot only lowest selected electrode
        figure(1)
        % plot all positions
        scatter( elecPos(:,1), elecPos(:,2), 150, 'k', 'square' ); hold on;
        scatter( xCoord, yCoord, 100, 'b', 'square', 'filled' );hold on;
        xlim([-16,64]);
        ylim([-10,10000]);
        title('NP 2.0 single shank view');
        hold off;
    else
        % four shank probe, no multiple connections
        figure(1)
        shankSep = 250;
        for sI = 0:3
            cc = find(shankind == sI);
            scatter( shankSep*sI + elecPos(:,1), elecPos(:,2), 30, 'k', 'square' ); hold on;
            scatter( shankSep*sI + xCoord(cc), yCoord(cc), 20, 'b', 'square', 'filled' ); hold on;
        end
        xlim([-16,3*shankSep+64]);
        ylim([-10,10000]);
        title('NP2.0 MS shank view');
        hold off;
    end


end % XY20Coord

% =========================================================
% Return x y coords for electrode index for 1.0 probes
%
%
function [xCoord, yCoord] = XYCoord10(meta, elecInd)

    nElec = 960;   % per shank; pattern repeats for the four shanks
    vSep  = 20;    % in um
    hSep  = 32;

    elecPos = zeros(nElec, 2);

    elecPos(1:4:end,1) = hSep/2;            % sites 0,4,8...
    elecPos(2:4:end,1) = (3/2)*hSep;        % sites 1,5,9...
    elecPos(3:4:end,1) = 0;                 % sites 2,6,10...
    elecPos(4:4:end,1) = hSep;              % sites 3,7,11...
    elecPos(:,1) = elecPos(:,1) + 11;       % x offset on the shank

    % fill in y values
    viHalf = (0:(nElec/2-1))';                % row numbers
    elecPos(1:2:end,2) = viHalf * vSep;       % sites 0,2,4...
    elecPos(2:2:end,2) = elecPos(1:2:end,2);  % sites 1,3,5...

    xCoord = elecPos(elecInd+1,1);
    yCoord = elecPos(elecInd+1,2);

    % single shank probe. Plot only lowest selected electrode
    figure(1)
    % plot all positions
    scatter( elecPos(:,1), elecPos(:,2), 150, 'k', 'square' ); hold on;
    scatter( xCoord, yCoord, 100, 'b', 'square', 'filled' );hold on;
    xlim([0,70]);
    ylim([-10,8000]);
    title('NP 1.0 single shank view');
    hold off;

end % XY10Coord

% =========================================================
% Return x y coords for electrode index type 1100 (UHD)
%
%
function [xCoord, yCoord] = XYCoord1100(meta, elecInd)

    nElec = 384;   % per shank; pattern repeats for the four shanks
    vSep  = 6;     % in um
    hSep  = 6;

    elecPos = zeros(nElec, 2);

    for i = 0:7
        ind = (i:8:nElec);
        elecPos(ind+1,1) = i*hSep;
        rowind = floor(ind/8);
        elecPos(ind+1,2) = rowind*vSep;
    end

    xCoord = elecPos(elecInd+1,1);
    yCoord = elecPos(elecInd+1,2);

    % single shank probe. Plot only lowest selected electrode
    figure(1)
    % plot all positions
    scatter( elecPos(:,1), elecPos(:,2), 150, 'k', 'square' ); hold on;
    scatter( xCoord, yCoord, 100, 'b', 'square', 'filled' );hold on;
    xlim([0,70]);
    ylim([-10,8000]);
    title('NP 1.0 single shank view');
    hold off;

end % XY1100Coord


% =========================================================
% Return x y coords for electrode index for 1.0 probes
%
%
function [xCoord, yCoord] = XYCoord1300(meta, elecInd)

    nElec = 960;   % per shank; pattern repeats for the four shanks
    vSep  = 20;    % in um
    hSep  = 48;

    elecPos = zeros(nElec, 2);

    elecPos(1:2:end,1) = 0;            % sites 0,2,4...
    elecPos(2:2:end,1) = hSep;         % sites 1,3,5...

    % fill in y values
    elecPos(1:end,2) = floor((0:nElec-1)/2) * vSep;       % all sites

    xCoord = elecPos(elecInd+1,1);
    yCoord = elecPos(elecInd+1,2);

    % single shank probe. Plot only lowest selected electrode
    figure(1)
    % plot all positions
    scatter( elecPos(:,1), elecPos(:,2), 150, 'k', 'square' ); hold on;
    scatter( xCoord, yCoord, 100, 'b', 'square', 'filled' );hold on;
    xlim([0,70]);
    ylim([-10,8000]);
    title('NP 1.0 single shank view');
    hold off;

end % XY10Coord

% =========================================================
% Return array of original channel IDs. As an example,
% suppose we want the imec gain for the ith channel stored
% in the binary data. A gain array can be obtained using
% ChanGainsIM() but we need an original channel index to
% do the look-up. Because you can selectively save channels
% the ith channel in the file isn't necessarily the ith
% acquired channel, so use this function to convert from
% ith stored to original index.
%
% Note: In SpikeGLX channels are 0-based, but MATLAB uses
% 1-based indexing, so we add 1 to the original IDs here.
%
function chans = OriginalChans(meta)
    if strcmp(meta.snsSaveChanSubset, 'all')
        chans = (1:str2double(meta.nSavedChans));
    else
        chans = str2num(meta.snsSaveChanSubset);
        chans = chans + 1;
    end
end % OriginalChans


% =========================================================
% Return counts of each imec channel type that compose
% the timepoints stored in binary file.
%
function [AP,LF,SY] = ChannelCountsIM(meta)
    M  = str2num(meta.snsApLfSy);
    AP = M(1);
    LF = M(2);
    SY = M(3);
end % ChannelCountsIM

