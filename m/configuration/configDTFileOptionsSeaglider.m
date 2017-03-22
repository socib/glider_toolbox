function seaglider_options = configDTFileOptionsSeaglider()
%CONFIGDTFILEOPTIONSSEAGLIDER  Configure loading options for Seaglider files in delayed time.
%
%  Syntax:
%    SEAGLIDER_OPTIONS = CONFIGDTFILEOPTIONSSEAGLIDER()
%
%  Description:
%    SEAGLIDER_OPTIONS = CONFIGDTFILEOPTIONSSEAGLIDER() should return a struct 
%    with the parameters that control which are the deployment files,
%    whether they need to be converted, and which files and data should be used
%    in delayed time mode. The returned struct should have the following fields:
%      LOG_NAME_PATTERN: string with the name pattern of Seaglider log files 
%        to be loaded by LOADSEAGLIDERDATA for processing.
%      ENG_NAME_PATTERN: string with the name pattern of Seaglider eng files.
%        to be loaded by LOADSEAGLIDERDATA for processing.
%      LOG_PARAMS: string cell array with the name of the parameters from
%        log files to be loaded by LOADSEAGLIDERDATA. Restricting the list of
%        parameters to load may reduce the memory footprint.
%      ENG_COLUMNS: string cell array with the name of the data columns from
%        eng files to be loaded by LOADSEAGLIDERDATA. Restricting the list of
%        columns to load may reduce the memory footprint.
%
%  Examples:
%    seaglider_options = configDTFileOptionsSeaglider()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    LOADSEAGLIDERDATA
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

  error(nargchk(0, 0, nargin, 'struct'));
  
  % Select dive log files to use. All log files:
  seaglider_options.log_name_pattern = '^p\d{3}\d{4}\.log$';
    
  % Select dive eng files to use. All eng files:
  seaglider_options.eng_name_pattern = '^p\d{3}\d{4}\.eng$';
  
  % Log parameters to load.
  seaglider_options.log_params = 'all';
  
  % Eng parameters to load.
  seaglider_options.eng_columns = 'all';
  
end
