function seaexplorer_options = configDTFileOptionsSeaExplorer()
%CONFIGDTFILEOPTIONSSEAEXPLORER  Configure loading options for SeaExplorer files in delayed time.
%
%  Syntax:
%    SEAEXPLORER_OPTIONS = CONFIGDTFILEOPTIONSSEAEXPLORER()
%
%  Description:
%    SEAEXPLORER_OPTIONS = CONFIGDTFILEOPTIONSSEAEXPLORER() should return
%    a struct with the parameters that control which are the deployment files,
%    whether they need to be converted, and which files and data should be used
%    in delayed time mode. The returned struct should have the following fields:
%      GLI_NAME_PATTERN: string with the name pattern of SeaExplorer glider
%        files to be loaded by LOADSEAEXPLORERDATA for processing.
%      PLD_NAME_PATTERN: string with the name pattern of SeaExplorer payload
%        files to be loaded by LOADSEAEXPLORERDATA for processing.
%      GLI_TIME: string with the name of the variable to use as timestamp
%        in glider files when combining data from a set of SeaExplorer files.
%      PLD_TIME: string with the name of the variable to use as timestamp
%        in payload files when combining data from a set of SeaExplorer files.
%      VARIABLES: string cell array with the name of the variables to load
%        from glider and payload files by LOADSEAEXPLORERDATA. Restricting
%        the list of variables to load may reduce the memory footprint.
%
%  Examples:
%    seaexplorer_options = configDTFileOptionsSeaExplorer()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    LOADSEAEXPLORERDATA
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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
  
  % Glider (.gli) files to use:
  seaexplorer_options.gli_name_pattern = '^.*\.gli(\..*)?$';
  
  % Payload (.pld) files to use:
  % They used to have the suffix '.dat' during the SeaExplorer development.
  seaexplorer_options.pld_name_pattern = '^.*\.(pld|dat)(\d*)?(\..*)?$';
  
  % Time variable column in glider files:
  seaexplorer_options.gli_time = 'Timestamp';
  
  % Time variable column in payload files:
  seaexplorer_options.pld_time = 'PLD_REALTIMECLOCK';
  
  % Variables to load:
  seaexplorer_options.variables = 'all';  
  
end
