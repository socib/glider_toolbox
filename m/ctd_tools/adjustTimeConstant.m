function timeConstant = adjustTimeConstant(profile1, profile2)
%ADJUSTTIMECONSTANT - Profile sensor time lag constant adjustment.
% This function receives as input parameters two profiles assumed to be
% downcast' and 'upcast', supposed to be measuring the same water column
% in different directions.
% Based on the assumption that both profiles should be as similar as
% possible, it finds the sensor timelag parameter, such that the area
% in a Value-Depth diagram between the corrected profiles is minimum.
%
% Syntax: timeConstant = adjustTimeConstant(profile1, profile2)
%
% Inputs:
%    profile1 - Profile structure*
%    profile2 - Profile structure*
%
% * Profile structure: A struct that contains several fields,
%   all of them column vectors with the same length:
%   - time: Present time instant at which this row was collected
%   - data: Value of any variable measured by the CTD
%
% Outputs:
%    timeConstant - Value containing the sensor time lag found
%
% Example:
%    timeConstant = adjustTimeConstant(profile1, profile2)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: BUILDPOLYGON, CORRECTTIMERESPONSE, FMINCON
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011

    % Minimize the area between the two profiles in the Value-Depth Diagram
    options = buildMinimizationOptions;

    firstGuess = 0.5;
    upperBound = 16;
    lowerBound = eps;
    timeConstant = fmincon(@computeProfArea, firstGuess, [], [], [], [], lowerBound, upperBound, [], options);

    function areaValue = computeProfArea(tC)

        % Correct both profiles with the same parameters
        profile1.correctedData = correctTimeResponse(profile1.data, profile1.time, tC);
        profile2.correctedData = correctTimeResponse(profile2.data, profile2.time, tC);

        % Compute, in the T profile diagramm domain,
        % the area of the polygon described by the two profiles:
        [dummy1, dummy2, areaValue] = buildPolygon( ...
            profile1.depth, profile1.correctedData, ...
            profile2.depth, profile2.correctedData);
    end
end