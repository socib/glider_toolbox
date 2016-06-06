function list = mput(h, path)
%MPUT  Upload file(s) to an SFTP server.
%
%  Syntax:
%    MPUT(H, PATH)
%    LIST = MPUT(H, PATH)
%
%  Description:
%    MPUT(H, PATH) uploads file(s) to the server.
%    If the path is a directory, the directory and its contents are uploaded.
%    If the path is a file, the file itself is uploaded.
%    Otherwise, the path is considered a glob which may contain wildcards 
%    ('*'), and only files matching the glob are uploaded, if any.
%
%    LIST = MPUT(H, ...) returns the list of uploaded files.
%
%  Examples:
%    % Upload file to remote working directory:
%    mput(h, filename)
%    % Upload all files and directories in current working directory:
%    mput(h, '*')
%    % Upoad all hidden files and directories to remote working directory.
%    list = mput(h, '.*')
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

  [status, attrout] = fileattrib(path);
  if ~status
    error('sftp:mget:FileError', attrout);
  end
  % FILEATTRIB recurses down directories when passed a glob, use DIR instead.
  if isscalar(attrout)
    [source, name, ext] = fileparts(attrout.Name);
    atts = struct();
    atts.name = [name ext];
    atts.isdir = attrout.directory;
  else
    [source, name, ext] = fileparts(path);
    if isempty(source)
      source = pwd();
    end
    atts = dir(path);
    atts = atts(~(strcmp({atts.name}, '.') | strcmp({atts.name}, '..')));
  end
    
  target = mexsftp('pwd', h.sftp_handle);
  if target(end) ~= '/'
    target = [target '/'];
  end
  dflags = [atts.isdir]';
  rpaths = {atts.name}';
  list = cell(0,1);
  while ~isempty(rpaths)
    rpath = rpaths{end};
    dflag = dflags(end);
    lpath = strrep(rpath, '/', filesep());
    rpaths(end) = [];
    dflags(end) = [];
    if dflag
      mkdir(h, rpath);
      atts = dir(fullfile(source, lpath));
      atts = atts(~(strcmp({atts.name}, '.') | strcmp({atts.name}, '..')));
      if ~isempty(atts)
        dflags(end + (1:numel(atts))) = [atts.isdir]';
        rpaths(end + (1:numel(atts))) = strcat(rpath, '/', {atts.name}');
      end
    else
      mexsftp('putfile', h.sftp_handle, ...
              fullfile(source, lpath), strcat(target, rpath));
    end
    list{end+1, 1} = strcat(target, rpath);
  end
  
end
