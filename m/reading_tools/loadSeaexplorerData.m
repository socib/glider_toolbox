function [meta, data] = loadSeaexplorerData(ascii_dir, name_pattern_nav, name_pattern_sci, varargin)
%LOADSEAEXPLORERDATA  Load SeaExplorer data from raw files in directory.
%
%  Syntax:
%    [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI)
%    [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI, OPTIONS)
%    [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI, OPT1, VAL1, ...)
%
%  [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI)
%  loads data and from Seaexplorer files in ascii text format
%  (*.gli.* or *.dat.*) contained in directory named by string
%  ASCII_DIR and whose name matches regular expression  in string
%  NAME_PATTERN_NAV (navigation files) or in string
%  NAME_PATTERN_SCI (science files). META and DATA contain loaded
%  metadata and data in the format  returned by functions SXCAT and SXMERGE.
%
%  [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI, OPTIONS) and
%  [META, DATA] = LOADSEAEXPLORERDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI, OPT1, VAL1, ...) 
%  accept the following options, given in ke-yvalue pairs OPT1, VAL1... or in a
%  struct OPTIONS with field names as option keys and field values as option 
%  values, allowing to restrict the time range or the sensor set of the data to
%  load, or to specify the output format:
%    
%    FORMAT: data output format.
%      String setting the format of the output DATA. Valid values are:
%        'array': DATA is a matrix with sensor readings as columns 
%           ordered as in the 'variables' metadata field.
%        'struct': DATA is a struct with sensor names as field names and column 
%           vectors of sensor readings as field values.
%      Default value: 'array'
%    TIMENAV: navigation data time stamp.
%      String setting the navigation data time sensor for merging and sorting 
%      sensor cycles.
%      Default value: 'Posixtime'
%    TIMESCI: scientific data time stamp.
%      String setting the scientific data time sensor for merging and sorting 
%      sensor cycles.
%      Default value: 'Posixtime'
%    VARIABLES: sensor filtering list.
%      String cell array with the names of the variables of interest. If given,
%      only variables present in both the input data sets and this list will be 
%      present in output. The string 'all' may also be given, in which case 
%      sensor filtering is not performed and all variables in input list will be 
%      present in output.
%      Default value: 'all' (do not perform sensor filtering).
%    PERIOD: time filtering boundaries.
%      Two element numeric array with the start and the end of the period 
%      of interest (seconds since 1970-01-01 00:00:00.00 UTC). If given,
%      only sensor cycles with timestamps within this period will be 
%      present in output. The string 'all' may also be given, in which case
%      time filtering is not performed and all variables cycles in input datsets
%      will be present in output.
%      Default value: 'all' (do not perform time filtering).
%
%  Notes:
%    This function is a simple shortcut to load all seaExplorer
%    files data in a directory belonging to the same deployment or
%    transect. It just filters the contents of the directory and
%    calls SX2MAT, SXCAT and SXMERGE, bypassing the given 
%    options (with conversions when needed). 
%
%  Examples:
%    [meta, data] = ...
%      loadSeaexplorerData(ascii_dir, name_pattern_nav, name_pattern_sci)
%    [meta, data] = ...
%      loadSeaexplorerData(ascii_dir, '^.*.gli.*$', '^.*.dat.*$', ...
%                     'timenav', 'Posixtime', 'timesci', 'Posixtime', ...
%                     'variables', variables_of_interest, 'period', period_of_interest, ...
%                     'format', 'struct');
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

error(nargchk(3, 13, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.timenav = 'Posixtime';
  options.timesci = 'Posixtime';
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
    error('glider_toolbox:loadSeaexplorerData:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:loadSeaexplorerData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Get file names matching the desired patterns.
  % Flatten lists to discard unmatched files.
  ascii_dir_contents = dir(ascii_dir);
  sx_nav_sel = ~[ascii_dir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({ascii_dir_contents.name}, name_pattern_nav));
  sx_sci_sel = ~[ascii_dir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({ascii_dir_contents.name}, name_pattern_sci));
  sx_nav_names = {ascii_dir_contents(sx_nav_sel).name};
  sx_nav_sizes = [ascii_dir_contents(sx_nav_sel).bytes];
  sx_sci_names = {ascii_dir_contents(sx_sci_sel).name};
  sx_sci_sizes = [ascii_dir_contents(sx_sci_sel).bytes];
  disp(['Navigation data files found: ' num2str(numel(sx_nav_names)) ...
        ' (' num2str(sum(sx_nav_sizes)*2^-10) ' kB).']);
  disp(['Scientific data files found: ' num2str(numel(sx_sci_names)) ...
        ' (' num2str(sum(sx_sci_sizes)*2^-10) ' kB).']);
   
  
  %% Load navigation files.
  disp('Loading navigation files...');
  sx_nav_files = cell(size(sx_nav_names));
  sx_nav_success = false(size(sx_nav_names));
  meta_nav = cell(size(sx_nav_names));
  data_nav = cell(size(sx_nav_names));
  for sx_nav_idx = 1:numel(sx_nav_names)
    try
     sx_nav_files{sx_nav_idx} = ...
       fullfile(ascii_dir, sx_nav_names{sx_nav_idx});
     [meta_nav{sx_nav_idx}, data_nav{sx_nav_idx}] = ...
         sx2mat(sx_nav_files{sx_nav_idx}, 'variables', options.variables);     
     sx_nav_success(sx_nav_idx) = true;
    catch exception
      disp(['Error loading ascii file ' sx_nav_files{sx_nav_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_nav = meta_nav(sx_nav_success);
  data_nav = data_nav(sx_nav_success);
  disp(['Navigation files loaded: ' ...
        num2str(numel(data_nav)) ' of ' num2str(numel(sx_nav_names)) '.']);

  
  %% Load science files.
  disp('Loading science files...');
  sx_sci_files = cell(size(sx_sci_names));
  sx_sci_success = false(size(sx_sci_names));
  meta_sci = cell(size(sx_sci_names));
  data_sci = cell(size(sx_sci_names));
  for sx_sci_idx = 1:numel(sx_sci_names)
    try
     sx_sci_files{sx_sci_idx} = ...
       fullfile(ascii_dir, sx_sci_names{sx_sci_idx});     
     [meta_sci{sx_sci_idx}, data_sci{sx_sci_idx}] = ...
         sx2mat(sx_sci_files{sx_sci_idx}, 'variables', options.variables);     
     sx_sci_success(sx_sci_idx) = true;
    catch exception
      disp(['Error loading ascii file ' sx_sci_files{sx_sci_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_sci = meta_sci(sx_sci_success);
  data_sci = data_sci(sx_sci_success);
  disp(['Science files loaded: ' ...
        num2str(numel(data_sci)) ' of ' num2str(numel(sx_sci_names)) '.']);
      

  %% Combine data from each bay.
  disp('Concatenate data...');
  [meta_nav, data_nav] = sxcat(meta_nav, data_nav, options.timenav);
  [meta_sci, data_sci] = sxcat(meta_sci, data_sci, options.timesci);


  %% Merge data from both bays. (NaNs appears in time here!)
  [meta, data] = ...
    sxmerge(meta_nav, data_nav, meta_sci, data_sci, ...
             'variables', options.variables, 'period', options.period, ...
             'format', options.format);
end

