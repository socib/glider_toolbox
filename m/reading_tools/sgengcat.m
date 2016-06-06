function [meta, data] = sgengcat(meta_list, data_list, varargin)
%SGENGCAT  Combine data from several Segalider eng files.
%
%  Syntax:
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST)
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST, OPTIONS)
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST) combines metadata in
%    struct array META_LIST and data in cell or struct array DATA_LIST into
%    a single data set with metadata in struct META and data in struct DATA.
%    Respective elements in META_LIST and DATA_LIST should be in the format 
%    returned by function SGENG2MAT, but do not need to have the same parameters 
%    or variables. Outputs META and DATA are in the same format, too, and gather
%    the input data sorted according to the mission number and the dive number.
%
%    META is a struct array combining the information in elements of META_LIST,
%    ordered according to the mission number and the dive number.
%    It has the following fields:
%      HEADERS: struct array with all eng headers.
%        This is the concatenation of the HEADERS field of all elements in
%        META_LIST.
%      START_SECS: number with the reference time for timestamped lines (start
%        time of first dive as seconds since 1970 January 01 00:00:00 UTC).
%      COLUMNS: string cell array with the names of the columns in the returned 
%        data array (in the same column order as the data).
%      SOURCES: string cell array containing FILENAME.
%
%    DATA is an array or a struct combining the data in DATA_LIST, ordered 
%    according to the mission number and the dive number, and with the time 
%    fields as seconds since the start time of the first dive.
%
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST, OPTIONS) and 
%    [META, DATA] = SGENGCAT(META_LIST, DATA_LIST, OPT1, VAL1, ...) 
%    accept the following options given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with data readings as columns ordered
%            as in the COLUMNS metadata field.
%          'struct': DATA is a struct with column names as field names
%            and column vectors of data columns as field values.
%        Default value: 'array'
%      COLUMNS: data column filtering list.
%        String cell array with the names of the data columns of interest.
%        If given, only parameters present in both the input list and this list
%        will be present in output. The string 'all' may also be given,
%        in which case column filtering is not performed and all columns
%        in the input list will be present in output.
%        Default value: 'all' (do not perform column filtering).
%      PERIOD: time filtering boundaries.
%        Two element numeric array with the start and the end of the period 
%        of interest (seconds since 1970-01-01 00:00:00.00 UTC). If given,
%        only data from dives with start time within this period will be
%        present in output. The string 'all' may also be given, in which case
%        time filtering is not performed and data from all dives will be
%        present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Examples:
%    [meta, data] = sgengcat(meta_list, data_list)
%
%  See also:
%    SGENG2MAT
%    SGLOG2MAT
%    SGLOGCAT
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
    error('glider_toolbox:sgengcat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sgengcat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  column_filter = true;
  column_list = cellstr(options.columns);
  start_filter = true;
  start_range = options.period;
  if ischar(options.columns) && strcmp(options.columns, 'all')
    column_filter = false;
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
    meta_list.headers =  struct('version', {}, 'glider', {}, 'mission', {}, ...
                                'dive', {}, 'basestation_version', {}, ...
                                'start', {}, 'columns', {});
    meta_list.columns = {};
    meta_list.start_secs = [];
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
  all_headers = vertcat(meta_list.headers);
  all_start_secs = vertcat(meta_list.start_secs);
  all_columns = {meta_list.columns}';
  % Filter data columns.
  outcol_list = unique(vertcat(all_columns{:}));
  column_filtering = true(size(outcol_list));
  if column_filter
    column_filtering = ismember(outcol_list, column_list);
  end
  outcol_list = outcol_list(column_filtering);
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
  starts_list = all_start_secs(time_filtering_and_miss_dive_sorting, :);
  datcol_list = all_columns(time_filtering_and_miss_dive_sorting, :);
  values_list = data_list(time_filtering_and_miss_dive_sorting, :);
  
  
  %% Reorder data columns and correct time offset converting to array if needed. 
  time_column = 'elaps_t';
  dive_start_offset_list = starts_list - min(starts_list);
  outdat_list = cell(size(values_list));
  for data_idx = 1:numel(values_list)
    values = values_list{data_idx};
    offset = dive_start_offset_list(data_idx);
    datcol = datcol_list{data_idx};
    [col_present, col_indices] = ismember(outcol_list, datcol);
    time_select = strcmp(time_column, datcol);
    if isstruct(values)
      values  = cell2mat(struct2cell(values)');
    end
    values(:, time_select) = values(:, time_select) + offset;
    outdat_list{data_idx} = nan(size(values, 1), numel(outcol_list));
    outdat_list{data_idx}(:, col_present) = values(:, col_indices(col_present));
  end
  
  
  %% Cat metadata and data.
  meta = struct();
  meta.sources = source_list;
  meta.headers = header_list;
  meta.start_secs = min(starts_list);
  meta.columns = outcol_list;
  data = vertcat(outdat_list{:});
  
  
  %% Convert output data to struct format if needed.
  switch output_format
    case 'array'
    case 'struct'
      data = cell2struct(num2cell(data, 1), meta.columns, 2);
    otherwise
      error('glider_toolbox:sgengcat:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
