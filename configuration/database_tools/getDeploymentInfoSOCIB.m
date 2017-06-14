function deployment_list = getDeploymentInfoSOCIB(varargin)
%GETDEPLOYMENTINFOSOCIB  Get deployment information from data base and SOCIB RESTful API.
%
%  Syntax:
%    DEPLOYMENT_LIST = GETDEPLOYMENTINFOSOCIB(QUERY, DBNAME)
%    DEPLOYMENT_LIST = GETDEPLOYMENTINFOSOCIB(QUERY, DBNAME, OPTIONS)
%    DEPLOYMENT_LIST = GETDEPLOYMENTINFOSOCIB(QUERY, DBNAME, OPT1, VAL1, ...)
%
%  DEPLOYMENT_LIST = GETDEPLOYMENTINFOSOCIB(...) retrieves deployment
%  information from the data base by passing all its arguments to
%  GETDEPLOYMENTINFODB, and adds the calibration information to each deployment
%  from SOCIB RESTful API.
%
%  Notes:
%    This is just a transitional solution to prevent the development from being
%    stucked unitl all the information can be retrieved from the API instead of
%    the data base.
%
%  Examples:
%    db_access = configDBAccess()
%    [query, fields] = configDTDeploymentInfoQuery()
%    deployments = getDeploymentInfoSOCIB(...
%      query, db_access.name, 'fields', fields,
%      'user', db_access.user, 'pass', db_access.pass, ...
%      'server' db_access.server, 'driver', db_access.driver)
%
%  See also:
%    GETDEPLOYMENTINFODB
%    LOADJSON
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2014
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

  error(nargchk(2, 16, nargin, 'struct'));


  %% Retrieve deployment information from data base.
  deployment_list = getDeploymentInfoDB(varargin{:});


  %% Retrieve deployment information from RESTful API (all deployments):
  request = ['http://apps.socib.es/DataDiscovery/list-deployments' ...
             '?instrumentation_info=calibration&platform_type=glider'];
  [response, status] = urlread(request);
  if status ~= 1
    error('glider_toolbox:getDeploymentInfoSOCIB:URLReadError', ...
          'Error retrieving deployment information from url: %s.', request);
  end
  deployment_details_list = loadjson(response);


  %% Add calibration information from SOCIB RESTful API to each deployment.
  for deployment_idx = 1:numel(deployment_list)
    calibration_parameters = struct();
    deployment_id = deployment_list(deployment_idx).deployment_id;
    deployment_details_select = ...
      cellfun(@(d)(d.id == deployment_id), deployment_details_list);
    if any(deployment_details_select)
      deployment_details = deployment_details_list{deployment_details_select};
      instrument_list = {};
      if isfield(deployment_details.platform, 'jsonInstrumentList')
        instrument_list = deployment_details.platform.jsonInstrumentList;
      end
      for instrument_idx = 1:numel(instrument_list)
        instrument = instrument_list{instrument_idx};
        sensor_list = {};
        if isfield(instrument, 'jsonSensorList')
          sensor_list = instrument.jsonSensorList;
        end
        for sensor_idx = 1:numel(sensor_list)
          sensor = sensor_list{sensor_idx};
          variable_list = {};
          if isfield(sensor, 'jsonVariableList')
            variable_list = sensor.jsonVariableList;
          end
          for variable_idx = 1:numel(variable_list)
            variable = variable_list{variable_idx};
            if isfield(variable, 'calibration')
              variable_name = variable.name;
              variable_parameters = variable.calibration.parameters;
              calibration_parameters.(variable_name) = variable_parameters;
            end
          end
        end
      end
    end
    deployment_list(deployment_idx).calibrations = calibration_parameters;
  end

end
