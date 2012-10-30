%MAIN_GLIDER_DATA_PROCESSING_NRT  Run near real time glider processing chain.
%
%  This script develops the full processing chain for real time glider data:
%    - Check for active deployments from deployment information source.
%    - Download new or updated deployment raw data files.
%    - Convert downloaded files to human readable format if needed.
%    - Preprocess raw data applying simple unit conversions data without 
%      modifying it:
%      1. NMEA latitude and longitude to decimal degrees.
%    - Produce standarized product version of raw data (NetCDF level 0).
%    - Process raw data to obtain well referenced trajectory data with new 
%      derived measurements and corrections. The following steps are applied:
%      01. Select reference sensors for time and space coordinates.
%      02. Select extra navigation sensors: commanded waypoints, pitch, depth...
%      03. Select sensors of interest: CTD, oxygen, ocean color...
%      04. Identify transect boundaries at waypoint changes.
%      05. Identify cast boundaries from vertical direction changes.
%      06. General sensor processings: sensor lag correction, interpolation.
%      07. Process CTD data: pressure filtering, thermal lag correction...
%      08. Derive new measurements: depth, salinity, density, ...
%    - Produce standarized product version of trajectory data (NetCDF level 1).
%    - Interpolate trajectory data to obtain vertically gridded profile data.
%    - Produce standarized product version of gridded data (NetCDF level 2).
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
config.local_paths = configRTLocalPaths();


%% Configure NetCDF output.
config.output_ncl0 = configOutputNetCDFL0();
config.output_ncl1 = configOutputNetCDFL1();
config.output_ncl2 = configOutputNetCDFL2();


%% Set the path to the data: edit for mission processing.
output_dirs.image_base_local_path = '/home/jbeltran/public_html/glider';
output_dirs.imageBaseURLPath    = 'http://www.socib.es/~jbeltran/glider/web';


%% Configure preprocessing options.
config.preprocessing_options = configPreprocessingOptions();


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
%active_deployments = active_deployments([active_deployments.deployment_id] == 99);
if isempty(active_deployments)
  disp('No glider deployments available.');
  return
else
  disp(['Deployments found: ' num2str(numel(active_deployments)) '.']);
end

                                       
%% Process active deployments.
for deployment_idx = 1:numel(active_deployments)
  %% Set deployment field shortcut variables.
  disp(['Processing deployment ' num2str(deployment_idx) '...']);
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
  disp('Deployment information:')
  disp(['  Glider name          : ' glider_name]);
  disp(['  Deployment identifier: ' num2str(deployment_id)]);
  disp(['  Deployment name      : ' deployment_name]);
  disp(['  Deployment start     : ' datestr(deployment_start)]);
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
  disp('Downloading deployment new data...');
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
  disp(['Binary data files downloaded: '  num2str(numel(new_xbds)) '.']);
  disp(['Surface log files downloaded: '  num2str(numel(new_logs)) '.']);
  
  
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
    dba_fullfile = fullfile(ascii_dir, dba_name_ext);
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
  disp(['Binary files converted: ' ...
        num2str(numel(new_dbas)) ' of ' num2str(numel(new_xbds)) '.']);


  %% Quit deployment processing if there is no new data.
  if isempty(new_dbas)
    disp('No new deployment data, skipping processing and product generation.');
    continue
  end
  
  
  %% Load data from ascii deployment glider files.
  % Shipped function ETIME ignores leap seconds, day saving time and time zones.
  % However, this error should not make a significative difference.
  disp('Loading raw deployment data from text files...');
  try
    load_start_epoch = etime(datevec(deployment_start), [1970 1 1 0 0 0.0]);
    if isempty(deployment_end)
      load_end_epoch = etime(datevec(now()), [1970 1 1 0 0 0.0]);
    else
      load_end_epoch = etime(datevec(deployment_end), [1970 1 1 0 0 0.0]);
    end
    [meta_raw, data_raw] = ...
      loadSlocumData(ascii_dir, ...
                     config.slocum_options.dba_name_pattern_nav, ...
                     config.slocum_options.dba_name_pattern_sci, ...
                     'timestamp_nav', config.slocum_options.dba_time_sensor_nav, ...
                     'timestamp_sci', config.slocum_options.dba_time_sensor_sci, ...
                     'sensors', config.slocum_options.dba_sensors, ...
                     'period', [load_start_epoch load_end_epoch], ...
                     'format', 'struct');
  catch exception
    disp('Error loading Slocum data:');
    disp(getReport(exception, 'extended'));
    disp(['Deployment ' num2str(deployment_id) ' processing aborted!']);
    continue
  end
  disp(['Slocum files loaded: ' num2str(numel(meta_raw.sources)) '.']);
  
  
  %% Add source files to deployment structure.
  deployment.source_files = sprintf('%s\n', meta_raw.headers.filename_label);
    
  
  %% Preprocess raw glider data.
  disp('Preprocessing raw data...');
  try
    data_preprocessed = ...
      preprocessGliderData(data_raw, config.preprocessing_options);
  catch exception
    disp('Error preprocessing raw data:');
    disp(getReport(exception, 'extended'));
    disp(['Deployment ' num2str(deployment_id) ' processing aborted!']);
    continue
  end
  
  
  %% Generate L0 NetCDF file (raw data).
  disp('Generating NetCDF L0 output...');
  output_ncl0 = [];
  try
    output_ncl0 = generateOutputNetCDFL0(ncl0_fullfile, data_raw, ...
                                         config.output_ncl0.var_meta, ...
                                         config.output_ncl0.dim_names, ...
                                         config.output_ncl0.global_atts, ...
                                         deployment);
    disp(['Output NetCDF L0 (raw data) generated: ' output_ncl0 '.']);
  catch exception
    disp(['Error generating NetCDF L0 (preprocessed data) output ' ncl0_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end;

  
  %% Process preprocessed glider data.
  disp('Processing glider data...');
  try
    processing_options.debugPlotPath = figure_dir;
    data_processed = processGliderData(data_preprocessed);
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
    disp(['Output NetCDF L1 (processed data) generated: ' output_ncl1 '.']);
  catch exception
    disp(['Error generating NetCDF L1 (processed data) output ' ncl1_fullfile ':']);
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
    disp(['Output NetCDF L2 (gridded data) generated: ' output_ncl2 '.']);
  catch exception
    disp(['Error generating NetCDF L2 (gridded data) output ' ncl2_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end;


  
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

