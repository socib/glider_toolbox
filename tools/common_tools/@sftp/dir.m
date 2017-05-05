function list = dir(h, path)
%DIR  List files on an SFTP server.
%
%  Syntax:
%    DIR(H)
%    DIR(H, PATH)
%    LIST = DIR(H, ...)
%
%  Description:
%    DIR(H, PATH) lists the files in a path.
%    If the path is a directory, the files in the directory are listed.
%    If the path is a file, tha file itself is listed.
%    Otherwise, the path is considered a glob which may contain wildcards 
%    ('?' or '*'), and only files matching the glob are listed, if any.
%
%    LIST = DIR(H, ...) returns the files in an M-by-1 structure with fields: 
%      NAME:    file name
%      BYTES:   number of bytes allocated to the file
%      ISDIR:   whether file is a directory or not
%      DATE:    modification time timestamp (string)
%      DATENUM: modification time as a serial date number
%
%  Examples:
%    % Print contents of current directory:
%    dir(h)
%    % Print contents of parent directory:
%    dir(h, '..')
%    % Get attributes of files in current directory:
%    list = d(h)
%    % Get attributes of files in parent directory:
%    list = d(h, '..')
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

  if (nargin < 2)
      path = '.';
  end
  
  try
    atts = mexsftp('lsfile', h.sftp_handle, path);
  catch exception
    if ~strcmp(exception.identifier, 'sftp:lsfile:ListError')
      rethrow(exception);
    end
    atts = [];
  end
  if isempty(atts)
    atts = mexsftp('lsglob', h.sftp_handle, path);
  elseif atts.isdir
    atts = mexsftp('lsdir', h.sftp_handle, path);
  end
  
  for i = 1:numel(atts)
    atts(i).datenum = datenum(atts(i).date);
    atts(i).date = datestr(atts(i).date, 'local');
  end
  
  if nargout < 1
    % Display in columns.
    disp(' ');
    if ~isempty(atts)
      entries = sortrows(char(strcat({atts.name},  {'  '})));
      width = [1 0] * get(0, 'CommandWindowSize')';
      cols = max(1, floor(width / size(entries, 2)));
      rows = ceil(size(entries, 1)/cols);
      entries(end+1:rows*cols, :) = ' ';
      disp(reshape(entries(reshape(1:rows*cols, rows, [])',:)', [], rows)')
    end
    disp(' ');
  else
    list = atts;
  end
  
end
