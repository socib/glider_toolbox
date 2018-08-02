function [outputs, meta_gridded, data_gridded] = module_l1_to_l2(netcdf_l1_file, netcdf_l2_file, varargin)
% MODULE_L1_TO_L2  Process glider data from L1 to L2 level
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
 
  narginchk(2, 6);
    
  options.processing_mode = 'rt';  
  options.configuration = '';
  
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
  meta_processed = struct();
  data_processed = struct();
  meta_gridded = struct();
  data_gridded = struct();
  outputs = struct();
  
  %% Load data from L1 file.
  try
    [ meta_processed, data_processed, ~, atts_processed  ] = loadNetCDF( netcdf_l1_file );
  catch exception
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error loading data from %s: %s', netcdf_l1_file, getReport(exception, 'extended'));
  end
  
  %% Grid processed glider data.
  if ~isempty(fieldnames(data_processed))
    disp('Gridding glider data...');
    try
      [data_gridded, meta_gridded] = ...
        gridGliderData(data_processed, meta_processed, config.gridding_options);
    catch exception
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error gridding glider deployment data: %s', getReport(exception, 'extended'));
    end
  end
  
  %% Generate L2 (gridded data) netcdf file, if needed and possible.
  if ~isempty(fieldnames(data_gridded)) && ~isempty(netcdf_l2_file)
    netcdf_l2_options = config.output_netcdf_l2;
    % reformat attributes
    for i = 1:length(netcdf_l2_options.attributes)
        if ~isempty(netcdf_l2_options.attributes(i).value)
            varname =  netcdf_l2_options.attributes(i).name;
            atts_gridded.(varname) =  netcdf_l2_options.attributes(i).value;
        end
    end
    disp('Generating NetCDF L2 output...');
    try
      outputs.netcdf_l2 = generateOutputNetCDF( ...
        netcdf_l2_file, data_gridded, meta_gridded, atts_gridded, ...
        netcdf_l2_options.variables, ...
        netcdf_l2_options.dimensions, ...
        atts_processed);
      disp(['Output NetCDF L2 (gridded data) generated: ' ...
            outputs.netcdf_l2 '.']);
    catch exception
      disp(['Error generating NetCDF L2 (gridded data) output ' ...
            netcdf_l2_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_l2_file)
      disp('Skip generation of NetCDF L2 outputs');
  end
  
end