function good = sxgoodfix(longitude, latitude, state)
%SXGOODFIX  Discard null and repeated fixes in SeaExplorer position data.
%
%  Syntax:
%    GOOD = SXGOODFIX(LONGITUDE, LATITUDE, STATE)
%
%  Description:
%    GOOD = SXGOODFIX(LONGITUDE, LATITUDE, STATE) returns a boolean vector
%    GOOD indicating whether the position coordinates in vectors LONGITUDE
%    and LATITUDE taken in the glider state in vector STATE are taken in the
%    right state, are valid and not null, and are not a repetition of the 
%    previous fix (see note on defects of SeaExplorer position data).
%    
%  Notes:
%    SeaExplorer position data both in glider and payload data set is defective.
%    According to the manufacturer, SeaExplorer gliders can only get valid GPS
%    fixes while the glider is in 'transmitting state' (116).
%    The glider state and the fix coordinates (in NMEA degrees format)
%    are the columns `NAV_RESOURCE`, `NAV_LONGITUDE`, and `NAV_LATITUDE`
%    in the glider data set, and the columns `Lon`, `Lat`, and `NavState`
%    in the payload data set. However, wrong position coordinates may appear
%    even in the right state:
%      - Entries equal to [0, 0] may appear when there is no proper fix
%        instead of the expected value [NaN, NaN].
%      - Apparently right entries that are in fact repetitions of the previous
%        fix, which can be taken too far away in the past.
%    Hence, this function flags a position as good only if:
%      - It was taken in the right state ('transmitting state', 116).
%      - The coordinates are valid (not NaN).
%      - It is not null (both coordinates equal to zero).
%      - It differs from the previous good position.
%
%    Note that the last two conditions may discard potentially valid fixes:
%    fixes effectively at the location [0, 0] (it is not on land),
%    or consecutive fixes that are effectively at the same location
%    or so close that due to the number of decimal digits used in the data file
%    they result in the same NMEA coordinates (although with 3 decimal digits
%    in NMEA degrees points at a distance of >=3 meters should have
%    distinguishable coordinates at all locations).
%
%  Examples:
%    data = [105            0.000            0.000
%            115            0.000            0.000
%            115            0.000            0.000
%            116            0.000            0.000
%            116            0.000            0.000
%            116         4303.860          641.011
%            116         4303.857          641.004
%            116         4303.852          640.996
%            116         4303.848          640.989
%            110         4303.848          640.989
%            110         4303.848          640.989
%            NaN              NaN              NaN
%            NaN              NaN              NaN
%            NaN              NaN              NaN
%            117         4303.848          640.989
%            117         4303.848          640.989
%            116         4303.848          640.989
%            116         4303.479          642.385
%            116         4303.477          642.377
%            116         4303.477          642.377
%            116         4303.471          642.363
%            116         4303.467          642.355
%            116         4303.467          642.355
%            116         4303.467          642.355
%            116         4303.449          642.313
%            116         4303.442          642.299];
%    longitude = data(:, 3);
%    latitude = data(:, 2);
%    state = data(:, 1);
%    good = sxgoodfix(longitude,latitude, state)
%    data(good, :)
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  error(nargchk(3, 3, nargin, 'struct'));

  good = (state == 116) ...
       & ~(isnan(longitude) | isnan(latitude)) ...
       & ~((longitude == 0) & (latitude == 0));
  good_indices = find(good);
  good(good_indices(2:end)) = (diff(longitude(good)) ~= 0) ...
                            & (diff(latitude (good)) ~= 0);

end
