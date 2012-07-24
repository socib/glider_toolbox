%MAINGLIDERDATAPROCESSINGNRT - Main script to run near real time glider processing chain.
% This script develops the full processing chain of glider data, from
% data downloading from the dockserver, data conversion, data processing
% and correction, netcdf storage and data images generation.
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2Âºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

%% Basic path setup
% Set the path for accessing the glider toolbox functionality
gliderToolboxDir = fileparts(mfilename('fullpath'));
addpath(genpath(gliderToolboxDir));

%% Set the path to the data: edit for mission processing
% Gliders configuration file directory
configDir = fullfile(gliderToolboxDir, 'config');
desiredExtensions = {'sbd', 'tbd', 'ebd'};
gliderSubDirTree = {...
    'binary',   ...
    'ascii',    ...
    'logs',     ...
    'matfiles', ...
    'netcdf'};

%outputDirs.ncBasePath         = '/data/current/opendap/observational/auv/glider/';
outputDirs.ncBasePath         = '/home/jbeltran/public_html/observational/auv/glider/';
outputDirs.imageBaseLocalPath = '/home/jbeltran/public_html/glider';
outputDirs.imageBaseURLPath   = 'http://www.socib.es/~jbeltran/glider/';
data_root_testing = '/home/jbeltran/public_html/glider';

%% Configure processing options
clear processingOptions;
processingOptions.salinityCorrected = 'TH';
processingOptions.allowSciTimeFill = true;
processingOptions.allowPressFilter = true;
processingOptions.allowDesynchroDeletion = true;
processingOptions.debugPlot        = true;


%% Get list of active deployments
disp('Retrieving remote list of deployments...');
currentDeploymentsList = getDeploymentsForTesting();
if isempty(currentDeploymentsList)
    disp(['Empty list of deployments found']);

