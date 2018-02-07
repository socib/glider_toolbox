function a = profileArea(x1, y1, x2, y2)
%PROFILEAREA  Compute the area eclosed by two profiles.
%
%  Syntax:
%    A = PROFILEAREA(X1, Y1, X2, Y2)
%
%  Description:
%    A = PROFILEAREA(X1, Y1, X2, Y2) returns the area A enclosed by consecutive 
%    profiles with opposite directions in vectors X1 and Y1, and X2 and Y2.
%
%  Notes:
%    This function is a simpler rewording of a previous function by Tomeu Garau,
%    called BUILDPOLYGON. He is the true glider man.
%
%    The union of the two profiles may be a complex polygon (self-intersecting).
%    Hence, the area is computed decomposing it in triangles with the function
%    POLY2TRY, and adding the absolute value of the area of each triangular 
%    component returned by POLYAREA.
%
%    Profile points with invalid coordinates (NaN) are ignored when building the
%    polygonal contour.
%
%  Examples:
%    x1 = [ 0 -1  1  0]
%    y1 = [ 2  1 -1 -2]
%    x2 = [ 0 -1  1  0]
%    y2 = [-2 -1  1  2]
%    figure
%    hold on
%    plot(x1, y1, 'b', x2, y2, 'r')
%    a = profileArea(x1, y1, x2, y2)
%    % POLYAREA would fail because of complex polygon:
%    a = polyarea([x1(:); x2(:)], [y1(:); y2(:)])
%
%  See also:
%    POLYAREA
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

  narginchk(4, 4);

  % Join both profiles discarding invalid coordinates.
  % The resulting contour may be a complex polygon.
  % Decompose it in triangular components and sum up their areas.
  % We could use ISFINITE instead of ISNAN to discard all non-numerical values.
  % However, this may not be practical because the decomposition would omit 
  % infinite triangles, and their contribution to the total area would be 0.
  xy = [x1(:) y1(:); x2(:) y2(:)];
  xy = xy(~any(isnan(xy), 2), :);
  [x, y] = poly2tri(xy(:,1), xy(:,2));
  a = sum(polyarea(x, y));

end
