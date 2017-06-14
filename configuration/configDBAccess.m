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

%  Copyright (C) 2013-2017
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
  
  %Boolean to Specify Whether to use SQL Database (1)
  %or Script (0) for Deployment Metadata
  db_access.useSQL = 1;

  %SQL Database Details
  db_access.server = 'jdbc:postgresql://apps.socib.es:5433/';
  db_access.name = 'management';
  db_access.user = 'postgres';
  db_access.pass = '+mngp0st+';
  db_access.driver = 'org.postgresql.Driver';

end
