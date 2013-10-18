function preprocessing_options = configDataPreprocessing()
%CONFIGDATAPREPROCESSING  Configure glider data preprocessing.
%
%  Syntax:
%    PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSING()
%
%  PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSING() should return a struct
%  setting the options for glider data preprocessing as needed by the function
%  PREPROCESSGLIDERDATA.
%
%  Examples:
%    preprocessing_options = configDataPreprocessing()
%
%  See also:
%    PREPROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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
  
  preprocessing_options.nmea_conversion_sensor_list = {
    'm_gps_lat'
    'm_gps_lon'
    'm_lat'
    'm_lon'
    'c_wpt_lat'
    'c_wpt_lon'
  };

end

