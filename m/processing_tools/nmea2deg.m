function varargout = nmea2deg(varargin)
%NMEA2DEG  Convert NMEA latitude and/or longitude degrees to decimal degrees.
%
%  Syntax:
%    DEG = NMEA2DEG(NMEA)
%    [DEGLAT, DEGLON] = NMEA2DEG(NMEALAT, NMEALON)
%
%  Description:
%    DEG = NMEA2DEG(NMEA) converts the scalar or array NMEA from NMEA latitude
%    or longitude degrees to decimal degrees applying the transformation:
%      DEG = FIX(NMEA/100) + REM(NMEA,100)/60;
%
%    [DEGLAT, DEGLON] = NMEA2DEG(NMEALAT, NMEALON) performs the same conversion
%    to each of its input arguments separately.
%
%  Examples:
%    nmea2deg(3330.00)
%    nmea = [36015.00 -445.25]
%    deg = nmea2deg(nmea)
%    nmealat = 3900.61662
%    nmealon = 257.99996
%    [deglat, deglon] = nmea2deg(nmealat, nmealon)
%
%  Notes:
%    The input values are not checked to be valid NMEA coordinate values.
%    So no warning is produced if the degree digits are out of [0,180] or
%    the integral part of de minute digits are out of [00,59].
%  
%  See also:
%    FIX
%    REM
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

  error(nargchk(1, 2, nargin, 'struct'));
  
  for varargidx = 1:numel(varargin)
    nmea = varargin{varargidx};
    deg = fix(nmea/100) + rem(nmea,100)/60;
    varargout{varargidx} = deg;
  end

end
