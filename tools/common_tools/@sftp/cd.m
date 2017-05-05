function pwd = cd(h, path)
%CD  Change or get current working directory on an SFTP server.
%
%  Syntax:
%    CD(H, PATH)
%    PWD = CD(H, PATH)
%    PWD = CD(H)
%
%  Description:
%    CD(H, PATH) changes the current working directory to the one specified.
%
%    PWD = CD(H, PATH) changes the working directory and returns the new one.
%
%    PWD = CD(H) returns the current working directory.
%
%  Examples:
%    % Get current directory:
%    old_dir = cd(h)
%    % Move up one directory and get new current directory:
%    new_dir = cd(h, '..'):
%    % Go back to previous directory:
%    cd(old_dir)
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

  if (nargin > 1)
    mexsftp('cwd', h.sftp_handle, path);
  end
  pwd = mexsftp('pwd', h.sftp_handle);
