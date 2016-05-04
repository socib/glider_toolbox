function [meta, data] = sxmerge(meta_gli, data_gli, meta_pld, data_pld, varargin)
%SXMERGE  Merge data from combined SeaExplorer glider and payload data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD)
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD, OPTIONS)
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD) merges the
%    glider and payload data sets described by metadata structs META_GLI and
%    META_PLD, and data arrays DATA_GLI and DATA_PLD into a single data set
%    described by metadata struct META and data array or struct DATA
%    (see format option described below). Input metadata and data should be
%    in the format returned by the function SXCAT. Data rows from both
%    data sets are merged based on the order of the respective timestamps.
%    See note on merging process.
%
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD, OPTIONS) and
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_PLD, DATA_PLD, OPT1, VAL1, ...)
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
%      TIMEGLI: glider timestamp.
%        String setting the name of the time variable for merging and sorting
%        data row readings from SeaExplorer .gli data set.
%        Default value: 'Timestamp'
%      TIMEPLD: payload timestamp.
%        String setting the name of the time variable for merging and sorting
%        data row readings from SeaExplorer payload data set.
%        Default value: 'PLD_REALTIMECLOCK'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the variables of interest.
%        If given, only variables present in both the input data sets and this
%        list will be present in output. The string 'all' may also be given,
%        in which case variable filtering is not performed and all variables
%        in the input data sets will be present in output.
%        Default value: 'all' (do not perform variable filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given,
%        only row readings with timestamps within this period will be present
%        in output. The string 'all' may also be given, in which case time 
%        filtering is not performed and all row readings in the input
%        data sets will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to merge data from SeaExplorer glider and
%    payload data sets, not from data sets coming from the same type of files
%    (use SXCAT instead).
%
%    The merging process sorts row variable readings from glider and  payload
%    data sets comparing the respective timestamp values. Row variable readings
%    coming from glider and payload data arrays with equal timestamp values are
%    merged into a single row, otherwise the missing variable values are filled
%    with invalid values (NaN). Variables in glider and payload data sets are
%    all different, but if there were duplicated variables, the values from each
%    data set would be merged in a common column according to the timestamp,
%    and an error would be raised if there were inconsistent valid data entries
%    (not NaN) for the same timestamp value.
%
%    All values in timestamp columns should be valid (not NaN).
%    In output, the .gli timestamp column contains the merged glider and payload
%    timestamps to provide a consistent comprehensive timestamp variable
%    for the merged data set. The payload timestamp contains only the timestamps
%    of the payload data set.
%
%  Examples:
%    [meta, data] = sxmerge(meta_gli, data_gli, meta_pld, data_pld)
%
%  See also:
%    SX2MAT
%    SXCAT
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

  error(nargchk(4, 14, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.timegli = 'Timestamp';
  options.timepld = 'PLD_REALTIMECLOCK';
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
    error('glider_toolbox:sxmerge:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sxmerge:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  time_variable_gli = options.timegli;
  time_variable_pld = options.timepld;
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
  
  
  %% Merge data and metadata checking for empty input cases.
  if isempty(meta_gli.sources) && isempty(meta_pld.sources)
    % No input data.
    % Both META_GLI and DATA_GLI, and META_PLD and DATA_PLD
    % are equal to the trivial output of SXCAT.
    % Disable filtering.
    meta = meta_gli; 
    data = data_gli;
    variable_filtering = false;
    time_filtering = false;
  elseif isempty(meta_pld.sources)
    % Only glider data.
    meta = meta_gli;
    data = data_gli;
    time_variable_merged = time_variable_gli; % Time variable for filtering.
  elseif isempty(meta_gli.sources)
    % Only payload data.
    meta = meta_pld;
    data = data_pld;
    time_variable_merged = time_variable_pld; % Time variable for filtering.
  else
    % Build list of sources and variables for merged data and metadata.
    sources_gli = meta_gli.sources;
    sources_pld = meta_pld.sources;
    sources_merged = vertcat(sources_gli, sources_pld);
    variables_gli = meta_gli.variables;
    variables_pld = meta_pld.variables;
    [variables_merged, ~, variables_merged_indices_to] = ...
      unique(vertcat(variables_gli, variables_pld));
    
    % Check that both data sets have their own timestamp variable.
    [time_variable_gli_present, time_variable_gli_col] = ...
      ismember(time_variable_gli, variables_gli);
    if ~time_variable_gli_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in glider data set: %s.', ...
            time_variable_gli);
    end
    [time_variable_pld_present, time_variable_pld_col] = ...
      ismember(time_variable_pld, variables_pld);
    if ~time_variable_pld_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in payload data set: %s.', ...
            time_variable_pld);
    end
    
    % Build list of unique timestamps and the output index of each data row. 
    stamp_gli = data_gli(:, time_variable_gli_col);
    stamp_pld = data_pld(:, time_variable_pld_col);
    [stamp_merged, ~, stamp_merged_indices_to] = ...
      unique(vertcat(stamp_gli, stamp_pld));
    
    % Build indices of glider and payload entries in merged data output.
    row_num_gli = numel(stamp_gli);
    row_range_gli = 1:row_num_gli;
    row_indices_gli = stamp_merged_indices_to(row_range_gli);
    row_num_pld = numel(stamp_pld);
    row_range_pld = row_num_gli + (1:row_num_pld);
    row_indices_pld = stamp_merged_indices_to(row_range_pld);
    row_num_merged = numel(stamp_merged);
    col_num_gli = numel(variables_gli);
    col_range_gli = 1:col_num_gli;
    col_indices_gli = variables_merged_indices_to(col_range_gli);
    col_num_pld = numel(variables_pld);
    col_range_pld = col_num_gli + (1:col_num_pld);
    col_indices_pld = variables_merged_indices_to(col_range_pld);
    col_num_merged = numel(variables_merged);
    
    % Check for consistency of overlapped glider and payload data.
    [row_overlap_merged, row_overlap_gli, row_overlap_pld] = ...
      intersect(row_indices_gli, row_indices_pld);
    [col_overlap_merged, col_overlap_gli, col_overlap_pld] = ...
      intersect(col_indices_gli, col_indices_pld);
    data_overlap_gli = data_gli(row_overlap_gli, col_overlap_gli);
    data_overlap_pld = data_pld(row_overlap_pld, col_overlap_pld);
    data_overlap_gli_valid = ~isnan(data_overlap_gli);
    data_overlap_pld_valid = ~isnan(data_overlap_pld);
    data_overlap_inconsistent = (data_overlap_gli ~= data_overlap_pld) ...
                              & data_overlap_gli_valid ...
                              & data_overlap_pld_valid;
    if any(data_overlap_inconsistent(:))
      [row_inconsistent, col_inconsistent] = find(data_overlap_inconsistent);
      err_msg_arg_list = cell(4, numel(row_inconsistent));
      err_msg_arg_list(1, :) = ...
        variables_merged(col_overlap_merged(col_inconsistent));
      err_msg_arg_list(2, :) = cellstr( ...
        datestr(posixtime2utc(stamp_merged(row_overlap_merged(row_inconsistent))), ...
                'dd/mm/yyyy HH:MM:SS.FFF'));
      err_msg_arg_list(3, :) = ...
        num2cell(data_overlap_gli(data_overlap_inconsistent));
      err_msg_arg_list(4, :) = ...
        num2cell(data_overlap_pld(data_overlap_inconsistent));
      err_msg_fmt = '\nInconsistent glider and payload value of %s at %s: %12f %12f';
      error('glider_toolbox:sxmerge:InconsistentData', ...
            'Inconsistent data:%s', sprintf(err_msg_fmt, err_msg_arg_list{:}));
    end
    
    % Set output merged data.
    data = nan(row_num_merged, col_num_merged);
    data(row_indices_gli, col_indices_gli) = data_gli;
    data(row_indices_pld, col_indices_pld) = data_pld;
    data_overlap_merged = data_overlap_gli;
    data_overlap_merged(data_overlap_pld_valid) = ...
      data_overlap_pld(data_overlap_pld_valid);
    data(row_overlap_merged, col_overlap_merged) = data_overlap_merged;
    
    % Copy payload timestamp entries to glider timestamp entries.
    data(row_indices_pld, col_indices_gli(time_variable_gli_col)) = stamp_pld;
    time_variable_merged = time_variable_gli;
    
    % Set metadata fields.
    meta.sources = sources_merged;
    meta.variables = variables_merged;
  end
  
  
  %% Perform time filtering if needed.
  if time_filtering
    [time_variable_merged_present, time_variable_merged_col] = ...
      ismember(time_variable_merged, meta.variables);
    if ~time_variable_merged_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in merged data set: %s.', ...
            time_variable_merged);
    end
    stamp_merged = data(:, time_variable_merged_col);
    stamp_select = ...
      ~(stamp_merged < time_range(1) | stamp_merged > time_range(2));
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
      error('glider_toolbox:sxmerge:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
