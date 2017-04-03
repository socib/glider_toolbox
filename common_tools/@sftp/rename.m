function rename(h, oldname, newname)
%RENAME  Rename a file or directory on an SFTP server.
%
%  Syntax:
%    RENAME(H, OLDNAME, NEWNAME)
%
%  Description:
%    RENAME(H, OLDNAME, NEWNAME) renames or moves a file on the server.
%
%  Examples:
%    rename(h, oldname, newname)
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

  mexsftp('rename', h.sftp_handle, oldname, newname);
  
end
