function [outputs, meta_raw, data_raw] = module_ascii_to_l0(ascii_dir, netcdf_l0_file, deployment, varargin)
% PROCESS_ASCII_TO_L0  Create L0 file from raw ascii glider data 
%
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
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
 
  narginchk(2, 10);
    
  options.processing_mode = 'rt';  
  options.calibration = '';
  options.configuration = '';
  options.output_type = 'science';
  options.data_result = '';  % (empty/other), raw, preprocessed, processed, 
                             % qc_processed, postprocessed,
                             % qc_postprocessed,gridded  
  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
            'Invalid option: %s.', opt);
    end
  end
  
  %% Read configuration values from configuration file
  if ischar(options.configuration)
      glider_toolbox_dir = configGliderToolboxPath();
      config = setupConfiguration(glider_toolbox_dir,  ...
                                    'processing_mode', options.processing_mode, ...
                                    'fconfig', options.configuration);
  else
      config = options.configuration;
  end
    
  if isempty(config) && ~isstruct(config)  
    error(strcat('glider_toolbox:', mfilename, ':MissingConfiguration'),...
          'Empty configuration file');
  end
  
  % Data and meta data at each step & the ones that are returned according
  % to the data_result option
  meta_raw = struct();
  data_raw = struct();
  outputs = '';
  
  %% Extract deployment information
  % Deployment can be either a structure with the information of the
  % deployment or a structure with the information of the database and the
  % deployment index. The information of the database can be directly input
  % in the structure or refer to a configuration file
  if ~isstruct(deployment)
    error(strcat('glider_toolbox:', mfilename, ':InvalidDeploymentType'), ...
        'Deployment class is: %s.', class(deployment));
  end
  
  if isfield(deployment,'db_access') 
      if ~isfield(deployment, 'id')
          error(strcat('glider_toolbox:', mfilename, ':InvalidDeploymentType'), ...
            'Deployment require DB id');
      end
      
      if isnumeric(deployment.id)
          deployment.id = num2str(deployment.id);
      end
      
      if ischar(deployment.db_access)           
          % read information from file
          fconfig = deployment.db_access;
          conf_read = readConfigFile(fconfig);
          if ~isfield(conf_read,'db_access')
              error(strcat('glider_toolbox:', mfilename, ':InvalidDBFormat'), ...
                'db_access information is required in file: %s', fconfig);
          end
          db_access = conf_read.db_access;
          db_access.fconfig = fconfig;
          
          if ~isfield(db_access,'name') || ~isfield(db_access,'user') ...
              || ~isfield(db_access,'pass') ||  ~isfield(db_access,'server') ...
              ||  ~isfield(db_access,'driver') 
                  error(strcat('glider_toolbox:', mfilename, ':InvalidDBFormat'), ...
                    'DB information is required: name, user, pass, server, driver');
          end
      end
      
      disp(strcat('Querying information of glider deployment ',{' '}, num2str(deployment.id), '...') );
      [db_access.db_query, db_access.db_fields] = configDTDeploymentInfoQueryDB('deployment_ids', deployment.id);
      deployment = getDeploymentInfoDB( db_access.db_query, db_access.name, ...
                                        'user', db_access.user, 'pass', db_access.pass, ...
                                        'server', db_access.server, 'driver', db_access.driver, ...
                                        'fields', db_access.db_fields);
  end
  
  
  %% Extract processing configuration
  glider_model = deployment.glider_model;
  [glider_type, processing_config] = extractDeploymentConfig(glider_model, config);

  if isempty(glider_type)
    error(strcat('glider_toolbox:', mfilename, ':InvalidGliderType'), ...
        'Unknown glider model: %s.', glider_model);
  end
  
  if isfield(deployment, 'calibrations')
    processing_config.preprocessing_options.calibration_parameter_list = deployment.calibrations;
  end
  
  %% Check output type
  if strcmp(options.output_type, 'science')
    netcdf_l0_options = processing_config.netcdf_l0_options;
  elseif strcmp(options.output_type, 'engineering')
    netcdf_l0_options = processing_config.netcdf_eng_options;
  end
  
  %% Load data from ascii deployment glider files.
  try
    [meta_raw, data_raw, source_files] = loadAsciiData( ascii_dir, glider_type, deployment.deployment_start, ...
                 processing_config.file_options, 'end_utc', deployment.deployment_end);
  catch exception
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error loading Ascii data from %s: %s', ascii_dir, getReport(exception, 'extended'));
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
          outputs = generateOutputNetCDF( ...
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
          outputs = generateOutputNetCDF( ...
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
          outputs = generateOutputNetCDF( ...
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
      disp(['Output NetCDF L0 (raw data) generated: ' outputs '.']);
    catch exception
      disp(['Error generating NetCDF L0 (raw data) output ' netcdf_l0_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_l0_file)
      disp('Skip generation of NetCDF L0 outputs');
  end
  
  
end