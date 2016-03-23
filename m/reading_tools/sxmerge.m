function [meta, data] = sxmerge(meta_nav, data_nav, meta_sci, data_sci, varargin)
%SXMERGE  Merge data from combined navigation and science data sets into a single data set.
%
%  Syntax:
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI)
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPTIONS)
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPT1, VAL1, ...) 
%
%  Description:
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI) merges the
%    navigation and science data sets described by metadata structs META_NAV and
%    META_SCI, and data arrays DATA_NAV and DATA_SCI into a single data set
%    described by metadata struct META and data array or struct DATA 
%    (see format option described below). Input metadata and data should be
%    in the format returned by the function SXCAT. Sensor cycles from both 
%    data sets are merged based on the order of the respective timestamps.
%    See note on merging process.
%
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPTIONS) and
%    [META, DATA] = SXMERGE(META_NAV, DATA_NAV, META_SCI, DATA_SCI, OPT1, VAL1, ...) 
%    accept the following options given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with sensor readings as columns 
%            ordered as in the 'variables' metadata field.
%          'struct': DATA is a struct with sensor names as field names
%            and column vectors of sensor readings as field values.
%        Default value: 'array'
%      TIMENAV: navigation data time stamp.
%        String setting the navigation data time sensor for merging and sorting 
%        sensor cycles.
%        Default value: 'm_present_time'
%      TIMESCI: scientific data time stamp.
%        String setting the scientific data time sensor for merging and sorting 
%        sensor cycles.
%        Default value: 'sci_m_present_time'
%      VARIABLES: sensor filtering list.
%        String cell array with the names of the variables of interest. If given,
%        only variables present in both the input data sets and this list
%        will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all variables
%        in input data sets will be present in output.
%        Default value: 'all' (do not perform sensor filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:0:00.00 UTC). If given, 
%        only sensor cycles with timestamps within this period will be
%        present in output. The string 'all' may also be given, in which case
%        time filtering is not performed and all variables cycles in the input 
%        data sets will be present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function should be used to merge data from navigation and science data
%    sets, not from data sets coming from the same bay (use SXCAT instead).
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
%    [meta, data] = sxmerge(meta_nav, data_nav, meta_sci, data_sci)
%
%  See also:
%    SX2MAT
%    SXCAT
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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
  options.timenav = 'Posixtime_nav';
  options.timesci = 'Posixtime_sci';
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
  output_format = options.format;
  timestamp_nav = options.timenav;
  timestamp_sci = options.timesci;
  sensor_filtering = true;
  sensor_list = options.variables;
  time_filtering = true;
  time_range = options.period;
  if ischar(options.variables) && strcmp(options.variables, 'all')
    sensor_filtering = false;
  end
  if ischar(options.period) && strcmp(options.period, 'all')
    time_filtering = false;
  end
  
  
  %% Merge data and metadata checking for empty input cases.
  if isempty(meta_sci.sources) && isempty(meta_nav.sources)
    % No input data.
    % Both META_NAV and DATA_NAV, and META_SCI and DATA_SCI
    % are equal to the trivial output of SXCAT.
    % Disable filtering.
    meta = meta_nav; 
    data = data_nav;
    sensor_filtering = false;
    time_filtering = false;
  elseif isempty(meta_sci.sources)
    % Only navigation data.
    meta = meta_nav;
    data = data_nav;
    timestamp_merged = timestamp_nav; % Unique timestamp to be used for time filtering.
  elseif isempty(meta_nav.sources)
    % Only science data.
    meta = meta_sci;
    data = data_sci;
    timestamp_merged = timestamp_sci; % Unique timestamp to be used for time filtering.
  else
    % Merge metadata performing sensor renaming if needed.
    % Sensor renaming is done to mimic the behaviour of WRC program 'sx_merge'.
    sources_nav = meta_nav.sources;
    headers_nav = meta_nav.headers;
    variables_nav_list = meta_nav.variables;
    units_nav_list = meta_nav.units;
    bytes_nav_list = meta_nav.bytes;
    sources_sci = meta_sci.sources;
    headers_sci = meta_sci.headers;
    variables_sci_list = meta_sci.variables;
    units_sci_list = meta_sci.units;
    bytes_sci_list = meta_sci.bytes;
    
    % Find duplication in variable names and rename
    [variables_dup_list, variables_dup_index_nav, variables_dup_index_sci] = ...
      intersect(variables_nav_list, variables_sci_list);    
    for i = 1:numel(variables_dup_list)
        sensorName = variables_dup_list{i};
        variables_nav_list{variables_dup_index_nav} = sprintf('%s_nav', sensorName);
        variables_sci_list{variables_dup_index_sci} = sprintf('%s_sci', sensorName);
    end
        
    meta.sources = vertcat(sources_nav, sources_sci);
    meta.headers = vertcat(headers_nav, headers_sci);
    meta.variables = vertcat(variables_nav_list, variables_sci_list);
    meta.units = vertcat(units_nav_list, units_sci_list);
    meta.bytes = vertcat(bytes_nav_list, bytes_sci_list);

    % No need to duplicate here
    if isfield(meta_nav, 'configuration_file')
        meta.configuration_file = meta_nav.configuration_file;
    end
    
    % Merge data.
    % Check that both data sets have their own timestamp sensor.
    [ts_nav_present, ts_nav_col] = ismember(timestamp_nav, variables_nav_list);
    if ~ts_nav_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp sensor in navigation data set: %s.', ...
            timestamp_nav);
    end
    [ts_sci_present, ts_sci_col] = ismember(timestamp_sci, variables_sci_list);

    if ~ts_sci_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp sensor in science data set: %s.', timestamp_sci);
    end

    %% SeaExplorer version %
    ts_nav = data_nav(:,ts_nav_col);
    ts_sci = data_sci(:,ts_sci_col);
    num_rows_nav = numel(ts_nav);
    num_rows_sci = numel(ts_sci);
    num_cols_nav = numel(variables_nav_list);
    num_cols_sci = numel(variables_sci_list);

    row_range_nav = (1:num_rows_nav);
    row_range_sci = num_rows_nav + (1:num_rows_sci);
    col_range_nav = (1:num_cols_nav);
    col_range_sci = num_cols_nav + (1:num_cols_sci);
    
    data = nan(num_rows_nav+num_rows_sci, num_cols_nav+num_cols_sci);
    data(row_range_nav, col_range_nav) = data_nav;
    data(row_range_sci, col_range_sci) = data_sci;

    % Merge timeSci with timeNav 
    data(row_range_sci, ts_nav_col) = ts_sci;    
    
    % Sort + Remove repetition (should not be a lot with a 1/1000sec precision)
    [ts_unique, ts_unique_idx, ~] = unique(data(:,ts_nav_col));
    data = data(ts_unique_idx,:);
        
    % replace time_sci by time_nav (now merged)
    [ts_nav_present, ts_nav_var_idx] = ismember(timestamp_nav, meta.variables);
    [ts_sci_present, ts_sci_var_idx] = ismember(timestamp_sci, meta.variables);
    data(:,ts_sci_var_idx) = data(:,ts_nav_var_idx);
    
    % Unique timestamp to be used for time filtering (both are the same anyways).
    timestamp_merged = timestamp_nav;
  end

 
  %% Perform sensor filtering if needed.
  if sensor_filtering
    [sensor_select, ~] = ismember(meta.variables, sensor_list);
    meta.variables = meta.variables(sensor_select);
    meta.units = meta.units(sensor_select);
    meta.bytes = meta.bytes(sensor_select);
    data = data(:,sensor_select);
  end
  
  
  %% Perform time filtering if needed.
  if time_filtering
    [ts_merged_present, ts_merged_col] = ...
      ismember(timestamp_merged, meta.variables);
    if ~ts_merged_present
      error('glider_toolbox:sxmerge:MissingTimestamp', ...
            'Missing timestamp sensor in merged data set: %s.', ...
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
