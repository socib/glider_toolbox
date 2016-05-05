function [xbds, logs] = getDockserverFiles(dockserver, glider, xbd_dir, log_dir, varargin)
%GETDOCKSERVERFILES  Get binary data files and surface log files from dockserver through (S)FTP.
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
%  the local directories are updated only if they are smaller than remote ones.
%
%  DOCKSERVER is a struct with the fields needed by functions FTP or SFTP:
%    HOST: url as either fully qualified name or IP with optional port (string).
%    USER: user to access the dockserver if needed (string).
%    PASS: password of the dockserver if needed (string).
%    CONN: name or handle of connection type function, @FTP (default) or @SFTP.
%
%  [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPTIONS) and
%  [XBDS, LOGS] = GETDOCKSERVERFILES(DOCKSERVER, GLIDER, XBD_DIR, LOG_DIR, OPT1, VAL1, ...)
%  accept the following options, given in key-value pairs OPT1, VAL1... or in a
%  struct OPTIONS with field names as option keys and field values as option 
%  values, allowing to restrict the set of files to download:
%    XBD: binary file name pattern.
%      Download binary files matching given pattern only.
%      Its value may be any valid regular expression string or empty.
%      If empty no binary files are downloaded.
%      Default value: '^.+\.[smdtne]bd$'
%    LOG: log file name pattern.
%      Download log files matching given pattern only.
%      Its value may be any valid regular expression string or empty.
%      If empty no log files are downloaded.
%      Default value: '^.+\.log$' 
%    START: initial date of the period of interest.
%      If given, do not download files before the given date.
%      It may be any valid input compatible with XBD2DATE and LOG2DATE
%      options below, usually a serial date number.
%      Default value: -Inf
%    FINAL: final date of the period of interest.
%      If given, do not download files after the the given date.
%      It may be any valid input compatible with XBD2DATE and LOG2DATE
%      options below, usually a serial date number.
%      Default value: +Inf
%    XBD2DATE: date of binary file.
%      If date filtering is enabled, use the given function
%      to extract the date of a binary file from its attributes.
%      The function receives a struct in the format returned by function DIR
%      and should return a date in a format comparable to START and FINAL.
%      Default value: date from file name (see note on date filtering)
%    LOG2DATE: date of log file.
%      If date filtering is enabled, use the given function
%      to extract the date of a log file from its attribtues.
%      The function receives a struct in the format returned by function DIR
%      and should return a date in a format comparable to START and FINAL.
%      Default value: date from file name (see note on date filtering)
%
%  Notes:
%    By default, date filtering is done based on the mission date computed
%    from the file names, not on the modification time. It relies on remote
%    file names having the conventional Slocum file name format.
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
%    dockserver.host = 'ftp.mydockserver.org'
%    dockserver.user = 'myself'
%    dockserver.pass = 'top_secret'   
%    glider = 'happyglider'
%    xbd_dir = 'funnymission/binary'
%    log_dir = 'funnymission/log'
%    % Get all binary and log files.
%    [xbds, logs] = getDockserverFiles(dockserver, glider, xbd_dir, log_dir)
%    % Get only small files and no logs from missions started last week:
%    [xbds, logs] = ...
%      getDockserverFiles(dockserver, glider, xbd_dir, log_dir, ...
%                         'xbd', '^*.[st]bd$', 'log', [], ...
%                         'start', now()-7, 'final', now())
%
%  See also:
%    FTP
%    SFTP
%    DIR
%    REGEX
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

  error(nargchk(4, 16, nargin, 'struct'));

  
  %% Set options and default values.
  options.start = -Inf;
  options.final = +Inf;
  options.xbd = '^.+\.[smdtne]bd$';
  options.log = '^.+\.log$';
  options.xbd2date = ...
    @(f)(datenum(str2double(regexp(f.name, '^.*-(\d{4})-(\d{3})-\d+-\d+\.[smdtne]bd$', ...
                                   'tokens','once')) * [1 0 0; 0 0 1] + [0 0 1]));
  options.log2date = ...
    @(f)(datenum(str2double(regexp(f.name, '^.*_.*_(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\.log$', ...
                                   'tokens','once'))));
  
  
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
  xbd_newfunc = [];
  log_newfunc = [];
  updatefunc = @(l,r)(l.bytes < r.bytes);
  if isfinite(options.start) || isfinite(options.final)
    xbd_newfunc = @(r)(options.start <= options.xbd2date(r) && ...
                       options.xbd2date(r) <= options.final);
    log_newfunc = @(r)(options.start <= options.log2date(r) && ...
                       options.log2date(r) <= options.final);
  end


  %% Open (S)FTP connection.
  host = dockserver.host;
  user = [];
  pass = [];
  conn = @ftp;
  if isfield(dockserver, 'user') && ~isequal(dockserver.user, [])
    user = dockserver.user;
  end
  if isfield(dockserver, 'pass') && ~isequal(dockserver.pass, [])
    pass = dockserver.pass;
  end
  if isfield(dockserver, 'conn') && ~isequal(dockserver.conn, [])
    conn = dockserver.conn;
    if ischar(conn)
      conn = str2func(conn);
    end
  end
  disp(['Connecting to host ' host '...']);
  ftp_handle = conn(host, user, pass);


  %% Binary data file download.
  disp('Downloading binary data files...');
  xbds = {};
  if ~isequal(xbd_name, [])
    try
     xbds = getfiles(ftp_handle, 'target', xbd_dir, ...
                     'source', remote_xbd_dir, 'include', xbd_name, ...
                     'new', xbd_newfunc, 'update', updatefunc);
    catch exception
      warning('glider_toolbox:getDockserverFiles:DownloadError', ...
              'Error downloading binary data files: %s', exception.message);
    end
    disp([num2str(numel(xbds)) ' new/updated binary data files fetched.']);
  end


  %% Surface log file download.
  disp('Downloading surface log files...');
  logs = {};
  if ~isequal(xbd_name, [])
    try
     logs = getfiles(ftp_handle, 'target', log_dir, ...
                     'source', remote_log_dir, 'include', log_name, ...
                     'new', log_newfunc, 'update', updatefunc);
    catch exception
      warning('glider_toolbox:getDockserverFiles:DownloadError', ...
              'Error downloading surface log files: %s.', exception.message);
    end
    disp([num2str(numel(logs)) ' new/updated surface log files fetched.']);
  end

  
  %% Close ftp connection.
  close(ftp_handle);
  disp(['Closed connection to host ' dockserver.host '.']);

end

