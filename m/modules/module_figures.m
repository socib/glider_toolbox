function [ figures ] = module_figures(netcdf_lX_file, figure_dir, varargin)
% MODULE_FIGURES  Create figures from L1 or L2 level
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
    
  options.figure_type = 'processed';  
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
      % The processing mode does not matter for the figure configuration so
      % we can take the default one of setupConfiguration
      config = setupConfiguration(glider_toolbox_dir, 'fconfig', options.configuration);
  else
      config = options.configuration;
  end
    
  if isempty(config) && ~isstruct(config)  
    error(strcat('glider_toolbox:', mfilename, ':MissingConfiguration'),...
          'Empty configuration file');
  end
  
  % Data and meta data at each step & the ones that are returned according
  % to the data_result option
  data_processed = struct();
  figures = '';
  
  %% Load data from L1 or L2 file.
  try
    [ ~, data_processed, ~, ~, deployment  ] = loadNetCDF( netcdf_lX_file );
  catch exception
      error(strcat('glider_toolbox:', mfilename, ':ProcessError'), ...
            'Error loading data from %s: %s', netcdf_l1_file, getReport(exception, 'extended'));
  end
  
  if ~isfield(deployment, 'processing_level')
    error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
            'Could not recognize level from processing_level attribute.');
  end
  
  if strfind(deployment.processing_level, 'L1')
    disp('Creating figures for level 1 product');
    figure_config = config.figures_processed.options;
  elseif strfind(deployment.processing_level, 'L2')
    disp('Creating figures for level 2 product');
    figure_config = config.figures_gridded.options;
  else
    error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
            'Invalid netCDF level: %s.', deployment.processing_level);
  end
  
  %% Generate gridded data figures.
  if ~isempty(fieldnames(data_processed)) && ~isempty(figure_dir)
    disp(strcat('Generating figures from', {' '}, options.figure_type, {' '} ,'data...'));
    try
      figures = generateGliderFigures( ...
        data_processed, figure_config, ...
        'date', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00'), ...
        'dirname', figure_dir);
    catch exception
      disp('Error generating gridded data figures:');
      disp(getReport(exception, 'extended'));
    end
  end
  
end