%MAINGLIDERDATAPROCESSING - Main script to run the glider processing chain
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

%% Script start: clean workspace and set path defaults
clear all;
close all;
clc;
%restoredefaultpath;

%% Basic path setup
% Set the path for accessing the glider toolbox functionality
gliderToolboxDir = fileparts(mfilename('fullpath'));
addpath(genpath(gliderToolboxDir));

%% Set the path to the data: edit for mission processing
% Gliders configuration file directory
configDir = fullfile(gliderToolboxDir, 'config');
desiredExtensions = {'dbd', 'ebd'}; %{'sbd', 'tbd'}; % {'dbd'};
gliderSubDirTree = {...
    'binary',   ...
    'ascii',    ...
    'logs',     ...
    'matfiles', ...
    'netcdf'};

outputDirs.ncBasePath         = '/data/current/opendap/observational/auv/glider/';
outputDirs.imageBaseLocalPath = '/home/glider/public_html/';
outputDirs.imageBaseURLPath   = 'http://www.socib.es/~glider/';


%% Configure processing options
clear processingOptions;
processingOptions.salinityCorrected = 'TH';
%processingOptions.tempTimeConstant = 0.4;
%processingOptions.condTimeConstant = 1.0;
processingOptions.thermalParams    = [0.18, 0.02, 7.16, 2.78];
%processingOptions.thermalParams    = repmat([0.18, 0.02, 7.16, 2.78], 1, 1);
processingOptions.thermalParamsMeaning{1} = {'temperature', 'conductivity'};
% processingOptions.thermalParamsMeaning{2} = {'Tcor', 'conductivity'};
% processingOptions.thermalParamsMeaning{3} = {'Tcor', 'Ccor'};
processingOptions.allowSciTimeFill = true;
processingOptions.allowPressFilter = true;
processingOptions.allowDesynchroDeletion = true;
processingOptions.debugPlot        = true;

%% Get config files, one for each glider in a deployment
if ~isdir(configDir)
    disp(['Invalid active deployments ROOT: ' configDir]);

else
    % Get the listing of glider configuration files
    gliderConfigFileList = dir(fullfile(configDir, '*.cfg'));

    if isempty(gliderConfigFileList)
        disp(['No config files (*.cfg) were found inside ', configDir]);
    else
        % Run through the list of active gliders
        for configIdx = 2:length(gliderConfigFileList)
            
            % Fullpath of configuration file
            configFilename = fullfile(configDir, gliderConfigFileList(configIdx).name);
            if ~exist(configFilename, 'file')
                disp(['Could not find ', configFilename]);
                continue;
            end;
            disp(['Glider configuration file: ' configFilename]);

            % Read in configuration parameters
            params = parseConfigFile(configFilename);
            if isempty(params)
                disp('Empty parameters data structure!');
                continue;
            end;
            [pathstr, gliderName] = fileparts(configFilename);
            gliderName = lower(gliderName);

            % Set the glider data root directory
            if ~isfield(params, 'DATA_ROOT')
                disp('Missing DATA_ROOT config parameter!');
                continue;
            end;
            
            % Generate glider directory if it does not exist
            gliderRootDir = fullfile(params.DATA_ROOT, gliderName);
            [success, errorMsg] = mkdir(gliderRootDir);
            if isequal(success,0)
                disp(errorMsg);
                return;
            end;

            % Create child directories contained in GLIDERSUBDIRTREE
           for dirIdx = 1:length(gliderSubDirTree)
                [success, errorMsg] = mkdir(fullfile(gliderRootDir, gliderSubDirTree{dirIdx}));
                if isequal(success, 0)
                    disp(errorMsg);
                    continue;
                end;
           end;

            % Define directories
            binaryDir = fullfile(gliderRootDir, 'binary');
            asciiDir  = fullfile(gliderRootDir, 'ascii');
            imageDir  = fullfile(outputDirs.imageBaseLocalPath, gliderName, params.DEPLOYMENT_NAME);
            [success, errorMsg] = mkdir(imageDir);
            if isequal(success, 0)
                disp(errorMsg);
                continue;
            end;
            
            [newSbds, newLogs] = getDockserverFiles(gliderName, params);
            
            % 1 - convert binary data files to ascii
            % *Note: the parameter 'e' for extension needs to be specified
            % in order to merge files with new Science Data Logging feature
