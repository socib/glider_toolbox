function [meta, data] = sglogcat(meta_list, data_list, varargin)
%SGLOGCAT  Combine data from several Seaglider log files.
%
%  Syntax:
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST)
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST, OPTIONS)
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST) combines metadata in
%    struct array META_LIST and data in cell or struct array DATA_LIST into
%    a single data set with metadata in struct META and data in struct DATA.
%    Respective elements in META_LIST and DATA_LIST should be in the format 
%    returned by function SGLOG2MAT, but do not need to have the same parameters 
%    or variables, and are sorted according to the mission number and the dive
%    number. Outputs META and DATA are in the same format, too.
%
%    META is a struct array combining the information in elements of META_LIST,
%    ordered according to the mission number and the dive number.
%    It has the following fields:
%      HEADERS: struct array with all log headers.
%        This is the concatenation of the HEADERS field of all elements
%        in META_LIST.
%      START_SECS: number with the reference time for timestamped lines (start
%        time of first dive as seconds since 1970 January 01 00:00:00 UTC).
%      PARAMS: struct with the names of the fields of non-scalar parameters.
%        This is the union of the PARAMS field of all elements in META_LIST.
%      GCHEAD: string cell array with the names of the fields for the GC lines.
%        This is the concatenation of the GCHEAD field of all elements
%        in META_LIST.
%      DEVICES: string cell array with the names of the fields for device lines.
%        This is the concatenation of the DEVICES field of all elements
%        in META_LIST.
%      SENSORS: string cell array with the names of the fields for sensor lines.
%        This is the concatenation of the SENSORS field of all elements
%        in META_LIST.
%      SOURCES: string cell array with the name of the source files.
%        This is the concatenation the SOURCES field of all elements
%        in META_LIST.
%
%    DATA is a struct combining the data in DATA_LIST, ordered according to
%    the mission number and the dive number, and with the time fields
%    of timestamed parameters (GC, STATE and SM_CCo) converted to
%    seconds since the start time of the first dive.
%
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST, OPTIONS) and 
%    [META, DATA] = SGLOGCAT(META_LIST, DATA_LIST, OPT1, VAL1, ...) accept
%    the following options given in key-value pairs OPT1, VAL1... or in a struct
%    OPTIONS with field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a struct with a scalar field for each scalar 
%            parameter and an array or cell array field for each non-scalar 
%            parameter. Values of non-scalar parameters are in the column order 
%            given by the corresponding field of the PARAMS metadata field.
%          'merged': DATA is a struct with a scalar or column vector field for
%            each scalar parameter or entry of a non-scalar parameter. 
%            For scalar parameters, the field is named after the parameter,
%            while for non-scalar parameters the field names are the parameter
%            name and its field names, separated by underscore.
%          'struct': DATA is a struct with a scalar field for each scalar 
%            parameter and a struct array for each non-scalar parameter.
%            The fields of the non-scalar parameters are given by
%            the corresponding field of the PARAMS metadata field.
%        Default value: 'array'
%      PARAMS: parameter filtering list.
%        String cell array with the names of the parameters of interest.
%        If given, only parameters present in both the input list and this list
%        will be present in output. For non-scalar parameters, the name 
%        of the identifier as it appears in the log line specifies including
%        all of its fields. Individual parameter fields are selected 
%        with the identifier and the name of the field separated by underscore
%        (e.g. 'GC_st_secs'). The string 'all' may also be given, in which case
%        parameter filtering is not performed and all parameters in input list
%        will be present in output.
%        Default value: 'all' (do not perform parameter filtering).
%      PERIOD: dive start time filtering boundaries.
%        Two element numeric array with the start and the end of the period 
%        of interest (seconds since 1970-01-01 00:00:00.00 UTC). If given, 
%        only data from dives with start time within this period will be 
%        present in output. The string 'all' may also be given, in which case 
%        time filtering is not performed and data from all dives will be 
%        present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Examples:
%    [meta, data] = sglogcat(meta_list, data_list)
%
%  See also:
%    SGLOG2MAT
%    SGENG2MAT
%    SGENGCAT
%    SGLOGENGMERGE
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

  error(nargchk(2, 8, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.params = 'all';
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
    error('glider_toolbox:sglogcat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sglogcat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  param_filter = true;
  param_list = cellstr(options.params);
  start_filter = true;
  start_range = options.period;
  if ischar(options.params) && strcmp(options.params, 'all')
    param_filter = false;
  end
  if ischar(options.period) && strcmp(options.period, 'all')
    start_filter = false;
  end
  
  
  %% Check input formats.
  % Be gentle and accept emtpy inputs and struct or cell arrays.
  % Also, ensure column layout.
  if isempty(meta_list)
    meta_list = struct();
    meta_list.sources = {};
    meta_list.headers =  struct('version', {}, 'glider', {}, ...
                                'mission', {}, 'dive', {}, 'start', {});
    meta_list.params = struct();
    meta_list.start_secs = [];
    meta_list.GCHEAD = {};
    meta_list.DEVICES = {};
    meta_list.SENSORS = {};
  elseif iscell(meta_list)
    meta_list = vertcat(meta_list{:});
  end
  if isstruct(data_list)
    data_list = num2cell(data_list(:)); % struct array to cell array conversion.
  else
    data_list = data_list(:);
  end
  
  
  %% Filter and sort input data sets.
  % Inputs are filtered according to start time
  % and sorted according to mission number and to dive number.
  all_sources = vertcat(meta_list.sources);
  all_gcheads = {meta_list.GCHEAD}';
  all_devices = {meta_list.DEVICES}';
  all_sensors = {meta_list.SENSORS}';
  all_start_secs = vertcat(meta_list.start_secs);
  all_params = {meta_list.params}';
  all_headers = vertcat(meta_list.headers);
  % Sort according mission and dive number (using a virtual rank index).
  all_dive_nums = vertcat(all_headers.dive);
  all_miss_nums = vertcat(all_headers.mission);
  [~, miss_dive_sorting] = ...
    sort(  (all_dive_nums - min(all_dive_nums)) ...
         + (all_miss_nums - min(all_miss_nums)) ...
           * (max(all_dive_nums) - min(all_dive_nums) + 1));
  % Filter dives out of the period of interest.
  time_filtering = true(size(meta_list));
  if start_filter
    time_filtering = ...
      start_range(1) <= all_start_secs & all_start_secs <= start_range(2);
  end
  % Sort and filter at once.
  time_filtering_and_miss_dive_sorting = ...
    miss_dive_sorting(time_filtering(miss_dive_sorting));
  header_list = all_headers(time_filtering_and_miss_dive_sorting, :);
  source_list = all_sources(time_filtering_and_miss_dive_sorting, :);
  gchead_list = all_gcheads(time_filtering_and_miss_dive_sorting, :);
  device_list = all_devices(time_filtering_and_miss_dive_sorting, :);
  sensor_list = all_sensors(time_filtering_and_miss_dive_sorting, :);
  column_list = all_params(time_filtering_and_miss_dive_sorting, :);
  starts_list = all_start_secs(time_filtering_and_miss_dive_sorting, :);
  values_list = data_list(time_filtering_and_miss_dive_sorting, :);
  
  
  %% Compute data availability according to required output.
  % Compute some support variables useful for the rest of the code:
  % - The list of available fields is the union of the fields in each data set.
  % - A data set x field table setting whether j-th field is in i-th data set.
  % - A data set x field table setting whether j-th field is nested in i-th data set.
  % - A data set x field table setting whether j-th field is a struct in i-th data set.
  % - A struct setting the member availablity for non-scalar parameters:
  %   Each field is named after a non-scalar parameter and its value is a 
  %   data set x member table setting whether k-th member is in corresponding
  %   field of i-th data set.
  % If parameter filtering is requested, ignore non-requested fields and members.
  field_list = cellfun(@fieldnames, column_list, 'UniformOutput', false);
  field_list = unique(vertcat(field_list{:}));
  field_present_list = ...
    cellfun(@(c)(isfield(c, field_list)), column_list, 'UniformOutput', false);
  field_present_list = horzcat(field_present_list{:})';
  field_nested_list = ...
    cellfun(@(d)(isfield(d, field_list)), values_list, 'UniformOutput', false);
  field_nested_list = horzcat(field_nested_list{:})';
  field_struct_list = false(size(field_nested_list));
  field_member_list = struct();
  field_member_present_list = struct();
  field_member_indices_list = struct();
  field_filtering = true(size(field_list));
  if param_filter
    field_filtering = ismember(field_list, param_list);
  end
  for field_idx = 1:numel(field_list);
    field = field_list{field_idx};
    field_present = field_present_list(:,field_idx);
    field_nested = field_nested_list(:,field_idx);
    field_struct = cellfun(@(d)(isstruct(d.(field))), ...
                           values_list(field_nested), 'UniformOutput', false);
    field_struct_list(field_nested, field_idx) = horzcat(field_struct{:})';
    member_list = cellfun(@(c)(c.(field)), ...
                         column_list(field_present), 'UniformOutput', false);
    member_list = unique(vertcat(member_list{:}));
    if ~field_filtering(field_idx)
      member_filtering = ...
        ismember(strcat(field, '_', member_list), param_list);
      member_list = member_list(member_filtering);
      field_filtering(field_idx) = any(member_filtering);
    end
    if field_filtering(field_idx)
      field_member_list.(field) = member_list;
      field_member_present_list.(field) = ...
        false(numel(column_list), numel(member_list));
      field_member_indices_list.(field) = ...
        zeros(numel(column_list), numel(member_list));
      if ~isempty(member_list)
        [member_present_list, member_indices_list] = ...
          cellfun(@(c)(ismember(member_list, c.(field))), ...
                       column_list(field_present), 'UniformOutput', false);
        field_member_present_list.(field)(field_present, :) = ...
          horzcat(member_present_list{:})';
        field_member_indices_list.(field)(field_present, :) = ...
          horzcat(member_indices_list{:})';
      end
    end
  end
  if param_filter
    field_list = field_list(field_filtering);
    field_present_list = field_present_list(:, field_filtering);
    field_nested_list = field_nested_list(:, field_filtering);
    field_struct_list = field_struct_list(:, field_filtering);
  end
  
  
  %% Cat metadata.
  meta = struct();
  meta.sources = source_list;
  meta.headers = header_list;
  meta.GCHEAD  = gchead_list;
  meta.DEVICES = device_list;
  meta.SENSORS = sensor_list;
  meta.start_secs = min(starts_list);
  meta.params = field_member_list;
    
    
  %% Cat ordinary data (one line in the log file).
  data = struct();
  spe_field_list = {'GC' 'STATE' 'SM_CCo'}';
  gps_field_list = {'GPSFIX'};
  bad_field_list = {'RECOV_CODE' 'RESTART_TIME'}'; 
  [~, field_index_list] = ...
    setdiff(field_list, vertcat(spe_field_list, gps_field_list, bad_field_list));
  for field_idx = field_index_list(:)'
    field = field_list{field_idx};
    field_present = field_present_list(:, field_idx);
    member_list = field_member_list.(field);
    if isempty(member_list)
      % Parameter is scalar, the same in all formats.
      % For consistency with non-scalar parameters, ensure column layout.
      field_value_list = ...
        cellfun(@(d)(d.(field)), values_list(field_present), ...
                'UniformOutput', false);
      field_value = vertcat(field_value_list{:});
      data.(field)(field_present, 1) = field_value;
      if isnumeric(field_value)
        data.(field)(~field_present, 1) = nan;
      else
        data.(field)(~field_present, 1) = {''};
      end
    else
      field_nested = field_nested_list(:, field_idx);
      field_struct = field_struct_list(:, field_idx);
      member_list = field_member_list.(field);
      member_present_list = field_member_present_list.(field);
      member_indices_list = field_member_indices_list.(field);
      for member_idx = 1:numel(member_list)
        member = member_list{member_idx};
        field_member = [field '_' member];
        member_present = member_present_list(:, member_idx);
        member_indices = member_indices_list(:, member_idx);
        member_struct = member_present & field_struct;
        member_nested = member_present & field_nested & ~field_struct;
        member_merged = member_present & ~field_nested;
        member_value_list = cell(size(values_list));
        if any(member_struct)
          member_value_list(member_struct) = ...
            cellfun(@(d)(d.(field).(member)), values_list(member_struct), ...
                    'UniformOutput', false);
        end
        if any(member_nested)
          member_value_list(member_nested) = ...
            cellfun(@(d,c)(d.(field)(:,c)), values_list(member_nested), ...
                    num2cell(member_indices(member_nested)), ...
                    'UniformOutput', false);
        end
        if any(member_merged)
          member_value_list(member_merged) = ...
            cellfun(@(d)(d.(field_member)), values_list(member_merged), ...
                    'UniformOutput', false);
        end
        member_value = vertcat(member_value_list{member_present});
        data.(field)(member_present, member_idx) = member_value;
        if isnumeric(member_value)
          data.(field)(~member_present, member_idx) = nan;
        else
          data.(field)(~member_present, member_idx) = {''};
        end
      end
    end
  end


  %% Cat special data (several lines in the log file).
  dive_start_offset_list = starts_list - min(starts_list);
  [~, spe_field_index_list] = ...
    intersect(field_list, ...
              vertcat(spe_field_list, gps_field_list, bad_field_list));
  spe_field_numeric_list = {'GC' 'SM_CCo'}';
  for spe_field_index = spe_field_index_list(:)'
    spe_field = field_list{spe_field_index};
    spe_field_numeric = any(strcmp(spe_field, spe_field_numeric_list));
    spe_member_list = field_member_list.(spe_field);
    spe_member_secs = strcmp('st_secs', spe_member_list);  
    spe_data_list = cell(size(values_list));
    for data_idx = 1:numel(values_list)
      spe_member_present = field_member_present_list.(spe_field)(data_idx, :);
      spe_member_indices = field_member_indices_list.(spe_field)(data_idx, :);
      if field_struct_list(data_idx, spe_field_index)
        spe_data = struct2cell(values_list{data_idx}.(spe_field))';
        if spe_field_numeric
          spe_data = cell2mat(spe_data);
        end
      elseif field_nested_list(data_idx, spe_field_index)
        spe_data = values_list{data_idx}.(spe_field);
      else
        if spe_field_numeric
          spe_data = zeros(0,sum(spe_member_present));
        else
          spe_data = cell(0,sum(spe_member_present));
        end
        for spe_member_idx = find(spe_member_present(:)');
          spe_member = [spe_field '_' spe_member_list{spe_member_idx}];
          spe_member_index = spe_member_indices(spe_member_idx);
          spe_member_values = values_list{data_idx}.(spe_member);
          if spe_field_numeric || iscell(spe_member_values)
            spe_data(1:numel(spe_member_values), spe_member_index) = ...
              spe_member_values;
          else
            spe_data(1:numel(spe_member_values), spe_member_index) = ...
              num2cell(spe_member_values);
          end
        end
      end
      spe_data_list{data_idx}(:, spe_member_present) = ...
         spe_data(:, spe_member_indices(spe_member_present));
      if spe_field_numeric
        spe_data_list{data_idx}(1:end, ~spe_member_present) = nan;
        if size(spe_data_list{data_idx}, 1) > 0 && any(spe_member_secs)
          spe_data_list{data_idx}(:, spe_member_secs) = ...
            spe_data_list{data_idx}(:, spe_member_secs) ...
            + dive_start_offset_list(data_idx);
        end
      else
        spe_data_list{data_idx}(1:end, ~spe_member_present) = {''};
        if size(spe_data_list{data_idx}, 1) > 0 && any(spe_member_secs)
          spe_data_list{data_idx}(:, spe_member_secs) = ...
            num2cell(vertcat(spe_data_list{data_idx}{:, spe_member_secs}) ...
                     + dive_start_offset_list(data_idx));
        end
      end
    end
    data.(spe_field) = vertcat(spe_data_list{:});
    if iscell(data.(spe_field))
      for spe_member_idx = 1:numel(spe_member_list)
        if ~iscellstr(data.(spe_field)(:,spe_member_idx))
          data_field_member_undef = ...
            cellfun(@isempty, data.(spe_field)(:,spe_member_idx));
          data.(spe_field)(data_field_member_undef, spe_member_idx) = {nan};
        end
      end
    end
  end
  
  
  %% Convert data to desired format.
  switch output_format
    case 'array'
    case 'merged'
      field_list = fieldnames(data);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = data.(field);
        if ~isempty(member_list)
          for member_idx = 1:numel(member_list)
            member = member_list{member_idx};
            field_member = [field '_' member];
            value = value_list(:, member_idx);
            if iscell(value) && ~iscellstr(value)
              value = vertcat(value{:});
            end
            data.(field_member) = value;
          end
          data = rmfield(data, field);
        end
      end
    case 'struct'
      field_list = fieldnames(data);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = data.(field);
        if ~isempty(member_list)
          if isnumeric(value_list)
            value_list = num2cell(value_list);
          end
          data.(field) = cell2struct(value_list, member_list, 2);
        end
      end
    otherwise
      error('glider_toolbox:sglog2cat:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
