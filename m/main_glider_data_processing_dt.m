%MAIN_GLIDER_DATA_PROCESSING_DT  Run delayed time glider processing chain.
%
%  This script develops the full processing chain for delayed time glider data:
%    - Check for configured deployments to process in delayed mode.
%    - Convert deployment binary files to human readable format, if needed.
%    - Load data from all files in a single and consistent structure.
%    - Preprocess raw data applying simple unit conversions data without 
%      modifying it:
%      01. NMEA latitude and longitude to decimal degrees.
%    - Produce standarized product version of raw data (NetCDF level 0).
%    - Process raw data to obtain well referenced trajectory data with new 
%      derived measurements and corrections. The following steps are applied:
%      01. Select reference sensors for time and space coordinates.
%      02. Select extra navigation sensors: commanded waypoints, pitch, depth...
%      03. Select sensors of interest: CTD, oxygen, ocean color...
%      04. Identify transect boundaries at waypoint changes.
%      05. Identify cast boundaries from vertical direction changes.
%      06. General sensor processings: sensor lag correction, interpolation....
%      07. Process CTD data: pressure filtering, thermal lag correction...
%      08. Derive new measurements: depth, salinity, density, ...
%    - Produce standarized product version of trajectory data (NetCDF level 1).
%    - Interpolate trajectory data to obtain gridded data
%      (vertical instantaneous profiles).
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


%% Configure deployment data paths.
config.local_paths = configDTLocalPaths();


%% Configure NetCDF output.
config.output_ncl0 = configDTOutputNetCDFL0();
config.output_ncl1 = configDTOutputNetCDFL1();
config.output_ncl2 = configDTOutputNetCDFL2();


%% Set the path to the data: edit for mission processing.
%{
output_dirs.image_base_local_path = '/home/jbeltran/public_html/glider';
output_dirs.imageBaseURLPath    = 'http://www.socib.es/~jbeltran/glider/web';
%}


%% Configure processing options.
config.preprocessing_options = configPreprocessingOptions();
config.processing_options = configProcessingOptions();
% config.gridding_options = configGriddingOptions();


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.db_fields] = configDTDeploymentInfoQuery();


%% Configure Slocum file downloading and conversion, and Slocum data loading.
config.slocum_options = configDTSlocumFileOptions();


%% Get list of deployments to process from database.
disp('Querying information of glider deployments...');
deployment_list = ...
  getDBDeploymentInfo(config.db_access, config.db_query, config.db_fields);
if isempty(deployment_list)
  disp('Selected glider deployments are not available.');
  return
else
  disp(['Selected deployments found: ' num2str(numel(deployment_list)) '.']);
end

                                       
%% Process active deployments.
for deployment_idx = 1:numel(deployment_list)
  %% Set deployment field shortcut variables.
  disp(['Processing deployment ' num2str(deployment_idx) ' ...']);
  deployment = deployment_list(deployment_idx);
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
    disp(['  Deployment end       : ' 'undefined']);
  else
    disp(['  Deployment end       : ' datestr(deployment_end)]);
  end

    
  %% Convert binary glider files to ascii human readable format, if needed.
  % Check deployment files available in binary directory,
  % convert them to ascii format in the ascii directory,
  % and store the returned absolute path for use later.
  % Since some conversion may fail use a cell array of string cell arrays and
  % flatten it when finished, leaving only the succesfully created dbas.
  if config.slocum_options.format_conversion
    % Look for xbds in binary directory.
    disp('Converting new deployment binary files...');
    bin_dir_contents = dir(binary_dir);
    xbd_sel = ~[bin_dir_contents.isdir] ...
      & ~cellfun(@isempty, regexp({bin_dir_contents.name}, config.slocum_options.bin_name_pattern));
    xbd_names = {bin_dir_contents(xbd_sel).name};
    xbd_sizes = [bin_dir_contents(xbd_sel).bytes];
    disp(['Binary files found: ' num2str(numel(xbd_names)) ...
        ' (' num2str(sum(xbd_sizes)*2^-10) ' kB).']);
    new_dbas = cell(size(xbd_names));
    for xbd_idx = 1:numel(xbd_names)
      xbd_name_ext = xbd_names{xbd_idx};
      dba_name_ext = regexprep(xbd_name_ext, ...
                               config.slocum_options.bin_name_pattern, ...
                               config.slocum_options.dba_name_replacement);
      xbd_fullfile = fullfile(binary_dir, xbd_name_ext);
      dba_fullfile = fullfile(ascii_dir, dba_name_ext);
      try
        new_dbas{xbd_idx} = {xbd2dba(xbd_fullfile, dba_fullfile, 'cache', cache_dir)};
      catch exception
        disp(['Error converting binary file ' xbd_name_ext ':']);
        disp(getReport(exception, 'extended'));
        new_dbas{xbd_idx} = {};
      end
    end
    new_dbas = [new_dbas{:}];
    disp(['Binary files converted: ' ...
          num2str(numel(new_dbas)) ' of ' num2str(numel(xbd_names)) '.']);
  end
  
  
  %% Load data from ascii deployment glider files.
  disp('Loading raw deployment data from text files...');
  try
    load_start = deployment_start;
    if isempty(deployment_end)
      load_end = posixtime2utc(posixtime());
    else
      load_end = deployment_end;
    end
    [meta_raw, data_raw] = ...
      loadSlocumData(ascii_dir, ...
                     config.slocum_options.dba_name_pattern_nav, ...
                     config.slocum_options.dba_name_pattern_sci, ...
                     'timestamp_nav', config.slocum_options.dba_time_sensor_nav, ...
                     'timestamp_sci', config.slocum_options.dba_time_sensor_sci, ...
                     'sensors', config.slocum_options.dba_sensors, ...
                     'period', [load_start load_end], ...
                     'format', 'struct');
  catch exception
    disp('Error loading Slocum data:');
    disp(getReport(exception, 'extended'));
    disp(['Deployment ' num2str(deployment_id) ' processing aborted!']);
    continue
  end
  disp(['Slocum files loaded: ' num2str(numel(meta_raw.sources)) '.']);
  
  
  %% Quit deployment processing if there is no new data.
  if isempty(meta_raw.sources)
    disp('No deployment data, skipping data processing and product generation.');
    continue
  end
  
  
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
    data_processed = ...
      processGliderData(data_preprocessed, config.processing_options);
  catch exception
    disp('Error processing glider deployment data:');
    disp(getReport(exception, 'extended'));
    disp('Skipping storage, gridding and plotting...');
    continue
  end

  
  %% Generate L1 NetCDF file (processed data).
  proc_data = data_processed;
  proc_meta = config.output_ncl1.var_meta;
  proc_dims = config.output_ncl1.dim_names;
  proc_atts = config.output_ncl1.global_atts; 
  try
    output_ncl1 = generateOutputNetCDFL1(ncl1_fullfile, proc_data, proc_meta, ...
                           proc_dims, proc_atts, deployment);
    disp(['Output NetCDF L1 (processed data) generated: ' output_ncl1 '.']);
  catch exception
    disp(['Error generating NetCDF L1 (processed data) output ' ncl1_fullfile ':']);
    disp(getReport(exception, 'extended'));
  end;
  
  return
  
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
