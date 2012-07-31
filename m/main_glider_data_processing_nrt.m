%MAIN_GLIDER_DATA_PROCESSING_NRT  Run near real time glider processing chain.
%
%  This script develops the full processing chain for real time glider data:
%    - Check for active deployments from deployment information source.
%    - Download new or updated deployment raw data files.
%    - Convert downloaded files to human readable format if needed.
%    - Preprocess raw data applying simple unit conversions data without
%      modifying it:
%      1. NMEA latitude and longitude to decimal degrees.
%    - Produce standarized product version of raw data.
%    - Process raw data deriving new measurements and applying corrections
%      to obtain well referenced trajectory data.
%    - Produce standarized product version of trajectory data.
%    - Interpolate trajectory data to obtain vertically gridded profile data.
%    - Produce standarized product version of gridded data.
%    - Generate descriptive figures of both trajectory and gridded data.
%
%  See also:
%
%  Notes:
%    This script is based on the previous work by Tomeu Garau. He is the true
%    glider man.
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat


%% Set the path to the data: edit for mission processing
% Gliders configuration file directory
glider_toolbox_dir = fileparts(mfilename('fullpath'));
config_dir = fullfile(glider_toolbox_dir, 'config');
desired_extensions = {'sbd', 'tbd'};
glider_sub_dir_tree = {...
  'binary',   ...
  'ascii',  ...
  'logs',   ...
  'figures', ...
  'netcdf'};

%output_dirs.nc_base_path     = '/data/current/opendap/observational/auv/glider/';
output_dirs.nc_base_path      = '/home/jbeltran/public_html/observational/auv/glider/';
output_dirs.image_base_local_path = '/home/jbeltran/public_html/glider';
output_dirs.imageBaseURLPath    = 'http://www.socib.es/~jbeltran/glider/web';


%% Configure processing options
processing_options.salinityCorrected = 'TH';
processing_options.allowSciTimeFill = true;
processing_options.allowPressFilter = true;
processing_options.allowDesynchroDeletion = true;
processing_options.debugPlot    = true;


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.db_fields] = configDBDeploymentInfoQuery();


%% Configure local data base path.
config.local_base_path = '/home/jbeltran/public_html/glider/data_rt';


%% Get list of active deployments from database.
disp('Querying information of glider deployments...');
active_deployments = getDBDeploymentInfo(config.db_access, ...
                                         config.db_query, ...
                                         config.db_fields);


%% Process active deployments
if isempty(active_deployments)
  disp('No glider deployments available.');
  return
end

active_deployments = active_deployments(strcmp({active_deployments.glider_name},'ideep00'));

for deployment_idx = 1:length(active_deployments)
  %% Deployment complete configuration.
  current_deployment = active_deployments(deployment_idx);
  config_filename = fullfile(config_dir, [current_deployment.glider_name, '.cfg']);
  if ~exist(config_filename, 'file')
    disp(['Could not find ', config_filename]);
    continue;
  end;

  % Add glider configuration parameters.
  params = parseConfigFile(config_filename);
  if isempty(params)
    disp('Empty parameters data structure!');
    continue;
  end;
  fields = fieldnames(params);
  for field_idx = 1:length(fields)
    current_field = fields{field_idx};
    current_deployment.(current_field) = params.(current_field);
  end;

  % Fix possibly missing deployment end time.
  if isempty(current_deployment.end_time)
    current_deployment.end_time = now();
  end


  % Set the glider data root directory
  %{
  if ~isfield(current_deployment, 'data_root')
    disp('Missing DATA_ROOT config parameter. Setting default value...');
    current_deployment.data_root = fullfile('/home/glider/glider_deployments/', glider_name, current_deployment.mission_name);
  end;
  %}
  current_deployment.data_root = fullfile(config.local_base_path, ...
                                          current_deployment.glider_name, ...
                                          datestr(current_deployment.start_time,'yyyymmdd'));


  %% Generate glider directory if it does not exist.
  [success, error_msg] = mkdir(current_deployment.data_root);
  if isequal(success,0)
    disp(error_msg);
    return;
  end;

  % Create child directories contained in GLIDERSUBDIRTREE
  for dir_idx = 1:length(glider_sub_dir_tree)
    [success, error_msg] = mkdir(fullfile(current_deployment.data_root, glider_sub_dir_tree{dir_idx}));
    if isequal(success, 0)
      disp(error_msg);
      continue;
    end;
  end;

  % Define directories
  binary_dir = fullfile(current_deployment.data_root, 'binary');
  ascii_dir  = fullfile(current_deployment.data_root, 'ascii');
  image_dir  = fullfile(current_deployment.data_root, 'figures');


  %% Download glider files from station(s).
  [new_sbds, new_logs] = getDockserverFiles(current_deployment.glider_name, ...
                                            current_deployment);

  %% Convert binary glider files.
  % 1 - convert binary data files to ascii
  % *Note: the parameter 'e' for extension needs to be specified
  % in order to merge files with new Science Data Logging feature
  if isdir(ascii_dir) && isdir(binary_dir)
    downloaded_loaders = convertSlocumBinaries([],...
      's', binary_dir, ...
      'd', ascii_dir, ...
      'e', desired_extensions, ...
      'f', fullfile(config_dir, 'sensorfilter.txt'), ...
      'c', binary_dir);
    disp([num2str(length(downloaded_loaders), '%0.0f'), ' files converted.']);
  end


  %% Load raw glider data (if there is something new).
  if isempty(downloaded_loaders)
    disp('No new deployment data to process, omitting...');
    continue
  end
  period = [current_deployment.start_time current_deployment.end_time];

  raw_data = loadTransectData(ascii_dir, period);
