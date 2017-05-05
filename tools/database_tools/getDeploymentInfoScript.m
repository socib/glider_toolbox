function [deployments] = getDeploymentInfoScript()
%GETDEPLOYMENTINFOSCRIPT Get deployment information from script file
%
%       The returned struct DATA should have the following fields to be considered 
%       a deployment structure:
%
%      [deployments] = getDeploymentInfoScript()
%
%      DEPLOYMENT_ID: deployment identifier (invariant over time).
%      DEPLOYMENT_NAME: deployment name (may eventually change).
%      DEPLOYMENT_START: deployment start date (see note on time format).
%      DEPLOYMENT_END: deployment end date (see note on time format).
%      GLIDER_NAME: glider platform name (present in Slocum file names).
%      GLIDER_SERIAL: glider serial code (present in Seaglider file names).
%      GLIDER_MODEL: glider model name (like Slocum G1, Slocum G2, Seaglider).
%
%       The returned structure may include other fields, which are considered to be
%       global deployment attributes by functions generating final products like
%       GENERATEOUTPUTNETCDF.
%
%  Notes:
%    Time columns selected in the query should be returned as UTC timestamp
%    strings in ISO 8601 format ('yyyy-mm-dd HH:MM:SS') or other format accepted
%    by DATENUM, and are converted to serial date number format. 
%    Null entries are set to invalid (NaN).
%
%  See also:
%    GETDEPLOYMENTINFODB
%
%  Authors:
%    Grant Rogers  <grogers@socib.es>

%
%  Copyright (C) 2017
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

%% Required Variables
deployments(1).glider_name='sdeep04';
deployments(1).glider_model='Slocum G2';
deployments(1).deployment_start=datenum(2016,09,06,10,37,00);
deployments(1).deployment_end=datenum(2016,10,26,09,39,36);

%% Optional Variables
deployments(1).deployment_id='Deployment__ID';
deployments(1).deployment_name='Deployment_Name';
deployments(1).glider_serial='Glider_Serial';
deployments(1).glider_instrument_name='Glider_Instrument_Name';
deployments(1).glider_deployment_code='Glider_Deployment_Code';
deployments(1).institution='Institution_Name';
deployments(1).instrument='Instrument_Name';
deployments(1).instrument_manufacturer='Instrument_Manufacturer';
deployments(1).instrument_model='Instrument_Model';
