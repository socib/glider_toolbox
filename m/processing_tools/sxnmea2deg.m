function varargout = sxnmea2deg(varargin)
%SXNMEA2DEG  Convert SeaExplorer NMEA latitude and/or longitude degrees to decimal degrees.
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
%    [DEGLAT, DEGLON] = SXNMEA2DEG(NMEALAT, NMEALON) performs the same
%    conversion on each of its input arguments separately. In addition,
%    it returns invalid values (nan, nan) for each position exactly equal to
%    (0, 0), and emmits a warning.
%
%  Examples:
%    sxnmea2deg(3330.00)
%    nmea = [36015.00 -445.25]
%    deg = sxnmea2deg(nmea)
%    nmealat = [3900.61662 3900.61662   0       0]
%    nmealon = [ 257.99996    0       257.99996 0]
%    [deglat, deglon] = sxnmea2deg(nmealat, nmealon)
%
%  Notes:
%    Null positions (0, 0) may appear in SeaExplorer glider data files without
%    any flag to distinguish them as bad measurements, so this function assumes
%    that all such positions are invalid, even though the values are plausible.
%  
%  See also:
%    FIX
%    REM
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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
  
  % Report null values as invalid SeaExplorer locations.
  if numel(varargin) > 1
    invalid = (varargin{1}(:) == 0) & (varargin{2}(:) == 0);
    if ~isempty(invalid)
      varargout{1}(invalid) = nan;
      varargout{2}(invalid) = nan;
      warning('glider_toolbox:sxnmeadeg:InvalidPosition', ...
              '%d invalid positions [0, 0] replaced by [NaN, NaN].', ...
              sum(invalid));
    end
  end

end
