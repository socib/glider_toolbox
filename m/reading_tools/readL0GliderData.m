function [data_raw, meta_raw] = readL0GliderData(Path)
%READL0GLIDERDATA  Reads all variables from the netCDF file.
%
%  Syntax:
%    [DATA_RAW, META_RAW] = READL0GLIDERDATA(PATH)
%
%  Description:
%    This script was used to skip the loading-heavy ascii / binary read-in
%    process and processed the L0 data from the socib thredds server
%    instead.
%    PATH describes the URL or file path to the desired netCDF file. The
%    function runs through all variables and stores all variables in
%    DATA_RAW and META_RAW.
%    Returns two structs DATA_RAW and META_RAW with all data and variable
%    names as found in the searched netCDF document.
%
%  Notes:
%    Usually used to read L0 glider data from socib thredds.
%
%  Examples:
%    [data_raw, meta_raw] = readL0GliderData(path)
%
%  See also:
%    NCREAD
%    NCINFO
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2016
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

info = ncinfo(Path);
for k = 1:numel(info.Variables)
    varname = info.Variables(k).Name(:)';
    %if strcmp(varname, 'm_heading') || strcmp(varname, 'm_roll')
    %    continue
    %end
    meta_raw.sensors{k,1} = varname;
    data_raw.(varname) = ncread(Path, varname);
end

end
