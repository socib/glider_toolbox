function [outputs, meta_res, data_res] = module_l0_to_EGOl1(netcdf_l0_file, netcdf_egol1_file, varargin)
% MODULE_L0_TO_L1  Process glider data from L0 to EGO L1 level
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
  meta_preprocessed = struct();
  data_preprocessed = struct();
  meta_processed = struct();
  data_processed = struct();
  meta_postprocessed = struct();
  data_postprocessed = struct();
  meta_qc_processed = struct();
  data_qc_processed = struct();
  meta_qc_postprocessed = struct();
  data_qc_postprocessed = struct();
  meta_res = struct();
  data_res = struct();
  outputs = struct();
  
  %% Load data from L0 file.
  try
    [ meta_raw, data_raw, ~, atts_raw, deployment  ] = loadNetCDF( netcdf_l0_file );
  catch exception
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error loading data from %s: %s', netcdf_l0_file, getReport(exception, 'extended'));
  end
  
  if strcmp(options.data_result, 'raw')
    meta_res = meta_raw;
    data_res = data_raw;
  end
  
  % Extract configuration of the processing according to the glider model
  att_select = strcmp('instrument_model', {atts_raw.name});
  if ~any(att_select)
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error reading NetCDF instrument model : %s', getReport(exception, 'extended'));
  end    
  glider_model = atts_raw(att_select).value;
  %glider_model = atts_raw.instrument_model;
  [glider_type, processing_config] = extractDeploymentConfig(glider_model, config);

  if isempty(glider_type)
    error('glider_toolbox:deploymentDataProcessing:InvalidGliderType', ...
        'Unknown glider model: %s.', glider_model);
  end
  
  if ~isempty(options.calibration)
    processing_config.preprocessing_options.calibration_parameter_list = deployment.calibrations;
  end

  %% Preprocess raw glider data.
  if ~isempty(fieldnames(data_raw))
    disp('Preprocessing raw data...');
    try
      if strcmp(glider_type, 'seaglider')
        seaglider_time_sensor_select = strcmp('elaps_t', {processing_config.preprocessing_options.time_list.time});
        processing_config.preprocessing_options.time_list(seaglider_time_sensor_select).conversion = @(t)(t +  meta_raw.start_secs);
      end
      
      [data_preprocessed, meta_preprocessed] = ...
        preprocessGliderData(data_raw, meta_raw, processing_config.preprocessing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error preprocessing glider deployment data: %s', getReport(exception, 'extended'));
    end
  end

  if strcmp(options.data_result, 'preprocessed')
    meta_res = meta_preprocessed;
    data_res = data_preprocessed;
  end

  %% Process preprocessed glider data.
  if ~isempty(fieldnames(data_preprocessed))
    disp('Processing glider data...');
    try
      [data_processed, meta_processed] = ...
        processGliderData(data_preprocessed, meta_preprocessed, ...
                          processing_config.processing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error processing glider deployment data: %s', getReport(exception, 'extended'));
    end
  end
  
  if strcmp(options.data_result, 'processed')
    meta_res = meta_processed;
    data_res = data_processed;
  end
  
  
  %% Quality control of processed glider data.
  if ~isempty(fieldnames(data_processed))
    disp('Performing quality control of glider data (Not implemented yet)...');
    try
      [data_qc_processed, meta_qc_processed] = ...
        processQCGliderData(data_processed, meta_processed); %, processing_config.postprocessing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error performing QC of processed data: %s', getReport(exception, 'extended'));
    end
  end
    
  if strcmp(options.data_result, 'qc_processed')
    meta_res = meta_qc_processed;
    data_res = data_qc_processed;
  end
  
  %% PostProcess and new QC of last L1 processed glider data.
  %  This step is performed when special format types are needed. 
  %  It calculates special parameters or rename as specified by the format
  %  definition
  perform_postprocessing = false;
  if ~isempty(netcdf_egol1_file) || ...
        strcmp(options.data_result, 'postprocessed')  || ...
        strcmp(options.data_result, 'qc_postprocessed')
     perform_postprocessing = true; 
  end
  if ~isempty(fieldnames(data_qc_processed)) && perform_postprocessing
    disp('Post processing processed glider data...');
    try
      [data_postprocessed, meta_postprocessed] = ...
        postProcessGliderData(data_qc_processed, meta_qc_processed, ...
                              config.output_netcdf_egol1.variables, ...   %, processing_config.postprocessing_options);
                              'deployment', deployment);
    catch exception
      disp('Error post processing glider deployment data:');
      disp(getReport(exception, 'extended'));
      perform_postprocessing = false;
    end
    
    
    if perform_postprocessing && ~isempty(fieldnames(data_postprocessed))  
        if strcmp(options.data_result, 'postprocessed')
            meta_res = meta_postprocessed;
            data_res = data_postprocessed;
        end

        disp('QC of post processed glider data (add EGO QC keywords)...');
        try
          [data_qc_postprocessed, meta_qc_postprocessed] = ...
            postProcessQCGliderData(data_postprocessed, meta_postprocessed); %, processing_config.postprocessing_options);
        catch exception
          disp('Error performing QC of post processed glider data:');
          disp(getReport(exception, 'extended'));
        end

        if strcmp(options.data_result, 'qc_postprocessed')
            meta_res = meta_qc_postprocessed;
            data_res = data_qc_postprocessed;
        end
    end
  end
  
  if ~isempty(fieldnames(data_qc_postprocessed)) && perform_postprocessing
    %% Generate L1 NetCDF-EGO file (processed data), if needed and possible.
    if ~isempty(fieldnames(data_qc_postprocessed)) && ~isempty(netcdf_egol1_file)
    netcdf_egol1_options = config.output_netcdf_egol1;
    disp('Generating NetCDF-EGO L1 output...');
    try
      outputs.netcdf_egol1 = generateOutputNetCDF( ...
        netcdf_egol1_file, data_qc_postprocessed, meta_qc_postprocessed, struct(), ...
        netcdf_egol1_options.variables, ...
        netcdf_egol1_options.dimensions, ...
        atts_raw, ...
        'modified', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SSZ'), ...
        'time_format', @(t)(datestr(posixtime2utc(t), 'yyyy-mm-ddTHH:MM:SSZ')), ...
        'netcdf_format', 'EGO', ...
        'required_atts', netcdf_egol1_options.attributes_required);
      disp(['Output NetCDF-EGO L1 (processed data) generated: ' ...
            outputs.netcdf_egol1 '.']);
    catch exception
      disp(['Error generating NetCDF-EGO L1 (processed data) output ' ...
            netcdf_egol1_file ':']);
      disp(getReport(exception, 'extended'));
    end
    elseif isempty(netcdf_egol1_file)
      disp('Skip generation of NetCDF-EGO L1 outputs');      
    end
  end  

  
end