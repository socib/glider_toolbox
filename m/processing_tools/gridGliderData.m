function data_grid = gridGliderData(data_proc, varargin)
%GRIDGLIDERDATA  Grid glider trajectory data over instantaneous homogeneous regular profiles.
%
%  Syntax:
%    DATA_GRID = GRIDGLIDERDATA(DATA_PROC, OPTIONS)
%    DATA_GRID = GRIDGLIDERDATA(DATA_PROC, OPT1, VAL1, ...)
%
%  DATA_GRID = GRIDGLIDERDATA(DATA_PROC, ...) converts glider trajectory data in
%  struct DATA_PROC to vertical instantaneous profiles defined at regular depth
%  intervals in DATA_GRID.
%  
%  Each cast identified in DATA_PROC is converted to an instantaneous vertical 
%  profile. The position and time coordinates of the new profile are the mean 
%  values of the respective coordinates in the cast. All profiles are defined at
%  the same depth coordinates, computed as the depth range of the whole 
%  trajectory divided in regular intervals of given resolution. Data in the cast
%  is interpolated over the new depth grid binning the readings lying in the 
%  corresponding depth intervals.
%
%  DATA_PROC should be a struct in the format returned by PROCESSGLIDERDATA,
%  where each field is a time sequence of readings of the variable with the same
%  name. At least, it should have a sequence for reference coordinates time,
%  latitude and longitude, and depth. It also should have a sequence of profile
%  indices that flags each reading with the number of the cast it belongs to.
%
%  Options may be given either as key-value pairs OPT1, VAL1 ... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    PROFILE: profile index sequence choices.
%      String cell array with the names of the sequence to be used as profile 
%      index, in order of preference.
%      Default value: {'profile_index'}
%    TIME: timestamp sequence choices.
%      String cell array with the names of the sequence to be used as time 
%      coordinates, in order of preference.
%      Default value: {'time'}
%    POSITION: latitude and longitude sequence choices.
%      Struct array whith the names of the sequence the to be used as 
%      latitude and longitude coordinates, in order of preference.
%      It should have the following fields:
%        LATITUDE: latitude sequence name.
%        LONGITUDE: longitude sequence name.
%      Default value: struct('latitude',  {latitude}, 'longitude', {'longitude'})
%    DEPTH: depth sequence choices.
%      String cell array with the names of the sequence to be use as depth
%      coordinate, in order of preference.
%      Default value: {'depth'}
%    DEPTH_STEP: depth resolution.
%      Positive number setting the depth resolution for output profiles.
%      Default value: 1
%    VARIABLES: list of variables to be included in output profiles.
%      String cell array with the names of the variables to be interpolated over
%      the output profiles.
%      Default value: {} (do nothing except compute profile coordinates)
%
%  DATA_GRID is a struct with two kind of fields: bidimensional arrays with 
%  profiles of gridded variables as rows, and one dimensional reference 
%  coordinate sequences: LATITUDE, LONTGITUDE, DEPTH, TIME and PROFILE_INDEX.
%  Coordinate sequences are selected according to preferred choices in options.
%  Only variables selected in options and also present in DATA_PROC are gridded.
%  Selected variables not present in DATA_PROC are silently omited
%
%  Notes:
%    This function is an improved version of a previous function by Tomeu Garau
%    with the same name. He is the true glider man.
%    Introduced changes are:
%      - Support for reference coordinate sequence selection, variables to
%        interpolate, gridding options.
%      - Use the mean value of readings lying in the depth interval centered at
%        each new depth level with the diameter of the depth resolution (instead
%        of interpolation).
%
%  Examples:
%    data_grid = gridGliderData(data_proc, options)
%
%  See also:
%    PROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 15, nargin, 'struct'));  
  
  
  %% Set gridding options from default values and extra arguments.
  % Set default option values.
  options = struct();
  options.profile = {'profile_index'};
  options.time = {'time'};
  options.position.latitude = 'latitude';
  options.position.longitude = 'longitude';
  options.depth = {'depth'};
  options.depth_step = 1;
  options.variables = {};
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
  for profile_sequence_idx = 1:numel(options.profile)
    profile_sequence = options.profile{profile_sequence_idx};
    if ismember(profile_sequence, sequence_list) ...
        && ~all(isnan(data_proc.(profile_sequence)))
      profile = data_proc.(profile_sequence);
      fprintf('Selected profile index coordinate sequence:\n');
      fprintf('  profile: %s\n', profile_sequence);
      profile_available = true;
      break;
    end
  end
  % Select time coordinate sequence.
  for time_sequence_idx = 1:numel(options.time)
    time_sequence = options.time{time_sequence_idx};
    if ismember(time_sequence, sequence_list) ...
        && any(data_proc.(time_sequence) > 0)
      time = data_proc.(time_sequence);
      fprintf('Selected time coordinate sequence:\n');
      fprintf('  time: %s\n', time_sequence);
      time_available = true;
      break;
    end
  end
  % Select position coordinate sequences.
  for position_sequence_idx = 1:numel(options.position)
    lat_sequence = options.position(position_sequence_idx).latitude;
    lon_sequence = options.position(position_sequence_idx).longitude;
    if all(ismember({lat_sequence lon_sequence}, sequence_list)) ...
        && ~all(isnan(data_proc.(lat_sequence))) ...
        && ~all(isnan(data_proc.(lon_sequence))) 
      latitude = data_proc.(lat_sequence);
      longitude = data_proc.(lon_sequence);
      fprintf('Selected position coordinate sequences:\n');
      fprintf('  latitude : %s\n', lat_sequence);
      fprintf('  longitude: %s\n', lon_sequence);
      position_available = true;
      break;
    end
  end
  % Select depth sequence.
  for depth_sequence_idx = 1:numel(options.depth)
    depth_sequence = options.depth{depth_sequence_idx};
    if ismember(depth_sequence, sequence_list) ...
        && ~all(isnan(data_proc.(depth_sequence)))
      depth = data_proc.(depth_sequence);
      fprintf('Selected depth coordinate sequence:\n');
      fprintf('  depth: %s\n', depth_sequence);
      depth_available = true;
      break;
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
  variable_name_list = intersect(sequence_list, options.variables);
  fprintf('Selected variables to interpolate:\n');
  %%{
  % Store variable as columns in a single array to accelerate binning below.
  num_variables = numel(variable_name_list);
  num_instants = numel(time);
  variables = nan(num_instants, num_variables);
  for variable_name_idx = 1:num_variables
    variable_name = variable_name_list{variable_name_idx};
    variables(:, variable_name_idx) = data_proc.(variable_name)(:);
    fprintf('  %s\n', variable_name);
  end
  %%}
  % fprintf('  %s\n', variable_name_list{:});
  

  
  %% Compute number of casts.
  num_casts = fix(max(profile));
  profile_range = (1:num_casts);


  %% Compute depth intervals.
  depth_resolution = options.depth_step;
  depth_min = floor(min(depth) / depth_resolution) * depth_resolution;
  depth_max = ceil(max(depth) / depth_resolution) * depth_resolution;
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
  data_grid_variables = nan(num_casts, num_levels, num_variables);

  
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

end
