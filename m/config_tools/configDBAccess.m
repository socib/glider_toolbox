function db_access = configDBAccess()
%CONFIGDBACCESS  Configure data base access parameters for glider processing.
%
%  DB_ACCESS = CONFIGDBACCESS() should return a struct with the access
%  parameters for the data base to be used during the glider processing, as
%  needed by the function GETDBDEPLOYMENTINFO.
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
%    GETDBDEPLOYMENTINFO
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  db_access.url  = 'jdbc:postgresql://mydb.myportal.mydomain:5433/my_data_base';
  db_access.name = 'my_data_base';
  db_access.user = 'myself';
  db_access.pass = 'top_secret';
  db_access.driver = 'org.postgresql.Driver';

end
