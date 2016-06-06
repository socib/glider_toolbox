function [meta, data] = loadSeaExplorerData(sxdir, gliregexp, pldregexp, varargin)
%LOADSEAEXPLORERDATA  Load SeaExplorer data from SeaExplorer glider and payload files in directory.
%
%  Syntax:
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP)
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP, OPTIONS)
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP)
%    loads data and metadata from SeaExplorer glider or payload files
%    in ascii text format contained in directory named by string SXDIR and
%    whose name matches regular expression in string GLIREGEXP (glider files)
%    or in string PLDREGEXP (payload files). META and DATA contain loaded
%    metadata and data in the format returned by functions SXCAT and SXMERGE.
%
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP, OPTIONS) and
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, PLDREGEXP, OPT1, VAL1, ...)
%    accept the following options, given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values, allowing to restrict the time range or the set of
%    variables to load, or to specify the output format:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with variable readings in the column order
%            specified by the VARIABLES metadata field.
%          'struct': DATA is a struct with variable names as field names
%            and column vectors of variable readings as field values.
%        Default value: 'array'
%      TIMEGLI: glider data timestamp.
%        String setting the name of the variable to use as timestamp for merging
%        and sorting data row readings from SeaExplorer glider data set.
%        Default value: 'Timestamp'
%      TIMEPLD: payload data timestamp.
%        String setting the name of the variable to use as timestamp for merging
%        and sorting data row readings from SeaExplorer payload data set.
%        Default value: 'PLD_REALTIMECLOCK'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the variables of interest.
%        If given, only variables present in both the input data sets and this
%        list will be present in output. The string 'all' may also be given,
%        in which case variable filtering is not performed and all variables
%        in input data sets will be present in output.
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
%    This function is a simple shortcut to load all SeaExplorer data
%    in a directory belonging to the same deployment or transect.
%    It just filters the contents of the directory and calls SX2MAT, SXCAT
%    and SXMERGE, bypassing the given options.
%
%  Examples:
%    [meta, data] = ...
%      loadSeaExplorerData(ascii_dir, gliregexp, pldregexp)
%    [meta, data] = ...
%      loadSeaExplorerData(ascii_dir, '^.*.gli.*$', '^.*.pld.*$', ...
%                          'timegli', 'Timestamp', ...
%                          'timepld', 'PLD_REALTIMECLOCK', ...
%                          'variables', variables_of_interest, ...
%                          'period', period_of_interest, ...
%                          'format', 'struct');
%
%  See also:
%    DIR
%    REGEXP
%    SX2MAT
%    SXCAT
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

  error(nargchk(3, 13, nargin, 'struct'));
  
  
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
    error('glider_toolbox:loadSeaExplorerData:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:loadSeaExplorerData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Get file names matching the desired patterns.
  % Flatten lists to discard unmatched files.
  sxdir_contents = dir(sxdir);
  gli_sel = ~[sxdir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({sxdir_contents.name}, gliregexp));
  pld_sel = ~[sxdir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({sxdir_contents.name}, pldregexp));
  gli_names = {sxdir_contents(gli_sel).name};
  gli_sizes = [sxdir_contents(gli_sel).bytes];
  pld_names = {sxdir_contents(pld_sel).name};
  pld_sizes = [sxdir_contents(pld_sel).bytes];
  disp(['SeaExplorer glider files found: ' num2str(numel(gli_names)) ...
        ' (' num2str(sum(gli_sizes)*2^-10) ' kB).']);
  disp(['SeaExplorer payload files found: ' num2str(numel(pld_names)) ...
        ' (' num2str(sum(pld_sizes)*2^-10) ' kB).']);
  
  
  %% Load glider files.
  disp('Loading SeaExplorer glider files...');
  gli_files = cell(size(gli_names));
  gli_success = false(size(gli_names));
  meta_gli = cell(size(gli_names));
  data_gli = cell(size(gli_names));
  for gli_idx = 1:numel(gli_names)
    try
      gli_files{gli_idx} = fullfile(sxdir, gli_names{gli_idx});
      [meta_gli{gli_idx}, data_gli{gli_idx}] = ...
        sx2mat(gli_files{gli_idx}, ...
               'time', options.timegli, 'variables', options.variables);
      gli_success(gli_idx) = true;
    catch exception
      disp(['Error loading SeaExplorer glider file ' gli_files{gli_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_gli = meta_gli(gli_success);
  data_gli = data_gli(gli_success);
  disp(['SeaExplorer glider files loaded: ' ...
        num2str(numel(data_gli)) ' of ' num2str(numel(gli_names)) '.']);
  
  
  %% Load payload files.
  disp('Loading SeaExplorer payload files...');
  pld_files = cell(size(pld_names));
  pld_success = false(size(pld_names));
  meta_pld = cell(size(pld_names));
  data_pld = cell(size(pld_names));
  for pld_idx = 1:numel(pld_names)
    try
      pld_files{pld_idx} = fullfile(sxdir, pld_names{pld_idx});
      [meta_pld{pld_idx}, data_pld{pld_idx}] = ...
        sx2mat(pld_files{pld_idx}, ...
               'time', options.timepld, 'variables', options.variables);
      pld_success(pld_idx) = true;
    catch exception
      disp(['Error loading SeaExplorer payload file ' pld_files{pld_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_pld = meta_pld(pld_success);
  data_pld = data_pld(pld_success);
  disp(['SeaExplorer payload files loaded: ' ...
        num2str(numel(data_pld)) ' of ' num2str(numel(pld_names)) '.']);
  
  
  %% Combine data from either glider or payload files.
  [meta_gli, data_gli] = sxcat(meta_gli, data_gli, options.timegli);
  [meta_pld, data_pld] = sxcat(meta_pld, data_pld, options.timepld);
  
  
  %% Merge data from glider and payload files.
  [meta, data] = ...
    sxmerge(meta_gli, data_gli, meta_pld, data_pld, ...
            'timegli', options.timegli, 'timepld', options.timepld, ...
            'variables', options.variables, 'period', options.period, ...
            'format', options.format);

end