%             if isdir(asciiDir) && isdir(binaryDir)
%                 downloadedLoaders = convertSlocumBinaries([],...
%                     's', binaryDir, ...
%                     'd', asciiDir, ...
%                     'e', desiredExtensions, ...
%                     'f', fullfile(configDir, 'sensorfilter.txt'), ...
%                     'c', binaryDir);
%                 disp([num2str(length(downloadedLoaders), '%0.0f')...
%                     ' files converted.']);
%             end

            % Loading and processing data if there is something new
            if 1%~isempty(downloadedLoaders)
                timeNumbers = sscanf(params.START_TIME, '%2d:%02d:%02d');
                period(1) = datenum(datevec(params.START_DATE) + [0 0 0 timeNumbers(:)']);
                timeNumbers = sscanf(params.END_TIME, '%2d:%02d:%02d');
                period(2) = datenum(datevec(params.END_DATE) + [0 0 0 timeNumbers(:)']);

                rawData = loadTransectData(asciiDir, period);
                missionId = [datestr(params.START_DATE, 'yyyymmdd'), '_', gliderName];
                
                % Store raw data in netcdf
%                 ncRawFilePath = fullfile(outputDirs.ncBasePath, ...
%                     gliderName, 'l0', datestr(params.START_DATE, 'yyyy'));
%                 mkdir(ncRawFilePath);
                ncRawFileName = [gliderName, '_L0_', datestr(params.START_DATE, 'yyyy-mm-dd'), '.nc'];
                ncRawDataFilename = fullfile(gliderRootDir, 'netcdf', ncRawFileName);
                %genRawGliderNcFile(ncRawDataFilename, rawData, params);

                 try
                    processingOptions.debugPlotPath = imageDir;
                    processedData = processGliderData(rawData, processingOptions);
                    
                 catch ME
                    processedData = [];
                    disp('Error in processing data');
                    disp(ME.stack);
                 end

                if ~isempty(processedData)
                    % Store results in mat file
                    procFilename = [gliderName, '_L1_', datestr(params.START_DATE, 'yyyy-mm-dd')];
                    processedDataFilename = fullfile(gliderRootDir, 'matfiles', [procFilename, '.mat']);
                    save(processedDataFilename, 'processedData');
                    % Store results in nc file
                    ncProcDataFilename = fullfile(gliderRootDir, 'netcdf', [procFilename, '.nc']);
                    %genProcGliderNcFile(ncProcDataFilename, processedData, params);

                    griddedData = gridGliderData(processedData);
                    % Remove comments when processing is ready
                    % pause(0.25); %  QUIRKS MODE
                    ncGriddedDataFilename = fullfile(gliderRootDir, 'netcdf', [missionId, '_gridded_data.nc']);
                    %genGriddedGliderNcFile(ncGriddedDataFilename, griddedData, params);

                    if isdir(imageDir)
                        try
%                             for transectStart = 1:length(processedData.transects) - 1
%                                 
%                                 [partialProcessedData, partialGriddedData] = ...
%                                     trimGliderData(processedData, griddedData, ...
%                                     [processedData.transects(transectStart), ...
%                                      processedData.transects(transectStart + 1)]);
%                                 
%                                 imgsList = generateScientificFigures(partialProcessedData, partialGriddedData, imageDir, [gliderName, '_']);
% 
%                             end;
                            imgsList = generateScientificFigures(processedData, griddedData, imageDir, [gliderName, '_']);
                            % Add URL base path to images
                            for idx = 1:length(imgsList)
                                imgsList(idx).path = fullfile(outputDirs.imageBaseURLPath, ...
                                    gliderName, params.DEPLOYMENT_NAME, ...
                                    imgsList(idx).path);
                            end;
                            jsonName = fullfile( outputDirs.imageBaseLocalPath, ...
                                [gliderName, '.', params.DEPLOYMENT_NAME, '.images.json']);
                            writeJSON(imgsList, jsonName);
                            
                        catch ME
                            xmlImgsList = '';
                            disp('Error in generateScientificFigures');
                            disp(getReport(ME, 'extended'));
                        end
                        
                    end;

                end; % if ~isempty(processedData)
            end;
        end; % for configIdx = 1:length(gliderConfigFileList)
    end; % if isempty(gliderConfigFileList)
end; % if ~isdir(configDir)

