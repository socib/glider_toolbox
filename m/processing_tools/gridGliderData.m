function [data_grid, meta_grid] = gridGliderData(data_proc, meta_proc, varargin)
%GRIDGLIDERDATA  Grid glider trajectory data over instantaneous homogeneous regular profiles.
%
%  Syntax:
%    [DATA_GRID, META_GRID] = GRIDGLIDERDATA(DATA_PROC, META_PROC)
%    [DATA_GRID, META_GRID] = GRIDGLIDERDATA(DATA_PROC, META_PROC, OPTIONS)
%    [DATA_GRID, META_GRID] = GRIDGLIDERDATA(DATA_PROC, META_PROC, OPT1, VAL1, ...)
%
%  Description:
%    DATA_GRID = GRIDGLIDERDATA(DATA_PROC, META_PROC) converts glider trajectory 
%    data in struct DATA_PROC to vertical instantaneous profiles defined at 
%    regular intervals of depth in DATA_GRID using default option values.
%    See options description below.
%
%    DATA_PROC should be a struct in the format returned by PROCESSGLIDERDATA,
%    where each field is a vector of readings of the variable with the same 
%    name along the glider trajectory. At least it should have a sequence for
%    each reference coordinate: time, latitude and longitude, and depth.
%    It also should have a sequence of profile indices that flags each reading
%    with the number of the cast it belongs to.
%
%    META_PROC is also a struct as returned by PROCESSGLIDERDATA, and gridding
%    information is added to any existing metadata of each reference coordinate
%    variable or data variable in returned struct META_GRID.
%
%    DATA_GRID is a struct with two kind of fields: bidimensional arrays with 
%    profiles of gridded variables as rows, and one dimensional reference 
%    coordinate sequences: LATITUDE, LONTGITUDE, DEPTH, TIME and PROFILE_INDEX.
%    Coordinate sequences are selected according to preferred choices in 
%    options (see below). Only variables selected in options and also present 
%    in DATA_PROC are gridded. Selected variables not present in DATA_PROC are
%    silently omited.
%
%    Each cast identified in DATA_PROC is converted to an instantaneous 
%    vertical profile. The position and time coordinates of the new profile are
%    the mean values of the respective coordinates in the cast. All profiles 
%    are defined at the same depth coordinates, computed as the depth range of
%    the whole trajectory divided into regular intervals of given resolution. 
%    The cast data is interpolated over the new depth grid binning the readings 
%    that lay in the corresponding depth intervals.
%
%    Options may be given in key-value pairs OPT1, VAL1... or in a struct 
%    OPTIONS with field names as option keys and field values as option values.
%    Recognized options are:
%      PROFILE_LIST: profile index sequence choices.
%        String cell array with the names of the sequence to be used as profile 
%        index, in order of preference.
%        Default value: {'profile_index'}
%      TIME_LIST: timestamp sequence choices.
%        String cell array with the names of the sequence to be used as time 
%        coordinates, in order of preference.
%        Default value: {'time'}
%      POSITION_LIST: latitude and longitude sequence choices.
%        Struct array with the names of the sequence the to be used as 
%        latitude and longitude coordinates, in order of preference.
%        It should have the following fields:
%          LATITUDE: latitude sequence name.
%          LONGITUDE: longitude sequence name.
%        Default value: struct('latitude',  {'latitude'}, 
%                              'longitude', {'longitude'})
%      DEPTH_LIST: depth sequence choices.
%        String cell array with the names of the sequence to be use as depth
%        coordinate, in order of preference.
%        Default value: {'depth'}
%      DEPTH_STEP: depth resolution.
%        Positive number setting the depth resolution for output profiles.
%        Default value: 1
%      VARIABLE_LIST: list of variables to be included in output profiles.
%        String cell array with the names of the variables to be interpolated
%        over the output profiles.
%        Default value: {} (do nothing except compute profile coordinates)
%
%  Notes:
%    This function is an improved version of a previous function by Tomeu Garau
%    with the same name. He is the true glider man. Main changes are:
%      - Support for reference coordinate sequence selection, variables to
%        interpolate, gridding options.
%      - Use the mean value of readings lying in the depth interval centered at
%        each new depth level with the diameter of the depth resolution
%        (instead of interpolation).
%
%  Examples:
%    [data_grid, meta_grid] = gridGliderData(data_proc, meta_proc, options)
%
%  See also:
%    PROCESSGLIDERDATA
%
%  Authors:
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

  error(nargchk(2, 16, nargin, 'struct'));  
  
  
  %% Set gridding options from default values and extra arguments.
  % Set default option values.
  options = struct();
  options.profile_list = {'profile_index'};
  options.time_list = {'time'};
  options.position_list.latitude = 'latitude';
  options.position_list.longitude = 'longitude';
  options.depth_list = {'depth'};
  options.depth_step = 1;
  options.variable_list = {};
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    option_key_list = fieldnames(varargin{1});
    option_val_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = varargin(1:2:end);
    option_val_list = varargin(2:2:end);
  else
    error('glider_toolbox:processGliderData:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:gridGliderData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end

  
  %% Get list of sequences in trajectory data.
  sequence_list = fieldnames(data_proc);
  
  
  %% Select profile index sequence and coordinate sequences.
  % Profile index and coordinate variables (latitude, longitude, depth and time)
  % are mandatory.
  profile_available = false;
  time_available = false;
  position_available = false;
  depth_available = false;
  % Select profile index sequence.
  profile_choice_list = cellstr(options.profile_list);
  for profile_choice_idx = 1:numel(profile_choice_list)
    profile_sequence = profile_choice_list{profile_choice_idx};
    if ismember(profile_sequence, sequence_list) ...
        && ~all(isnan(data_proc.(profile_sequence)))
      fprintf('Selected profile index coordinate sequence:\n');
      fprintf('  profile: %s\n', profile_sequence);
      profile_available = true;
      break
    end
  end
  % Select time coordinate sequence.
  time_choice_list = cellstr(options.time_list);
  for time_choice_idx = 1:numel(time_choice_list)
    time_sequence = time_choice_list{time_choice_idx};
    if ismember(time_sequence, sequence_list) ...
        && any(data_proc.(time_sequence) > 0)
      fprintf('Selected time coordinate sequence:\n');
      fprintf('  time: %s\n', time_sequence);
      time_available = true;
      break
    end
  end
  % Select position coordinate sequences.
  position_choice_list = options.position_list;
  for position_choice_idx = 1:numel(position_choice_list)
    latitude_sequence = position_choice_list(position_choice_idx).latitude;
    longitude_sequence = position_choice_list(position_choice_idx).longitude;
    if all(ismember({latitude_sequence longitude_sequence}, sequence_list)) ...
        && ~all(isnan(data_proc.(latitude_sequence))) ...
        && ~all(isnan(data_proc.(longitude_sequence))) 
      fprintf('Selected position coordinate sequences:\n');
      fprintf('  longitude: %s\n', latitude_sequence);
      fprintf('  latitude : %s\n', longitude_sequence);
      position_available = true;
      break
    end
  end
  % Select depth sequence.
  depth_choice_list = cellstr(options.depth_list);
  for depth_choice_idx = 1:numel(depth_choice_list)
    depth_sequence = depth_choice_list{depth_choice_idx};
    if ismember(depth_sequence, sequence_list) ...
        && ~all(isnan(data_proc.(depth_sequence)))
      fprintf('Selected depth coordinate sequence:\n');
      fprintf('  depth: %s\n', depth_sequence);
      depth_available = true;
      break
    end
  end
  % Check all required inputs are present.
  coordinate_sequence_available = ...
    [profile_available time_available position_available depth_available];
  if ~all(coordinate_sequence_available)
    coordinate_sequences = {'profile' 'time' 'position' 'depth'};
    miss_coords = coordinate_sequences(~coordinate_sequence_available);
    miss_coords_str = [sprintf('%s, ', miss_coords{1:end-1}) miss_coords{end}];
    error('glider_toolbox:processGliderData:MissingCoordinateSequence', ...
          'Missing coordinate sequences in data set: %s.', miss_coords_str);
  end


  %% Select variables to grid.
  variable_list_choice = cellstr(options.variable_list);
  variable_name_list = intersect(sequence_list, variable_list_choice);
  fprintf('Selected variables to interpolate:\n');
  fprintf('  %s\n', variable_name_list{:});

  
  %% Store variables as columns in a single array to accelerate binning below.
  profile = data_proc.(profile_sequence);
  time = data_proc.(time_sequence);
  latitude = data_proc.(latitude_sequence);
  longitude = data_proc.(longitude_sequence);
  depth = data_proc.(depth_sequence);
  num_variables = numel(variable_name_list);
  num_instants = numel(time);
  variables = nan(num_instants, num_variables);
  for variable_name_idx = 1:num_variables
    variable_name = variable_name_list{variable_name_idx};
    variables(:, variable_name_idx) = data_proc.(variable_name)(:);
  end

  
  %% Compute number of casts.
  num_casts = fix(max(profile));
  profile_range = (1:num_casts);


  %% Compute depth intervals.
  depth_resolution = options.depth_step;
  depth_min = round(min(depth) / depth_resolution) * depth_resolution;
  depth_max = round(max(depth) / depth_resolution) * depth_resolution;
  depth_range = depth_min : depth_resolution : depth_max;
  num_levels = numel(depth_range);
  
  
  %% Initialize output.
  data_grid.depth = depth_range(:);
  data_grid.profile_index = profile_range(:);
  data_grid.time = nan(num_casts, 1);
  data_grid.longitude = nan(num_casts, 1);
  data_grid.latitude = nan(num_casts, 1);
  for variable_name_idx = 1:numel(variable_name_list)
    variable_name = variable_name_list{variable_name_idx};
    data_grid.(variable_name) = nan(num_casts, num_levels);
  end
  

  %% Compute profile coordinates and profile data.
  % Spatial and temporal coordinates are the mean values among cast readings.
  % Selected variable data is interpolated at selected depth levels.
  %{
  for cast_idx = 1:num_casts
    cast_select = (profile == cast_idx);
    cast_lat = latitude(cast_select);
    cast_lon = longitude(cast_select);
    cast_depth = depth(cast_select);
    cast_time = time(cast_select);
    data_grid.time(cast_idx) = nanmean(cast_time);
    data_grid.latitude(cast_idx) = nanmean(cast_lat);
    data_grid.longitude(cast_idx) = nanmean(cast_lon);
    for variable_name_idx = 1:numel(variable_name_list)
      variable_name = variable_name_list{variable_name_idx};
      cast_variable = data_proc.(variable_name)(cast_select);
      cast_valid = ~(isnan(cast_depth(:)) | isnan(cast_variable(:)));
      if sum(cast_valid) > 2
        data_grid.(variable_name)(cast_idx, :) = ...
          interp1(cast_depth(cast_valid), cast_variable(cast_valid), ...
          depth_range(:));
      end
    end
  end
  %}
  %%{
  % Spatial and temporal coordinates are the mean values among cast readings.
  % Selected variable data is binned taking the mean values of readings in depth
  % intervals centered at selected depth levels.
  % For better performance, compute variable data in single array and move it to
  % output struct at the end.
  fprintf('Gridding variables with settings:\n');
  fprintf('  depth level min : %d\n', depth_min);
  fprintf('  depth level max : %d\n', depth_max);
  fprintf('  depth level step: %d\n', depth_resolution);
  fprintf('  number of depth levels: %d\n', num_levels);
  fprintf('  number of profiles    : %d\n', num_casts);
  fprintf('  number of variables   : %d\n', num_variables);
  data_grid_variables = nan(num_casts, num_levels, num_variables);
  for cast_idx = 1:num_casts
    cast_select = (profile == cast_idx);
    cast_lat = latitude(cast_select);
    cast_lon = longitude(cast_select);
    cast_depth = depth(cast_select);
    cast_time = time(cast_select);
    cast_variables = variables(cast_select, :);
    data_grid.time(cast_idx) = nanmean(cast_time);
    data_grid.latitude(cast_idx) = nanmean(cast_lat);
    data_grid.longitude(cast_idx) = nanmean(cast_lon);
    if ~isempty(cast_variables) % Speed up when there are no variables.
      data_grid_variables(cast_idx, :, :) = ...
        cell2mat(arrayfun(@(d) nanmean(cast_variables(abs(cast_depth-d)<=0.5*depth_resolution, :), 1), ...
                          depth_range(:), 'UniformOutput', false));
    end
  end
  % Move binned variable data to output struct.
  for variable_name_idx = 1:num_variables
    variable_name = variable_name_list{variable_name_idx};
    data_grid.(variable_name) = data_grid_variables(:, :, variable_name_idx);
  end
  %%}

  
  %% Add gridding metadata:
  meta_grid.profile_index = meta_proc.(profile_sequence);
  meta_grid.profile_index.grid_sources = profile_sequence;
  meta_grid.profile_index.grid_resolution = 1;
  meta_grid.profile_index.grid_min = min(profile_range);
  meta_grid.profile_index.grid_max = max(profile_range);
  meta_grid.depth = meta_proc.(depth_sequence);
  meta_grid.depth.grid_sources = depth_sequence;
  meta_grid.depth.grid_resolution = depth_resolution;
  meta_grid.depth.grid_min = depth_min;
  meta_grid.depth.grid_max = depth_max;
  meta_grid.time = meta_proc.(time_sequence);
  meta_grid.time.grid_sources = time_sequence;
  meta_grid.time.grid_coordinates = {'profile_index'};
  meta_grid.time.grid_method = {'mean'};
  meta_grid.longitude = meta_proc.(longitude_sequence);
  meta_grid.longitude.grid_sources = longitude_sequence;
  meta_grid.longitude.grid_coordinates = {'profile_index'};
  meta_grid.longitude.grid_method = {'mean'};
  meta_grid.latitude = meta_proc.(latitude_sequence);
  meta_grid.latitude.grid_sources = latitude_sequence;
  meta_grid.latitude.grid_coordinates = {'profile_index'};
  meta_grid.latitude.grid_method = {'mean'};
  for variable_name_idx = 1:numel(variable_name_list)
    variable_name = variable_name_list{variable_name_idx};
    meta_grid.(variable_name) = meta_proc.(variable_name);
    meta_grid.(variable_name).grid_sources = variable_name;
    meta_grid.(variable_name).grid_coordinates = {'profile_index' 'depth'};
    meta_grid.(variable_name).grid_method = {'index' 'mean'};
  end
  
end
