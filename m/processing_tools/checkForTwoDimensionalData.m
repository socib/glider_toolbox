function bool = checkForTwoDimensionalData(data)
%CHECKFORTWODIMENSIONALDATA  Simple check, if the data has at least 2 dimensions.
%
%  Syntax:
%    BOOL = CHECKFORTWODIMENSIONALDATA(DATA)
%
%  Description:
%    Returns true (1) or false (0), if the column of the data array has
%    more than one entry.
%    Care, no cross-check validation, if it is really only 2D or multi
%    dimensional. Also, if a 1D array is passed (and should correctly be
%    identified as false), it must be a row-array.
%    Function is used to determine, if the incoming data array is gridded
%    data or just a one dimensional array.
%
%  Notes:
%    Input data array should be a row x column array.
%
%  Examples:
%    bool = checkForTwoDimensionalData(data)
%
%  See also:
%    SIZE
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

dataDimensions = size(data);

if dataDimensions(2)>=2
    bool=true;
else
    bool=false;
end


end
