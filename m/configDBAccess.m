function db_access = configDBAccess()
%CONFIGDBACCESS  Configure data base access parameters for glider processing.
%
%  Syntax:
%    DB_ACCESS = CONFIGDBACCESS()
%
%  Description:
%    DB_ACCESS = CONFIGDBACCESS() should return a struct with the access
%    parameters for the data base to be used during the glider processing
%    as needed by the function GETDEPLOYMENTINFODB.
%
%  Notes:
%    Edit this file filling in the parameters of your data base.
%    Once configured, this file will contain private data, so you should not
%    make it public.
%
%  Examples:
%    db_access = configDBAccess()
%
%  See also:
%    GETDEPLOYMENTINFODB
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

  db_access.server = 'jdbc:postgresql://mydb.myportal.mydomain:5433/my_data_base';
  db_access.name = 'my_data_base';
  db_access.user = 'myself';
  db_access.pass = 'top_secret';
  db_access.driver = 'org.postgresql.Driver';

end
