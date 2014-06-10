function [xbds, logs] = getDockserverFiles(dockserver, glider, xbd_dir, log_dir, varargin)
%GETDOCKSERVERFILES  Get binary data files and surface log files from dockserver through FTP.
%
%  Syntax:
%    [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR)
%    [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPTIONS)
%    [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPT1, VAL1, ...)
%
%  [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR) 
%  retrieves new binary files (.[smdtne]bd) and surface dialog files from the
%  glider named GLIDER from the remote dockserver defined by struct DOCKSERVER
%  to local directories XBD_DIR and LOG_DIR respectively, and returns the list
%  of downloaded files in string cell arrays XBDS and LOGS. Existing files in 
%  the local directories are updated only if the remote ones are larger.
%
%  DOCKSERVER is a struct with the fields needed by the function FTP:
%    HOST: url as either fully qualified name or IP (string).
%    USER: user to access the dockserver (string).
%    PASS: password of the dockserver (string).
%
%  [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPTIONS) and
%  [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPT1, VAL1, ...)
%  accept the following options, given in key-value pairs OPT1, VAL1... or in a
%  struct OPTIONS with field names as option keys and field values as option 
%  values, allowing to restrict the set of files to download:
%    XBD: binary file name pattern.
%      Download binary files matching given pattern only.
%      Its value may be any valid regular expression string or false.
%      Set it to the empty string or false to disable download.
%      Default value: '^.+\.[smdtne]bd$'
%    LOG: log file name pattern.
%      Download log files matching given pattern only.
%      Its value may be any valid regular expression string.
%      Set it to the empty string or false to disable download.
%      Default value: '^.+\.log$' 
%    START: initial date of the period of interest.
%      If given, do not download files before the given date.
%      It may be any valid input to the function DATENUM.
%      Default value: -Inf
%    FINAL: final date of the period of interest.
%      If given, do not download files after the the given date.
%      It may be any valid input to the function DATENUM.
%      Default value: +Inf
%    XBD2DATE: binary file name to date conversion.
%      If date filtering is enabled, use the given function to extract the date
%      of a binary file from its name. The function receives a string with the
%      file name and should return a date in any format accepted by DATENUM.
%      Default value: see note on date filtering.
%    LOG2DATE: log file name to date conversion.
%      If date filtering is enabled, use the given function to extract the date
%      of a log file from its name. The function receives a string with the
%      file name and should return a date in any format accepted by DATENUM.
%      Default value: see note on date filtering.
%
%  Notes:
%    Date filtering is done based on the mission date from the file names, not
%    on the file attributes. By default, it relies on remote file names having
%    the conventional Slocum file name format.
%    For binary files it is:
%      ru07-2011-347-4-0.sbd
%    where
%      ru07: glider name.
%      2011: year in which the mission was started.
%      347: zero-based day of the year on which the mission was started.
%      4: zero-based mission number for the day the mission was started.
%      0: zero-based segment number of the current mission number.
%    For log files it is:
%      icoast00_modem_20120510T091438.log
%    where
%      icoast00: glider name.
%      modem: transmission method ('modem' or 'network').
%      20120510T091438: ISO 8601 UTC timestamp.
%
%    This function is based on the previous work by Tomeu Garau. He is the true
%    glider man.
%
%  Examples:
%   dockserver.host = 'ftp.mydockserver.org'
%   dockserver.user = 'myself'
%   dockserver.pass = 'top_secret'   
%   glider = 'happyglider'
%   xbd_dir = '~/my_glider/binary'
%   log_dir = '~/my_glider/log'
%   % Get all binary and log files.
%   [xbds, logs] = getDockserverFiles(dockserver, glider, xbd_dir, log_dir)
%   % Get only small files and no logs from missions started last month:
%   [xbds, logs] = getDockserverFiles(dockserver, glider, xbd_dir, log_dir, ...
%                                     'xbd', '^*.[st]bd$', 'log', '', ...
%                                     'start', now()-30, 'final', now())
%
%  See also:
%    FTP
%    DATENUM
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  error(nargchk(4, 12, nargin, 'struct'));

  
  %% Set options and default values.
  options.start = -Inf;
  options.final = +Inf;
  options.xbd = '^.+\.[smdtne]bd$';
  options.log = '^.+\.log$';
  options.xbd2date = ...
    @(s)(str2double(regexp(s, '^.*-(\d{4})-(\d{3})-\d+-\d+\.[smdtne]bd$', ...
                    'tokens','once')) * [1 0 0; 0 0 1] + [0 0 1]);
  options.log2date = ...
    @(s)(str2double(regexp(s, '^.*_.*_(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\.log$', ...
                    'tokens','once')) );
  
  
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
    error('glider_toolbox:getDockserverFiles:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:getDockserverFiles:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end


  %% Dockserver (remote) directory definition.
  % Consider pass these paths as (maybe optional) input arguments.
  % Old dockservers used this other base path:
  %remote_base_dir = '/home/dockserver/gliders';
  remote_base_dir = '/var/opt/gmc/gliders';
  remote_xbd_dir = [remote_base_dir '/' lower(glider) '/' 'from-glider'];
  remote_log_dir = [remote_base_dir '/' lower(glider) '/' 'logs'];


  %% Collect some parameters given in options.
  xbd_name = options.xbd;
  log_name = options.log;
  xbd_date_args = {};
  log_date_args = {};
  if isfinite(datenum(options.start)) || isfinite(datenum(options.final))
    xbd_date_args = {options.start, options.final, options.xbd2date};
    log_date_args = {options.start, options.final, options.log2date};
  end


  %% Open ftp connection.
  disp(['Connecting to host ' dockserver.host '...']);
  ftp_handle = ftp(dockserver.host, dockserver.user, dockserver.pass);


  %% Binary data file download.
  disp('Downloading binary data files...');
  xbds = {};
  if xbd_name
    try
     xbds = fetchNewAndUpdatedFiles(ftp_handle, remote_xbd_dir, ...
                                    xbd_dir, xbd_name, xbd_date_args{:});
    catch exception
      warning('glider_toolbox:getDockserverFiles:DownloadError', ...
              'Error download binary data files: %s', exception.message);
    end
    disp([num2str(numel(xbds)) ' new/updated binary data files fetched.']);
  end


  %% Surface log file download.
  disp('Downloading surface log files...');
  logs = {};
  if log_name
    try
     logs = fetchNewAndUpdatedFiles(ftp_handle, remote_log_dir, ...
                                    log_dir, log_name, log_date_args{:});
    catch exception
      warning('glider_toolbox:getDockserverFiles:DownloadError', ...
              'Error download surface log files: %s.', exception.message);
    end
    disp([num2str(numel(logs)) ' new/updated surface log files fetched.']);
  end

  %% Close ftp connection.
  close(ftp_handle);
  disp(['Closed connection to host ' dockserver.host '.']);

end


function files = fetchNewAndUpdatedFiles(ftp_handle, remote_dir, local_dir, name, start_date, final_date, name2date)
%FETCHNEWANDUPDATEDFILES Fetch only new or updated files from remote ftp directory.
%
%  FILES = FETCHNEWANDUPDATEDFILES(FTP_HANDLE, REMOTE_DIR, LOCAL_DIR, NAME)
%  Download all files with names matching the pattern NAME from remote directory
%  REMOTE_DIR  to local directory LOCAL_DIR using the valid ftp connection
%  FTP_HANDLE. It returns the list of downloaded files.
%
%  FILES = FETCHNEWANDUPDATEDFILES(..., START_DATE, FINAL_DATE, NAME2DATE)
%  filters the files to download to those ones whose date obtained from name
%  scanning according to NAME2DATE falls between START_DATE and FINAL_DATE.
  files = {};
  % Enable date filtering if optional argument has be passed.
  filter_date = (nargin==7);
  % List remote files.
  remote_files = dir(ftp_handle, remote_dir);
  % Check the list of remote files.
  if isempty(remote_files)
    disp(['Non existing or empty remote directory ' remote_dir '.']);
    return;
  end
  % Go to remote directory (it should be save here).
  cd(ftp_handle, remote_dir);
  % Select files mathcing name pattern and date.
  remote_match = ~cellfun(@isempty, regexp({remote_files.name}, name, 'match'));
  remote_files = remote_files(remote_match);
  if filter_date
    remote_dates = cellfun(@(s) datenum(name2date(s)), {remote_files.name});
    remote_indate = ...
      datenum(start_date) <= remote_dates & remote_dates <= datenum(final_date);
    remote_files = remote_files(remote_indate);
  end
  if isempty(remote_files)
    disp(['No files satisfying criteria in remote directory ' remote_dir '.']);
    return;
  end
  % Check for files already existing in the local directory.
  [status, attrout] = fileattrib(local_dir);
  if ~status
    % Create local directory.
    [success, message] = mkdir(local_dir);
    if ~success
      error('glider_toolbox:getDockserverFiles:LocalDirectoryError', ...
            'Could not create directory %s: %s.', local_dir, message);
    end
  elseif ~attrout.directory
    % Given local directory path points to a file, not a directory.
    error('glider_toolbox:getDockserverFiles:LocalDirectoryError', ...
          'Not a directory: %s.', attrout.Name);
  else
    % Select only new files or files whose size is bigger in the dockserver.
    local_files = dir(local_dir);
    [existing, local_idx] = ismember({remote_files.name}, {local_files.name});
    updated = ...
      [remote_files(existing).bytes] > [local_files(local_idx(existing)).bytes];
    to_download = ~existing;
    to_download(existing) = updated;
    remote_files = remote_files(to_download);
  end
  if isempty(remote_files)
    disp(['No new/updated files in remote directory ' remote_dir '.']);
    return;
  end
  % Download the files.
  files = cellfun(@(f) mget(ftp_handle, f, local_dir), {remote_files.name});
end
