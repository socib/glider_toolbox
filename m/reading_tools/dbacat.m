function [meta, data] = dbacat(meta_list, data_list, timestamp, varargin)
%DBACAT  Combine data from several dba data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP)
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP, OPTIONS)
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP) combines data from 
%    arrays in cell array DATA_LIST and metadata from structs in cell array 
%    META_LIST into a single data set with data in array DATA and metadata in 
%    struct array META. Elements in META_LIST and DATA_LIST should have the
%    format returned by function DBA2MAT, but they do not need to have the same
%    set of sensors. Outputs META and DATA have the same format, too.
%    META is a struct array combining the information in elements of META_LIST.
%    It has following fields:
%      HEADERS: struct array built concatenating the HEADERS field of all 
%        elements in META_LIST.
%      SENSORS: string cell array with the names of the sensors present in the
%        returned data array (in the same column order), built merging 
%        the SENSORS field of all elements in META_LIST.
%      UNITS: string cell array with the units of the sensors present in the
%        returned data array (in the same column order), built merging 
%        the UNITS field of all elements in META_LIST.
%      BYTES: array with the number of bytes of each sensor present in the 
%        returned data array, (in the same column order), built merging 
%        the BYTES field of all elements in META_LIST.
%      SOURCES: string cell array built concatenating the SOURCES field
%        of all elements in META_LIST.
%    DATA is a numeric array combining the rows of arrays in DATA_LIST,
%    reordering the sensor columns if needed, and sorting the resulting rows
%    according to a timestamp from sensor named by string TIMESTAMP.
%
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP, OPTIONS) and 
%    [META, DATA] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP, OPT1, VAL1, ...) 
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
%      SENSORS: sensor filtering list.
%        String cell array with the names of the sensors of interest.
%        If given, only sensors present in both the input data sets and this
%        list will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all sensors
%        in the input list will be present in output.
%        Default value: 'all' (do not perform sensor filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given,
%        only sensor cycles with timestamps within this period will be present
%        in output. The string 'all' may also be given, in which case time 
%        filtering is not performed and all sensors cycles in the input list
%        will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to combine data from several navigation files,
%    or from several science files, but not from both navigation and science
%    files (use DBAMERGE instead).
%
%    Since sensor cycles (data rows) with the same timestamp may be present 
%    in several data sets (e.g. when combining data from sbd and mbd files),
%    the function checks that data in those sensor cycles are consistent.
%    If the same sensor is present in sensor cycles from different data sets
%    with the same timestamp and different valid values (not NaN), an error is
%    thrown. Otherwise the values are merged into a single sensor cycle.
%
%    However, note that sensor cycles with the same timestamp in the same data
%    set are not merged, and the values in the latest sensor cycle will be used.
%    This may be relevant when binary data files are converted to ascii format 
%    with the option -o (the initial sensor cycle values may be omited if the
%    timestamp in the following sensor cycle is the same).
%
%    All values in the timestamp columns should be valid (not NaN).
%
%  Examples:
%    [meta, data] = dbacat(meta_list, data_list, timestamp)
%
%  See also:
%    XBD2DBA
%    DBA2MAT
%    DBAMERGE
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

  error(nargchk(3, 9, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
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
    error('glider_toolbox:dbacat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:dbacat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
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
  
  
  %% Cat data and metadata checkin for trivial empty input.
  % Check for trivial empty input.
  if isempty(meta_list)
    sources_cat = cell(0, 1);
    headers_cat = ...
      struct('dbd_label', cell(0, 1), 'encoding_ver', cell(0, 1), ...
             'num_ascii_tags', cell(0, 1), 'all_sensors', cell(0, 1), ...
             'filename', cell(0, 1), 'the8x3_filename', cell(0, 1), ...
             'filename_extension', cell(0, 1), 'filename_label', cell(0, 1), ...
             'mission_name', cell(0, 1), 'fileopen_time', cell(0, 1), ...
             'sensors_per_cycle', cell(0, 1), 'num_label_lines', cell(0, 1), ...
             'num_segments', cell(0, 1), 'segment_filenames', cell(0, 1));
    sensors_cat_list = cell(0, 1);
    units_cat_list = cell(0, 1);
    bytes_cat_list = cell(0, 1);
  else
    meta_struct = [meta_list{:}];
    sources_cat = vertcat(meta_struct.sources);
    headers_cat = vertcat(meta_struct.headers);
    sensors_cat_list = {meta_struct.sensors}';
    units_cat_list = {meta_struct.units}';
    bytes_cat_list = {meta_struct.bytes}';
  end
  
  % Build list of sensor information for concatenated data and metadata.
  [~, ~, sensors_cat_indices_to] = unique(vertcat(sensors_cat_list{:}));
  sensors_cat = cell(0, 1);
  units_cat = cell(0, 1);
  bytes_cat = zeros(0, 1, 'int32');
  sensors_cat(sensors_cat_indices_to) = vertcat(sensors_cat_list{:});
  units_cat(sensors_cat_indices_to) = vertcat(units_cat_list{:});
  bytes_cat(sensors_cat_indices_to) = vertcat(bytes_cat_list{:});
  
  % Build list of indices of input data entries in concatenated data output.
  stamp_cat_list = cellfun(@(d, m) d(:, strcmp(timestamp, m.sensors)), ...
                           data_list(:), meta_list(:), 'UniformOutput', false);
  [~, ~, stamp_cat_indices_to] = unique(vertcat(stamp_cat_list{:}));
  stamp_cat = zeros(0, 1);
  stamp_cat(stamp_cat_indices_to) = vertcat(stamp_cat_list{:});
  
  % Build list of indices of input data entries in concatenated data output.
  row_num_total = numel(stamp_cat);
  row_num_list = cellfun(@numel, stamp_cat_list(:));
  row_end_list = cumsum(row_num_list);
  row_start_list = 1 + [0; row_end_list(1:end-1)];
  col_num_total = numel(sensors_cat);
  col_num_list = cellfun(@numel, sensors_cat_list(:));
  col_end_list = cumsum(col_num_list);
  col_start_list = 1 + [0; col_end_list(1:end-1)];
  
  % Set output concatenated data checking for consistency of overlapped data.
  data = nan(row_num_total, col_num_total);
  for data_idx = 1:numel(data_list)
    row_range = row_start_list(data_idx):row_end_list(data_idx);
    row_indices = stamp_cat_indices_to(row_range);
    col_range = col_start_list(data_idx):col_end_list(data_idx);
    col_indices = sensors_cat_indices_to(col_range);
    data_old = data(row_indices, col_indices);
    data_new = data_list{data_idx};
    data_old_valid = ~isnan(data_old);
    data_new_valid = ~isnan(data_new);
    data_inconsistent = ...
      (data_old ~= data_new) & data_old_valid & data_new_valid;
    if any(data_inconsistent(:))
      [row_inconsistent, col_inconsistent] = find(data_inconsistent);
      err_msg_arg_list = cell(4, numel(row_inconsistent));
      err_msg_arg_list(1, :) = sensors_cat(col_indices(col_inconsistent));
      err_msg_arg_list(2, :) = num2cell(stamp_cat(row_indices(row_inconsistent)));
      err_msg_arg_list(3, :) = num2cell(data_old(data_inconsistent));
      err_msg_arg_list(4, :) = num2cell(data_new(data_inconsistent));
      err_msg_fmt = '\nInconsistent value of %s at %12f: %12f %12f';
      error('glider_toolbox:dbacat:InconsistentData', ...
            'Inconsistent data:%s', sprintf(err_msg_fmt, err_msg_arg_list{:}));
    end
    data_old(data_new_valid) = data_new(data_new_valid);
    data(row_indices, col_indices) = data_old;
  end
  
  % Set metadata fields.
  meta.sources = sources_cat;
  meta.headers = headers_cat;
  meta.sensors = sensors_cat;
  meta.units = units_cat;
  meta.bytes = bytes_cat;
  
  
  %% Perform time filtering if needed.
  if time_filtering
    stamp_select = ~(stamp_cat < time_range(1) | stamp_cat > time_range(2));
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
      error('glider_toolbox:dbacat:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
