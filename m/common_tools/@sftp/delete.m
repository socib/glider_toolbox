function delete(h, filename)
%DELETE  Delete file(s) on an SFTP server.
%
%  Syntax:
%    DELETE(H, FILENAME)
%
%  Description:
%    DELETE(H, FILENAME) deletes file(s) on the server.
%
%  Examples:
%    delete(h, filename)
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

  try
    atts = mexsftp('lsfile', h.sftp_handle, filename);
  catch exception
    if ~strcmp(exception.identifier, 'sftp:lsfile:ListError')
      rethrow(exception);
    end
    atts = mexsftp('lsglob', h.sftp_handle, filename);
  end
  
  filesep_index = find(filename == '/', 1, 'last');
  if isempty(filesep_index)
      prefix = '';
  else
      prefix = [filename(1:filesep_index-1) '/']; 
  end
 
  for i = 1:numel(atts)
    mexsftp('delfile', h.sftp_handle, [prefix atts(i).name]);
  end
  
end