else
    for deploymentIdx = 1:length(currentDeploymentsList)
        currentDeployment = currentDeploymentsList{deploymentIdx};
        gliderName = currentDeployment.glider;
        configFilename = fullfile(configDir, [gliderName, '.cfg']);
        if ~exist(configFilename, 'file')
            disp(['Could not find ', configFilename]);
            continue;
        end;

        % Read in configuration parameters
        params = parseConfigFile(configFilename);
        if isempty(params)
            disp('Empty parameters data structure!');
            continue;
        end;

        % Copy additional static glider parameters to deployment params
        fields = fieldnames(params);
        for fieldIdx = 1:length(fields)
            currentField = fields{fieldIdx};
            currentDeployment.(currentField) = params.(currentField);
        end;

        % Set the glider data root directory
        if ~isfield(currentDeployment, 'dataRoot')
            disp('Missing DATA_ROOT config parameter. Setting default value...');
            currentDeployment.dataRoot = fullfile('/home/glider/gliderDeployments/', gliderName, currentDeployment.mission_name);
        end;
        currentDeployment.dataRoot = fullfile(data_root_testing, gliderName, currentDeployment.mission_name);

        % Generate glider directory if it does not exist
        [success, errorMsg] = mkdir(currentDeployment.dataRoot);
        if isequal(success,0)
            disp(errorMsg);
            return;
        end;

        % Create child directories contained in GLIDERSUBDIRTREE
        for dirIdx = 1:length(gliderSubDirTree)
            [success, errorMsg] = mkdir(fullfile(currentDeployment.dataRoot, gliderSubDirTree{dirIdx}));
            if isequal(success, 0)
                disp(errorMsg);
                continue;
            end;
        end;

        % Define directories
        binaryDir = fullfile(currentDeployment.dataRoot, 'binary');
        asciiDir  = fullfile(currentDeployment.dataRoot, 'ascii');
        imageDir  = fullfile(outputDirs.imageBaseLocalPath, gliderName, currentDeployment.mission_name);
        [success, errorMsg] = mkdir(imageDir);
        if isequal(success, 0)
            disp(errorMsg);
            continue;
        end;

        [newSbds, newLogs] = getDockserverFiles(gliderName, currentDeployment);

        % 1 - convert binary data files to ascii
        % *Note: the parameter 'e' for extension needs to be specified
        % in order to merge files with new Science Data Logging feature
        if isdir(asciiDir) && isdir(binaryDir)
            downloadedLoaders = convertSlocumBinaries([],...
                's', binaryDir, ...
                'd', asciiDir, ...
                'e', desiredExtensions, ...
                'f', fullfile(configDir, 'sensorfilter.txt'), ...
                'c', binaryDir);
            disp([num2str(length(downloadedLoaders), '%0.0f'), ' files converted.']);
        end

        % Loading and processing data if there is something new
        if ~isempty(downloadedLoaders)
            if isfield(currentDeployment, 'start_time')
                timeNumbers = sscanf(currentDeployment.start_time, '%2d:%02d');
            else
                timeNumbers = [0 0];
            end;
            period(1) = datenum(datevec(currentDeployment.start_date) + [0 0 0 timeNumbers(:)' 0]);

            if isfield(currentDeployment, 'end_time')
                timeNumbers = sscanf(currentDeployment.end_time, '%2d:%02d');
            else
                timeNumbers = [0 0];
            end;
            period(2) = datenum(datevec(currentDeployment.end_date) + [0 0 0 timeNumbers(:)' 0]);

            rawData = loadTransectData(asciiDir, period);
            missionId = [datestr(currentDeployment.start_date, 'yyyymmdd'), '_', gliderName];


            % Generate L0 (Raw) netcdf file and store it
            try
                generateNcProduct(currentDeployment, outputDirs, gliderName, 'L0', rawData);
            catch ME
                disp('could not generate glider raw netcdf file');
                disp(getReport(ME, 'extended'));
            end;

            try
                processingOptions.debugPlotPath = imageDir;
                processedData = processGliderData(rawData, processingOptions);
            catch ME
                processedData = [];
                disp('Error in processing data');
                disp(getReport(ME, 'extended'));
            end

            if isempty(processedData)
                disp('processed data is empty. Skipping storage, gridding and plotting.');
                continue;
            end;

            % Generate L1 (Processed) netcdf file and store it
            try
                % Store results in mat file
                procFilename = [gliderName, '_L1_', datestr(currentDeployment.start_date, 'yyyy-mm-dd')];
                processedDataFilename = fullfile(currentDeployment.dataRoot, 'matfiles', [procFilename, '.mat']);
                save(processedDataFilename, 'processedData');

                generateNcProduct(currentDeployment, outputDirs, gliderName, 'L1', processedData);
            catch ME
                disp('could not generate glider processed netcdf file');
                disp(getReport(ME, 'extended'));
            end;

            % Generate L2 (Gridded) netcdf file and store it
            try
                griddedData = gridGliderData(processedData);
                generateNcProduct(currentDeployment, outputDirs, gliderName, 'L2', griddedData);
            catch ME
                disp('could not generate glider gridded netcdf file');
                disp(getReport(ME, 'extended'));
            end;

            if isdir(imageDir)
                try
%                             for transectStart = 1:length(processedData.transects) - 1
%                                 [partialProcessedData, partialGriddedData] = ...
%                                     trimGliderData(processedData, griddedData, ...
%                                     [processedData.transects(transectStart), ...
%                                      processedData.transects(transectStart + 1)]);
%                                 transectImageDir = fullfile(imageDir, ['transect', num2str(transectStart)]);
%                                 mkdir(transectImageDir);
%                                 imgsList = generateScientificFigures(partialProcessedData, partialGriddedData, transectImageDir, [gliderName, '_']);
%                             end;
                    imgsList = generateScientificFigures(processedData, griddedData, imageDir, [gliderName, '_']);
                    % Add URL base path to images
                    for idx = 1:length(imgsList)
                        imgsList(idx).path = fullfile(outputDirs.imageBaseURLPath, ...
                            gliderName, currentDeployment.mission_name, ...
                            imgsList(idx).path);
                    end;
                    jsonName = fullfile( outputDirs.imageBaseLocalPath, ...
                        [gliderName, '.', currentDeployment.mission_name, '.images.json']);
                    writeJSON(imgsList, jsonName);
                catch ME
                    xmlImgsList = '';
                    disp('Error in generateScientificFigures');
                    disp(getReport(ME, 'extended'));
                end;
            end; % if isdir(imageDir)
        end; % if ~isempty(downloadedLoaders)
    end; % for deploymentIdx = 1:length(currentDeploymentsList)
end; % if isempty(currentDeploymentsList)
