function [meta, data] = sxmerge(meta_gli, data_gli, meta_dat, data_dat, varargin)
%SXMERGE  Merge data from combined SeaExplorer .gli and .dat data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT)
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT, OPTIONS)
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT) merges the
%    navigation and science data sets described by metadata structs META_GLI and
%    META_DAT, and data arrays DATA_GLI and DATA_DAT into a single data set
%    described by metadata struct META and data array or struct DATA
%    (see format option described below). Input metadata and data should be
%    in the format returned by the function SXCAT. Data rows from both
%    data sets are merged based on the order of the respective timestamps.
%    See note on merging process.
%
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT, OPTIONS) and
%    [META, DATA] = SXMERGE(META_GLI, DATA_GLI, META_DAT, DATA_DAT, OPT1, VAL1, ...)
%    accept the following options given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with variable readings in the column order
%            specified by the VARIABLES metadata field.
%          'struct': DATA is a struct with sensor names as field names
%            and column vectors of sensor readings as field values.
%        Default value: 'array'
%      TIMEGLI: navigation data (.gli) time stamp.
%        String setting the name of the variable to use as timestamp for
%        merging and sorting data row readings from SeaExplorer .gli data set.
%        Default value: 'Timestamp'
%      TIMEDAT: science data (.dat) time stamp.
%        String setting the name of the variable to use as timestamp for
%        merging and sorting data row readings from SeaExplorer .dat data set.
%        Default value: 'PLD_REALTIMECLOCK'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the variables of interest. If given,
%        only variables present in both the input data sets and this list
%        will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all variables
%        in input data sets will be present in output.
%        Default value: 'all' (do not perform variable filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given, 
%        only row readings with timestamps within this period will be present
%        in output. The string 'all' may also be given, in which case time 
%        filtering is not performed and all row readings in the input data sets
%        will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to merge data from .gli and .dat data sets,
%    not from data sets coming from the same type of files (use SXCAT instead).
%
%    The function is inpired from dbamerge.m, although the
%    algorithm is slightly different. In the merging process, we
%    first concatenate science and navigation data this way:
%
%              /---------.---------\
%              |         .         |
%              |   NAV   . [empty] |
%              |         .         |
%              |---------.---------|
%              |         .         |
%              | [empty] .   SCI   |
%              |         .         |
%              \-------------------/ 
%
%    Then the time vector is sorted and "uniqued" and the column
%    reordered accordingly. At this stage, this may be considered a
%    weakness since some point with good data are discarded if the
%    same timestamp is given for nav and sci data is exactly the
%    same. But this should be marginal with a time resolution of
%    1/1000 s for the science bay (For M78 deployment .01% of data
%    were ignored). 
%
%  Examples:
%    [meta, data] = sxmerge(meta_gli, data_gli, meta_dat, data_dat)
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
  options.timedat = 'PLD_REALTIMECLOCK';
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
  timestamp_gli = options.timegli;
  timestamp_dat = options.timedat;
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
  if isempty(meta_gli.sources) && isempty(meta_dat.sources)
    % No input data.
    % Both META_GLI and DATA_GLI, and META_DAT and DATA_DAT
    % are equal to the trivial output of SXCAT.
    % Disable filtering.
    meta = meta_gli; 
    data = data_gli;
    variable_filtering = false;
    time_filtering = false;
  elseif isempty(meta_dat.sources)
    % Only navigation data.
    meta = meta_gli;
    data = data_gli;
    timestamp_merged = timestamp_gli; % Unique timestamp to be used for time filtering.
  elseif isempty(meta_gli.sources)
    % Only science data.
    meta = meta_dat;
    data = data_dat;
    timestamp_merged = timestamp_dat; % Unique timestamp to be used for time filtering.
  else
    % Merge metadata performing variable renaming if needed.
    sources_gli = meta_gli.sources;
    variables_gli_list = meta_gli.variables;
    sources_dat = meta_dat.sources;
    variables_dat_list = meta_dat.variables;
    [variables_dup_list, variables_dup_index_gli, variables_dup_index_dat] = ...
      intersect(variables_gli_list, variables_dat_list);    
    for i = 1:numel(variables_dup_list)
        sensorName = variables_dup_list{i};
        variables_gli_list{variables_dup_index_gli} = sprintf('%s_gli', sensorName);
        variables_dat_list{variables_dup_index_dat} = sprintf('%s_dat', sensorName);
    end
    meta.sources = vertcat(sources_gli, sources_dat);
    meta.variables = vertcat(variables_gli_list, variables_dat_list);
    
    % Merge data.
    % Check that both data sets have their own timestamp variable.
    [ts_gli_present, ts_gli_col] = ismember(timestamp_gli, variables_gli_list);
    if ~ts_gli_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in navigation (.gli) data set: %s.', ...
            timestamp_gli);
    end
    [ts_dat_present, ts_dat_col] = ismember(timestamp_dat, variables_dat_list);
    if ~ts_dat_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in science (.dat) data set: %s.', ...
            timestamp_dat);
    end
    
    %% SeaExplorer version %
    ts_gli = data_gli(:,ts_gli_col);
    ts_dat = data_dat(:,ts_dat_col);
    num_rows_gli = numel(ts_gli);
    num_rows_dat = numel(ts_dat);
    num_cols_gli = numel(variables_gli_list);
    num_cols_dat = numel(variables_dat_list);

    row_range_gli = (1:num_rows_gli);
    row_range_dat = num_rows_gli + (1:num_rows_dat);
    col_range_gli = (1:num_cols_gli);
    col_range_dat = num_cols_gli + (1:num_cols_dat);
    
    data = nan(num_rows_gli+num_rows_dat, num_cols_gli+num_cols_dat);
    data(row_range_gli, col_range_gli) = data_gli;
    data(row_range_dat, col_range_dat) = data_dat;
    
    % Merge timeSci with timeNav 
    data(row_range_dat, ts_gli_col) = ts_dat;    
    
    % Sort + Remove repetition (should not be a lot with a 1/1000sec precision)
    [ts_unique, ts_unique_idx, ~] = unique(data(:,ts_gli_col));
    data = data(ts_unique_idx,:);
        
    % replace time_dat by time_gli (now merged)
    [ts_gli_present, ts_gli_var_idx] = ismember(timestamp_gli, meta.variables);
    [ts_dat_present, ts_dat_var_idx] = ismember(timestamp_dat, meta.variables);
    data(:,ts_dat_var_idx) = data(:, ts_gli_var_idx);
    
    % Unique timestamp to be used for time filtering (both are the same anyways).
    timestamp_merged = timestamp_gli;
  end
  
  
  %% Perform variable filtering if needed.
  if variable_filtering
    [variable_select, ~] = ismember(meta.variables, variable_list);
    meta.variables = meta.variables(variable_select);
    data = data(:, variable_select);
  end
  
  
  %% Perform time filtering if needed.
  if time_filtering
    [ts_merged_present, ts_merged_col] = ...
      ismember(timestamp_merged, meta.variables);
    if ~ts_merged_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp variable in merged data set: %s.', ...
            timestamp_merged);
    end
    ts_merged = data(:, ts_merged_col);
    ts_select = ~(ts_merged < time_range(1) | ts_merged > time_range(2));
    data = data(ts_select, :);
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
