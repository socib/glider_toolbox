function [ ] = startLogging( log_file, gtb_version, deployment )%READCONFIGFILE 
%   TODO: Add description
% Use diary('off') to stop logging.
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
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

  
  narginchk(3, 3);
  
  %% Start deployment processing logging.
  % DIARY will fail if log file base directory does not exist.
  % Create the base directory first, if needed.
  % This is an ugly hack (the best known way) to check if the directory exists.
  [log_dir, ~, ~] = fileparts(log_file);  
  [status, attrout] = fileattrib(log_dir);
  if ~status 
    [status, message] = mkdir(log_dir);
  elseif ~attrout.directory
    status = false;
    message = 'not a directory';
  end
  % Enable log only if directory was already there or has been created properly.
  if status
    try
      diary(log_file);
      diary('on');
    catch exception
      disp(['Error enabling processing log diary ' log_file ':']);
      disp(getReport(exception, 'extended'));
    end
  else
    disp(['Error creating processing log directory ' log_dir ':']);
    disp(message);
  end
  disp(['Deployment processing start time: ' ...
        datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);

  %% Report toolbox version:    
  disp(['Toolbox version: ' gtb_version]);


  %% Report deployment information.
  if ~isempty(deployment) 
      disp('Deployment information:')
      disp(['  Glider name          : ' deployment.glider_name]);
      disp(['  Glider model         : ' deployment.glider_model]);
      disp(['  Glider serial        : ' deployment.glider_serial]);
      disp(['  Deployment identifier: ' num2str(deployment.deployment_id)]);
      disp(['  Deployment name      : ' deployment.deployment_name]);
      disp(['  Deployment start     : ' datestr(deployment.deployment_start)]);
      if isnan(deployment.deployment_end)
        disp(['  Deployment end       : ' 'undefined']);
      else
        disp(['  Deployment end       : ' datestr(deployment.deployment_end)]);
      end
  end

end

