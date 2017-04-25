function data_struct_output = removeVariablesFromStruct(data_struct_input, remove_cell_strings, prefix)
%REMOVEVARIABLESFROMSTRUCT  Removes variables from input data struct.
%
%  Syntax:
%    DATA_STRUCT_OUTPUT = REMOVEVARIABLESFROMSTRUCT(DATA_STRUCT_INPUT, REMOVE_CELL_STRINGS, PREFIX)
%
%  Description:
%    This function removes variables from the specified DATA_STRUCT_INPUT.
%    A prefix can be added to the strings stored in the REMOVE_CELL_STRINGS
%    cell.
%
%  Notes:
%    Actually, if no prefix is desired, an empty string must be given to
%    the function.
%
%  Examples:
%    data_struct_output = removeVariablesFromStruct(data_struct_input, remove_cell_strings, prefix)
%
%  See also:
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

%% Check input.
validateattributes(data_struct_input, {'struct'}, {'nonempty'})
validateattributes(remove_cell_strings, {'cell'}, {'nonempty'})
validateattributes(prefix, {'char'}, {})

%% Begin assembly.
data_struct_output = data_struct_input;

for i=1:length(remove_cell_strings)
    searched_field = strcat(prefix, remove_cell_strings{i});
    if isfield(data_struct_input, searched_field)
        data_struct_output = rmfield(data_struct_output, searched_field);
    end
end

end
