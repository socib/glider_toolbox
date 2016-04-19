function [meta, data] = sxcat(meta_list, data_list, timestamp, varargin)
%SXCAT  Combine data from several SeaExplorer data sets of the same type into a single data set.
%
%  Syntax:
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP)
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP, OPTIONS)
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP) combines data from 
%    arrays in cell array DATA_LIST and metadata from structs in cell array 
%    META_LIST into a single data set with data in array DATA and metadata in 
%    struct array META. Elements in META_LIST and DATA_LIST should have the
%    format returned by function SX2MAT, but they do not need to have the same
%    set of variables. Outputs META and DATA have the same format, too.
%    META is a struct array combining the information in elements of META_LIST.
%    It has following fields:
%      VARIABLES: string cell array with the names of the variables present
%        in the returned data array (in the same column order), built merging
%        the VARIABLES field of all elements in META_LIST.
%      SOURCES: string cell array built concatenating the SOURCES field
%        of all elements in META_LIST.
%    DATA is a numeric array combining the rows of arrays in DATA_LIST,
%    reordering the variable columns if needed, and sorting the resulting rows
%    according to a timestamp from variable named by string TIMESTAMP.
%
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP, OPTIONS) and
%    [META, DATA] = SXCAT(META_LIST, DATA_LIST, TIMESTAMP, OPT1, VAL1, ...)
%    accept the following options given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with variable readings in the column order
%            specified by the VARIABLES metadata field.
%          'struct': DATA is a struct with variable names as field names
%            and column vectors of variable readings as field values.
%        Default value: 'array'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the variables of interest.
%        If given, only variables present in both the input data sets and this
%        list will be present in output. The string 'all' may also be given,
%        in which case variable filtering is not performed and all variables
%        in the input list will be present in output.
%        Default value: 'all' (do not perform variable filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given, 
%        only row readings with timestamps within this period will be present
%        in output. The string 'all' may also be given, in which case time 
%        filtering is not performed and all row readings in the input list
%        will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to combine data from several glider files,
%    or from several payload files, but not from both glider and payload files
%    (use SXMERGE instead).
%
%    If data rows with the same timestamp are present in several data sets,
%    the function checks that data in those row readings is consistent.
%    If the same variable is present in row readings from different data sets
%    with the same timestamp and different valid values (not NaN), an error is
%    thrown. Otherwise the values are merged into a single data row.
%    However, note that in the odd case of data rows with the same timestamp
%    in the same data set, they would not be merged and the values
%    in the latest one would be used.
%
%    All values in timestamp columns should be valid (not NaN).
%
%  Examples:
%    [meta, data] = sxcat(meta_list, data_list, timestamp)
%
%  See also:
%    SX2MAT
%    SXMERGE
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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
  options.variables = 'all';
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
    error('glider_toolbox:sxcat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sxcat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  variable_filtering = true;
  variable_list = cellstr(options.variables);
  time_filtering = true;
  time_range = options.period;
  if ischar(options.variables) && strcmp(options.variables, 'all')
    variable_filtering = false;
  end
  if ischar(options.period) && strcmp(options.period, 'all')
    time_filtering = false;
  end
  
  
  %% Cat data and metadata checkin for trivial empty input.
  % Check for trivial empty input.
  if isempty(meta_list)
    sources_cat_list = cell(0, 1);
    variables_cat_list = cell(0, 1);
  else
    meta_struct = [meta_list{:}];
    sources_cat_list = {meta_struct.sources}';
    variables_cat_list = {meta_struct.variables}';
  end
  
  % Build list of sources and variables for concatenated data and metadata.
  sources_cat = vertcat(sources_cat_list{:});
  [variables_cat, ~, variables_cat_indices_to] = ...
    unique(vertcat(variables_cat_list{:}));
  
  % Build list of unique timestamps and the output index of each data row.
  stamp_cat_list = cellfun(@(d, m) d(:, strcmp(timestamp, m.variables)), ...
                           data_list(:), meta_list(:), 'UniformOutput', false);
  [stamp_cat, ~, stamp_cat_indices_to] = unique(vertcat(stamp_cat_list{:}));
  
  % Build list of indices of input data entries in concatenated data output.
  total_rows = numel(stamp_cat);
  row_num_list = cellfun(@numel, stamp_cat_list(:));
  row_end_list = cumsum(row_num_list);
  row_start_list = 1 + [0; row_end_list(1:end-1)];
  total_cols = numel(variables_cat);
  col_num_list = cellfun(@numel, variables_cat_list(:));
  col_end_list = cumsum(col_num_list);
  col_start_list = 1 + [0; col_end_list(1:end-1)];
  
  % Set output concatenated data checking for consistency of overlapped data.
  data = nan(total_rows, total_cols);
  for data_idx = 1:numel(data_list)
    row_range = row_start_list(data_idx):row_end_list(data_idx);
    row_indices = stamp_cat_indices_to(row_range);
    col_range = col_start_list(data_idx):col_end_list(data_idx);
    col_indices = variables_cat_indices_to(col_range);
    data_old = data(row_indices, col_indices);
    data_new = data_list{data_idx};
    data_old_valid = ~isnan(data_old);
    data_new_valid = ~isnan(data_new);
    data_inconsistent = ...
      (data_old ~= data_new) & data_old_valid & data_new_valid;
    if any(data_inconsistent(:))
      [row_inconsistent, col_inconsistent] = find(data_inconsistent);
      err_msg_arg_list = cell(4, numel(row_inconsistent));
      err_msg_arg_list(1, :) = variables_cat(col_indices(col_inconsistent));
      err_msg_arg_list(2, :) = cellstr( ...
        datestr(posixtime2utc(stamp_cat(row_indices(row_inconsistent))), ...
                'dd/mm/yyyy HH:MM:SS.FFF'));
      err_msg_arg_list(3, :) = num2cell(data_old(data_inconsistent));
      err_msg_arg_list(4, :) = num2cell(data_new(data_inconsistent));
      err_msg_fmt = '\nInconsistent value of %s at %s: %12f %12f';
      error('glider_toolbox:sxcat:InconsistentData', ...
            'Inconsistent data:%s', sprintf(err_msg_fmt, err_msg_arg_list{:}));
    end
    data_old(data_new_valid) = data_new(data_new_valid);
    data(row_indices, col_indices) = data_old;
  end
  
  % Set metadata fields.
  meta.sources = sources_cat;
  meta.variables = variables_cat;
  
  
  %% Perform time filtering if needed.
  if time_filtering
    stamp_select = ~(stamp_cat < time_range(1) | stamp_cat > time_range(2));
    data = data(stamp_select, :);
  end
  
  
  %% Perform variable filtering if needed.
  if variable_filtering
    [variable_select, ~] = ismember(meta.variables, variable_list);
    meta.variables = meta.variables(variable_select);
    data = data(:, variable_select);
  end
  
  
  %% Convert output data to struct format if needed.
  switch output_format
    case 'array'
    case 'struct'
      data = cell2struct(num2cell(data, 1), meta.variables, 2);
    otherwise
      error('glider_toolbox:sxcat:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
