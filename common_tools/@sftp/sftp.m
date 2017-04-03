function h = sftp(host, username, password)
%SFTP  Create an SFTP object.
%
%  Syntax:
%    H = SFTP(HOST)
%    H = SFTP(HOST, USERNAME)
%    H = SFTP(HOST, USERNAME, PASSWORD)
%
%  Description:
%    H = SFTP(HOST, USERNAME, PASSWORD) returns an SFTP object.
%    If USERNAME is not specified, the default user for that host will be used.
%    If PASSWORD is not specified, public key authentication will be used.
%
%  Examples:
%    h = sftp(host)
%    h = sftp(host, username)
%    h = sftp(host, username, password)
%
%  See also:
%    CLOSE
%    CD
%    DIR
%    MGET
%    MPUT
%    RENAME
%    DELETE
%    MKDIR
%    RMDIR
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

  error(nargchk(0, 3, nargin, 'struct'));

  if (nargin == 1) && isa(host, 'sftp')
    % Short circuit copy constructor.
    h = host;
  else
    switch nargin
      case 0
        host = [];
        username = [];
        password = [];
      case 1
        username = [];
        password = [];
      case 2
        password = [];
    end
    colon = find(host==':');
    if isempty(colon)
      h.host = host;
      h.port = [];
    else
      h.host = host(1:colon-1);
      h.port = str2double(host(colon+1:end));
    end
    h.username = username;
    h.password = password;
    h.sftp_handle = mexsftp('create', h.host, h.port, h.username, h.password);
    h.cleanup = onCleanup(@()(mexsftp('delete', h.sftp_handle)));
    h = class(h, 'sftp');
  end

end
