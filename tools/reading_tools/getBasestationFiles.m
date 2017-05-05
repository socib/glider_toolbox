function [engs, logs] = getBasestationFiles(basestation, glider, eng_dir, log_dir, varargin)
%GETBASESTATIONFILES  Get Seaglider eng and log data files from basestation through (S)FTP.
%
%  Syntax:
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR)
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR, OPTIONS)
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR, OPT1, VAL1, ...)
%
%  Description:
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR)
%    retrieves Seaglider dive data files (.eng) and dive log files (.log) from
%    the glider with serial code GLIDER from the basestation defined by struct 
%    BASESTATION to local directories ENG_DIR and LOG_DIR respectively, and
%    returns the list of downloaded files in string cell arrays ENGS and LOGS.
%    Existing files in the local directories are updated only if they are 
%    smaller than remote ones.
%
%  BASESTATION is a struct with the fields needed by functions FTP or SFTP:
%    HOST: url as either fully qualified name or IP with optional port (string).
%    USER: user to access the basestation if needed (string).
%    PASS: password of the basestation if needed (string).
%    CONN: name or handle of connection type function, @FTP (default) or @SFTP.
%
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR, OPTIONS) and 
%    [ENGS, LOGS] = GETBASESTATIONFILES(BASESTATION, GLIDER, ENG_DIR, LOG_DIR, OPT1, VAL1, ...)
%    accept the following options, given in key-value pairs OPT1, VAL1...
%    or in a struct OPTIONS with field names as option keys and field values
%    as option values, allowing to restrict the set of files to download:
%      ENG: engineering data file name pattern.
%        Download engineering files matching given pattern only.
%        Its value may be any valid regular expression string or empty.
%        If empty, no engineering data files are downloaded.
%        Default value: ['^p' GLIDER '\d+\.eng$']
%      LOG: log file name pattern.
%        Download log data files matching given pattern only.
%        Its value may be any valid regular expression string.
%        If empty, no log files are downloaded.
%        Default value: ['^p' GLIDER '\d+\.log$']
%      START: initial date of the period of interest.
%        If given, do not download files before the given date.
%        It may be any valid input compatible with ENG2DATE and LOG2DATE
%        options below, usually a serial date number.
%        Default value: -Inf
%      FINAL: final date of the period of interest.
%        If given, do not download files after the the given date.
%        It may be any valid input compatible with ENG2DATE and LOG2DATE
%        options below, usually a serial date number.
%        Default value: +Inf
%      ENG2DATE: date of binary file.
%        If date filtering is enabled, use the given function
%        to extract the date of an eng data file from its attributes.
%        The function receives a struct in the format returned by function DIR
%        and should return a date in a format comparable to START and FINAL.
%        Default value: modification time (see note on date filtering)
%      LOG2DATE: date of log file.
%        If date filtering is enabled, use the given function
%        to extract the date of a log file from its attribtues.
%        The function receives a struct in the format returned by function DIR
%        and should return a date in a format comparable to START and FINAL.
%        Default value: modification time (see note on date filtering)
%
%  Notes:
%    By default, date filtering is done based on the modification time
%    of the remote files. Filtering by dive number is also possible,
%    by providing a function to extract the dive number from the file name 
%    in options ENG2DATE and LOG2DATE and define the dive range in options 
%    START and FINAL.
%
%  Examples:
%    basestation.host = 'ftp.mybasestation.org'
%    basestation.user = 'myself'
%    basestation.pass = 'top_secret'   
%    glider = 'happyglider'
%    eng_dir = 'funnymission/ascii'
%    log_dir = 'funnymission/ascii'
%    % Get all engineering data files and log data files.
%    [engs, logs] = getBasestationFiles(basestation, glider, eng_dir, log_dir)
%    % Get only eng files and no log files for even dives during last week:
%    [engs, logs] = ...
%      getBasestationFiles(basestation, glider, eng_dir, log_dir, ...
%                          'eng', '^p\d+[02468].eng$', 'log', [], ...
%                          'start', now()-7, 'final', now())
%
%  See also:
%    FTP
%    SFTP
%    DIR
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
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

  error(nargchk(4, 12, nargin, 'struct'));

  
  %% Set options and default values.
  options.start = -Inf;
  options.final = +Inf;
  options.eng = ['^p' glider '\d+\.eng$'];
  options.log = ['^p' glider '\d+\.log$'];
  options.eng2date = @(f)(f.datenum);
  options.log2date = @(f)(f.datenum);
  
  
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
    error('glider_toolbox:getBasestationFiles:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:getBasestationFiles:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end


  %% Basestation (remote) directory definition.
  % Consider pass these paths as (maybe optional) input arguments.
  remote_base_dir = '/home';
  remote_eng_dir = [remote_base_dir '/' 'sg' glider];
  remote_log_dir = [remote_base_dir '/' 'sg' glider];


  %% Collect some parameters given in options.
  eng_name = options.eng;
  log_name = options.log;
  eng_newfunc = [];
  log_newfunc = [];
  updatefunc = @(l,r)(l.bytes < r.bytes);
  if isfinite(options.start) || isfinite(options.final)
    eng_newfunc = @(r)(options.start <= options.eng2date(r) && ...
                       options.xbd2date(r) <= options.final);
    log_newfunc = @(r)(options.start <= options.log2date(r) && ...
                       options.log2date(r) <= options.final);
  end


  %% Open (S)FTP connection.
  host = basestation.host;
  user = [];
  pass = [];
  conn = @ftp;
  if isfield(basestation, 'user') && ~isequal(basestation.user, [])
    user = basestation.user;
  end
  if isfield(basestation, 'pass') && ~isequal(basestation.pass, [])
    pass = basestation.pass;
  end
  if isfield(basestation, 'conn') && ~isequal(basestation.conn, [])
    conn = basestation.conn;
    if ischar(conn)
      conn = str2func(conn);
    end
  end
  disp(['Connecting to host ' host '...']);
  ftp_handle = conn(host, user, pass);


  %% Engineering data file download.
  disp('Downloading engineering data files...');
  engs = {};
  if ~isequal(eng_name, [])
    try
      engs = getfiles(ftp_handle, 'target', eng_dir, ...
                      'source', remote_eng_dir, 'include', eng_name, ...
                      'new', eng_newfunc, 'update', updatefunc);
    catch exception
      warning('glider_toolbox:getBasestationFiles:DownloadError', ...
              'Error downloading engineering data files: %s', exception.message);
    end
    disp([num2str(numel(engs)) ' new/updated engineering data files fetched.']);
  end


  %% Log data file download.
  disp('Downloading log data files...');
  logs = {};
  if ~isequal(log_name, [])
    try
      logs = getfiles(ftp_handle, 'target', log_dir, ...
                      'source', remote_log_dir, 'include', log_name, ...
                      'new', log_newfunc, 'update', updatefunc);
    catch exception
      warning('glider_toolbox:getBasestationFiles:DownloadError', ...
              'Error downloading log data files: %s.', exception.message);
    end
    disp([num2str(numel(logs)) ' new/updated log data files fetched.']);
  end

  
  %% Close ftp connection.
  close(ftp_handle);
  disp(['Closed connection to host ' basestation.host '.']);

end
