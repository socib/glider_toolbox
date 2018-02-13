function [ ncvars ] = getNCVars( filename )
%GETNCVARS Reads data from NC file
%
%  Syntax: 
%     NCVARS = GETNCVARS( FILENAME );
%
%  Description:
%     Reads the netCDF file and returns a structure containing the data.
%     The fields of the structure correspond to the names of the data. The
%     values of the structures are the values for each specific variable.
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>

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

  narginchk(1, 1);


    ncvars = struct();
  
    % Read NC file
    fileContent = nc_info(filename);
    
    % Run through the list of available variables
    for varIdx = 1:length(fileContent.Dataset)
        % Get the variable name
        varName = fileContent.Dataset(varIdx).Name;
        % Build a command to load that variable
        matlabCommand = ['ncvars.', varName, ' = nc_varget(filename, ''', varName, ''');'];
        % Evaluate the command
        eval(matlabCommand);
        disp( varName);
    end;
  
  
end

