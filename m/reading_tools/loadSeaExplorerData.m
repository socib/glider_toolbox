function [meta, data] = loadSeaExplorerData(sxdir, gliregexp, datregexp, varargin)
%LOADSEAEXPLORERDATA  Load SeaExplorer data from .gli and .dat files in directory.
%
%  Syntax:
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP)
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP, OPTIONS)
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP)
%    loads data and metadata from SeaExplorer files in ascii text format
%    (.gli or .dat) contained in directory named by string SXDIR and whose
%    name matches regular expression in string GLIREGEXP (navigation files)
%    or in string DATREGEXP (science files). META and DATA contain loaded
%    metadata and data in the format returned by functions SXCAT and SXMERGE.
%
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP, OPTIONS) and
%    [META, DATA] = LOADSEAEXPLORERDATA(SXDIR, GLIREGEXP, DATREGEXP, OPT1, VAL1, ...) 
%    accept the following options, given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values, allowing to restrict the time range or the set of
%    variables to load, or to specify the output format:
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
%      loadSeaExplorerData(ascii_dir, gliregexp, datregexp)
%    [meta, data] = ...
%      loadSeaExplorerData(ascii_dir, '^.*.gli.*$', '^.*.dat.*$', ...
%                          'timegli', 'Timestamp', ...
%                          'timedat', 'PLD_REALTIMECLOCK', ...
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
  dat_sel = ~[sxdir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({sxdir_contents.name}, datregexp));
  gli_names = {sxdir_contents(gli_sel).name};
  gli_sizes = [sxdir_contents(gli_sel).bytes];
  dat_names = {sxdir_contents(dat_sel).name};
  dat_sizes = [sxdir_contents(dat_sel).bytes];
  disp(['SeaExplorer .gli files found: ' num2str(numel(gli_names)) ...
        ' (' num2str(sum(gli_sizes)*2^-10) ' kB).']);
  disp(['SeaExplorer .dat files found: ' num2str(numel(dat_names)) ...
        ' (' num2str(sum(dat_sizes)*2^-10) ' kB).']);
  
  
  %% Load .gli files.
  disp('Loading SeaExplorer .gli files...');
  gli_files = cell(size(gli_names));
  gli_success = false(size(gli_names));
  meta_gli = cell(size(gli_names));
  data_gli = cell(size(gli_names));
  for gli_idx = 1:numel(gli_names)
    try
      gli_files{gli_idx} = fullfile(sxdir, gli_names{gli_idx});
      [meta_gli{gli_idx}, data_gli{gli_idx}] = ...
        sx2mat(gli_files{gli_idx}, 'variables', options.variables);
      gli_success(gli_idx) = true;
    catch exception
      disp(['Error loading SeaExplorer .gli file ' gli_files{gli_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_gli = meta_gli(gli_success);
  data_gli = data_gli(gli_success);
  disp(['SeaExplorer .gli files loaded: ' ...
        num2str(numel(data_gli)) ' of ' num2str(numel(gli_names)) '.']);
  
  
  %% Load .dat files.
  disp('Loading SeaExplorer .dat files...');
  dat_files = cell(size(dat_names));
  dat_success = false(size(dat_names));
  meta_dat = cell(size(dat_names));
  data_dat = cell(size(dat_names));
  for dat_idx = 1:numel(dat_names)
    try
      dat_files{dat_idx} = ...
        fullfile(sxdir, dat_names{dat_idx});
      [meta_dat{dat_idx}, data_dat{dat_idx}] = ...
        sx2mat(dat_files{dat_idx}, 'variables', options.variables);     
      dat_success(dat_idx) = true;
    catch exception
      disp(['Error loading SeaExplorer .dat file ' dat_files{dat_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_dat = meta_dat(dat_success);
  data_dat = data_dat(dat_success);
  disp(['SeaExplorer .dat files loaded: ' ...
        num2str(numel(data_dat)) ' of ' num2str(numel(dat_names)) '.']);
  
  
  %% Combine data from .gli and .dat files.
  [meta_gli, data_gli] = sxcat(meta_gli, data_gli, options.timegli);
  [meta_dat, data_dat] = sxcat(meta_dat, data_dat, options.timedat);
  
  
  %% Merge data from both bays.
  [meta, data] = ...
    sxmerge(meta_gli, data_gli, meta_dat, data_dat, ...
            'variables', options.variables, 'period', options.period, ...
            'format', options.format);

end
