function segmentData = loadSegmentData(fullPathLoaderFile, varargin)
%LOADSEGMENTDATA - loads a data segment from a slocum glider file
%  Optionally, the caller can specify a time interval, so only
%  data belonging to that period will be loaded
%
% Syntax: segmentData = loadSegmentData(fullPathLoaderFile, varargin)
%
% Inputs:
%    fullPathLoaderFile - Fully qualified data loader file name (.m)
%    varargin - Description
%    - timeInterval (optional): a vector with two values which
%      represent the time interval where data is required by the caller in
%      matlab time units (days since year 0000?).
%    - saveOrigWorkspace (optional): a boolean value specifiying if original
%      global workspace should be preserved or not.
%
% Outputs:
%    segmentData - a structure containing the data matrix, column
%    definition and file source
%
% Example:
%    segmentData = loadSegmentData(fullPathLoaderFile)
%    segmentData = loadSegmentData(fullPathLoaderFile, [b e])
%    segmentData = loadSegmentData(fullPathLoaderFile, [b e], false)
%
% Other m-files required: dealWithGlobalWorkspace
% Subfunctions: none
% MAT-files required: none
%
% See also: DEALWITHGLOBALWORKSPACE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 18-Feb-2011
%

    % Initialize output
    segmentData = [];

    % Check that input loader file exists
    if ~exist(fullPathLoaderFile, 'file')
        disp([fullPathLoaderFile, ' file segment loader does not exist. Skipped']);
        return;
    end;

    % Check which options were provided
    if nargin > 1 % Time interval provided
        timeInterval = varargin{1};
    end;
    if nargin > 2 % Time interval and workspace provided
        saveOrigWorkspace = varargin{2};
    else
        saveOrigWorkspace = true;
    end;

    % Saves current directory in order to restore it
    % after calling the loader script
    currentDir = pwd;

    % Extract path to data and loader name
    [loaderPath, loaderScriptName] = fileparts(fullPathLoaderFile);

    % Save the current workspace global status if required
    if saveOrigWorkspace,
        dealWithGlobalWorkspace('save', 'clear');
    else
        dealWithGlobalWorkspace('clear');
    end;

    % Execute the data loader script.
    % This will leave global variables with the columns definition
    % plus the data matrix
    try
        cd(loaderPath);
        eval(loaderScriptName);
    catch ME
        cd(currentDir);
        disp(['Loading of ', loaderScriptName, ' failed']);
        disp(ME.message);
        return;
    end;
    cd(currentDir);

    % If a time interval was provided, trim data
    if exist('timeInterval', 'var') && ~isempty(timeInterval)
        iniDate = min(timeInterval);
        endDate = max(timeInterval);

        % Convert 'epoch' time definition (seconds since 1970)
        % to Matlab time definition:
        if exist('m_present_time', 'var')
            timeCol = m_present_time;
        elseif exist('sci_m_present_time', 'var')
            timeCol = sci_m_present_time;
        else
            disp('No time column definition was found');
            return;
        end;
        numRows = size(data, 1); %#ok<NODEF>
        timePreffix = repmat([1970, 1, 1, 0, 0], numRows, 1);
        timeLine = datenum([timePreffix, data(:, timeCol)]);
        inPeriod = timeLine >= iniDate & timeLine <= endDate;
        data = data(inPeriod, :); %#ok<NASGU>
    end;

    % Join in one structure the data matrix and the column definition:
    % The variables generated in this process were global by default,
    % so take benefit from that for looking up them into the workspace
    desiredFields = whos('global');
    segmentData.data = [];
    fieldsNames = {desiredFields.name};
    for fieldIdx = 1:length(fieldsNames),
        currentFieldName = fieldsNames{fieldIdx};
        segmentData.(currentFieldName) = eval(currentFieldName);

        % Declare field as a global variable to enable access
        % and clear it from the workspace
        eval(['global ', currentFieldName]);
        clear('global', currentFieldName);
    end;

    % Add a field indicating the source of this information so it is
    % similar to a transect with its source list
    segmentData.source = {segmentData.run_name};
    segmentData = rmfield(segmentData, 'run_name');

    % Restore the original workspace global status and
    % remove temporary file
    if saveOrigWorkspace
        dealWithGlobalWorkspace('clear','restore');
    else
        dealWithGlobalWorkspace('clear');
    end;

end
