function [sql_query, deployment_fields] = configDTDeploymentInfoQuery()
%CONFIGDTDEPLOYMENTINFOQUERY  Configure the query used to retrieve glider deployment information from the data base for delayed time processing.
%
%  [SQL_QUERY, DEPLOYMENT_FIELDS] = CONFIGDTDEPLOYMENTINFOQUERY() should return
%  the SQL query to get information about glider deployments to be processed in
%  delayed time. SQL_QUERY is the query to execute. When executed, the return 
%  value should be a cell array with information of each deployment at each row.
%  The mapping between deployment fields and data base table fields (columns of 
%  the cell array returned by the query) is given by the string cell array 
%  DEPLOYMENT_FIELDS. Deployment fields are described in GETDBDEPLOYMENTINFO.
%
%  Notes:
%    Edit this file filling in the field mapping of your data base and the
%    query that returns that fields for each deployment.
%
%  Examples:
%    [sql_query, deployment_fields] = configDTDeploymentInfoQuery()
%
%  See also:
%    GETDBDEPLOYMENTINFO
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  % Select the identifiers of deployments to process.
  deployment_ids = {'1' '2'};
  
  % Select the deployment fields.
  % First column is deployment field
  % Second column is column in data base table.
  fields_map = {
    'deployment_id'            'deployment_id'
    'deployment_name'          'deployment_name'
    'deployment_start'         'deployment_initial_date'
    'deployment_end'           'deployment_end_date'
    'glider_name'              'platform_name'
    'glider_instrument_name'   'instrument_name'
    'glider_deployment_code'   'deployment_code'
  };

  deployment_fields = fields_map(:,1)';
  db_fields = fields_map(:,2)';

  % Build the query.
  db_fields_str = [sprintf('%s, ', db_fields{1:end-1}) db_fields{end}];

  sql_query = ['select ' db_fields_str ...
               '  from instrumentation.deployment' ...
               '  inner join instrumentation.instrument' ...
               '    on (deployment_instrument_id=instrument_id)' ...
               '  inner join instrumentation.instrument_type' ...
               '    on (instrument_instrument_type_id=instrument_type_id)' ...
               '  inner join instrumentation.instrument_platform' ...
               '    on (instrument_platform_instrument_id=instrument_id and instrument_platform_installation_date < now() and (instrument_platform_uninstallation_date is null or instrument_platform_uninstallation_date > now()))' ...
               '  inner join instrumentation.platform' ...
               '    on (instrument_platform_platform_id = platform_id)' ...
               '  where (deployment_id in (' deployment_ids_str '));'];

end
