%MAIN_GLIDER_DATA_PROCESSING_DT  Run delayed time glider processing chain.
%
%  Description:
%    This script develops the processing chain for delayed time glider data:
%      - Check for configured deployments to process in delayed mode.
%      - Convert deployment binary files to human readable format, if needed.
%      - Load data from all files in a single and consistent structure.
%      - Generate standarized product version of raw data (NetCDF level 0).
%      - Preprocess raw data applying simple unit conversions and factory
%        calibrations without modifying their nominal value:
%          -- Select reference sensors for time and space coordinates.
%             Perform unit conversions if necessary.
%          -- Select extra navigation sensors: waypoints, pitch, depth...
%             Perform unit conversions if necessary.
%          -- Select sensors of interest: CTD, oxygen, ocean color...
%             Perform unit conversions and factory calibrations if necessary.
%      - Process preprocessed data to obtain well referenced trajectory data
%        with new derived measurements and corrections:
%          -- Fill missing values of time and space reference sensors.
%          -- Fill missing values of other navigation sensors.
%          -- Identify transect boundaries at waypoint changes.
%          -- Identify cast boundaries from vertical direction changes.
%          -- Apply generic sensor processings: sensor lag correction... 
%          -- Process CTD data: pressure filtering, thermal lag correction...
%          -- Derive new measurements: depth, salinity, density...
%      - Generate standarized product version of trajectory data (NetCDF 
%        level 1).
%      - Generate descriptive figures from trajectory data.
%      - Interpolate/bin trajectory data to obtain gridded data (vertical 
%        instantaneous profiles of already processed data).
%      - Generate standarized product version of gridded data (NetCDF level 2).
%      - Generate descriptive figures from gridded data.
%      - Copy generated data products to its public location, if needed.
%      - Copy generated figures to its public location and generate figure
%        information service file, if needed.
%
%    Deployment information is queried from a data base by GETDEPLOYMENTINFODB.
%    Data base access parameters may be configured in CONFIGDBACCESS.
%    Selected deployments and their metadata fields may be configured in 
%    CONFIGDTDEPLOYMENTINFOQUERYDB.
%
%    For each deployment, the messages produced during each processing step are
%    recorded to a log file. This recording is enabled just before the start of
%    the processing of the deployment, and it is turned off when the processing
%    finishes, with the function DIARY.
%
%    Input deployment raw data is loaded from a directory of raw text files
%    with LOADSLOCUMDATA, LOADSEAGLIDERDATA or LOADSEAEXPLORERDATA. 
%    For Slocum gliders a directory of raw  binary files may also
%    be specified, and automatic conversion to text file format may be enabled.
%    The conversion is performed by the function XBD2DBA, which is called
%    for each binary file in the specified binary directory
%    with a renaming pattern to specify the name of the resulting text file,
%    and performs a system call to program 'dbd2asc' by WRC.
%    The path to the 'dbd2asc' program may be configured in CONFIGWRCPROGRAMS.
%    Input file conversion and data loading options may be configured in 
%    CONFIGDTFILEOPTIONSSLOCUM, CONFIGDTFILEOPTIONSSEAGLIDER, and
%    CONFIGDTFILEOPTIONSSEAEXPLORER.
%
%    Output products, figures and processing logs are generated to local paths.
%    Input and output paths may be configured using expressions built upon
%    deployment field value replacements in CONFIGDTPATHSLOCAL.
%
%    Raw data is preprocessed to apply some simple unit conversions with the
%    function PREPROCESSGLIDERDATA. The preprocessing options and its 
%    parameters may be configured in CONFIGDATAPREPROCESSINGSLOCUM,
%    CONFIGDATAPREPROCESSINGSEAGLIDER and CONFIGDATAPREPROCESSINGSEAEXPLORER.
%
%    Preprocessed data is processed with PROCESSGLIDERDATA to obtain properly 
%    referenced data with a trajectory data structure. The desired processing 
%    actions (interpolations, filterings, corrections and derivations) 
%    and its parameters may be configured in CONFIGDATAPROCESSINGSLOCUMG1, 
%    CONFIGDATAPROCESSINGSLOCUMG2, CONFIGDATAPROCESSINGSEAGLIDER and
%    CONFIGDATAPROCESSINGSEAEXPLORER.
%
%    Processed data is interpolated/binned with GRIDGLIDERDATA to obtain a data 
%    set with the structure of a trajectory of instantaneous vertical profiles 
%    sampled at a common set of regular depth levels. The desired gridding 
%    parameters may be configured in CONFIGDATAGRIDDING.
%
%    Standard products in NetCDF format are generated from raw data,
%    processed data and gridded data with GENERATEOUTPUTNETCDF.
%    Raw data is stored in NetCDF format as level 0 output product.
%    This file mimics the appearance of the raw data text files, but gathering
%    all useful data in a single place. Hence, the structure of the resulting
%    NetCDF file varies with each type of glider, and may be configured
%    in CONFIGDTOUTPUTNETCDFL0SLOCUM, CONFIGDTOUTPUTNETCDFL0SEAGLIDER and
%    CONFIGDTOUTPUTNETCDFL0SEAEXPLORER. Processed and gridded data sets are
%    stored in NetCDF format as level 1 and level 2 output products
%    respectively. The structure of these files does not depend on the type
%    of glider the data comes from, and may be configured in
%    CONFIGDTOUTPUNETCDFL1 and CONFIGDTOUTPUTNETCDFL2 respectively.
%
%    Figures describing the collected glider data may be generated from 
%    processed data and from gridded data. Figures are generated by 
%    GENERATEGLIDERFIGURES, and may be configured in CONFIGFIGURES.
%    Available plots are: scatter plots of measurements on vertical transect 
%    sections, temperature-salinity diagrams, trajectory and current maps,
%    and profile statistics plots. Other plot functions may be used,
%    provided that their call syntax is compatible with GENERATEGLIDERFIGURES.
%
%    Selected data output products and figures may be copied to a public 
%    location for distribution purposes. For figures, a service file describing
%    the available figures and their public location may also be generated.
%    This file is generated by function SAVEJSON with the figure information
%    returned by GENERATEGLIDERFIGURES updated with the new public location.
%    Public products and figures to copy and their locations may be configured
%    in CONFIGDTPATHSPUBLIC.
%
%  See also:
%    CONFIGWRCPROGRAMS
%    CONFIGDBACCESS
%    CONFIGDTDEPLOYMENTINFOQUERYDB
%    CONFIGDTPATHSLOCAL
%    CONFIGDTFILEOPTIONSSLOCUM
%    CONFIGDTFILEOPTIONSSEAGLIDER
%    CONFIGDTFILEOPTIONSSEAEXPLORER
%    CONFIGDATAPREPROCESSINGSLOCUM
%    CONFIGDATAPREPROCESSINGSEAGLIDER
%    CONFIGDATAPREPROCESSINGSEAEXPLORER
%    CONFIGDATAPROCESSINGSLOCUMG1
%    CONFIGDATAPROCESSINGSLOCUMG2
%    CONFIGDATAPROCESSINGSEAGLIDER
%    CONFIGDATAPROCESSINGSEAEXPLORER
%    CONFIGDATAGRIDDING
%    CONFIGDTOUTPUTNETCDFL0SLOCUM
%    CONFIGDTOUTPUTNETCDFL0SEAGLIDER
%    CONFIGDTOUTPUTNETCDFL0SEAEXPLORER
%    CONFIGDTOUTPUTNETCDFL1
%    CONFIGDTOUTPUTNETCDFL2
%    CONFIGFIGURES
%    GETDEPLOYMENTINFODB
%    LOADSLOCUMDATA
%    PREPROCESSGLIDERDATA
%    PROCESSGLIDERDATA
%    GRIDGLIDERDATA
%    GENERATEOUTPUTNETCDF
%    GENERATEFIGURES
%    DIARY
%    STRFSTRUCT
%    XBD2DBA
%    SAVEJSON
%
%  Notes:
%    This script is based on the previous work by Tomeu Garau. He is the true
%    glider man.
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.


