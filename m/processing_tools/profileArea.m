function a = profileArea(x1, y1, x2, y2)
%PROFILEAREA  Compute the area eclosed by two profiles.
%
%  A = PROFILEAREA(X1, Y1, X2, Y2) returns the area A enclosed by consecutive 
%  profiles with opposite directions given by vectors X1 and Y1, and X2 and Y2.
%
%  Notes:
%    The union of the two profiles may be a complex polygon (self-intersecting).
%    Hence, the are is computed decomposing it in triangles with the functions
%    POLY2CW and POLY2FV and adding the area of each triangular component 
%    returned by POLYAREA.
%
%    Profile points with invalid coordinates are ignored when building the
%    polygon contour.
%
%    This function is a simpler rewording of a previous function by Tomeu Garau,
%    called BUILDPOLYGON. He is the true glider man.
%
%  Examples:
%    x1 = [ 0 -1  1  0]
%    y1 = [ 2  1 -1 -2]
%    x2 = [ 0 -1  1  0]
%    y2 = [-2 -1  1  2]
%    figure
%    hold on
%    plot(x1, y1, 'b')
%    plot(x2, y2, 'r')
%    a = profileArea(x1, y1, x2, y2)
%    % POLYAREA would fail because of complex polygon:
%    a = polyarea([x1(:); x2(:)], [y1(:); y2(:)])
%
%  See also:
%    POLY2FV
%    POLYAREA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(4, 4, nargin, 'struct'));

  % Join both profiles discarding invalid coordinates.
  % The resulting contour may be a complex polygon.
  % Decompose it in triangular components and sum up their areas.
  % We could use ISFINITE instead to discard all non numerical values.
  % However, this may not be practical because the decomposition would omit 
  % infinie triangles, and their contribution to the total area would be 0.
  xy = [x1(:) y1(:); x2(:) y2(:)];
  xy = xy(~any(isnan(xy), 2), :);
  [x, y] = poly2cw(xy(:,1), xy(:,2));
  [f, v] = poly2fv(x, y);
  a = sum(polyarea(reshape(v(f,1),size(f))', reshape(v(f,2),size(f))'));

end
