function out_struct = configDTOutputNetCDFIgnoreQcParameters()
%CONFIGDTOUTPUTNETCDFIGNOREQCPARAMETERS  Variablenames to be ignored.
%
%  Syntax:
%    CONFIGDTOUTPUTNETCDFIGNOREQCPARAMETERS(OUT_STRUCT)
%
%  Description:
%    Lists the variable names that shall be ignored in the netCDF
%    generation.
%    Can be useful for variables where no QC is applied anyway. Like
%    position_status, roll, pitch, heading, ...
%    Append a new string to the end of the out_struct cell to ignore
%    further QC variables.
%
%  Notes:
%    The prefix QC_ is taken in the removeVariablesFromStruct function.
%
%  Examples:
%    configDTOutputNetCDFIgnoreQcParameters(out_struct)
%
%  See also:
%    REMOVEVARIABLESFROMSTRUCT
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

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

out_struct = {};

out_struct{end+1} = 'position_status';
out_struct{end+1} = 'roll';
out_struct{end+1} = 'pitch';
out_struct{end+1} = 'heading';
out_struct{end+1} = 'transect_index';
out_struct{end+1} = 'distance_over_ground';
out_struct{end+1} = 'profile_index';
out_struct{end+1} = 'profile_direction';
out_struct{end+1} = 'flow_ctd';

out_struct = out_struct';

end
