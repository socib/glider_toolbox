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


%% Configure toolbox and configuration file path.
glider_toolbox_dir = configGliderToolboxPath();
% Glider configuration file directory
% config_dir = fullfile(glider_toolbox_dir, 'config');
desired_extensions = {'sbd', 'tbd', 'mbd', 'nbd'};


%% Configure deployment data paths.
config.local_paths = configLocalPathsRT();


%% Configure NetCDF output.
config.output_ncl0 = configOutputNetCDFL0();
config.output_ncl1 = configOutputNetCDFL1();
config.output_ncl2 = configOutputNetCDFL2();


%% Set the path to the data: edit for mission processing.
output_dirs.image_base_local_path = '/home/jbeltran/public_html/glider';
output_dirs.imageBaseURLPath    = 'http://www.socib.es/~jbeltran/glider/web';


%% Configure processing options.
processing_options.salinityCorrected = 'TH';
processing_options.allowSciTimeFill = true;
processing_options.allowPressFilter = true;
processing_options.allowDesynchroDeletion = true;
processing_options.debugPlot    = true;


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.db_fields] = configDBDeploymentInfoQuery();


%% Configure dockserver glider data source.
config.dockservers = configDockservers();


%% Configure Slocum file downloading and conversion, and Slocum data loading.
config.slocum_options = configRTSlocumFileOptions;


%% Get list of active deployments from database.
disp('Querying information of glider deployments...');
active_deployments = getDBDeploymentInfo(config.db_access, ...
                                         config.db_query, ...
                                         config.db_fields);
active_deployments = active_deployments([active_deployments.deployment_id] == 99);
if isempty(active_deployments)
  disp('No glider deployments available.');
  return
