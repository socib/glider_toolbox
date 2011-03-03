function [x, y, area] = buildPolygon(x1, y1, x2, y2)
%BUILDPOLYGON - Builds a polygon based on two lines and computes its area
%
% Syntax: [x, y, area] = buildPolygon(x1, y1, x2, y2)
%
% Inputs:
%    x1 - x-coordinate of the first line
%    y1 - y-coordinate of the first line
%    x2 - x-coordinate of the second line
%    y2 - y-coordinate of the second line
%
% Outputs:
%    x - x-coordinate of the polygon
%    y - y-coordinate of the polygon
%    area - area value of the polygon
%
% Example:
%    [x, y, area] = buildPolygon(x1, y1, x2, y2)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: POLY2CW,  POLY2FV, POLYAREA
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

    % Make sure input variables are column vectors
    x1 = x1(:);
    y1 = y1(:);
    x2 = x2(:);
    y2 = y2(:);

    % Join both profiles to build the contour of the polygon
    x = [x1; x2];
    y = [y1; y2];
    [x, y] = poly2cw(x, y);
    
    % As the polygon might be self-intersecting, divide it in triangles
    [faces, vertices] = poly2fv(x, y);

    % When divided in triangles, compute the area of each one and sum them up
    area = 0;
    for faceIdx = 1:size(faces, 1),
        vertexIdx = faces(faceIdx, [1:3, 1]);
        area = area + polyarea(vertices(vertexIdx, 1), vertices(vertexIdx, 2));
    end;
   
%     figure(34); clf;
%     patch('Faces', faces, ...
%           'Vertices', vertices, ...
%           'FaceColor', 'k', 'EdgeColor', 'none');
%     pause(0.25);
end