%{
  % Generate L0 (Raw) netcdf file and store it
  try
    generateNcProduct(current_deployment, output_dirs, glider_name, 'L0', raw_data);
  catch ME
    disp('could not generate glider raw netcdf file');
    disp(getReport(ME, 'extended'));
  end;
%}


  %% Process raw glider data to get clean trajectory data.
  try
    processing_options.debugPlotPath = image_dir;
    processed_data = processGliderData(raw_data, processing_options);
  catch ME
    processed_data = [];
    disp('Error processing data:');
    disp(getReport(ME, 'extended'));
  end

  if isempty(processed_data)
    disp('processed data is empty. Skipping storage, gridding and plotting.');
    continue;
  end;


  %% Process glider trajectory data to vertically gridded data.
  gridded_data = gridGliderData(processed_data);
%{
  % Generate L1 (Processed) netcdf file and store it
  try
    % Store results in mat file
    proc_filename = [glider_name, '_L1_', datestr(current_deployment.start_date, 'yyyy-mm-dd')];
    processed_data_filename = fullfile(current_deployment.data_root, 'matfiles', [proc_filename, '.mat']);
    save(processed_data_filename, 'processed_data');

    generateNcProduct(current_deployment, output_dirs, glider_name, 'L1', processed_data);
  catch ME
    disp('could not generate glider processed netcdf file');
    disp(getReport(ME, 'extended'));
  end;
%}

%{
  % Generate L2 (Gridded) netcdf file and store it
  try
    generateNcProduct(current_deployment, output_dirs, glider_name, 'L2', gridded_data);
  catch ME
    disp('could not generate glider gridded netcdf file');
    disp(getReport(ME, 'extended'));
  end;
%}


  %% Generate deployment figures.
  if isdir(image_dir)
    try
%{
    for transect_start = 1:length(processed_data.transects) - 1
      [partial_processed_data, partial_gridded_data] = ...
      trimGliderData(processed_data, gridded_data, ...
      [processed_data.transects(transect_start), ...
      processed_data.transects(transect_start + 1)]);
      transect_image_dir = fullfile(image_dir, ['transect', num2str(transect_start)]);
      mkdir(transect_image_dir);
      imgs_list = generateScientificFigures(partial_processed_data, partial_gridded_data, transect_image_dir, [glider_name, '_']);
    end;
%}
    imgs_list = generateScientificFigures(processed_data, gridded_data, ...
                                          image_dir, [current_deployment.glider_name, '_']);
      % Add URL base path to images
      for idx = 1:length(imgs_list)
        imgs_list(idx).path = fullfile(output_dirs.imageBaseURLPath, ...
                                       current_deployment.glider_name, ...
                                       current_deployment.mission_name, ...
                                       imgs_list(idx).path);
      end
      json_name = fullfile( output_dirs.image_base_local_path, ...
        [current_deployment.glider_name, '.', current_deployment.mission_name, '.images.json']);
      writeJSON(imgs_list, json_name);
    catch ME
      xml_imgs_list = '';
      disp('Error generating scientific figures:');
      disp(getReport(ME, 'extended'));
    end;
  end; % if isdir(image_dir)
end; % for deployment_idx = 1:length(active_deployments)

