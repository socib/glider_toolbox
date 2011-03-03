function correctionParams = fitThermalLagParams(gliderProfile, referenceProfile)
%FITTHERMALLAGPARAMS - CTDs Thermal lag parameters fitting.
% This function receives as input parameters 'gliderProfile' and 'referenceProfile', 
% two profiles which are supposed to be measuring the same water column.
% Based on the assumption that both profiles should be as similar as
% possible, it finds the thermal lag parameters related to alpha and tau, such that
% the area in a TS diagram between the corrected glider profile and reference profile is minimum.
%
% Syntax: correctionParams = fitThermalLagParams(gliderProfile, referenceProfile)
%
% Inputs:
%    gliderProfile - A profile structure*
%    referenceProfile - A profile structure*
%
% * Profile structure: A struct that contains several fields,
%   all of them column vectors with the same length:
%   - ptime: Present time instant at which this row was collected
%   - depth: Depth (pressure in decibars) measured by the CTD
%   - temp: Temperature measured by the CTD
%   - cond: Conductivity measured by the CTD
%   - pitch: Pitch angle of the glider (optional)
%
% Outputs:
%    correctionParams - vector containing the correction parameters
%    used to correct the profile thermal lag
%
% Example:
%    correctionParams = fitThermalLagParams(gliderProfile, referenceProfile)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: CORRECTTHERMALLAG, FMINCON, BUILDPOLYGON
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

    % Starting guess of the solution: get the parameters estimated
    % from the correction of one of the profiles.
    % The selection of the profile is arbitrary.
    [dummyCorrectedProfile, firstGuess] = correctThermalLag(gliderProfile);
    maxTime = max(gliderProfile.ptime(:)) - min(gliderProfile.ptime(:));

    % Minimize the area between the two profiles in the TS Diagram
    options = buildMinimizationOptions;
    
    upperBound = [2, 1, maxTime, maxTime/2];
    lowerBound = 1e-5 * ones(size(firstGuess));
    correctionParams = fmincon(@computeTSArea, firstGuess, [], [], [], [], lowerBound, upperBound, [], options);
    
    function areaValue = computeTSArea(params)
        
        % Correct both profiles with the same parameters
        correctedGliderProfile = correctThermalLag(gliderProfile, params);
    
        % Compute salinity and temperature of each profile
        temperatureGlider = correctedGliderProfile.temp;
        cndrGlider        = correctedGliderProfile.cond * 10 / sw_c3515;
        salinityGlider    = sw_salt(cndrGlider, correctedGliderProfile.tempInCell, correctedGliderProfile.depth);
            
        temperatureRef = referenceProfile.temp;
        salinityRef    = referenceProfile.salt;
    
        isGliderDowncast = (correctedGliderProfile.depth(end) > correctedGliderProfile.depth(1));
        isRefDowncast    = (referenceProfile.depth(end) > referenceProfile.depth(1));
        
        % If they don't go in differnt directions, 
        % flip one of them to form a well posed polygon
        if ~xor(isGliderDowncast, isRefDowncast),
            salinityRef    = flipud(salinityRef);
            temperatureRef = flipud(temperatureRef);
        end;
        
        % Compute, in the TS diagramm domain,
        % the area of the polygon described by the two profiles:
        [s, t, areaValue] = buildPolygon( ...
            salinityGlider, temperatureGlider, ...
            salinityRef, temperatureRef);
    end

end
