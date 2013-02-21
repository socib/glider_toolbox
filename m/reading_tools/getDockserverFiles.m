function [bin_files, log_files] = getDockserverFiles(dockserver, glider_name, local_bin_dir, local_log_dir, varargin)
%GETDOCKSERVERFILES  Get binary data files and logs from dockserver through FTP.
%
%  Syntax:
%    GETDOCKSERVERFILES(DOCKSERVER, GLIDER_NAME, LOCAL_BIN_DIR, LOCAL_LOG_DIR)
%    GETDOCKSERVERFILES(DOCKSERVER, GLIDER_NAME, LOCAL_BIN_DIR, LOCAL_LOG_DIR, OPT1, VAL1, ...)
%
%  GETDOCKSERVERFILES(DOCKSERVER, GLIDER_NAME, LOCAL_BIN_DIR, LOCAL_LOG_DIR, ...)
%  retrieve  new .[smdtne]bd files and surface dialog files of the glider named
%  GLIDER_NAME from DOCKSERVER to LOCAL_BIN_DIR and LOCAL_LOG_DIR respectively,
%  returning string cell arrays  with the list of downloaded files.
%  Files already existing in the local directories are considered older than the
%  ones in the dockserver it they are smaller.
%
%  DOCKSERVER is a struct with the fields needed by the function FTP:
%    HOST: url as either fully qualified name or IP (string).
%    USER: user to access the dockserver (string).
%    PASS: password of the dockserver (string).
%
%  The list of files to download may be restricted with the following options:
%    'start': do not not download files previous to the given date.
%        Its value may be any valid input to the function DATENUM.
%    'end': do not not download files previous to the given date.
%        Its value may be any valid input to the function DATENUM.
%    'bin_name': download only binary files matching given pattern.
%        Its value may be any valid regular expression string or false.
%        Set it to the empty string or false to disable downloading.
%    'log_name': download only log files matching given pattern.
%        Its value may be any valid regular expression string.
%        Set it to the empty string or false to disable downloading.
%
%  Notes:
%    Date filtering is done based on the mission date from the file names, not
%    on the file attributes. Hence it relies on remote file names having the
%    conventional Slocum file name format.
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
%   glider_name = 'happyglider'
%   bin_dir = '~/my_glider/binary'
%   log_dir = '~/my_glider/log'
%   % Get all binary and log files.
%   [bin_files, log_files] = ...
%      getDockserverFiles(dockserver, glider_name, bin_dir, log_dir)
%   % Get only small files and no logs from missions started last month:
%   [bin_files, log_files] = ...
%      getDockserverFiles(dockserver, glider_name, bin_dir, log_dir, ...
%                         'bin_name', '^*.[st]bd$',   'log_name', '', ...
%                         'start', now()-30, 'end', now())
%
%  See also:
%    FTP
%    DATENUM
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  %% Argument handling.
  error(nargchk(4, 12, nargin, 'struct'));

  date_filtering = false;
  start_date = -Inf;
  end_date = Inf;
  bin_name = '^.+\.[smdtne]bd$';
  log_name = '^.+\.log$';
  for i=1:2:numel(varargin)
    opt = varargin{i};
    val = varargin{i+1};
    switch lower(opt)
      case 'start'
        start_date = val;
        date_filtering = true;
      case 'end'
        end_date = val;
        date_filtering = true;
      case 'bin_name'
        bin_name = val;
      case 'log_name'
        log_name = val;
      otherwise
        error('glider_toolbox:getDockServerFiles:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end


  %% Dockserver (remote) directory definition.
  % Consider pass these paths as (maybe optional) input arguments.
  % Old dockservers used this other base path:
  %remote_base_dir = '/home/dockserver/gliders';
  remote_base_dir = '/var/opt/gmc/gliders';
  remote_bin_dir = [remote_base_dir '/' lower(glider_name) '/' 'from-glider'];
  remote_log_dir = [remote_base_dir '/' lower(glider_name) '/' 'logs'];


  %% Name date format.
  bin_date_scan = ...
    @(s)( cellfun(@str2double, regexp(s, ...
                                      '^.*-(\d{4})-(\d{3})-\d+-\d+\.[smdtne]bd$', ...
                                      'tokens','once'))*[1 0 0; 0 0 1] + [0 0 1]);
  log_date_scan = ...
    @(s)( cellfun(@str2double, regexp(s, ...
                                      '^.*_.*_(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\.log$', ...
                                      'tokens','once')) );


  %% Date filtering parameters.
  if date_filtering
    bin_date_filtering_params = {start_date, end_date, bin_date_scan};
    log_date_filtering_params = {start_date, end_date, log_date_scan};
  else
    bin_date_filtering_params = {};
    log_date_filtering_params = {};
  end


  %% Open ftp connection.
  disp(['Connecting to host ' dockserver.host '...']);
  ftp_handle = ftp(dockserver.host, dockserver.user, dockserver.pass);


  %% Binary data file downloading.
  disp('Downloading binary data files...');
  bin_files = {};
  if bin_name
    try
     bin_files = fetchNewAndUpdatedFiles(ftp_handle, remote_bin_dir, ...
                                         local_bin_dir, bin_name, ...
                                         bin_date_filtering_params{:});
    catch exception
      warning('glider_toolbox:reading_tools:BinDownloadingError', ...
              'Error downloading binary data files: %s', exception.message);
    end
    disp([num2str(numel(bin_files)) ' new/updated binary data files fetched.']);
  end


  %% Surface log file downloading.
  disp('Downloading surface log files...');
  log_files = {};
  if log_name
    try
     log_files = fetchNewAndUpdatedFiles(ftp_handle, remote_log_dir, ...
                                         local_log_dir, log_name, ...
                                         log_date_filtering_params{:});
    catch exception
      warning('glider_toolbox:reading_tools:LogDownloadingError', ...
              'Error downloading surface log files: %s.', exception.message);
    end
    disp([num2str(numel(log_files)) ' new/updated surface log files fetched.']);
  end

  %% Close ftp connection.
  close(ftp_handle);
  disp(['Closed connection to host ' dockserver.host '.']);

end


function files = fetchNewAndUpdatedFiles(ftp_handle, remote_dir, local_dir, name, start_date, end_date, date_scan)
%FETCHNEWANDUPDATEDFILES Fetch only new or updated files from remote ftp directory.
%
%  FILES = FETCHNEWANDUPDATEDFILES(FTP_HANDLE, REMOTE_DIR, LOCAL_DIR, NAME)
%  Download all files with names matching the pattern NAME from remote directory
%  REMOTE_DIR  to local directory LOCAL_DIR using the valid ftp connection
%  FTP_HANDLE. It returns the list of donloaded files.
%
%  FILES = FETCHNEWANDUPDATEDFILES(..., START_DATE, END_DATE, DATE_SCAN)
%  filters the files to download to those ones whose date obtained from name
%  scanning according to DATE_SCAN falls between START_DATE and END_DATE.
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
    remote_dates = cellfun(@(s) datenum(date_scan(s)), {remote_files.name});
    remote_indate = ...
      datenum(start_date) <= remote_dates & remote_dates <= datenum(end_date);
    remote_files = remote_files(remote_indate);
  end
  if isempty(remote_files)
    disp(['No files satisfying criteria in remote directory ' remote_dir '.']);
    return;
  end
  % Check for files already existing in the local directory.
  if exist(local_dir, 'dir')
    % Select only new files or files whose size is bigger in the dockserver.
    local_files = dir(local_dir);
    [existing, local_idx] = ismember({remote_files.name}, {local_files.name});
    updated = ...
      [remote_files(existing).bytes] > [local_files(local_idx(existing)).bytes];
    to_download = ~existing;
    to_download(existing) = updated;
    remote_files = remote_files(to_download);
  else
    % Create local directory because mget does not do it.
    [success, message] = mkdir(local_dir);
    if ~success
      error('glider_toolbox:reading_tools:LocalDirectoryError', ...
            'Could not create local directory %s: %s.', local_dir, message);
    end
  end
  if isempty(remote_files)
    disp(['No new/updated files in remote directory ' remote_dir '.']);
    return;
  end
  % Download the files.
  files = cellfun(@(f) mget(ftp_handle, f, local_dir), {remote_files.name});
end
