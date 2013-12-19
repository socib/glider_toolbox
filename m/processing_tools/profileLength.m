function l = profileLength(x, y)
%PROFILELENGTH  Compute the length of q profiles.
%
%  Syntax:
%    L = PROFILELENGTH(X, Y)
%
%  L = PROFILEAREA(X, Y) returns the lengtyh L of a profile of measurements
%  given by vectors X and Y.
%
%  Notes:
%    The length is computed as the sum of the length of then segments between
%    consecutive points in the polygon.
%
%    Profile points with invalid coordinates (NaN) are ignored.
%
%  Examples:
%    x = [-1 -1  1  1]
%    y = [ 2  0  0 -2]
%    plot(x, y)
%    l = profileLength(x, y)
%
%  See also:
%    PROFILEAREA
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

  error(nargchk(2, 2, nargin, 'struct'));

  % We could use ISFINITE instead of ISNAN to discard all non numerical values.
  % However, this may not be practical because the decomposition would omit 
  % infinite triangles, and their contribution to the total area would be 0.
  xy = [x(:) y(:)];
  xy = xy(~any(isnan(xy), 2), :);
  l = sum(sqrt(sum(diff(xy, 1) .^ 2, 2)));
  

end
