function cLim = getColorLimits(variable)
%GETCOLORLIMITS - Returns the adequate color limits to plot the variable
% Returns a two-element vector with adequate lower and higher limits 
% for plotting the input variable. It computes a certain percentile from
% the input data
%
% Syntax: cLim = getColorLimits(variable)
%
% Inputs:
%    variable - the input dataset
%
% Outputs:
%    cLim - the two-element vector containing the lower and higher limits
%
% Example:
%    cLim = getColorLimits(variable)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: SORT, NUMEL, FLOOR, CEIL
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 21-May-2012
%

    sortedVar = sort(variable(~isnan(variable)));
    N = numel(sortedVar);
    if N < 100
        lowPercentile = 1;
        highPercentile = N;
    else
        lowPercentile = ceil(N / 100); % Threshold set to 1%
        highPercentile = N - lowPercentile + 1;
    end;
    cLim = [sortedVar(lowPercentile), sortedVar(highPercentile)];

end