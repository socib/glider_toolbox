function files = getfiles(connection, varargin)
%GETFILES  Fetch new and updated files from a remote directory.
%
%  Syntax:
%    FILES = GETFILES(CONNECTION, OPTIONS)
%    FILES = GETFILES(CONNECTION, OPT1, VAL1, ...)
%
%  Description:
%    FILES = GETFILES(CONNECTION, OPTIONS) and
%    FILES = GETFILES(CONNECTION, OPT1, VAL1, ...) retrieve files from a 
%    directory on a remote server through the FTP-like object CONNECTION 
%    according to the options given in key-value pairs OPT1, VAL1... or in 
%    scalar struct OPTIONS with field names as option keys and field values as 
%    option values. Recognized options are:
%      SOURCE: remote source directory.
%       String with the name of the remote directory to download the files from.
%       If not given, the current working directory on the server is used.
%       Default value: [] (use remote current working directory)
%     TARGET: local target directory.
%       String with the name of the local directory to download the files to.
%       If empty, the current working directory on the local client is used.
%       Default value: [] (use local current remote directory)
%     INCLUDE: name pattern of files to include in the download.
%       String with the pattern (regular expression) of the files to download.
%       Only files whose name match this pattern are downloaded.
%       If not given, all files in the source directory are downloaded.
%       Default value: [] (download all files in source directory)
%     EXCLUDE: name pattern of files to exclude from the download.
%       String with the pattern (regular expression) of the files to exclude.
%       All files whose name match this pattern are not downloaded.
%       If not given, all files are downloaded.
%       Default value: [] (do not exclude any file)
%     NEW: filter new files on the remote server.
%       Name or handle of the predicate function new files on the server must
%       satisfy to be included in the download. The function receives a single
%       input with the attributes of the new files as returned by DIR operation,
%       and returns one logical output whether to download respective file.
%       If not given, all new files are downloaded.
%       Default value: [] (download all new files)
%     UPDATE: filter files on the server already existing at the local side.
%       Name or handle of the predicate function files on the server must
%       satisfy to consider them as updated and include them in the download.
%       The function receives two inputs: the attributes of corresponding local
%       and remote files as returned by DIR operation, and returns one output 
%       whether to update the local file with the remote one.
%       If not given, the test is based on the modification time, and only
%       files on the server newer than respective local files are downloaded.
%      Default value: [] (overwrite all exisiting files)
%
%  Examples:
%    connection = ftp('ftp://myserver.org')
%    % Download all files in remote directory to local directory.
%    files = getfiles(connection)
%    % Download files in remote directory matching given name,
%    % and update existing files only when the remote ones are newer.
%    files = getfiles( ...
%      connection, ...
%      'source', '/var/opt/gmc/gliders/happyglider/from-glider', ...
%      'target', 'funnymission/binary', ...
%      'include', '^.*\.[smdtne]bd$', ...
%      'update', @(l,r)(l.datenum < r.datenum) );
%
%  See also:
%    FTP
%    SFTP
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

  error(nargchk(1, 13, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.source = [];
  options.target = [];
  options.include = [];
  options.exclude = [];
  options.new = [];
  options.update = [];


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
    error('glider_toolbox:getfiles:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:getfiles:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Parse options to more practical values.
  chdir = false;
  totarget = false;
  include_all = true;
  exclude_none = true;
  new_all = true;
  update_all = true;
  if ~isequal([], options.source)
    chdir = true;
    source = options.source;
  end
  if ~isequal([], options.target)
    totarget = true;
    target = options.target;
  end
  if ~isequal([], options.include)
    include_all = false;
    include = options.include;
  end 
  if ~isequal([], options.exclude)
    exclude_none = false;
    exclude = options.exclude;
  end
  if ~isequal([], options.new)
    new_all = false;
    newfunc = options.new;
    if ischar(newfunc)
      newfunc = str2func(newfunc);
    end
  end
  if ~isequal([], options.update)
    update_all = false;
    updatefunc = options.update;
    if ischar(updatefunc)
      updatefunc = str2func(udpatefunc);
    end
  end
  
  
  %% List remote files and fetch the required ones.
  if chdir
    old_pwd = cd(connection);
    cd(connection, source);
  end
  ratts = dir(connection, source);
  if totarget
    latts = dir(target);
  else
    latts = dir();
  end
  select = true(size(ratts));
  lexist = false(size(ratts));
  lindex = zeros(size(ratts));
  [lexist(:), lindex(:)] = ismember({ratts.name}', {latts.name}');
  if ~include_all
    select(select) = ...
      ~cellfun(@isempty, regexp({ratts(select).name}, include, 'match'));
  end
  if ~exclude_none
    select(select) = ...
      cellfun(@isempty, regexp({ratts(select).name}, exclude, 'match'));
  end
  if ~new_all
    select(select & ~lexist) = arrayfun(newfunc, ratts(select & ~lexist));
  end
  if ~update_all
    select(select & lexist) = arrayfun(updatefunc, ...
                                       latts(lindex(select & lexist)), ...
                                       ratts(select & lexist));
  end
  if (totarget)
    getfunc = @(name)(mget(connection, name, target));
  else
    getfunc = @(name)(mget(connection, name));
  end
  files = cellfun(getfunc, {ratts(select).name});
  if chdir
    cd(connection, old_pwd);
  end
  
end
