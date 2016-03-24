function seaexplorer_options = configDTFileOptionsSeaexplorer()
%CONFIGDTFILEOPTIONSSEAEXPLORER  Configure loading options for Seaexplorer files in delayed time.
%
%  Syntax:
%    SEAEXPLORER_OPTIONS = CONFIGDTFILEOPTIONSSEAEXPLORER()
%
%  Description:
%    SEAEXPLORER_OPTIONS = CONFIGDTFILEOPTIONSSEAEXPLORER() should return a struct 
%    with the parameters that control which are the deployment files,
%    whether they need to be converted, and which files and data should be used
%    in delayed time mode. The returned struct should have the following fields:
%      LOG_NAME_PATTERN: string with the name pattern of Seaexplorer log files 
%        to be loaded by LOADSEAEXPLORERDATA for processing.
%      ENG_NAME_PATTERN: string with the name pattern of Seaexplorer eng files.
%        to be loaded by LOADSEAEXPLORERDATA for processing.
%      LOG_PARAMS: string cell array with the name of the parameters from
%        log files to be loaded by LOADSEAEXPLORERDATA. Restricting the list of
%        parameters to load may reduce the memory footprint.
%      ENG_COLUMNS: string cell array with the name of the data columns from
%        eng files to be loaded by LOADSEAEXPLORERDATA. Restricting the list of
%        columns to load may reduce the memory footprint.
%
%  Examples:
%    seaexplorer_options = configDTFileOptionsSeaexplorer()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    LOADSEAEXPLORERDATA
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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
  
  % Select dive log files to use. All log files:
  seaexplorer_options.nav_name_pattern = '^.*.gli.*$';
    
  % Select dive eng files to use. All eng files:
  seaexplorer_options.sci_name_pattern = '^.*.dat.*$';
  
  % Variables to load.
  seaexplorer_options.variables = 'all';  
  
  % Time sensor column in navigation files:
  seaexplorer_options.time_sensor_nav = 'Posixtime_nav';
  
  % Time sensor column in science files:
  seaexplorer_options.time_sensor_sci = 'Posixtime_sci';
end
