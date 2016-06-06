function [meta, data] = loadSeagliderData(sgdir, logregexp, engregexp, varargin)
%LOADSEAGLIDERDATA  Load Seaglider data from log and eng files in directory.
%
%  Syntax:
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP)
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP, OPTIONS)
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP) loads data
%    and metadata from Seaglider files in log text format (.log) and eng data
%    format (.eng) contained in directory named by string SGDIR and whose name 
%    matches regular expression in string LOGREGEXP or string ENGREGEXP. 
%    META and DATA contain loaded metadata and data in the format returned by 
%    SGLOGENGMERGE.
%
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP, OPTIONS) and
%    [META, DATA] = LOADSEAGLIDERDATA(SGDIR, LOGREGEXP, ENGREGEXP, OPT1, VAL1, ...)
%    accept the following options, given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values, allowing to restrict the time range or the set of 
%    data parameters and columns to load, or to specify the output format:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a struct with the following fields:
%            LOG: array with log parameters in the column order specified by
%              PARAMS metadata field.
%            ENG: array or cell array with the eng columns and GC and SM_CCo
%              log parameter columns in the column order specified by COLUMNS
%              metadata field.
%            GPS: array or cell array with the GPS log columns in the order
%              specified by the GPS metadata field.
%            See note on array format.
%          'merged': DATA is a struct with a column vector field for each
%            parameter in log or gps data, and for each column in eng data.
%          'struct': DATA is a struct with a column vector field for each
%            column in eng data and gps data, and for each scalar parameter
%            in log data; and with a struct field for each non-scalar parameter
%            in log data.
%        Default value: 'array'
%      PARAMS: log parameter filtering list.
%        String cell array with the names of the log parameters of interest. 
%        If given, only parameters present in both the input data set and
%        this list will be present in output. For non-scalar parameters,
%        the name of the identifier as it appears in the log line specifies
%        including all of its fields. Individual parameter fields are selected
%        with the identifier and the name of the field separated by underscore
%        (e.g. 'FINISH_dens'). The string 'all' may also be given, 
%        in which case parameter filtering is not performed and all parameters
%        in input list will be present in output.
%        Default value: 'all' (do not perform log parameter filtering).
%      COLUMNS: eng column filtering list.
%        String cell array with the names of the eng data columns of interest. 
%        If given, only columns present in both the input data set and this list
%        will be present in output. The string 'all' may also be given, 
%        in which case column filtering is not performed and all columns
%        in input list will be present in output.
%        Default value: 'all' (do not perform eng column filtering).
%      PERIOD: dive start time filtering boundaries.
%        Two element numeric array with the start and the end of the period
%        of interest (seconds since 1970-01-01 00:00:00.00 UTC). If given,
%        only data from dives with start time within this period will be
%        present in output. The string 'all' may also be given, in which case
%        time filtering is not performed and data from all dives will be
%        present in output.
%        Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function is a simple shortcut to load all log and eng data in a 
%    directory belonging to the same deployment or transect. It just filters 
%    the contents of the directory and calls SGLOG2MAT and SGLOGCAT, SGENG2MAT
%    and SGENGCAT, and finally SGLOGENGMERGE, bypassing the given options.
%
%    When there are both textual and numeric columns in the output,
%    the 'array' format might require a large amount of memory because of the 
%    storage in a cell array. Formats 'struct' and 'merged' require much 
%    less space in that case.
%
%  Examples:
%    [meta, data] = ...
%      loadSeagliderData(sgdir, logregexp, engregexp)
%    [meta, data] = ...
%      loadSeagliderData(sgdir, logregexp, engregexp, ...
%                        'columns', columns_of_interest, ...
%                        'params', params_of_interest, 
%                        'period', period_of_interest, ...
%                        'format', 'merged');
%
%  See also:
%    SGLOG2MAT
%    SGLOGCAT
%    SGENG2MAT
%    SGENGCAT
%    SGLOGENGMERGE
%    DIR
%    REGEXP
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

  error(nargchk(3, 13, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.columns = 'all';
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
    error('glider_toolbox:loadSeagliderData:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:loadSeagliderData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Get file names matching the desired patterns.
  % Flatten lists to discard unmatched files.
  sgdir_contents = dir(sgdir);
  log_sel = ~[sgdir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({sgdir_contents.name}, logregexp));
  eng_sel = ~[sgdir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({sgdir_contents.name}, engregexp));
  log_names = {sgdir_contents(log_sel).name};
  log_sizes = [sgdir_contents(log_sel).bytes];
  eng_names = {sgdir_contents(eng_sel).name};
  eng_sizes = [sgdir_contents(eng_sel).bytes];
  disp(['Seaglider log files found: ' num2str(numel(log_names)) ...
        ' (' num2str(sum(log_sizes)*2^-10) ' kB).']);
  disp(['Seaglider eng files found: ' num2str(numel(eng_names)) ...
        ' (' num2str(sum(eng_sizes)*2^-10) ' kB).']);
  
  
  %% Load log files.
  disp('Loading Seaglider log files...');
  log_files = cell(size(log_names));
  log_success = false(size(log_names));
  meta_log = cell(size(log_names));
  data_log = cell(size(log_names));
  for log_idx = 1:numel(log_names)
    try
      log_files{log_idx} = fullfile(sgdir, log_names{log_idx});
      [meta_log{log_idx}, data_log{log_idx}] = ...
        sglog2mat(log_files{log_idx}, 'params', options.params);
      log_success(log_idx) = true;
    catch exception
      disp(['Error loading Seaglider log file ' log_files{log_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_log = meta_log(log_success);
  data_log = data_log(log_success);
  disp(['Seaglider log files loaded: ' ...
        num2str(numel(data_log)) ' of ' num2str(numel(log_names)) '.']);
  
  
  %% Load eng files.
  disp('Loading Seaglider eng files...');
  eng_files = cell(size(eng_names));
  eng_success = false(size(eng_names));
  meta_eng = cell(size(eng_names));
  data_eng = cell(size(eng_names));
  for eng_idx = 1:numel(eng_names)
    try
      eng_files{eng_idx} = fullfile(sgdir, eng_names{eng_idx});
      [meta_eng{eng_idx}, data_eng{eng_idx}] = ...
        sgeng2mat(eng_files{eng_idx}, 'columns', options.columns);
      eng_success(eng_idx) = true;
    catch exception
      disp(['Error loading Seglider eng file ' eng_files{eng_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_eng = meta_eng(eng_success);
  data_eng = data_eng(eng_success);
  disp(['Seaglider eng files loaded: ' ...
        num2str(numel(data_eng)) ' of ' num2str(numel(eng_names)) '.']);
  
  
  %% Combine data from log and eng files respectively.
  [meta_log, data_log] = sglogcat(meta_log, data_log, 'period', options.period);
  [meta_eng, data_eng] = sgengcat(meta_eng, data_eng, 'period', options.period);
  
  
  %% Merge data from log and eng files.
  [meta, data] = sglogengmerge(meta_log, data_log, meta_eng, data_eng, ...
                               'format', options.format);

end
