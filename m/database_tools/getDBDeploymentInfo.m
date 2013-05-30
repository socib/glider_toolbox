function data = getDBDeploymentInfo(db_access, query, fields)
%GETDBDEPLOYMENTINFO  Get deployment information from data base.
%
%  DATA = GETDBDEPLOYMENTINFO(DB_ACCESS, QUERY, FIELDS) executes the given QUERY
%  on the data base described in struct DB_ACCESS, and returns a struct DATA
%  with fields given by string cell array FIELDS mapped to the corresponding 
%  columns in the query result.
%
%  DB_ACCESS should be a struct with the needed fields to access the data base:
%    URL: url of the data base (string).
%    NAME: name of the data base (string).
%    USER: user of the data base (string).
%    PASS: password of the data base (string).
%    DRIVER: name of the data base driver (string).
%
%  The number of elements in FIELDS must match the number of columns queried.
%
%  The returned struct DATA should have the following fields to be considered 
%  a deployment structure:
%    DEPLOYMENT_ID: deployment identifier (invariant over time).
%    DEPLOYMENT_NAME: deployment name (may eventually change).
%    DEPLOYMENT_START: deployment start date (see note on time format).
%    DEPLOYMENT_END: deployment end date (see note on time format).
%    GLIDER_NAME: glider platform name (as used in glider file names).
%    GLIDER_INSTRUMENT_NAME: glider instrument name (e.g. internal unit name).
%    GLIDER_DEPLOYMENT_NUMBER: number of deployment of this glider.
%  The returned structure may include other fields, which are considered to be
%  global deployment attributes by functions generating final products like
%  GENERATEOUTPUTNETCDFL0, GENERATEOUTPUTNETCDFL1 and GENERATEOUTPUTNETCDFL2.
%
%  Notes:
%    Time columns selected in the query should be returned as UTC timestamp
%    strings in ISO 8601 format ('yyyy-mm-dd HH:MM:SS'), and are converted to
%    serial date number format. Null fields are set to the empty matrix ([]).
%
%  Examples:
%    db_access = configDBAccess()
%    [query, fields] = configDBDeploymentInfoQuery()
%    deployment_info = getDBDeploymentInfo(db_access, query, fields)
%
%  See also:
%    GENERATEOUTPUTNETCDFL0
%    GENERATEOUTPUTNETCDFL1
%    GENERATEOUTPUTNETCDFL2
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  error(nargchk(1, 3, nargin, 'struct'));

  % Retrieve data from data base as cell array.
  conn = database(db_access.name, db_access.user, db_access.pass, ...
                  db_access.driver, db_access.url);
  if (~isconnection(conn))
    error('glider_toolbox:db_tools:ConnectionError', ...
          'Error connecting to database: %s.', conn.Message);
  end
  data_format = setdbprefs('DataReturnFormat');
  setdbprefs('DataReturnFormat', 'cellarray');
  try
    data = fetch(conn, query);
  catch exception
    close(conn);
    setdbprefs('DataReturnFormat', data_format);
    rethrow(exception);
  end
  close(conn);
  setdbprefs('DataReturnFormat', data_format);

  % Adapt number of columns when the result of the query is empty.
  if all(size(data)==0)
    data = cell(0,numel(fields));
  end
  
  % Convert time fields from timestamp string to serial date number.
  time_fields = {'deployment_start', 'deployment_end'};
  time_field_columns = ismember(fields, time_fields);
  time_data = data(:, time_field_columns);
  if iscellstr(time_data)
    % DATENUM does not handle empty date string cell arrays properly.
    time_data_null = strcmp('null', time_data);
    if any(~time_data_null)
      time_data(~time_data_null) = ...
        num2cell(datenum(time_data(~time_data_null), 'yyyy-mm-dd HH:MM:SS'));
    end
    time_data(time_data_null) = {[]};
  else
    error('glider_toolbox:db_tools:TimeFieldError', ...
          'Wrong time data type (not a timestamp string).');
  end
  data(:, time_field_columns) = time_data;

  % Convert to structure array.
  data = cell2struct(data, fields, 2);

end
