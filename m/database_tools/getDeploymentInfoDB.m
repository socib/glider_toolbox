function data = getDeploymentInfoDB(query, dbname, varargin)
%GETDEPLOYMENTINFODB  Get deployment information from database.
%
%  Syntax:
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME)
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME, OPTIONS)
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME, OPT1, VAL1, ...)
%
%  Description:
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME) executes the query given by 
%    string QUERY on the database named by string DBNAME and returns a struct
%    DATA with fields given by corresponding columns in the query result.
%
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME, OPTIONS) and 
%    DATA = GETDEPLOYMENTINFODB(QUERY, DBNAME, OPT1, VAL1, ...) accept the 
%    following options given in key-value pairs OPT1, VAL1... or in struct
%    OPTIONS with field names as option keys and field values as option values:
%      USER: database user name.
%        String with the name of the user of the database.
%        Default value: '' (user name not required by database)
%      PASS: database user password.
%        String with the password of the user of the database.
%        Default value: '' (user name not required by database)
%      SERVER: database server url.
%        String with the URL of the database server.
%        Default value: [] (do not specify a URL when connecting to database)
%      DRIVER: database driver.
%        String with the name of the driver to access the database.
%        Default value: [] (do not specify a driver when connecting to database)
%      FIELDS: database column renaming.
%        String cell array with alternative field names for output structure.
%        It should have the same number of elements than selected columns.
%        If empty, no renaming is done and column names are used as field names.
%        Default value: [] (do not rename columns)
%      TIME_FIELDS: timestamp fields.
%        String cell array with the name of the output fields to be converted to
%        from timestamp string to serial date number.
%        Default value: {'deployment_start' 'deployment_end'}
%      TIME_FORMAT: timestamp field format.
%        String with the format of the timestamp columns returned by the query.
%        Default value: 'yyyy-mm-dd HH:MM:SS' (ISO 8601 format)
%
%    The returned struct DATA should have the following fields to be considered 
%    a deployment structure:
%      DEPLOYMENT_ID: deployment identifier (invariant over time).
%      DEPLOYMENT_NAME: deployment name (may eventually change).
%      DEPLOYMENT_START: deployment start date (see note on time format).
%      DEPLOYMENT_END: deployment end date (see note on time format).
%      GLIDER_NAME: glider platform name (present in Slocum file names).
%      GLIDER_SERIAL: glider serial code (present in Seaglider file names).
%      GLIDER_MODEL: glider model name (like Slocum G1, Slocum G2, Seaglider).
%    The returned structure may include other fields, which are considered to be
%    global deployment attributes by functions generating final products like
%    GENERATEOUTPUTNETCDF.
%
%  Notes:
%    Time columns selected in the query should be returned as UTC timestamp
%    strings in ISO 8601 format ('yyyy-mm-dd HH:MM:SS') or other format accepted
%    by DATENUM, and are converted to serial date number format. 
%    Null entries are set to invalid (NaN).
%
%  Examples:
%    db_access = configDBAccess()
%    [query, fields] = configDTDeploymentInfoQuery()
%    deployment_info = getDeploymentInfoDB(...
%      query, db_access.name, 'fields', fields, 
%      'user', db_access.user, 'pass', db_access.pass, ...
%      'server' db_access.server, 'driver', db_access.driver)
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    DATABASE
%    FETCH
%    DATENUM
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

  error(nargchk(2, 16, nargin, 'struct'));

  
  %% Set options and default values.
  options.user = '';
  options.pass = '';
  options.driver = '';
  options.server = '';
  options.fields = {};
  options.time_fields = {'deployment_start' 'deployment_end'};
  options.time_format = 'yyyy-mm-dd HH:MM:SS';

  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:getDeploymentInfoDB:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:getDeploymentInfoDB:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Retrieve data from database as a structure.
  if isempty(options.driver) && isempty(options.server)
    access_params = {options.user options.pass};
  else
    access_params = {options.user options.pass options.driver options.server};
  end
  conn = database(dbname, access_params{:});
  if (~isconnection(conn))
    error('glider_toolbox:db_tools:ConnectionError', ...
          'Error connecting to database: %s.', conn.Message);
  end
  dbprefs = setdbprefs();
  setdbprefs({'NullNumberRead', 'NullStringRead', 'DataReturnFormat'}, ...
             {'NaN',            'null',           'structure'} );
  try
    data = fetch(conn, query);
  catch exception
    close(conn);
    setdbprefs(dbprefs);
    rethrow(exception);
  end
  close(conn);
  setdbprefs(dbprefs);
  
  
  %% Convert to cell array for postprocessing.
  % MATLAB is not consistent when the DataReturnFormat is structure.
  % If no rows match the selected query, an empty array is returned instead.
  if isstruct(data)
    if isempty(options.fields)
      fields = fieldnames(data);
    else
      fields = cellstr(options.fields(:));
    end
    data = struct2cell(data);
    for i = 1:size(data, 1)
      if isnumeric(data{i})
        data{i} = num2cell(data{i});
      end
    end
    data = horzcat(data{:});
  else
    fields = cellstr(options.fields);
    data = cell(0, numel(fields));
  end


  %% Convert time fields from timestamp string to serial date number.
  time_format = options.time_format;
  time_fields = cellstr(options.time_fields);
  time_field_columns = ismember(fields, time_fields);
  time_data = data(:,time_field_columns);
  if iscellstr(time_data)
    % DATENUM does not handle empty date string cell arrays properly.
    time_data_null = strcmp('null', time_data);
    if any(~time_data_null(:))
      time_data(~time_data_null) = ...
        num2cell(datenum(time_data(~time_data_null), time_format));
    end
    time_data(time_data_null) = {NaN};
  else
    error('glider_toolbox:db_tools:TimeFieldError', ...
          'Wrong time data type (not a timestamp string).');
  end
  data(:, time_field_columns) = time_data;
  

  %% Convert back to structure array with new field names.
  data = cell2struct(data, fields, 2);

end
