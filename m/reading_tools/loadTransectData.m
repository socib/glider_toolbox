function transectData = loadTransectData(loadersSource, varargin)
%LOADTRANSECTDATA - Loads all data segments from a slocum glider
%  that are in a certain folder and returns a structure with its content.
%  Optionally, the caller can specify a timeInterval, so only
%  data belonging to that period will be loaded
%
% Syntax: transectData = loadTransectData(loadersSource, varargin)
%
% Inputs:
%    loadersSource - the path to the loaders scripts
%    timeInterval (optional) - a vector with two values which
%                              represent the time interval where
%                              the transect is defined
%
% Outputs:
%    transectData - a structure containing the data matrix, column
%    definition and files sources
%
% Example:
%    transectData = loadTransectData(loadersSource);
%    transectData = loadTransectData(loadersSource, [b e])
%
% Other m-files required: loadSegmentData, removeDuplicatedRecords,
%  listLoaders, dealWithGlobalWorkspace
% Subfunctions: none
% MAT-files required: none
%
% See also: LOADSEGMENTDATA, REMOVEDUPLICATEDRECORDS,
%  DEALWITHGLOBALWORSPACE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 18-Feb-2011
%

    % Initialize output variable as an empty var struct
    transectData = struct([]);

    % Check which type of loaders source the user provided
    if iscell(loadersSource)
        loadersList = loadersSource;
    else
        % Check that input loader file exists
        if ~exist(loadersSource, 'dir')
            disp([loadersSource, ' folder does not exist. Skipped']);
            return;
        end;

        % Get the files list on the loaders path
        loadersList = listLoaders(loadersSource);
        if isempty(loadersList)
            disp(['No loader scripts found on ', loadersSource, '. Skipped']);
            return;
        end;
    end;

    % Check if a time interval was provided
    switch nargin
        case 1
            timeInterval = [];
        case 2
            timeInterval = varargin{1};
        otherwise
            disp([mfilename, ' received wrong number of parameters']);
    end;

    % Save original state of workspace
    % and tell the segments loader not to do it
    dealWithGlobalWorkspace('save', 'clear');
    saveOrigWorkspace = false;

    % Go through the list of loader scripts
    for fileIdx = 1:length(loadersList)
        curentLoaderFile = loadersList{fileIdx};
        disp(['Loading ', curentLoaderFile, ' ...']);

        % Read segment data. If a time interval was provided,
        % use it to trim data
        currentSegmentData = loadSegmentData(curentLoaderFile, timeInterval, saveOrigWorkspace);
        if isempty(currentSegmentData)
            % No need to update transect data with this segment, so skip it
            continue;
        end;

        % Get information about the transect collected so far
        % and the current segment
        if ~isempty(transectData)
            oldFieldList = fieldnames(transectData);
            oldFieldList = setdiff(oldFieldList, 'data');
            oldFieldList = setdiff(oldFieldList, 'source');
            oldRows = size(transectData.data, 1);
        else
            oldFieldList = {};
            oldRows = 0;
        end;

        newFieldList = fieldnames(currentSegmentData);
        newFieldList = setdiff(newFieldList, 'data');
        newFieldList = setdiff(newFieldList, 'source');
        newRows = size(currentSegmentData.data, 1);

        % Accumulate the current segment data to the whole transect data
        if isempty(transectData) % Very first segment of the transect
            transectData = currentSegmentData;
        else
            wholeFieldList = union(oldFieldList, newFieldList);
            newDataMatrix =nan(oldRows + newRows, length(wholeFieldList));
            clear updatedTransectData;
            for fieldIdx = 1:length(wholeFieldList)
                currentFieldName = char(wholeFieldList{fieldIdx});
                if ismember(currentFieldName, oldFieldList)
                    oldFieldValues = transectData.data(:, transectData.(currentFieldName));
                    newDataMatrix(1:oldRows, fieldIdx) = oldFieldValues;
                end
                if ismember(currentFieldName, newFieldList)
                    newFieldValues = currentSegmentData.data(:, currentSegmentData.(currentFieldName));
                    newDataMatrix(oldRows+1:end, fieldIdx) = newFieldValues;
                end
                updatedTransectData.(currentFieldName) = fieldIdx;
            end % for fieldIdx
            updatedTransectData.data = newDataMatrix;
            % Accumulate in the 'source' field the list of segments used
            newSource = [transectData.source; currentSegmentData.source];
            updatedTransectData.source = newSource;
            transectData = updatedTransectData;
        end;
        % Sort data by record timestamp
        if isfield(transectData, 'm_present_time')
            timeCol = transectData.m_present_time;
        elseif isfield(transectData, 'sci_m_present_time')
            timeCol = transectData.sci_m_present_time;
        else
            disp('No time column definition was found');
            return;
        end;
        timeVector = transectData.data(:, timeCol);
        if ~issorted(timeVector)
            [~, correctRowIndexOrder] = sort(timeVector);
            transectData.data = transectData.data(correctRowIndexOrder, :);
        end;
        % Eliminate records where timestamps are duplicated
        keepFirst = true;
        transectData.data = removeDuplicatedRecords(transectData.data, timeCol, keepFirst);
    end; % for fileIdx = 1:length(loadersList)

end
