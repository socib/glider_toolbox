%MAIN_GLIDER_DATA_PROCESSING_NRT  Run near real time glider processing chain.
%
%  This script develops the full processing chain for real time glider data:
%  - Check for active deployments from deployment information source.
%
%
%  See also:
%
%  Notes: This script is based on the previous work by Tomeu Garau.
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
  'matfiles', ...
  'netcdf'};

%output_dirs.nc_base_path     = '/data/current/opendap/observational/auv/glider/';
output_dirs.nc_base_path      = '/home/jbeltran/public_html/observational/auv/glider/';
output_dirs.image_base_local_path = '/home/jbeltran/public_html/glider';
output_dirs.imageBaseURLPath    = 'http://www.socib.es/~jbeltran/glider/';
data_root_testing = '/home/jbeltran/public_html/glider';


%% Configure processing options
processing_options.salinity_corrected = 'TH';
processing_options.allow_sci_time_fill = true;
processing_options.allow_press_filter = true;
processing_options.allow_desynchro_deletion = true;
processing_options.debug_plot    = true;


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.deployment_fields] = configDBDeploymentInfoQuery();


%% Get list of active deployments from database.
disp('Querying information of glider deployments...');
active_deployments = getDBDeploymentInfo(config.db_access, ...
                                         config.db_query, ...
                                         config.db_fields);

%% Process active deployments
if isempty(active_deployments)
  disp(['No glider deployments available.']);
  return
end

for deployment_idx = 1:length(active_deployments)
  current_deployment = active_deployments{deployment_idx};
  config_filename = fullfile(config_dir, [glider_name, '.cfg']);
  if ~exist(config_filename, 'file')
  disp(['Could not find ', config_filename]);
  continue;
  end;

  % Read in configuration parameters
  params = parseConfigFile(config_filename);
  if isempty(params)
  disp('Empty parameters data structure!');
  continue;
  end;

  % Copy additional static glider parameters to deployment params
  fields = fieldnames(params);
  for field_idx = 1:length(fields)
  current_field = fields{field_idx};
  current_deployment.(current_field) = params.(current_field);
  end;

  % Set the glider data root directory
  if ~isfield(current_deployment, 'data_root')
  disp('Missing DATA_ROOT config parameter. Setting default value...');
  current_deployment.data_root = fullfile('/home/glider/glider_deployments/', glider_name, current_deployment.mission_name);
  end;
  current_deployment.data_root = fullfile(data_root_testing, glider_name, current_deployment.mission_name);

  % Generate glider directory if it does not exist
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
  image_dir  = fullfile(output_dirs.image_base_local_path, glider_name, current_deployment.mission_name);
  [success, error_msg] = mkdir(image_dir);
  if isequal(success, 0)
  disp(error_msg);
  continue;
  end;

  [new_sbds, new_logs] = getDockserverFiles(glider_name, current_deployment);

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

  % Loading and processing data if there is something new
  if ~isempty(downloaded_loaders)
    if isfield(current_deployment, 'start_time')
      time_numbers = sscanf(current_deployment.start_time, '%2d:%02d');
    else
      time_numbers = [0 0];
    end;
    period(1) = datenum(datevec(current_deployment.start_date) + [0 0 0 timeNumbers(:)' 0]);

    if isfield(current_deployment, 'end_time')
      time_numbers = sscanf(current_deployment.end_time, '%2d:%02d');
    else
      time_numbers = [0 0];
    end;
    period(2) = datenum(datevec(current_deployment.end_date) + [0 0 0 timeNumbers(:)' 0]);

    raw_data = loadTransectData(ascii_dir, period);
    mission_id = [datestr(current_deployment.start_date, 'yyyymmdd'), '_', glider_name];

%{
    % Generate L0 (Raw) netcdf file and store it
    try
      generateNcProduct(current_deployment, output_dirs, glider_name, 'L0', raw_data);
    catch ME
      disp('could not generate glider raw netcdf file');
      disp(getReport(ME, 'extended'));
    end;
%}

    try
      processing_options.debug_plot_path = image_dir;
      processed_data = processGliderData(raw_data, processing_options);
    catch ME
      processed_data = [];
      disp('Error in processing data');
      disp(getReport(ME, 'extended'));
    end

    if isempty(processed_data)
      disp('processed data is empty. Skipping storage, gridding and plotting.');
      continue;
    end;

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
      imgs_list = generateScientificFigures(processed_data, gridded_data, image_dir, [glider_name, '_']);
        % Add URL base path to images
        for idx = 1:length(imgs_list)
          imgsList(idx).path = fullfile(output_dirs.imageBaseURLPath, ...
            glider_name, current_deployment.mission_name, ...
            imgsList(idx).path);
        end;
        json_name = fullfile( output_dirs.image_base_local_path, ...
          [glider_name, '.', current_deployment.mission_name, '.images.json']);
        writeJSON(imgs_list, json_name);
      catch ME
        xml_imgs_list = '';
        disp('Error in generate_scientific_figures');
        disp(getReport(ME, 'extended'));
      end;
    end; % if isdir(image_dir)
  end; % if ~isempty(downloaded_loaders)
end; % for deployment_idx = 1:length(active_deployments)

