function [meta, data] = dbacat(meta_list, data_list, timestamp, varargin)
%DBACAT  Combine data from several dba data sets into a single data set.
%
%  [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP) combines data from 
%  arrays in cell array DATA_LIST and metadata from structs in cell array 
%  META_LIST into a single data set with data in array DATA and metadata in 
%  struct array META. Elements in META_LIST and DATA_LIST should have the format
%  returned by function DBA2MAT, but do not need to have the same sensor set.
%  Outputs META and DATA have the same format, too.
%  META is a struct array combining the information in elements of META_LIST.
%  It has following fields:
%    HEADERS: struct array built concatenating the HEADERS field of all elements
%      in META_LIST.
%    SENSORS: string cell array with the names of the sensors present in the
%      returned data array (in the same column order), built merging the SENSORS
%      field of all elements in META_LIST.
%    UNITS: string cell array with the units of the sensors present in the
%      returned data array (in the same column order), built merging the UNITS
%      field of all elements in META_LIST.
%    BYTES: array with the number of bytes of each sensor present in the 
%      returned data array, (in the same column order), built merging the BYTES
%      field of all elements in META_LIST.
%    SOURCES: string cell array built concatenating the SOURCES field of all 
%      elements in META_LIST.
%  DATA is a numeric array combining the rows of arrays in DATA_LIST, reordering
%  the sensor columns if needed, and sorting the resulting rows according to a 
%  timestamp from sensor named by string TIMESTAMP.
%
%  [META, DATA] = DBACAT(..., OPT1, VAL1, ...) accepts the following options:
%    'format': a string setting the format of the output DATA. Valid values are:
%      'array' (default): DATA is a matrix whith sensor readings as columns 
%         ordered as in the 'sensors' metadata field.
%      'struct': DATA is a struct with sensor names as field names and column 
%         vectors of sensor readings as field values.
%    'sensors': a string cell array with the names of the sensors of interest.
%      If given, only sensors present in both the input data sets and this list
%      will be present in output.
%    'period': a two element numeric array with the start and end of the time
%      interval of interest (seconds since 1970-01-01 00:0:00.00 UTC).
%      If given, only sensor cycles with timestamps within this period will be
%      present in output.
%
%  Notes:
%    This function should be used to combine data from several navigation files,
%    or from several science files, but not from both navigation and science
%    files (use DBAMERGE instead).
%
%    Since sensor cycles (data rows) with the same timestamp may be present 
%    in several data sets (e.g. when combining data from sbd and mbd files),
%    the function checks that data in those sensor cycles is consistent.
%    If the same sensor is present in sensor cycles from different data sets 
%    with the same timestamp and different valid values (not nan), an error is
%    thrown. Otherwise the values are merged into a single sensor cycle.
%
%    However, note that sensor cycles with the same timestamp in the same data
%    set are not merged, and the values in the latest sensor cycle will be used.
%    This may be relevant when binary data files are converted to ascii format 
%    with the option -o (the initial sensor cycle values may be omited if the
%    timestamp in the following sensor cycle is the same).
%
%    All values in timestamp columns should be valid (not nan).
%
%  Examples:
%    [meta, data] = dbacat(meta_list, data_list, timestamp)
%
%  See also:
%    XBD2DBA
%    DBA2MAT
%    DBAMERGE
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(3, 9, nargin, 'struct'));
  
  % Set option values.
  output_format = 'array';
  sensor_filtering = false;
  sensor_list = [];
  time_filtering = false;
  time_range = [];
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'format'
        output_format = val;
      case 'sensors'
        sensor_filtering = true;
        sensor_list = val;
      case 'period'
        time_filtering = true;
        time_range = val;
      otherwise
        error('glider_toolbox:dbacat:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end
  
  % Check for trivial empty input.
  if isempty(meta_list)
    meta_struct = struct();
    meta_struct.sources = {};
    meta_struct.headers = ...
      struct('dbd_label', {}, 'encoding_ver', {}, 'num_ascii_tags', {}, ...
             'all_sensors', {}, 'filename', {}, 'the8x3_filename', {}, ...
             'filename_extension', {}, 'filename_label', {}, ...
             'mission_name', {}, 'fileopen_time', {}, ...
             'sensors_per_cycle', {}, 'num_label_lines', {}, ...
             'num_segments', {}, 'segment_filenames', {});
    meta_struct.sensors = {};
    meta_struct.units = {};
    meta_struct.bytes = [];
  else
    meta_struct = [meta_list{:}];
  end
  
  % Cat metadata.
  all_sources = vertcat(meta_struct.sources);
  all_headers = vertcat(meta_struct.headers);
  all_sensors = vertcat(meta_struct.sensors);
  all_units = vertcat(meta_struct.units);
  all_bytes = vertcat(meta_struct.bytes);
  
  [sensors_list, sensors_idx] = unique(all_sensors);
  meta.sources = all_sources;
  meta.headers = all_headers;
  meta.sensors = all_sensors(sensors_idx);
  meta.units   = all_units(sensors_idx);
  meta.bytes   = all_bytes(sensors_idx);
  
  % Cat data.
  [~, sensor_index_list] = cellfun(@(m) ismember(m.sensors, sensors_list), ...
                                   meta_list, 'UniformOutput', false);
  ts_list = cellfun(@(d,m) d(:,strcmp(timestamp, m.sensors)), ...
                    data_list(:), meta_list(:), 'UniformOutput', false);
  [ts_unique, ~, ts_indices_to] = unique(vertcat(ts_list{:}));
  total_rows = numel(ts_unique);
  total_cols = numel(sensors_list);
  data = nan(total_rows, total_cols);
  num_rows_list = cellfun(@numel, ts_list);
  row_end_list = cumsum(num_rows_list);
  row_start_list = 1 + [0; row_end_list(1:end-1)];
  for data_idx = 1:numel(data_list)
    row_range = row_start_list(data_idx):row_end_list(data_idx);
    row_indices = ts_indices_to(row_range);
    col_indices = sensor_index_list{data_idx};
    data_old = data(row_indices, col_indices);
    data_new = data_list{data_idx};
    data_nan = isnan(data_new);
    if ~all(isnan(data_old(data_old(~data_nan)~=data_new(~data_nan))))
      error('glider_toolbox:dbacat:InconsistentData', 'Inconsistent data.');
    end
    data_new(data_nan) = data_old(data_nan);
    data(row_indices, col_indices) = data_new;
  end
  
  % Perform time filtering if needed.
  if time_filtering
    ts_select = ~(ts_unique < time_range(1) | ts_unique > time_range(2));
    data = data(ts_select,:);
  end
  
  % Perform sensor filtering if needed.
  if sensor_filtering
    [sensor_select, ~] = ismember(meta.sensors, sensor_list);
    meta.sensors = meta.sensors(sensor_select);
    meta.units = meta.units(sensor_select);
    meta.bytes = meta.bytes(sensor_select);
    data = data(:,sensor_select);
  end
  
  % Convert output data to struct format if needed.
  switch output_format
    case 'array'
    case 'struct'
      data = cell2struct(num2cell(data,1), meta.sensors, 2);
  end

end
