function [meta, data] = loadSlocumData(ascii_dir, name_pattern_nav, name_pattern_sci, varargin)
%LOADSLOCUMDATA  Load Slocum data from dba files in directory.
%
%  [META, DATA] = LOADSLOCUMDATA(ASCII_DIR, NAME_PATTERN_NAV, NAME_PATTERN_SCI)
%  loads data and from Slocum files in ascii text format (dba) contained in 
%  directory named by string ASCII_DIR and whose name matches regular expression
%  in string NAME_PATTERN_NAV (navigation files) or in string NAME_PATTERN_SCI 
%  (science files). META and DATA contain loaded metadata and data in the format 
%  returned by functions DBACAT and DBAMERGE.
%
%  [META, DATA] = LOADSLOCUMDATA(..., OPT1, VAL1, ...) accepts the following 
%  options allowing to restrict the time range or the sensor set of the data 
%  to load, or specify the output format:
%    'format': a string setting the format of the output DATA. Valid values are:
%      'array' (default): DATA is a matrix whith sensor readings as columns 
%         ordered as in the 'sensors' metadata field.
%      'struct': DATA is a struct with sensor names as field names and column 
%         vectors of sensor readings as field values.
%    'timestamp_nav': a string setting the time sensor from navigation data for
%      merging and sorting sensor cycles. Default value is 'm_present_time'.
%    'timestamp_sci': a string setting the time sensor from science data for 
%      merging and sorting sensor cycles. Default value is 'sci_m_present_time'.
%    'sensors': a string cell array with the names of the sensors of interest.
%      If given, only sensors present in both the input data sets and this list
%      will be present in output.
%    'period': a two element numeric array with the start and end of the time
%      interval of interest (UTC serial date numbers). If given, only sensor 
%      cycles with timestamps within this period will be present in output.
%
%  Notes:
%    This function is a simple shortcut to load all dba data in a directory
%    belonging to the same deployment or transect. It just filters the contents
%    of the directory and calls DBA2MAT, DBACAT and DBAMERGE, bypassing the
%    given options (with conversions when needed).
%
%  Examples:
%    [meta, data] = loadSlocumData(ascii_dir, name_pattern_nav, name_pattern_sci)
%    [meta, data] = loadSlocumData(ascii_dir, name_pattern_nav, name_pattern_sci, ...
%                                  'timestamp_nav', 'm_present_time', ...
%                                  'timestamp_sci', 'sci_m_present_time', ...
%                                  'sensors', sensors_of_interest, ..
%                                  'period', period_of_interset, ...
%                                  'format', 'struct');
%
%  See also:
%    DIR
%    REGEXP
%    DBA2MAT
%    DBACAT
%    DBAMERGE
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(3, 13, nargin, 'struct'));
  
  
  %% Set option values.
  timestamp_nav_args = {'timestamp_nav' 'm_present_time'};
  timestamp_sci_args = {'timestamp_sci' 'sci_m_present_time'};
  format_args = {};
  sensor_filtering_args = {};
  time_filtering_args = {};
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'format'
        format_args = {opt val};
      case 'timestamp_nav'
        timestamp_nav_args = {opt val};
      case 'timestamp_sci'
        timestamp_sci_args = {opt val};
      case 'sensors'
        sensor_filtering_args = {opt val};
      case 'period'
        time_filtering_args = {opt utc2posixtime(val)};
      otherwise
        error('glider_toolbox:loadSlocumData:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end
  
  
  %% Get file names matching the desired patterns.
  % Flatten lists to discard unmatched files.
  ascii_dir_contents = dir(ascii_dir);
  dba_nav_sel = ~[ascii_dir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({ascii_dir_contents.name}, name_pattern_nav));
  dba_sci_sel = ~[ascii_dir_contents.isdir] ...
    & ~cellfun(@isempty, regexp({ascii_dir_contents.name}, name_pattern_sci));
  %{
  dba_nav_names = regexp(dba_all_names, name_pattern_nav, 'match');
  dba_sci_names = regexp(dba_all_names, name_pattern_sci, 'match');
  dba_nav_names = [dba_nav_names{:}];
  dba_sci_names = [dba_sci_names{:}];
  %}
  dba_nav_names = {ascii_dir_contents(dba_nav_sel).name};
  dba_nav_sizes = [ascii_dir_contents(dba_nav_sel).bytes];
  dba_sci_names = {ascii_dir_contents(dba_sci_sel).name};
  dba_sci_sizes = [ascii_dir_contents(dba_sci_sel).bytes];
  disp(['Navigation data files found: ' num2str(numel(dba_nav_names)) ...
        ' (' num2str(sum(dba_nav_sizes)*2^-10) ' kB).']);
  disp(['Scientific data files found: ' num2str(numel(dba_sci_names)) ...
        ' (' num2str(sum(dba_sci_sizes)*2^-10) ' kB).']);
  
  
  %% Load navigation files.
  disp('Loading navigation files...');
  dba_nav_files = cell(size(dba_nav_names));
  dba_nav_success = false(size(dba_nav_names));
  meta_nav = cell(size(dba_nav_names));
  data_nav = cell(size(dba_nav_names));
  for dba_nav_idx = 1:numel(dba_nav_names)
    try
     dba_nav_files{dba_nav_idx} = ...
       fullfile(ascii_dir, dba_nav_names{dba_nav_idx});
     [meta_nav{dba_nav_idx}, data_nav{dba_nav_idx}] = ...
       dba2mat(dba_nav_files{dba_nav_idx}, sensor_filtering_args{:});
     dba_nav_success(dba_nav_idx) = true;
    catch exception
      disp(['Error loading ascii file ' dba_nav_files{dba_nav_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_nav = meta_nav(dba_nav_success);
  data_nav = data_nav(dba_nav_success);
  disp(['Navigation files loaded: ' ...
        num2str(numel(data_nav)) ' of ' num2str(numel(dba_nav_names)) '.']);


  %% Load science files.
  disp('Loading science files...');
  dba_sci_files = cell(size(dba_sci_names));
  dba_sci_success = false(size(dba_sci_names));
  meta_sci = cell(size(dba_sci_names));
  data_sci = cell(size(dba_sci_names));
  for dba_sci_idx = 1:numel(dba_sci_names)
    try
     dba_sci_files{dba_sci_idx} = ...
       fullfile(ascii_dir, dba_sci_names{dba_sci_idx});
     [meta_sci{dba_sci_idx}, data_sci{dba_sci_idx}] = ...
       dba2mat(dba_sci_files{dba_sci_idx}, sensor_filtering_args{:});
     dba_sci_success(dba_sci_idx) = true;
    catch exception
      disp(['Error loading ascii file ' dba_sci_files{dba_sci_idx} ':']);
      disp(getReport(exception, 'extended'));
    end
  end
  meta_sci = meta_sci(dba_sci_success);
  data_sci = data_sci(dba_sci_success);
  disp(['Science files loaded: ' ...
        num2str(numel(data_sci)) ' of ' num2str(numel(dba_sci_names)) '.']);


  %% Combine data from each bay.
  if ~isempty(meta_nav)
    [meta_nav, data_nav] = ...
      dbacat(meta_nav, data_nav, timestamp_nav_args{2});
  end
  if ~isempty(meta_sci)
    [meta_sci, data_sci] = ...
      dbacat(meta_sci, data_sci, timestamp_sci_args{2});
  end
  
  
  %% Merge data from both bays.
  [meta, data] = ...
    dbamerge(meta_nav, data_nav, meta_sci, data_sci, ...
             format_args{:}, sensor_filtering_args{:}, time_filtering_args{:});

end