%% Configure toolbox and configuration file path.
glider_toolbox_dir = configGliderToolboxPath();
glider_toolbox_ver = configGliderToolboxVersion();


%% Configure external programs paths.
config.wrcprogs = configWRCPrograms();


%% Configure deployment data paths.
config.paths_public = configDTPathsPublic();
config.paths_local = configDTPathsLocal();


%% Configure figure outputs.
[config.figures_processed, config.figures_gridded] = configFigures();


%% Configure NetCDF outputs.
config.output_netcdf_l0_slocum = configDTOutputNetCDFL0Slocum();
config.output_netcdf_l0_seaglider = configDTOutputNetCDFL0Seaglider();
config.output_netcdf_l0_seaexplorer = configDTOutputNetCDFL0SeaExplorer();
config.output_netcdf_l1 = configDTOutputNetCDFL1();
config.output_netcdf_l2 = configDTOutputNetCDFL2();


%% Configure processing options.
config.preprocessing_options_slocum = configDataPreprocessingSlocum();
config.preprocessing_options_seaglider = configDataPreprocessingSeaglider();
config.preprocessing_options_seaexplorer = configDataPreprocessingSeaExplorer();
config.processing_options_slocum_g1 = configDataProcessingSlocumG1();
config.processing_options_slocum_g2 = configDataProcessingSlocumG2();
config.processing_options_seaglider = configDataProcessingSeaglider();
config.processing_options_seaexplorer = configDataProcessingSeaExplorer();
config.gridding_options = configDataGridding();


