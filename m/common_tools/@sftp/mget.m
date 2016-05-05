function list = mget(h, path, target)
%MGET  Download file(s) from an SFTP server.
%
%  Syntax:
%    MGET(H, PATH)
%    MGET(H, PATH, TARGET)
%    LIST = MGET(H, ...)
%
%  Description:
%    MGET(H, PATH) downloads file(s) from the server to the current directory.
%    If the path is a directory, the directory and its contents are downloaded.
%    If the path is a file, tha file itself is downloaded.
%    Otherwise, the path is considered a glob which may contain wildcards 
%    ('?' or '*'), and only files matching the glob are downloaded, if any.
%
%    MGET(H, PATH, TARGET) downloads the file(s) to the given target directory
%    instead of the current one.
%
%    LIST = MGET(H, ...) returns the list of downloaded files.
%
%  Examples:
%    % Download file from remote working directory to current working directory:
%    mget(h, filename)
%    % Download file from remote working directory to another directory:
%    mget(h, filename, target)
%    % Download all files and directories in remote working directory:
%    mget(h, '*')
%    % Download all hidden files and directories in remote working directory,
%    % to a different directory:
%    list = mget(h, '.*', stash)
%
%  See also:
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

  if (nargin < 3)
    target = pwd();
  end
    
  try
    atts = mexsftp('lsfile', h.sftp_handle, path);
  catch exception
    if ~strcmp(exception.identifier, 'sftp:lsfile:ListError')
      rethrow(exception);
    end
    atts = mexsftp('lsglob', h.sftp_handle, path);
  end
  if isempty(atts)
   error('sftp:mget:NotFound', ...
         'No such file or directory: %s.', path);
  end
  
  filesep_index = find(path == '/', 1, 'last');
  if isempty(filesep_index)
    rprefix = '';
    lprefix = target;
  else
    rprefix = path(1:filesep_index);
    lprefix = fullfile(target, strrep(rprefix, '/', filesep()));
  end
  [status, attrout] = fileattrib(lprefix);
  if ~status
    [success, message] = mkdir(lprefix);
    if ~success
      error('sftp:mget:DirectoryError', ...
            'Could not create directory %s: %s.', lprefix, message);
    end
  elseif ~attrout.directory
    error('sftp:mget:DirectoryError', 'Not a directory: %s.', lprefix);
  end
  
  dflags = [atts.isdir]';
  rpaths = strcat(rprefix, {atts.name}');
  list = cell(0,1);
  while ~isempty(rpaths)
    rpath = rpaths{end};
    dflag = dflags(end);
    lpath = fullfile(target, strrep(rpath, '/', filesep()));
    rpaths(end) = [];
    dflags(end) = [];
    if dflag
      [status, attrout] = fileattrib(lpath);
      if ~status
        [success, message] = mkdir(lpath);
        if ~success
          error('sftp:mget:DirectoryError', ...
                'Could not create directory %s: %s.', lpath, message);
        end
      elseif ~attrout.directory
        error('sftp:mget:DirectoryError', 'Not a directory: %s.', attrout.Name);
      end
      atts = mexsftp('lsdir', h.sftp_handle, rpath);
      if ~isempty(atts)
        dflags(end + (1:numel(atts))) = [atts.isdir]';
        rpaths(end + (1:numel(atts))) = strcat(rpath, '/', {atts.name}');
      end
    else
      mexsftp('getfile', h.sftp_handle, rpath, lpath);
    end
    list{end+1, 1} = lpath;
  end
  
end
