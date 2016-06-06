function [meta, data] = dbamerge(meta_nav, data_nav, meta_sci, data_sci, varargin)
%DBAMERGE  Merge data from combined navigation and science data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI)
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPTIONS)
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI) merges the
%    navigation and science data sets described by metadata structs META_NAV and
%    META_SCI, and data arrays DATA_NAV and DATA_SCI into a single data set
%    described by metadata struct META and data array or struct DATA 
%    (see format option described below). Input metadata and data should be
%    in the format returned by the function DBACAT. Sensor cycles from both
%    data sets are merged based on the order of the respective timestamps.
%    See note on merging process.
%
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPTIONS) and
%    [META, DATA] = DBAMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPT1, VAL1, ...)
%    accept the following options given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with sensor readings in the column order
%            specified by the SENSORS metadata field.
%          'struct': DATA is a struct with sensor names as field names
%            and column vectors of sensor readings as field values.
%        Default value: 'array'
%      TIMENAV: navigation data timestamp.
%        String setting the name of the time sensor for merging and sorting
%        sensor cycles from the navigation data set.
%        Default value: 'm_present_time'
%      TIMESCI: scientific data timestamp.
%        String setting the name of the time sensor for merging and sorting
%        sensor cycles from the science data set.
%        Default value: 'sci_m_present_time'
%      SENSORS: sensor filtering list.
%        String cell array with the names of the sensors of interest.
%        If given, only sensors present in both the input data sets and this
%        list will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all sensors
%        in the input data sets will be present in output.
%        Default value: 'all' (do not perform sensor filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given,
%        only sensor cycles with timestamps within this period will be present
%        in output. The string 'all' may also be given, in which case time 
%        filtering is not performed and all sensors cycles in the input
%        data sets will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to merge data from navigation and science
%    data sets, not from data sets coming from the same bay (use DBACAT
%    instead).
%
%    The function is designed after the programs provided by WRC 'dba_merge',
%    'dba_sensor_filter' and 'dba_time_filter'. Since these programs are not 
%    well documented, specially 'dba_merge', and the source code is not
%    available, it is coded after some reverse engineering and its behaviour
%    only asserted for compatibility with original 'dba_merge' program through
%    experimental ways.
%
%    The merging process sorts sensor cycles from navigation and science data
%    sets comparing the respective timestamp values. Sensor cycles coming from
%    navigation and science data arrays with equal timestamp values are merged
%    into a single sensor cycle, otherwise the missing sensor values are filled
%    with invalid values (NaN). In addition, if some sensor is present in both
%    data sets, the repeated instance is renamed: 'sci_XXX' to 'gld_dup_sci_XXX'
%    and 'YYY' to 'sci_dup_YYY'. If the sensor originates in the science bay,
%    the navigation bay instance is prepended with the prefix 'gld_dup_'.
%    Otherwise if the sensor originates in the navigation bay, the science bay
%    instance is prepended with the prefix 'sci_dup_'. This renaming is the
%    behaviour of the original program 'dba_merge', as described here:
%      <http://marine.rutgers.edu/~kerfoot/slocum/data/readme/wrc_doco/dbd_file_format.txt>
%
%  Examples:
%    [meta, data] = dbamerge(meta_nav, data_nav, meta_sci, data_sci)
%
%  See also:
%    XBD2DBA
%    DBA2MAT
%    DBACAT
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

  error(nargchk(4, 14, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.timenav = 'm_present_time';
  options.timesci = 'sci_m_present_time';
  options.sensors = 'all';
  options.period = 'all';
  
  
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
    error('glider_toolbox:dbamerge:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:dbamerge:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  time_sensor_nav = options.timenav;
  time_sensor_sci = options.timesci;
  sensor_filtering = true;
  sensor_list = cellstr(options.sensors);
  time_filtering = true;
  time_range = options.period;
  if ischar(options.sensors) && strcmp(options.sensors, 'all')
    sensor_filtering = false;
  end
  if ischar(options.period) && strcmp(options.period, 'all')
    time_filtering = false;
  end
  
  
  %% Merge data and metadata checking for empty input cases.
  if isempty(meta_sci.sources) && isempty(meta_nav.sources)
    % No input data.
    % Both META_NAV and DATA_NAV, and META_SCI and DATA_SCI
    % are equal to the trivial output of DBACAT.
    % Disable filtering.
    meta = meta_nav; 
    data = data_nav;
    sensor_filtering = false;
    time_filtering = false;
  elseif isempty(meta_sci.sources)
    % Only navigation data.
    meta = meta_nav;
    data = data_nav;
    time_sensor_merged = time_sensor_nav; % Time sensor for filtering.
  elseif isempty(meta_nav.sources)
    % Only science data.
    meta = meta_sci;
    data = data_sci;
    time_sensor_merged = time_sensor_sci; % Time sensor for filtering.
  else
    % Merge metadata performing sensor renaming if needed.
    % Sensor renaming is done to mimic the behaviour of WRC program 'dba_merge'.
    sources_nav = meta_nav.sources;
    headers_nav = meta_nav.headers;
    sensors_nav = meta_nav.sensors;
    units_nav = meta_nav.units;
    bytes_nav = meta_nav.bytes;
    sources_sci = meta_sci.sources;
    headers_sci = meta_sci.headers;
    sensors_sci = meta_sci.sensors;
    units_sci = meta_sci.units;
    bytes_sci = meta_sci.bytes;
    [sensors_dup, sensors_dup_index_nav, sensors_dup_index_sci] = ...
      intersect(sensors_nav, sensors_sci);
    sensors_dup_sci_select = strncmp('sci_', sensors_dup, 4);
    sensors_dup_nav_select = ~sensors_dup_sci_select;
    sensors_nav(sensors_dup_index_nav(sensors_dup_sci_select)) = ...
      strcat('gld_dup_', sensors_dup(sensors_dup_sci_select));
    sensors_sci(sensors_dup_index_sci(sensors_dup_nav_select)) = ...
      strcat('sci_dup_', sensors_dup(sensors_dup_nav_select));
    meta.sources = vertcat(sources_nav, sources_sci);
    meta.headers = vertcat(headers_nav, headers_sci);
    meta.sensors = vertcat(sensors_nav, sensors_sci);
    meta.units = vertcat(units_nav, units_sci);
    meta.bytes = vertcat(bytes_nav, bytes_sci);
    
    % Merge data.
    % Check that both data sets have their own timestamp sensor.
    [time_sensor_nav_present, time_sensor_nav_col] = ...
      ismember(time_sensor_nav, sensors_nav);
    if ~time_sensor_nav_present
      error('glider_toolbox:dbamerge:MissingTimestamp', ...
            'Missing timestamp sensor in navigation data set: %s.', ...
            time_sensor_nav);
    end
    [time_sensor_sci_present, time_sensor_sci_col] = ...
      ismember(time_sensor_sci, sensors_sci);
    if ~time_sensor_sci_present
      error('glider_toolbox:dbamerge:MissingTimestamp', ...
            'Missing timestamp sensor in science data set: %s.', ...
            time_sensor_sci);
    end
    
    % Build list of unique timestamps and output index of each sensor cycle.
    stamp_nav = data_nav(:, time_sensor_nav_col);
    stamp_sci = data_sci(:, time_sensor_sci_col);
    [stamp_merged, ~, stamp_merged_indices_to] = ...
      unique(vertcat(stamp_nav, stamp_sci));
    
    % Build merged data array with sensor columns horizontally concatenated 
    % and different sensor cycles verticaly interleaved according to timestamp.
    row_num_nav = numel(stamp_nav);
    row_range_nav = (1:row_num_nav);
    row_num_sci = numel(stamp_sci);
    row_range_sci = row_num_nav + (1:row_num_sci);
    row_num_merged = numel(stamp_merged);
    col_num_nav = numel(sensors_nav);
    col_range_nav = (1:col_num_nav);
    col_num_sci = numel(sensors_sci);
    col_range_sci = col_num_nav + (1:col_num_sci);
    col_num_merged = col_num_nav + col_num_sci;
    data = nan(row_num_merged, col_num_merged);
    data(stamp_merged_indices_to(row_range_nav), col_range_nav) = data_nav;
    data(stamp_merged_indices_to(row_range_sci), col_range_sci) = data_sci;
    
    % Fill missing navigation timestamp values with science timestamp values.
    % This is done to mimic the behaviour of the WRC program 'dba_merge'.
    stamp_nav_invalid = isnan(data(:, time_sensor_nav_col));
    data(stamp_nav_invalid, time_sensor_nav_col) = ...
      data(stamp_nav_invalid, col_num_nav + time_sensor_sci_col);
    
    % Unique timestamp to be used for time filtering.
    time_sensor_merged = time_sensor_nav;
  end
  
  
  %% Perform time filtering if needed.
  if time_filtering
    [time_sensor_merged_present, time_sensor_merged_col] = ...
      ismember(time_sensor_merged, meta.sensors);
    if ~time_sensor_merged_present
      error('glider_toolbox:dbamerge:MissingTimestamp', ...
            'Missing timestamp sensor in merged data set: %s.', ...
            time_sensor_merged);
    end
    stamp_merged = data(:, time_sensor_merged_col);
    stamp_select = ...
      ~(stamp_merged < time_range(1) | stamp_merged > time_range(2));
    data = data(stamp_select, :);
  end
  
  
  %% Perform sensor filtering if needed.
  if sensor_filtering
    [sensor_select, ~] = ismember(meta.sensors, sensor_list);
    meta.sensors = meta.sensors(sensor_select);
    meta.units = meta.units(sensor_select);
    meta.bytes = meta.bytes(sensor_select);
    data = data(:, sensor_select);
  end
  
  
  %% Convert output data to struct format if needed.
  switch output_format
    case 'array'
    case 'struct'
      data = cell2struct(num2cell(data, 1), meta.sensors, 2);
    otherwise
      error('glider_toolbox:dbamerge:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
