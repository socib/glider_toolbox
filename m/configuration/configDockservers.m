function dockservers = configDockservers()
%CONFIGDOCKSERVERS  Configure dockserver parameters for glider data processing.
%
%  Syntax:
%    DOCKSERVERS = CONFIGDOCKSERVERS()
%
%  Description:
%    DOCKSERVERS = CONFIGDOCKSERVERS() should return a struct array with the
%    access parameters for the dockservers containing Slocum glider data, as
%    needed by the function GETDOCKSERVERFILES.
%
%  Notes:
%    Edit this file filling in the parameters of your dockservers.
%    Once configured, this file will contain private data, so you should not
%    make it public.
%
%  Examples:
%    dockservers = configDockservers()
%
%  See also:
%    GETDOCKSERVERFILES
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

  error(nargchk(0, 0, nargin, 'struct'));

  dockservers(1).url  = 'http://mydockserver01.myportal.mydomain';
  dockservers(1).user = 'myself';
  dockservers(1).pass = 'top_secret';

  dockservers(2).url  = 'http://mydockserver02.myportal.mydomain';
  dockservers(2).user = 'myself';
  dockservers(2).conn = @sftp;

end