%% Configure file download and conversion and data loading.
config.file_options_slocum = configDTFileOptionsSlocum();
config.file_options_seaglider = configDTFileOptionsSeaglider();
config.file_options_seaexplorer = configDTFileOptionsSeaExplorer();


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.db_fields] = configDTDeploymentInfoQueryDB();


%% Get list of deployments to process from database.
disp('Querying information of glider deployments...');
deployment_list = getDeploymentInfoDB( ...
  config.db_query, config.db_access.name, ...
  'user', config.db_access.user, 'pass', config.db_access.pass, ...
  'server', config.db_access.server, 'driver', config.db_access.driver, ...
  'fields', config.db_fields);
if isempty(deployment_list)
  disp('Selected glider deployments are not available.');
  return
else
  disp(['Selected deployments found: ' num2str(numel(deployment_list)) '.']);
end


%% Process active deployments.
for deployment_idx = 1:numel(deployment_list)
  %% Set deployment field shortcut variables and initialize other ones.
  % Initialization of big data variables may reduce out of memory problems,
  % provided memory is properly freed and not fragmented.
  disp(['Processing deployment ' num2str(deployment_idx) '...']);
  deployment = deployment_list(deployment_idx);
  processing_log = strfstruct(config.paths_local.processing_log, deployment);
  binary_dir = strfstruct(config.paths_local.binary_path, deployment);
  cache_dir = strfstruct(config.paths_local.cache_path, deployment);
  log_dir = strfstruct(config.paths_local.log_path, deployment);
  ascii_dir = strfstruct(config.paths_local.ascii_path, deployment);
  figure_dir = strfstruct(config.paths_local.figure_path, deployment);
  netcdf_l0_file = strfstruct(config.paths_local.netcdf_l0, deployment);
  netcdf_l1_file = strfstruct(config.paths_local.netcdf_l1, deployment);
  netcdf_l2_file = strfstruct(config.paths_local.netcdf_l2, deployment);
  source_files = {};
  meta_raw = struct();
  data_raw = struct();
  meta_preprocessed = struct();
  data_preprocessed = struct();
  meta_processed = struct();
  data_processed = struct();
  meta_gridded = struct();
  data_gridded = struct();
  outputs = struct();
  figures = struct();
  deployment_name  = deployment.deployment_name;
  deployment_id = deployment.deployment_id;
  deployment_start = deployment.deployment_start;
  deployment_end = deployment.deployment_end;
  glider_name = deployment.glider_name;
  glider_model = deployment.glider_model;
  glider_serial = deployment.glider_serial;
  glider_type = '';
  if ~isempty(regexpi(glider_model, '.*slocum.*g1.*', 'match', 'once'))
    glider_type = 'slocum_g1';
  elseif ~isempty(regexpi(glider_model, '.*slocum.*g2.*', 'match', 'once'))
    glider_type = 'slocum_g2';
  elseif ~isempty(regexpi(glider_model, '.*seaglider.*', 'match', 'once'))
    glider_type = 'seaglider';
  elseif ~isempty(regexpi(glider_model, '.*seaexplorer.*', 'match', 'once'))
      glider_type = 'seaexplorer';
  end
  % Options depending on the type of glider:
  switch glider_type
    case 'slocum_g1'
      file_options = config.file_options_slocum;
      preprocessing_options = config.preprocessing_options_slocum;
      processing_options = config.processing_options_slocum_g1;
      netcdf_l0_options = config.output_netcdf_l0_slocum;
    case 'slocum_g2'
      file_options = config.file_options_slocum;
      preprocessing_options = config.preprocessing_options_slocum;
      processing_options = config.processing_options_slocum_g2;
      netcdf_l0_options = config.output_netcdf_l0_slocum;
    case 'seaglider'
      file_options = config.file_options_seaglider;
      preprocessing_options = config.preprocessing_options_seaglider;
      processing_options = config.processing_options_seaglider;
      netcdf_l0_options = config.output_netcdf_l0_seaglider;
    case 'seaexplorer' 
      file_options = config.file_options_seaexplorer;
      preprocessing_options = config.preprocessing_options_seaexplorer;
      processing_options = config.processing_options_seaexplorer;
      netcdf_l0_options = config.output_netcdf_l0_seaexplorer;
  end
  if isfield(deployment, 'calibrations')
    preprocessing_options.calibration_parameter_list = deployment.calibrations;
  end
  gridding_options = config.gridding_options;
  netcdf_l1_options = config.output_netcdf_l1;
  netcdf_l2_options = config.output_netcdf_l2;
  figproc_options = config.figures_processed;
  figgrid_options = config.figures_gridded;


  %% Start deployment processing logging.
  % DIARY will fail if log file base directory does not exist.
  % Create the base directory first, if needed.
  % This is an ugly hack (the best known way) to check if the directory exists.
  [processing_log_dir, ~, ~] = fileparts(processing_log);  
  [status, attrout] = fileattrib(processing_log_dir);
  if ~status 
    [status, message] = mkdir(processing_log_dir);
  elseif ~attrout.directory
    status = false;
    message = 'not a directory';
  end
  % Enable log only if directory was already there or has been created properly.
  if status
    try
      diary(processing_log);
      diary('on');
    catch exception
      disp(['Error enabling processing log diary ' processing_log ':']);
      disp(getReport(exception, 'extended'));
    end
  else
    disp(['Error creating processing log directory ' processing_log_dir ':']);
    disp(message);
  end
  disp(['Deployment processing start time: ' ...
        datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);


  %% Report toolbox version:    
  disp(['Toolbox version: ' glider_toolbox_ver]);


  %% Report deployment information.
  disp('Deployment information:')
  disp(['  Glider name          : ' glider_name]);
  disp(['  Glider model         : ' glider_model]);
  disp(['  Glider serial        : ' glider_serial]);
  disp(['  Deployment identifier: ' num2str(deployment_id)]);
  disp(['  Deployment name      : ' deployment_name]);
  disp(['  Deployment start     : ' datestr(deployment_start)]);
  if isnan(deployment_end)
    disp(['  Deployment end       : ' 'undefined']);
  else
    disp(['  Deployment end       : ' datestr(deployment_end)]);
  end


  %% Convert binary glider files to ascii human readable format, if needed.
  % Check deployment files available in binary directory,
  % convert them to ascii format in the ascii directory,
  % and store the returned absolute path for later use.
  % Since some conversion may fail use a cell array of string cell arrays and
  % flatten it when finished, leaving only the succesfully created dbas.
  % Give a second try to failing files, because they might have failed due to 
  % a missing cache file generated later.
  switch glider_type
    case {'slocum_g1' 'slocum_g2'}
      if file_options.format_conversion
        % Look for xbds in binary directory.
        disp('Converting binary data files to ascii format...');
        bin_dir_contents = dir(binary_dir);
        xbd_select = ~[bin_dir_contents.isdir] ...
          & ~cellfun(@isempty, regexp({bin_dir_contents.name}, file_options.xbd_name_pattern));
        xbd_names = {bin_dir_contents(xbd_select).name};
        xbd_sizes = [bin_dir_contents(xbd_select).bytes];
        disp(['Binary files found: ' num2str(numel(xbd_names)) ...
             ' (' num2str(sum(xbd_sizes)*2^-10) ' kB).']);
        new_files = cell(size(xbd_names));
        for conversion_retry = 1:2
          for xbd_idx = 1:numel(xbd_names)
            if isempty(new_files{xbd_idx})
              xbd_name_ext = xbd_names{xbd_idx};
              dba_name_ext = regexprep(xbd_name_ext, ...
                                       file_options.xbd_name_pattern, ...
                                       file_options.dba_name_replace);
              xbd_fullfile = fullfile(binary_dir, xbd_name_ext);
              dba_fullfile = fullfile(ascii_dir, dba_name_ext);
              try
                new_files{xbd_idx} = ...
                  {xbd2dba(xbd_fullfile, dba_fullfile, 'cache', cache_dir, ...
                           'cmdname', config.wrcprogs.dbd2asc)};
              catch exception
                new_files{xbd_idx} = {};
                if conversion_retry == 2
                  disp(['Error converting binary file ' xbd_name_ext ':']);
                  disp(getReport(exception, 'extended'));
                end
              end
            end
          end
        end
        new_files = [new_files{:}];
        disp(['Binary files converted: ' ...
              num2str(numel(new_files)) ' of ' num2str(numel(xbd_names)) '.']);
      end
    otherwise
  end


  %% Load data from ascii deployment glider files.
  disp('Loading raw deployment data from text files...');
  load_start = utc2posixtime(deployment_start);
  load_final = posixtime();
  if ~isnan(deployment_end)
    load_final = utc2posixtime(deployment_end);
  end
  try
    switch glider_type
      case {'slocum_g1' 'slocum_g2'}
        [meta_raw, data_raw] = ...
          loadSlocumData(ascii_dir, ...
                         file_options.dba_name_pattern_nav, ...
                         file_options.dba_name_pattern_sci, ...
                         'timenav', file_options.dba_time_sensor_nav, ...
                         'timesci', file_options.dba_time_sensor_sci, ...
                         'sensors', file_options.dba_sensors, ...
                         'period', [load_start load_final], ...
                         'format', 'struct');
        source_files = {meta_raw.headers.filename_label};
      case 'seaglider'
        [meta_raw, data_raw] = ...
          loadSeagliderData(ascii_dir, ...
                            file_options.log_name_pattern, ...
                            file_options.eng_name_pattern, ...
                            'columns', file_options.eng_columns, ...
                            'params' , file_options.log_params, ...
                            'period', [load_start load_final], ...
                            'format', 'merged');
        source_files = meta_raw.sources;
      case {'seaexplorer'}
        [meta_raw, data_raw] = ...
          loadSeaExplorerData(ascii_dir, ...
                              file_options.gli_name_pattern, ...
                              file_options.pld_name_pattern, ...
                              'timegli', file_options.gli_time, ...
                              'timepld', file_options.pld_time, ...
                              'format', 'struct');
        source_files = meta_raw.sources;
      otherwise
        warning('glider_toolbox:main_glider_data_processing_dt:InvalidGliderType', ...
                'Unknown glider model: %s.', glider_model);
    end
  catch exception
    disp('Error loading raw data:');
    disp(getReport(exception, 'extended'));
  end


  %% Add source files to deployment structure if loading succeeded.
  if isempty(source_files)
    disp('No deployment data, processing and product generation will be skipped.');
  else
    disp(['Files loaded in deployment period: ' num2str(numel(source_files)) '.']);
    deployment.source_files = sprintf('%s\n', source_files{:});
  end


  %% Generate L0 NetCDF file (raw/preprocessed data), if needed and possible.
  if ~isempty(fieldnames(data_raw)) && ~isempty(netcdf_l0_file)
    disp('Generating NetCDF L0 output...');
    try
      switch glider_type
        case {'slocum_g1' 'slocum_g2'}
          outputs.netcdf_l0 = generateOutputNetCDF( ...
            netcdf_l0_file, data_raw, meta_raw, deployment, ...
            netcdf_l0_options.variables, ...
            netcdf_l0_options.dimensions, ...
            netcdf_l0_options.attributes, ...
            'time', {'m_present_time' 'sci_m_present_time'}, ...
            'position', {'m_gps_lon' 'm_gps_lat'; 'm_lon' 'm_lat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'m_depth' 'sci_water_pressure'}, ...
            'vertical_conversion', {[]        @(z)(z * 10)}, ...
            'vertical_positive',   {'down'} );
        case 'seaglider'
          outputs.netcdf_l0 = generateOutputNetCDF( ...
            netcdf_l0_file, data_raw, meta_raw, deployment, ...
            netcdf_l0_options.variables, ...
            netcdf_l0_options.dimensions, ...
            netcdf_l0_options.attributes, ...
            'time', {'elaps_t'}, ...
            'time_conversion', @(t)(t + meta_raw.start_secs), ... 
            'position', {'GPSFIX_fixlon' 'GPSFIX_fixlat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'depth'}, ...
            'vertical_conversion', {@(z)(z * 10)}, ... 
            'vertical_positive',   {'down'} );
        case {'seaexplorer'}
          outputs.netcdf_l0 = generateOutputNetCDF( ...
              netcdf_l0_file, data_raw, meta_raw, deployment, ...
              netcdf_l0_options.variables, ...
              netcdf_l0_options.dimensions, ...
              netcdf_l0_options.attributes, ...
              'time', {'Timestamp' 'PLD_REALTIMECLOCK'}, ...
              'position', {'NAV_LONGITUDE' 'NAV_LATITUDE'; 'Lon' 'Lat'}, ...
              'position_conversion', @nmea2deg, ...
              'vertical',            {'Depth' 'SBD_PRESSURE'}, ...
              'vertical_conversion', {[]        @(z)(z * 10)}, ...
              'vertical_positive',   {'down'} );      
      end
      disp(['Output NetCDF L0 (raw data) generated: ' outputs.netcdf_l0 '.']);
    catch exception
      disp(['Error generating NetCDF L0 (raw data) output ' netcdf_l0_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Preprocess raw glider data.
  if ~isempty(fieldnames(data_raw))
    disp('Preprocessing raw data...');
    try
      switch glider_type 
        case 'seaglider'
          seaglider_time_sensor_select = ...
            strcmp('elaps_t', {preprocessing_options.time_list.time});
          preprocessing_options.time_list(seaglider_time_sensor_select).conversion = ...
            @(t)(t +  meta_raw.start_secs);
      end
      [data_preprocessed, meta_preprocessed] = ...
        preprocessGliderData(data_raw, meta_raw, preprocessing_options);
    catch exception
      disp('Error preprocessing glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Process preprocessed glider data.
  if ~isempty(fieldnames(data_preprocessed))
    disp('Processing glider data...');
    try
      [data_processed, meta_processed] = ...
        processGliderData(data_preprocessed, meta_preprocessed, processing_options);
    catch exception
      disp('Error processing glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate L1 NetCDF file (processed data), if needed and possible.
  if ~isempty(fieldnames(data_processed)) && ~isempty(netcdf_l1_file)
    disp('Generating NetCDF L1 output...');
    try
      outputs.netcdf_l1 = generateOutputNetCDF( ...
        netcdf_l1_file, data_processed, meta_processed, deployment, ...
        netcdf_l1_options.variables, ...
        netcdf_l1_options.dimensions, ...
        netcdf_l1_options.attributes);
      disp(['Output NetCDF L1 (processed data) generated: ' ...
            outputs.netcdf_l1 '.']);
    catch exception
      disp(['Error generating NetCDF L1 (processed data) output ' ...
            netcdf_l1_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate processed data figures.
  if ~isempty(fieldnames(data_processed)) && ~isempty(figure_dir)
    disp('Generating figures from processed data...');
    try
      figures.figproc = generateGliderFigures( ...
        data_processed, figproc_options, ...
        'date', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00'), ...
        'dirname', figure_dir);
    catch exception
      disp('Error generating processed data figures:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Grid processed glider data.
  if ~isempty(fieldnames(data_processed))
    disp('Gridding glider data...');
    try
      [data_gridded, meta_gridded] = ...
        gridGliderData(data_processed, meta_processed, gridding_options);
    catch exception
      disp('Error gridding glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate L2 (gridded data) netcdf file, if needed and possible.
  if ~isempty(fieldnames(data_gridded)) && ~isempty(netcdf_l2_file)
    disp('Generating NetCDF L2 output...');
    try
      outputs.netcdf_l2 = generateOutputNetCDF( ...
        netcdf_l2_file, data_gridded, meta_gridded, deployment, ...
        netcdf_l2_options.variables, ...
        netcdf_l2_options.dimensions, ...
        netcdf_l2_options.attributes);
      disp(['Output NetCDF L2 (gridded data) generated: ' ...
            outputs.netcdf_l2 '.']);
    catch exception
      disp(['Error generating NetCDF L2 (gridded data) output ' ...
            netcdf_l2_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate gridded data figures.
  if ~isempty(fieldnames(data_gridded)) && ~isempty(figure_dir)
    disp('Generating figures from gridded data...');
    try
      figures.figgrid = generateGliderFigures( ...
        data_gridded, figgrid_options, ...
        'date', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00'), ...
        'dirname', figure_dir);
    catch exception
      disp('Error generating gridded data figures:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Copy selected products to corresponding public location, if needed.
  if ~isempty(fieldnames(outputs))
    disp('Copying public outputs...');
    output_name_list = fieldnames(outputs);
    for output_name_idx = 1:numel(output_name_list)
      output_name = output_name_list{output_name_idx};
      if isfield(config.paths_public, output_name) ...
           && ~isempty(config.paths_public.(output_name))
        output_local_file = outputs.(output_name);
        output_public_file = ...
          strfstruct(config.paths_public.(output_name), deployment);
        output_public_dir = fileparts(output_public_file);
        [status, attrout] = fileattrib(output_public_dir);
        if ~status
          [status, message] = mkdir(output_public_dir);
        elseif ~attrout.directory
          status = false;
          message = 'not a directory';
        end
        if status
          [success, message] = copyfile(output_local_file, output_public_file);
          if success
            disp(['Public output ' output_name ' succesfully copied: ' ...
                  output_public_file '.']);
          else
            disp(['Error creating public copy of deployment product ' ...
                  output_name ': ' output_public_file '.']);
            disp(message);
          end
        else
          disp(['Error creating public output directory ' ...
                output_public_dir ':']);
          disp(message);
        end
      end
    end
  end


  %% Copy selected figures to its public location, if needed.
  % Copy all generated figures or only the ones in the include list (if any) 
  % excluding the ones in the exclude list. 
  if ~isempty(fieldnames(figures)) ...
      && isfield(config.paths_public, 'figure_dir') ...
      && ~isempty(config.paths_public.figure_dir)
    disp('Copying public figures...');
    public_figure_baseurl = ...
      strfstruct(config.paths_public.figure_url, deployment);
    public_figure_dir = ...
      strfstruct(config.paths_public.figure_dir, deployment);
    public_figure_include_all = true;
    public_figure_exclude_none = true;
    public_figure_include_list = [];
    public_figure_exclude_list = [];
    if isfield(config.paths_public, 'figure_include')
      public_figure_include_all = false;
      public_figure_include_list = config.paths_public.figure_include;
    end
    if isfield(config.paths_public, 'figure_exclude')
      public_figure_exclude_none = false;
      public_figure_exclude_list = config.paths_public.figure_exclude;
    end
    public_figures = struct();
    public_figures_local = struct();
    figure_output_name_list = fieldnames(figures);
    for figure_output_name_idx = 1:numel(figure_output_name_list)
      figure_output_name = figure_output_name_list{figure_output_name_idx};
      figure_output = figures.(figure_output_name);
      figure_name_list = fieldnames(figure_output);
      for figure_name_idx = 1:numel(figure_name_list)
        figure_name = figure_name_list{figure_name_idx};
        if (public_figure_include_all ...
            || ismember(figure_name, public_figure_include_list)) ...
            && (public_figure_exclude_none ...
            || ~ismember(figure_name, public_figure_exclude_list))
          if isfield(public_figures_local, figure_name)
            disp(['Warning: figure ' figure_name ' appears to be duplicated.']);
          else
            public_figures_local.(figure_name) = figure_output.(figure_name);
          end
        end
      end
    end
    public_figure_name_list = fieldnames(public_figures_local);
    if ~isempty(public_figure_name_list)
      [status, attrout] = fileattrib(public_figure_dir);
      if ~status
        [status, message] = mkdir(public_figure_dir);
      elseif ~attrout.directory
        status = false;
        message = 'not a directory';
      end
      if status
        for public_figure_name_idx = 1:numel(public_figure_name_list)
          public_figure_name = public_figure_name_list{public_figure_name_idx};
          figure_local = public_figures_local.(public_figure_name);
          figure_public = figure_local;
          figure_public.url = ...
            [public_figure_baseurl '/' ...
             figure_public.filename '.' figure_public.format];
          figure_public.dirname = public_figure_dir;
          figure_public.fullfile = ...
            fullfile(figure_public.dirname, ...
                     [figure_public.filename '.' figure_public.format]);
          [success, message] = ...
            copyfile(figure_local.fullfile, figure_public.fullfile);
          if success
            public_figures.(public_figure_name) = figure_public;
            disp(['Public figure ' public_figure_name ' succesfully copied.']);
          else
            disp(['Error creating public copy of figure ' ...
                  public_figure_name ': ' figure_public.fullfile '.']);
            disp(message);
          end
        end
      else
        disp(['Error creating public figure directory ' public_figure_dir ':']);
        disp(message);
      end
    end
    % Write the figure information to the JSON service file.
    if isfield(config.paths_public, 'figure_info') ...
        && ~isempty(config.paths_public.figure_info)
      disp('Generating figure information service file...');
      public_figure_info_file = ...
        strfstruct(config.paths_public.figure_info, deployment);
      try
        savejson(public_figures, public_figure_info_file);
        disp(['Figure information service file successfully generated: ' ...
              public_figure_info_file]);
      catch exception
        disp(['Error creating figure information service file ' ...
              public_figure_info_file ':']);
        disp(message);
      end
    end
  end


  %% Stop deployment processing logging.
  disp(['Deployment processing end time: ' ...
        datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);
  diary('off');

end
