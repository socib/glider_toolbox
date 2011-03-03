function newPressure = applyPressureFilter(sciTime, oldPressure, options)
%APPLYPRESSUREFILTER - Filters a pressure signal to smooth it
% This function low pass filters the pressure time series 
% to remove noise from the pressure sensor
%
% Syntax: newPressure = applyPressureFilter(sciTime, oldPressure, options)
%
% Inputs:
%    sciTime - column vector with time instants
%    oldPressure - column vector with pressure sensor readings
%    options - structure with options such as debugging
%
% Outputs:
%    newPressure - column vector with filtered pressure time serie
%
% Example:
%    newPressure = applyPressureFilter(sciTime, oldPressure, options)
%
% Other m-files required: seabirdFilter
% Subfunctions: none
% MAT-files required: none
%
% See also: SEABIRDFILTER, INTERP1
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 22-Feb-2011
%

    % Initialize output
    newPressure = oldPressure;
    pressTimeConstant = 4;
    
    % Denan original data    
    origPressSignal = oldPressure;
    goodRows = find(~isnan(origPressSignal));
    origPressSignal = origPressSignal(goodRows);
    pressTimeRange  = sciTime(goodRows);

    timeColumn = 1;
    keepFirst = true;
    [temp, idxRemoved, idxStayed] = ...
        removeDuplicatedRecords([pressTimeRange(:), origPressSignal(:)], ...
        timeColumn, keepFirst);

    pressTimeRange = temp(:, 1);
    origPressSignal = temp(:, 2);

    % Set the pressure time series on a regular time basis
    regTimeRange = min(pressTimeRange):max(pressTimeRange);
    regPressSignal = interp1(pressTimeRange, origPressSignal, regTimeRange);
    % Filter the regular time series
    newPressSignal = seabirdFilter(regPressSignal, pressTimeConstant, 1);
    % Set the time series on it original time instants
    newPressSignal = interp1(regTimeRange, newPressSignal, pressTimeRange);


    
    newPressure(goodRows(idxStayed))  = newPressSignal;
    newPressure(goodRows(idxRemoved)) = nan;
    
end