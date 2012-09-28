function [meta_out, data_out] = dbacat(meta_list, data_list, timestamp)
%DBACAT  Combine data from several dba data sets into a single data set.
%
%  [META_OUT, DATA_OUT] = DBACAT(META_LIST, DATA_LIST, TIMESTAMP) combines
%  data from arrays in cell array DATA_LIST and metadata from structs in cell
%  array META_LIST into a single data set with data in array DATA_OUT and
%  metadata in struct META_OUT according to a timestamp from sensor named by
%  string TIMESTAMP. META_OUT, DATA_OUT, and the elements of META_LIST and
%  DATA_LIST follow the format returned by the function DBA2MAT, except that
%  header entries from ascii tags are omitted.
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
%    with the option -o (the initial sensor cycle values may be ommited if the
%    timestamp in the following sensor cycle is the same).
%
%    All values in timestamp columns should be valid (not nan).
%
%  Examples:
%    [meta_out, data_out] = dbacat(meta_list, data_list, timestamp)
%
%  See also:
%    XBD2DBA
%    DBA2MAT
%    DBAMERGE
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(3, 3, nargin, 'struct'));
  
  % Cat metadata.
  meta_struct = [meta_list{:}];
  
  all_sensors = vertcat(meta_struct.sensors);
  all_units = vertcat(meta_struct.units);
  all_bytes = vertcat(meta_struct.bytes);
  all_sources = vertcat(meta_struct.sources);
  
  [sensors_list, sensors_idx] = unique(all_sensors);
  meta_out.sensors = all_sensors(sensors_idx);
  meta_out.units   = all_units(sensors_idx);
  meta_out.bytes   = all_bytes(sensors_idx);
  meta_out.sources = all_sources;
  
  % Cat data.
  [~, sensor_index_list] = cellfun(@(m) ismember(m.sensors, sensors_list), ...
                                   meta_list, 'UniformOutput', false);
  ts_list = cellfun(@(d,m) d(:,strcmp(timestamp, m.sensors)), ...
                    data_list(:), meta_list(:), 'UniformOutput', false);
  [ts_unique, ~, ts_indices_to] = unique(vertcat(ts_list{:}));
  total_rows = numel(ts_unique);
  total_cols = numel(sensors_list);
  data_out = nan(total_rows, total_cols);
  num_rows_list = cellfun(@numel, ts_list);
  row_end_list = cumsum(num_rows_list);
  row_start_list = 1 + [0; row_end_list(1:end-1)];
  for data_idx = 1:numel(data_list)
    row_range = row_start_list(data_idx):row_end_list(data_idx);
    row_indices = ts_indices_to(row_range);
    col_indices = sensor_index_list{data_idx};
    data_old = data_out(row_indices, col_indices);
    data_new = data_list{data_idx};
    data_nan = isnan(data_new);
    if ~all(isnan(data_old(data_old(~data_nan)~=data_new(~data_nan))))
      error('glider_toolbox:dbacat:InconsistentData', 'Inconsistent data.');
    end
    data_new(data_nan) = data_old(data_nan);
    data_out(row_indices, col_indices) = data_new;
  end

end
