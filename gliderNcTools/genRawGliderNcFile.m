function genRawGliderNcFile(outFilename, rawData, params)
%GENRAWGLIDERNCFILE - Generates a glider netcdf file from raw data
% This function creates, defines and fills in a netcdf file with glider data
%
% Syntax: genRawGliderNcFile(outFilename, rawData, params)
%
% Inputs:
%    outFilename - Fully qualified name of the netcdf output file
%    rawData - structure containing the fields to be converted to variables
%    params - structure containing the glider deployment metadata
%
% Outputs: none
%
% Example:
%    genRawGliderNcFile(outFilename, rawData, params)
%
% Other m-files required: SNCTOOLS toolbox required
% Subfunctions: none
% MAT-files required: none
%
% See also: NC_CREATE_EMPTY, NC_ADD_DIMENSION, NC_ADDVAR, NC_ATTPUT,
% NC_VARPUT
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

%% FILE CREATION
    % First of all, generate an empty file to be filled in
    nc_create_empty(outFilename);
    
%% DIMENSIONS
    % Add a dimension to index records (it has to be unlimited)
    recordDimName = 'time';
    nc_add_dimension(outFilename, recordDimName, 0); % UNLIMITED
    
%% VARIABLES
    % Get the list of fields appearing on the rawData structure
    fieldList = fieldnames(rawData);
    
    % Loop through the list of fields to define the file
    for fieldIdx = 1:length(fieldList)

        currentFieldName = fieldList{fieldIdx};
        currentField = rawData.(currentFieldName);
        
        % If the field contains just one number, 
        % it will be assumed to be a column definition, thus,
        % a variable for the netcdf
        if isnumeric(currentField) && (numel(currentField) == 1)
            varstruct.Name = currentFieldName;
            varstruct.Nctype = 'NC_DOUBLE';
            varstruct.Dimension = {recordDimName};
            varstruct.Attribute = getRawGliderVarAtts(currentFieldName);
            nc_addvar(outFilename, varstruct);
        end
    end

%% GLOBAL ATTRIBUTES: METADATA
    % A list of 'fixed' attributes (user can override them)
    nc_attput(outFilename, nc_global, 'type', 'Slocum glider raw data file');
    nc_attput(outFilename, nc_global, 'creation_date', datestr(now));
    nc_attput(outFilename, nc_global, 'netcdf_version', '3.6.1');
    
    % Source ascii files list
    if ~isempty(rawData.source)
        sourceFileList = rawData.source{1};
        for srcIdx = 2:length(rawData.source)
            sourceFileList = strcat(sourceFileList, ['; ', rawData.source{srcIdx}]);
        end;
        nc_attput(outFilename, nc_global, 'source_files', sourceFileList);
    end
    
    % Get the list of fields appearing on the params structure
    paramNames = fieldnames(params);
    
    % Define a parameter name preffix to look for
    mdPreffix = 'METADATA_';
    preffixLength = length(mdPreffix);
    
    % Loop through the list of fields to find metadata fields
    for paramIdx = 1:length(paramNames)
        currentParamName = paramNames{paramIdx};
        
        % If the field name starts with the predefined preffix
        % get the rest of the name and add it to the netcdf file
        % as a global attribute
        if strncmp(currentParamName, mdPreffix, preffixLength)
            attName = currentParamName(preffixLength+1:end);
            nc_attput(outFilename, nc_global, attName, params.(currentParamName));
        end
    end

%% FILE FILLING

    % Loop through the list of fields again to fill the file
    for fieldIdx = 1:length(fieldList)

        currentFieldName = fieldList{fieldIdx};
        currentField = rawData.(currentFieldName);
        
        % If the field contains just one number, 
        % it will be assumed to be a column definition, thus,
        % a variable for the netcdf
        if isnumeric(currentField) && (numel(currentField) == 1)
            nc_varput(outFilename, currentFieldName, ...
                rawData.data(:,currentField), 0, size(rawData.data, 1));
        end
    end
    
    % STILL TO BE FIXED
%     lat = rawData.data(:, rawData.m_gps_lat);
%     lon = rawData.data(:, rawData.m_gps_lon);
%     time = rawData.data(:, rawData.m_present_time);
%     
%     latIdx  = find(~isnan(lat),  1, 'first');
%     lonIdx  = find(~isnan(lon),  1, 'first');
%     timeIdx = find(~isnan(time), 1, 'first');
% 
%     % Rewrite some global attributes with contained information
% 	nc_attput(outFilename, nc_global, 'launch_latitude', lat(latIdx));
%     nc_attput(outFilename, nc_global, 'launch_longitude', lon(lonIdx));
%     
%     d = nc_attget(outFilename, nc_global, 'launch_date');
%     nc_attput(outFilename, nc_global, 'launch_date', datestr(d));
%     
%     d = datenum([1970 1 1 0 0 time(timeIdx)]);
%     nc_attput(outFilename, nc_global, 'start_date', datestr(d));
% 
%     nc_attput(outFilename, nc_global, 'southernmost_latitude', min(lat));
%     nc_attput(outFilename, nc_global, 'northernmost_latitude', max(lat));
%     nc_attput(outFilename, nc_global, 'westernmost_longitude', min(lon));
%     nc_attput(outFilename, nc_global, 'easternmost_longitude', max(lon));
    
end