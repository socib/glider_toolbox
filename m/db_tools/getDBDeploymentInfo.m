function data = getDBDeploymentInfo(db_access, query, fields)
%GETDBDEPLOYMENTINFO  Get deployment information from data base.
%
%  DATA = GETDBDEPLOYMENTINFO(DB_ACCESS, QUERY, FIELDS) Executes the given QUERY
%  on the data base described in struct DB_ACCESS and returns a struct DATA
%  with fields given by FIELDS cell array mapped to the corresponding columns in
%  the query result.
%
%  DB_ACCESS should be a struct with the needed fields to access
%  the data base:
%    URL: url of the data base (string).
%    NAME: name of the data base (string).
%    USER: user of the data base (string).
%    PASS: password of the data base (string).
%    DRIVER: name of the data base driver (string).
%
%  The number of elements in FIELDS must match the number of columns queried.
%
%  For the returned DATA be a deployment structure, it should have the following
%  minimal set of fields:
%   DEPLOYMENT_ID: deployment identifier (invariant over time).
%   DEPLOYMENT_NAME: deployment name (may eventually change).
%   GLIDER_NAME: glider platform name.
%   GLIDER_DEPLOYMENT_NUMBER: number of deployment of this glider.
%   DEPLOYMENT_START: deployment start date (see note on time format).
%   DEPLOYMENT_END: deployment end date (see note on time format).
%
%  Notes:
%    Time columns returned by the query should be returned as UTC timestamp
%    strings in ISO 8601 format ('yyyy-mm-dd HH:MM:SS'), and are converted to
%    serial date number format. Null fields are set to the empty matrix ([]).
%
%  Examples:
%    db_access = configDBAccess()
%    [query, fields] = configDBDeploymentInfoQuery()
%    deployment_info = getDBDeploymentInfo(db_access, query, fields)
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 3, nargin, 'struct'));

  % Retrieve data from data base as cell array.
  conn = database(db_access.name, db_access.user, db_access.pass, ...
                  db_access.driver, db_access.url);
  if (~isconnection(conn))
    error('glider_toolbox:db_tools:ConnectionError', ...
          ['Error connecting to database: ' conn.Message]);
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

  % Convert available time fields.
  time_fields = {'start_time', 'end_time'};
  time_field_columns = ismember(fields, time_fields);
  time_data = data(:, time_field_columns);
  if iscellstr(time_data)
    time_data_null = cellfun(@(s) strcmp(s,'null'), time_data);
    time_data(~time_data_null) = num2cell(datenum(time_data(~time_data_null), 'yyyy-mm-dd HH:MM:SS'));
    time_data(time_data_null) = {[]};
  else
    error('glider_toolbox:db_tools:TimeFieldError', ...
          'Wrong time data type (not a timestamp string).');
  end
  data(:, time_field_columns) = time_data;

  % Convert to structure array.
  data = cell2struct(data, fields, 2);

end
