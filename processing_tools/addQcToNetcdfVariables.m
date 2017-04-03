function out_struct = addQcToNetcdfVariables(variable_list)
%ADDQCTONETCDFVARIABLES  Adds QC structs for NetCDF generation.
%
%  Syntax:
%    OUT_STRUCT = ADDQCTONETCDFVARIABLES(VARIABLE_LIST)
%
%  Description:
%    Uses existing variable list from a configDTOutputNetCDF to add QC
%    structs to use the QC outputs for the netcdf generation.
%    Adds the identifier QC_ to the variable structs.
%    Uses the long_name and standard_name inputs from the linked variable
%    list for clearness.
%
%  Notes:
%
%  Examples:
%    out_struct = addQcToNetcdfVariables(variable_list)
%
%  See also:
%    CONFIGBASICQUALITYCONTROL
%    CONFIGDTOUTPUTNETCDFL1
%    CONFIGDTOUTPUTNETCDFL2
%    GENERATEOUTPUTNETCDF
%    COMBINEDATAANDQC
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

%% Check inputs.
narginchk(1,1)
validateattributes(variable_list, {'struct'}, {'nonempty'})

%% Begin assembly.

out_struct = struct();

names = fieldnames(variable_list);
for i=1:numel(names)
    %% Add original variable data
    out_struct.(names{i}) = variable_list.(names{i});
    %% Add _QC
    new_name = strcat('QC_', names{i});
    out_struct.(new_name).dimensions = variable_list.(names{i}).dimensions;
    out_struct.(new_name).attributes = struct();
    out_struct.(new_name).attributes(1,1).name = variable_list.(names{i}).attributes(1).name;
    out_struct.(new_name).attributes(1,1).value = ['QC of ' variable_list.(names{i}).attributes(1).value];
    out_struct.(new_name).attributes(2,1).name = variable_list.(names{i}).attributes(2).name;
    out_struct.(new_name).attributes(2,1).value = ['QC_' variable_list.(names{i}).attributes(2).value];
    out_struct.(new_name).attributes(3,1).name = 'quality_control_convention';
    out_struct.(new_name).attributes(3,1).value = 'SOCIB Quality control';
    out_struct.(new_name).attributes(4,1).name = 'valid_min';
    out_struct.(new_name).attributes(4,1).value = '1';
    out_struct.(new_name).attributes(5,1).name = 'valid_max';
    out_struct.(new_name).attributes(5,1).value = '9';
    out_struct.(new_name).attributes(6,1).name = 'flag_values';
    out_struct.(new_name).attributes(6,1).value = strrep(mat2str(uint8([1, 3, 4, 6, 9])),' ', ', ');
    out_struct.(new_name).attributes(7,1).name = 'flag_meanings';
    out_struct.(new_name).attributes(7,1).value = 'good_data probably_bad_data bad_data spike missing_value';
    out_struct.(new_name).datatype = 'byte';
    
end

end
