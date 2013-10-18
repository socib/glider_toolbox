function deg = nmea2deg(nmea)
%NMEA2DEG  Convert NMEA latitude/longitude degrees to decimal degrees.
%
%  Syntax:
%    DEG = NMEA2DEG(NMEA)
%
%  DEG = NMEA2DEG(NMEA) Converts the scalar or array NMEA from NMEA
%  latitude/longitude degrees to decimal degrees applying the transformation:
%     DEG = FIX(NMEA/100) + REM(NMEA,100)/60;
%    
%  Examples:
%    nmea2deg(3330.00)
%    nmea = [36015.00 -445.25]
%    deg = nmea2deg(nmea)
%
%  Notes:
%    The input number is not checked to be a valid NMEA coordinate value.
%    So no warning is produced if the degree digits are out of [0,180] or
%    the integral part of de minute digits are out of [00,59].
%  
%  See also:
%    FIX
%    REM
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

  error(nargchk(1, 1, nargin, 'struct'));
  
  deg = fix(nmea/100) + rem(nmea,100)/60;

end
