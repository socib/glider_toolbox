function [meta, data] = sglogengmerge(meta_log, data_log, meta_eng, data_eng, varargin)
%SGLOGENGMERGE  Merge data from combined Seaglider log and eng data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG)
%    [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG, OPTIONS)
%    [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG, OPT1, VAL1, ...) 
%
%  Description:
%    [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG) 
%    merges the data sets described by metadata structs META_LOG and META_ENG,
%    and data arrays or structs DATA_LOG and DATA_ENG into a single data set
%    described by metadata struct META and data array or struct DATA 
%    (see format option described below). Input metadata and data should be 
%    in the format returned by the functions SGLOGCAT and SGENGCAT.
%    Log data referenced to the dive start time (GC, STATE and SM_CCo fields)
%    is merged with eng data. See note on merging.
%
%    META is a struct array combining the information in META_LOG and META_ENG.
%    It has the following fields:
%      LOGHEADERS: struct array of log headers.
%        These are the log data headers in META_LOG. Entries corresponding
%        to unmatched eng headers have all fields empty.
%      ENGHEADERS: struct array of eng headers.
%        These are the eng data headers from META_ENG. Entries corresponding
%        to unmatched log headers have all fields empty.
%      START_SECS: number with the reference time for timestamped data lines. 
%        This is the minimum of the START_SECS field in META_LOGG and META_ENG: 
%        start time of first dive as seconds since 1970 Janyuay 01 00:00:00 UTC.
%      COLUMNS: string cell array with the names of the columns in output data.
%        This are the column names in META_ENG. See note on data merging.
%      PARAMS: struct with the names of the fields of non-scalar parameters.
%        This is the PARAMS field in META_LOG.
%      GCHEAD: string cell array with the names of the fields for the GC lines.
%        This is the GCHEAD field in META_LOG.
%      DEVICES: string cell array with the names of the fields for device lines.
%        This is the DEVICES field in META_LOG.
%      SENSORS: string cell array with the names of the fields for sensor lines.
%        This is the SENSORS field in META_LIST.
%      SOURCES: string cell array with the name of the source files.
%        This is the concatenation the SOURCES field in META_LOG and META_ENG.
%
%  [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG, OPTIONS) and
%  [META, DATA] = SGLOGENGMERGE(META_LOG, DATA_LOG, META_ENG, DATA_ENG, OPT1, VAL1, ...) 
%  accept the following options given in key-value pairs OPT1, VAL1...
%  or in a struct OPTIONS with field names as option keys and field values
%  as option values:
%    FORMAT: data output format.
%      String setting the format of the output DATA. Valid values are:
%        'array': DATA is a struct with the following fields:
%          LOG: array with log parameters in the column order specified by
%            PARAMS metadata field.
%          ENG: array or cell array with the eng columns and GC and SM_CCo
%            log parameter columns in the column order specified by COLUMNS
%            metadata field.
%          GPSFIX: array or cell array with the GPS log columns in the order
%            specified by the GPSFIX metadata field.
%          See note on array format.
%        'merged': DATA is a struct with a column vector field for each
%          parameter in log or gps data, and for each column in eng data.
%        'struct': DATA is a struct with a column vector field for each column
%          in eng data and gps data, and for each scalar parameter in log data; 
%          and with a struct field for each non-scalar parameter in log data.
%      Default value: 'array'
%    PARAMS: log parameter filtering list.
%      String cell array with the names of the log parameters of interest. 
%      If given, only parameters present in both the input data sets and this
%      list will be present in output. For non-scalar parameters, the name
%      of the identifier as it appears in the log line specifies including
%      all of its fields. Individual parameter fields are selected 
%      with the identifier and the name of the field separated by underscore
%      (e.g. 'FINISH_dens'). The string 'all' may also be given, in which case
%      parameter filtering is not performed and all parameters in input list
%      will be present in output.
%      Default value: 'all' (do not perform log parameter filtering).
%    COLUMNS: eng column filtering list.
%      String cell array with the names of the eng data columns of interest. 
%      If given, only columns present in both the input data sets and this list
%      will be present in output. The string 'all' may also be given,
%      in which case column filtering is not performed and all columns
%      in the list will be present in output.
%      Default value: 'all' (do not perform eng column filtering).
%
%  Notes:
%    This function should be used to merge data from log and eng files
%    concatenated by SGLOGCAT and SGENGCAT respectively.
%
%    The log parameters GC, STATE and SM_CCo contain values produced during the
%    dive and timestamped according to the start of it. Hence, they are merged 
%    with the data collected in the eng files. To avoid name clashes and
%    duplications, the following fields of the log parameters are renamed:
%      - 'st_secs' field of 'GC'/'STATE'/'SM_CCo' parameter maps to 'elaps_t'
%      - 'depth'   field of 'GC' parameter maps to 'GC_depth'
%      - 'gcphase' field of 'GC' parameter maps to 'GC_phase'
%    STATE lines ususally do not have a unique timestamp (the timestamp of 
%    consecutive end-begin lines is the same) and in that case only the last 
%    line appears in the output.ç
%
%    Depth in 'GC' log lines and in eng columns is not merged because they come
%    in different units (m and cm). Also, there seems to be some time mismatch.
%
%    Output in 'array' format when there are both textual and numeric columns
%    might require a large amount of memory because of the storage in a cell
%    array.
%
%  Examples:
%    [meta, data] = sglogengmerge(meta_log, data_log, meta_eng, data_eng)
%
%  See also:
%    SGLOG2MAT
%    SGLOGCAT
%    SGENGCAT
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
  options.params = 'all';
  options.columns = 'all';
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
    error('glider_toolbox:sglogengmerge:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sglogengmerge:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = options.format;
  param_filter = true;
  param_filter_list = cellstr(options.params);
  column_filter = true;
  column_filter_list = cellstr(options.columns);
  if ischar(options.params) && strcmp(options.params, 'all')
    param_filter = false;
  end
  if ischar(options.columns) && strcmp(options.columns, 'all')
    column_filter = false;
  end
  
  
  %% GPS data goes on its own.
  % However, it is described in the PARAMS metadata field.
  
  
  %% Eng data merged with numeric timestamped log data.
  % Precompute timestamp column and column names,
  % and convert eng, GC and SM_CCo data to array if needed.
  min_start_secs = min([meta_log.start_secs; meta_eng.start_secs]);
  % Eng data:
  eng = data_eng;
  if isstruct(eng)
    eng = cell2mat(struct2cell(eng)');
  end
  eng_column_list = meta_eng.columns;
  eng_secs_offset = meta_eng.start_secs - min_start_secs;
  eng_secs_select = strcmp('elaps_t', eng_column_list);
  eng(:, eng_secs_select) = eng(:, eng_secs_select) + eng_secs_offset;
  eng_secs = eng(:, eng_secs_select);
  if column_filter
    eng_column_filtering = ismember(eng_column_list, column_filter_list);
    eng_column_list = eng_column_list(eng_column_filtering);
    eng = eng(:, eng_column_filtering);
    if ~any(eng_column_filtering)
      eng_secs = zeros(0, 1);
      eng = [];
    end
  end
  % Log data to be merged with eng data:
  logeng_param_list = {'GC' 'SM_CCo' 'STATE'}';
  logeng_param_numeric_list = [true true false]';
  logeng_member_map = {
    'st_secs' 'elaps_t'
    'gcphase' 'GC_phase'
    'depth'   'GC_depth'
  };
  logeng_param_list = ...
    intersect(fieldnames(meta_log.params), logeng_param_list);
  logeng_secs_offset = meta_log.start_secs - min_start_secs;
  logeng_stsecs_list = repmat({zeros(0, 1)}, size(logeng_param_list));
  logeng_column_list = repmat({cell(0,1)}, size(logeng_param_list));
  logeng_values_list = cell(size(logeng_param_list));
  for logeng_param_idx = 1:numel(logeng_param_list)
    logeng_param = logeng_param_list{logeng_param_idx};
    logeng_param_numeric = logeng_param_numeric_list(logeng_param_idx);
    logeng_members = meta_log.params.(logeng_param);
    logeng_columns = strcat(logeng_param, '_', logeng_members);
    if ~isfield(data_log, logeng_param)
      logeng_values = ...
        cellfun(@(f)(data_log.(f)), logeng_columns, 'UniformOutput', false);
      if ~logeng_param_numeric
        logeng_values_numeric = cellfun(@isnumeric, logeng_values);
        logeng_values(logeng_values_numeric) = ...
          cellfun(@num2cell, logeng_values(logeng_values_numeric), ...
                  'UniformOutput', false);
      end
      logeng_values = horzcat(logeng_values{:});
    elseif isstruct(data_log.(logeng_param))
      logeng_values = struct2cell(data_log.(logeng_param))';
      if logeng_param_numeric
        logeng_values = cell2mat(logeng_values);
      end
    else
      logeng_values = data_log.(logeng_param);
    end
    logeng_stsecs_column = strcmp('st_secs', logeng_members);
    if logeng_param_numeric
      logeng_stsecs = logeng_values(:, logeng_stsecs_column);
      logeng_stsecs = logeng_stsecs + logeng_secs_offset;
      logeng_values(:, logeng_stsecs_column) = logeng_stsecs;
    else
      logeng_stsecs = cell2mat(logeng_values(:, logeng_stsecs_column));
      logeng_stsecs = logeng_stsecs + logeng_secs_offset;
      logeng_values(:, logeng_stsecs_column) = num2cell(logeng_stsecs);
    end
    [logeng_column_renaming, logeng_column_map] = ...
      ismember(logeng_members, logeng_member_map(:,1));
    logeng_columns(logeng_column_renaming) = ...
      logeng_member_map(logeng_column_map(logeng_column_renaming), 2);
    logeng_member_filtering = true(size(logeng_members));
    if param_filter && ~any(strcmp(logeng_param, param_filter_list))
      logeng_member_filtering = ismember(logeng_members, param_filter_list);
    end
    if any(logeng_member_filtering)
      logeng_column_list{logeng_param_idx} = ...
        logeng_columns(logeng_member_filtering);
      logeng_values_list{logeng_param_idx} = ...
        logeng_values(:, logeng_member_filtering);
      logeng_stsecs_list{logeng_param_idx} = logeng_stsecs;
    end
  end
  % Merge timestamped data.
  logeng_data_list = vertcat({eng}, logeng_values_list(:));
  logeng_secs_list = vertcat(eng_secs, logeng_stsecs_list{:});
  logeng_cols_list = vertcat(eng_column_list, logeng_column_list{:});
  column_list = unique(logeng_cols_list);
  [logeng_cols_present_list, logeng_cols_indices_list] = ...
    ismember(logeng_cols_list, column_list);
  [logeng_secs, ~, logeng_rows_indices_list] = unique(logeng_secs_list);
  [logeng_num_rows_list, logeng_num_cols_list] = ...
    cellfun(@size, logeng_data_list);
  logeng_rows_final_list = cumsum(logeng_num_rows_list);
  logeng_rows_start_list = 1 + [0; logeng_rows_final_list(1:end-1)];
  logeng_cols_final_list = cumsum(logeng_num_cols_list);
  logeng_cols_start_list = 1 + [0; logeng_cols_final_list(1:end-1)];
  logeng = struct();
  logeng_rows_total = numel(logeng_secs);
  % logeng_cols_total = numel(column_list);
  % logeng = nan(logeng_rows_total, logeng_cols_total); 
  for data_idx = 1:numel(logeng_data_list)
    logeng_rows_range = ...
      logeng_rows_start_list(data_idx):logeng_rows_final_list(data_idx);
    logeng_rows_indices = logeng_rows_indices_list(logeng_rows_range);
    logeng_cols_range = ...
      logeng_cols_start_list(data_idx):logeng_cols_final_list(data_idx);
    logeng_cols_present = logeng_cols_present_list(logeng_cols_range);
    logeng_cols_indices = logeng_cols_indices_list(logeng_cols_range);
    for logeng_col_idx = find(logeng_cols_present(:)')
      column_index = logeng_cols_indices(logeng_col_idx);
      column = column_list{column_index};
      value = logeng_data_list{data_idx}(:,logeng_col_idx);
      if iscell(value) && ~iscellstr(value)
        value = cell2mat(value);
      end
      if ~isfield(logeng, column)
        if isnumeric(value)
          logeng.(column) = nan(logeng_rows_total, 1);
        else
          logeng.(column) = repmat({''}, logeng_rows_total, 1);
        end
      end
      logeng.(column)(logeng_rows_indices) = value;
    end
  end
  
  
  %% Log parameter data.
  log = struct();
  param_list = struct();
  log_param_list = setdiff(fieldnames(meta_log.params), logeng_param_list);
  log_param_filtering = true(size(log_param_list));
  if param_filter
    log_param_filtering = ismember(log_param_list, param_filter_list);
  end
  for log_param_idx = 1:numel(log_param_list)
    log_field = log_param_list{log_param_idx};
    log_member_list = meta_log.params.(log_field);
    log_field_member_list = strcat(log_field, '_', log_member_list);
    log_member_filtering = ismember(log_field_member_list, param_filter_list);
    log_values = [];
    if ~isfield(data_log, log_field)
      for log_member_idx = numel(log_field_member_list):-1:1
        log_field_member = log_field_member_list{log_member_idx};
        if iscell(log_values) && isnumeric(data_log.(log_field_member))
          log_values(:,log_member_idx) = num2cell(data_log.(log_field_member));
        elseif isnumeric(log_values) && iscell(data_log.(log_field_member))
          log_values = num2cell(log_values);
          log_values(:,log_member_idx) = data_log.(log_field_member);  
        else
          log_values(:,log_member_idx) = data_log.(log_field_member);  
        end
      end
    elseif isstruct(data_log.(log_field))
      log_values = struct2cell(data_log.(log_field))';
      if ~iscellstr(log_values)
        log_values = cell2mat(log_values);
      end
    else
      log_values = data_log.(log_field);
    end
    if log_param_filtering(log_param_idx)
      param_list.(log_field) = log_member_list;
      log.(log_field) = log_values;
    elseif any(log_member_filtering)
      param_list.(log_field) = log_member_list(log_member_filtering);
      log.(log_field) = log_values(:, log_member_filtering);
    end
  end
  
  
  %% Merge metadata.
  % Sort according mission and dive number (using a virtual rank index).
  num_log_headers = numel(meta_log.headers);
  num_eng_headers = numel(meta_eng.headers);
  all_miss_nums = vertcat(meta_log.headers.mission, meta_eng.headers.mission);
  all_dive_nums = vertcat(meta_log.headers.dive, meta_eng.headers.dive);
  [~, ~, miss_dive_sorting] = ...
    unique(  (all_dive_nums - min(all_dive_nums)) ...
           + (all_miss_nums - min(all_miss_nums)) ...
             * (max(all_dive_nums) - min(all_dive_nums) + 1));
  meta = struct();
  meta.logheaders(miss_dive_sorting(1:num_log_headers)) = meta_log.headers;
  meta.engheaders(miss_dive_sorting(num_log_headers + (1:num_eng_headers))) = ...
    meta_eng.headers;
  meta.sources = vertcat(meta_log.sources, meta_eng.sources);
  meta.start_secs = min_start_secs;
  meta.GCHEAD = meta_log.GCHEAD;
  meta.SENSORS = meta_log.SENSORS;
  meta.DEVICES = meta_log.DEVICES;
  meta.params = param_list;
  meta.columns = column_list;
  
  
  %% Convert output data to struct format if needed.
  switch output_format
    case 'array'
      data = struct();
      gps_field_list = {'GPSFIX'}';
      odd_field_list = {'RECOV_CODE' 'RESTART_TIME'}';
      field_list = intersect(fieldnames(meta.params), ...
                             vertcat(gps_field_list, odd_field_list));
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        value_list = log.(field);
        data.(field) = value_list;
      end
      log = struct2cell(rmfield(log, vertcat(gps_field_list, odd_field_list)));
      log_num = cellfun(@isnumeric, log);
      if any(log_num) && ~all(log_num)
        log(log_num) = cellfun(@num2cell, log(log_num), 'UniformOutput', false);
      end
      log = horzcat(log{:});
      data.log = log;
      logeng = struct2cell(logeng);
      logeng_num = cellfun(@isnumeric, logeng);
      if any(logeng_num) && ~all(logeng_num)
        logeng(logeng_num) = ...
          cellfun(@num2cell, logeng(logeng_num), 'UniformOutput', false);
      end
      logeng = horzcat(logeng{:});
      data.eng = logeng;
    case 'merged'
      data = struct();
      field_list = fieldnames(meta.params);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = log.(field);
        if isempty(member_list)
          data.(field) = value_list;
        else
          for member_idx = 1:numel(member_list)
            member = member_list{member_idx};
            field_member = [field '_' member];
            value = value_list(:, member_idx);
            if iscell(value) && ~iscellstr(value)
              value = vertcat(value{:});
            end
            data.(field_member) = value;
          end
        end
      end
      field_list = meta.columns;
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        value = logeng.(field);
        if iscell(value) && ~iscellstr(value)
          value = vertcat(value{:});
        end
        data.(field) = value;
      end
    case 'struct'
      data = struct();
      field_list = fieldnames(meta.params);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = log.(field);
        if isempty(member_list)
          data.(field) = value_list;
        else
          if isnumeric(value_list)
            value_list = num2cell(value_list);
          end
          data.(field) = cell2struct(value_list, member_list, 2);
        end
      end
      field_list = meta.columns;
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        value = logeng.(field);
        if iscell(value) && ~iscellstr(value)
          value = vertcat(value{:});
        end
        data.(field) = value;
      end
    otherwise
      error('glider_toolbox:sglogengmerge:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
