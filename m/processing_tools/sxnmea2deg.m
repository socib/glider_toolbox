function varargout = sxnmea2deg(varargin)
% SXNMEA2DEG  Convert NMEA latitude and/or longitude degrees to
% decimal degrees. This function also check Lat/Lon integrity for
% SeaExplorer gliders. The function is thus a slight modification of
% the original nmea2deg.m in the original glider_toolbox
%
%  Syntax:
%    DEG = SXNMEA2DEG(NMEA)
%    [DEGLAT, DEGLON] = SXNMEA2DEG(NMEALAT, NMEALON)
%
%  Description:
%    DEG = SXNMEA2DEG(NMEA) converts the scalar or array NMEA from NMEA latitude
%    or longitude degrees to decimal degrees applying the transformation:
%      DEG = FIX(NMEA/100) + REM(NMEA,100)/60;
%
%    [DEGLAT, DEGLON] = SXNMEA2DEG(NMEALAT, NMEALON) performs the same conversion
%    to each of its input arguments separately.
% 
%  For each case, geographical coordinates where lat=0 AND lon=0
%  are replaced by NaNs. 
%
%  Examples:
%    sxnmea2deg(3330.00)
%    nmea = [36015.00 -445.25]
%    deg = sxnmea2deg(nmea)
%    nmealat = 3900.61662
%    nmealon = 257.99996
%    [deglat, deglon] = sxnmea2deg(nmealat, nmealon)
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
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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
  
  % Check integrity if lat and lon are provided
  if numel(varargout) == 2
    deg1 = varargout{1};
    deg2 = varargout{2};

    I = find(deg1 == 0 & deg2 == 0);
    if ~isempty(I)
      deg1(I) = NaN;
      deg2(I) = NaN;      
      disp('[WARNING] coordinates (lat,lon) = (0.0,0.0) were flagged as NaNs')          
      varargout{1} = deg1;
      varargout{2} = deg2;
    end
  end      
    
end
