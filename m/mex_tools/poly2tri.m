function [xtri, ytri] = poly2tri(x, y)
%POLY2TRI  Polygon triangulation using GPC library.
%
%  Syntax:
%    [XTRI, YTRI] = POLY2TRI(X, Y)
%
%  [XTRI, YTRI] = POLY2TRI(X, Y) triangulates the polygon with coordinates in
%  vectors X and Y, returning the coordinates of the resulting triangulation in
%  3xM arrays XTRI and YTRI, where M is the number of triangles in the
%  decomposition, and each column defines a triangle. X and Y must have the same 
%  dimensions. The polygon may be self-intersecting, and it is supposed to be
%  closed even if the first vertex is not repeated at the end.
%
%  Notes:
%    The true decomposition is performed by the function GPC_POLYGON_TO_TRISTRIP
%    of the General Polygon Clipper library (GPC), written by Alan Murta.
%    This function is called in the companion mex file.
%
%    An alternative implementation using constrained Delaunay triangulation
%    functions provided by MATLAB is commented in this source file.
%    If you can not build or use the GPC based mex file, uncoment those lines.
%
%  Examples:
%    x = [0 -1 -1  0  0  1  1  0]
%    y = [0  0 -1 -1  1  1  0  0]
%    [xtri, ytri] = poly2tri(x, y)
%    patch(xtri, ytri, 1:size(xtri,2), 'Marker', 'none', 'EdgeColor', 'none')
%    hold on
%    plot(x, y, '-r', 'LineWidth', 2)
%
%  References:
%    Alan Murta, GPC - General Polygon Clipper library:
%    http://www.cs.man.ac.uk/~amurta/software/index.html#gpc
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error('glider_toolbox:poly2tri:MissingMexfile', 'Missing required mex file.');

  % Altrernative implementation using Delaunay Triangulation built in MATLAB.
  %{
  nv = numel(x);
  triangulation =  DelaunayTri(x(:), y(:), [1 (2:nv); (2:nv) 1]');
  indices = triangulation.inOutStatus;
  faces = triangulation.Triangulation(indices, :);
  vertices = triangulation.X;
  xtri = reshape(vertices(faces, 1), size(faces))';
  ytri = reshape(vertices(faces, 2), size(faces))'; 
  %}
  
end