end

                                       
%% Process active deployments.
for deployment_idx = 1:numel(active_deployments)
  %% Set deployment field shortcut variables.
  deployment = active_deployments(deployment_idx);
  deployment_name = deployment.deployment_name;
  deployment_id = deployment.deployment_id;
  deployment_start = deployment.deployment_start;
  deployment_end = deployment.deployment_end;
  glider_name = deployment.glider_name;
  binary_dir = strfglider(config.local_paths.binary_path, deployment);
  cache_dir = strfglider(config.local_paths.cache_path, deployment);
  log_dir = strfglider(config.local_paths.log_path, deployment);
  ascii_dir = strfglider(config.local_paths.ascii_path, deployment);
  figure_dir = strfglider(config.local_paths.figure_path, deployment);
  ncl0_fullfile = strfglider(config.local_paths.netcdf_l0, deployment);
  ncl1_fullfile = strfglider(config.local_paths.netcdf_l1, deployment);
  ncl2_fullfile = strfglider(config.local_paths.netcdf_l2, deployment);
  
  
  %% Notify the processing of this deployment.
  disp(['Processing deployment ' num2str(deployment_id) ':']);
  disp(['  Glider name      : ' glider_name]);
  disp(['  Deployment name  : ' deployment_name]);
  disp(['  Deployment start : ' datestr(deployment_start)]);
  if isempty(deployment_end)
    disp(['  Deployment end   : ' 'undefined']);
  else
    disp(['  Deployment end   : ' datestr(deployment_end)]);
  end

    
  %% Download deployment glider files from station(s).
  % Check for new or updated deployment files in every dockserver.
  % Deployment start time must be truncated to days because the date of 
  % a binary file is deduced from its name only up to day precission.
  % Deployment end time may be undefined.
  download_start = datenum(datestr(deployment_start,'yyyy-mm-dd'),'yyyy-mm-dd');
  if isempty(deployment_end)
    download_end = now();
  else
    download_end = deployment_end;
  end
  new_xbds = cell(size(config.dockservers));
  new_logs = cell(size(config.dockservers));
  for dockserver_idx = 1:numel(config.dockservers)
    dockserver = config.dockservers(dockserver_idx);
    try
      [new_xbds{dockserver_idx}, new_logs{dockserver_idx}] = ...
        getDockserverFiles(dockserver, glider_name, binary_dir, log_dir, ...
                           'start', download_start, 'end', download_end, ...
                           'bin_name', config.slocum_options.bin_name_pattern, ...
                           'log_name', config.slocum_options.log_name_pattern);
    catch exception
      disp(['Error getting dockserver files from ' dockserver.host ':']);
      disp(getReport(exception, 'extended'));
    end
  end  
  new_xbds = [new_xbds{:}];
  new_logs = [new_logs{:}];
  
  
  %% Convert binary glider files to ascii human readable format.
  % For each downloaded binary file, convert it to ascii format in the ascii
  % directory and store the returned absolute path for use later.
  % Since some conversion may fail use a cell array of string cell arrays and
  % flatten it when finished, leaving only the succesfully created dbas.
  disp('Converting binary data files to ascii format...');
  new_dbas = cell(size(new_xbds));
  for xbd_idx = 1:numel(new_xbds)
    [~, xbd_name, xbd_ext] = fileparts(new_xbds{xbd_idx});
    xbd_name_ext = [xbd_name xbd_ext];
    dba_name_ext = regexprep(xbd_name_ext, ...
                             config.slocum_options.bin_name_pattern, ...
                             config.slocum_options.dba_name_replacement); 
    dba_fullfile = fullfile(ascii_dir, [xbd_name '_' xbd_ext(2:end) '.dba']);
    try
      new_dbas{xbd_idx} = { xbd2dba(new_xbds{xbd_idx}, dba_fullfile, ...
                                    'cache', cache_dir) };
    catch exception
      disp(['Error converting binary file ' [xbd_name xbd_ext] ':']);
      disp(getReport(exception, 'extended'));
      new_dbas{xbd_idx} = {};
    end
  end
  new_dbas = [new_dbas{:}];
  disp(['Binary files successfully converted: ' ...
        num2str(numel(new_dbas)) ' of ' num2str(numel(new_xbds)) '.']);
  
 
  %% Quit deployment processing if there is no new data.
  if isempty(new_dbas)
    disp('No new deployment data, skipping processing and product generation.');
    continue
  end
  
  
  %% Load data from ascii deployment glider files.
  % Load all files matching the desired pattern (not only the newly generated).
  % Flatten lists to discard unmatched files.
  ascii_dir_contents = dir(ascii_dir);
  dba_all_names = {ascii_dir_contents(~[ascii_dir_contents.isdir]).name};
  dba_nav_names = ...
    regexp(dba_all_names, config.slocum_options.dba_name_pattern_nav, 'match');
  dba_sci_names = ...
    regexp(dba_all_names, config.slocum_options.dba_name_pattern_sci, 'match');
  dba_nav_names = [dba_nav_names{:}];
  dba_sci_names = [dba_sci_names{:}];
  % Load data from individual ascii files.
  % Perform sensor filtering now to reduce memory usage.
  if isfield(config.slocum_options, 'dba_sensors')
    dba_sensor_args = {'sensors' config.slocum_options.dba_sensors};
  else
    dba_sensor_args = {};
  end
  % Load navigation files.
  dba_nav_files = cell(size(dba_nav_names));
  dba_nav_success = false(size(dba_nav_names));
  meta_nav = cell(size(dba_nav_names));
  data_nav = cell(size(dba_nav_names));
  for dba_nav_idx = 1:numel(dba_nav_names)
    try
     dba_nav_files{dba_nav_idx} = ...
       fullfile(ascii_dir, dba_nav_names{dba_nav_idx});
     [meta_nav{dba_nav_idx}, data_nav{dba_nav_idx}] = ...
       dba2mat(dba_nav_files{dba_nav_idx}, dba_sensor_args{:});
     dba_nav_success(dba_nav_idx) = true;
    catch exception
      disp(['Error loading ascii file ' dba_nav_files{dba_nav_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_nav = meta_nav(dba_nav_success);
  data_nav = data_nav(dba_nav_success);
  % Load science files.
  dba_sci_files = cell(size(dba_sci_names));
  dba_sci_success = false(size(dba_sci_names));
  meta_sci = cell(size(dba_sci_names));
  data_sci = cell(size(dba_sci_names));
  for dba_sci_idx = 1:numel(dba_sci_names)
    try
     dba_sci_files{dba_sci_idx} = ...
       fullfile(ascii_dir, dba_sci_names{dba_sci_idx});
     [meta_sci{dba_sci_idx}, data_sci{dba_sci_idx}] = ...
       dba2mat(dba_sci_files{dba_sci_idx}, dba_sensor_args{:});
     dba_sci_success(dba_sci_idx) = true;
    catch exception
      disp(['Error loading ascii file ' dba_sci_files{dba_sci_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_sci = meta_sci(dba_sci_success);
  data_sci = data_sci(dba_sci_success);
  % Combine data from each bay.
  if ~isempty(meta_nav)
    [meta_nav, data_nav] = ...
      dbacat(meta_nav, data_nav, config.slocum_options.dba_time_sensor_nav);
  end
  if ~isempty(meta_sci)
    [meta_sci, data_sci] = ...
      dbacat(meta_sci, data_sci, config.slocum_options.dba_time_sensor_sci);
  end
  % Merge data from both bays.
  [meta_raw, data_raw] = ...
    dbamerge(meta_nav, data_nav, meta_sci, data_sci, ...
             'format', 'array', dba_sensor_args{:});
  
  
  %% Convert binary glider files to human readable format.
  % 1 - convert binary data files to ascii
  % *Note: the parameter 'e' for extension needs to be specified
  % in order to merge files with new Science Data Logging feature
  if ~isdir(ascii_dir)
    [success, error_msg] = mkdir(ascii_dir);
    if ~success
      disp(['Error creating directory for ascii files ' ascii_dir ':']);
      disp(error_msg);
      disp('Deployment processing aborted.');
      continue
    end
  end
  downloaded_loaders = convertSlocumBinaries([],...
    's', binary_dir, ...
    'd', ascii_dir, ...
    'e', desired_extensions, ...
    'f', fullfile(glider_toolbox_dir, 'config', 'sensorfilter.txt'), ...
    'c', binary_dir);
  disp([num2str(length(downloaded_loaders), '%0.0f'), ' files converted.']);

    
  %% Load raw glider data (if there is something new).
  if isempty(downloaded_loaders)
    disp('No new deployment data to process, omitting this deployment...');
    continue
  end
  raw_data = loadTransectData(ascii_dir, [download_start download_end]);
  
  
  %% Generate L0 NetCDF file (raw data).
  raw_data_aux = struct();
  for f = setdiff(fieldnames(raw_data),{'data' 'source'})
    raw_data_aux.(f{:}) = raw_data.data(:,raw_data.(f{:}));
  end
  raw_meta = config.output_ncl0.var_meta;
  raw_dims = config.output_ncl0.dim_names;
  raw_atts = config.output_ncl0.global_atts; 
  try
    generateOutputNetCDFL0(ncl0_fullfile, raw_data_aux, raw_meta, ...
                           raw_dims, raw_atts, deployment);
  catch exception
    disp(['Error creating L0 (raw data) NetCDF file ' ncl0_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end;

  
  %% Create figure directory if needed.
  % Check it here because processing function produces debugging plots.
  if ~isdir(figure_dir)
    [success, error_msg] = mkdir(figure_dir);
    if ~success
      disp(['Error creating directory for deployment figures ' figure_dir ':']);
      disp(error_msg);
      continue
    end
  end

  
  %% Process raw glider data to get clean trajectory data.
  try
    processing_options.debugPlotPath = figure_dir;
    processed_data = processGliderData(raw_data, processing_options);
  catch exception
    disp('Error processing glider deployment data:');
    disp(getReport(exception, 'extended'));
    disp('Skipping storage, gridding and plotting...');
    continue
  end

  
  %% Generate L1 NetCDF file (processed data).
  field_renaming = {
    'navTime' 'time_nav'
    'sciTime' 'time_sci'
    'wptLat'  'waypoint_latitude'
    'wptLon'  'waypoint_longitude'
    'distanceOverGround' 'distance_over_ground'
    'continousDepth'     'continous_depth'
    'Tcor'               'temperature_corrected'
    'Ccor'               'conductivity_corrected'
    'salinity_corrected_TH'            'salinity_corrected_thermal' 
    'salinity_corrected_Tcor_TH'       'salinity_corrected_temperature_thermal'
    'salinity_corrected_Tcor_Ccor_TH'  'salinity_corrected_temperature_conductivity_thermal'
    'backscatter470' 'backscatter_470'
    'backscatter532' 'backscatter_532'
    'backscatter660' 'backscatter_660'
    'irradiance412nm' 'irradiance_412'
    'irradiance442nm' 'irradiance_442'
    'irradiance491nm' 'irradiance_491'
    'irradiance664nm' 'irradiance_664'
  };
  proc_data_aux = processed_data;
  for old_new_name = field_renaming'
    if isfield(proc_data_aux, old_new_name{1})
      [proc_data_aux.(old_new_name{2})] = proc_data_aux.(old_new_name{1});
      proc_data_aux = rmfield(proc_data_aux, old_new_name{1});
    end
  end
  proc_meta = config.output_ncl1.var_meta;
  proc_dims = config.output_ncl1.dim_names;
  proc_atts = config.output_ncl1.global_atts; 
  try
    generateOutputNetCDFL1(ncl1_fullfile, proc_data_aux, proc_meta, ...
                           proc_dims, proc_atts, deployment);
  catch exception
    disp(['Error creating L1 (processed data) NetCDF file ' ncl1_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end;
  
  
  %% Process glider trajectory data to vertically gridded data.
  try
    gridded_data = gridGliderData(processed_data);
  catch exception
    disp('Error processing glider deployment data:');
    disp(getReport(exception, 'extended'));
    continue
  end
  

  %% Generate L2 (gridded data) netcdf file.
  grid_data_aux = gridded_data.grids;
  for f = fieldnames(gridded_data.gridCoords)'
    grid_data_aux.(strrep(f{:},'Range','')) = gridded_data.gridCoords.(f{:});
  end
  grid_meta = config.output_ncl2.var_meta;
  grid_dims = config.output_ncl2.dim_names;
  grid_atts = config.output_ncl2.global_atts; 
  try
    generateOutputNetCDFL2(ncl2_fullfile, grid_data_aux, grid_meta, ...
                           grid_dims, grid_atts, deployment);
  catch exception
    disp(['Error creating L2 (gridded data) NetCDF file ' ncl2_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end

  
  %% Generate deployment figures.
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
                                          figure_dir, [glider_name, '_']);
    % Add URL base path to images
    for idx = 1:length(imgs_list)
      imgs_list(idx).path = fullfile(output_dirs.imageBaseURLPath, ...
                                     glider_name, deployment_name, ...
                                     imgs_list(idx).path);
    end
    json_name = fullfile(output_dirs.image_base_local_path, ...
                         [glider_name '.' deployment_name '.images.json']);
    writeJSON(imgs_list, json_name);
  catch exception
    disp('Error generating scientific figures:');
    disp(getReport(exception, 'extended'));
  end
  
end

