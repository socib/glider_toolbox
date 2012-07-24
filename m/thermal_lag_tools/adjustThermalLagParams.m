function correctionParams = adjustThermalLagParams(downcast, upcast)
%ADJUSTTHERMALLAGPARAMS - CTDs Thermal lag parameters adjustment.
% This function receives as input parameters 'downcast' and 'upcast',
% two profiles which are supposed to be measuring the same water column
% in different directions.
% Based on the assumption that both profiles should be as similar as
% possible, it finds the thermal lag parameters related to alpha and tau, such that
% the area in a TS diagram between the corrected profiles is minimum.
%
% Syntax: correctionParams = adjustThermalLagParams(downcast, upcast)
%
% Inputs:
%    downcast - Profile structure*
%    upcast - Profile structure*
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
%   used to correct the profile thermal lag.
%
% Example:
%    correctionParams = adjustThermalLagParams(downcast, upcast)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: CORRECTTHERMALLAG, FMINCON
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
    [dummyCorrectedProfile, firstGuess] = correctThermalLag(downcast); %#ok<ASGLU>
    maxTime = max(downcast.ptime(:)) - min(downcast.ptime(:));

     % Minimize the area between the two profiles in the TS Diagram
    options = buildMinimizationOptions;

    upperBound = [2, 1, maxTime, maxTime/2];
    lowerBound = eps * ones(size(firstGuess));
    correctionParams = fmincon(@computeTSArea, firstGuess, [], [], [], [], lowerBound, upperBound, [], options);

    function areaValue = computeTSArea(params)

        % Correct both profiles with the same parameters
        correctedDowncast = correctThermalLag(downcast, params);
        correctedUpcast   = correctThermalLag(upcast  , params);

        % Compute salinity and temperature of each profile
        temperatureDowncast = correctedDowncast.temp;
        %cndrDowncast = correctedDowncast.condOutCell * 10 / sw_c3515;
        %salinityDowncast = sw_salt(cndrDowncast, temperatureDowncast, correctedDowncast.depth);
        cndrDowncast = correctedDowncast.cond * 10 / sw_c3515;
        salinityDowncast = sw_salt(cndrDowncast, correctedDowncast.tempInCell, correctedDowncast.depth);

        temperatureUpcast = correctedUpcast.temp;
        %cndrUpcast = correctedUpcast.condOutCell * 10 / sw_c3515;
        %salinityUpcast = sw_salt(cndrUpcast, temperatureUpcast, correctedUpcast.depth);
        cndrUpcast = correctedUpcast.cond * 10 / sw_c3515;
        salinityUpcast = sw_salt(cndrUpcast, correctedUpcast.tempInCell, correctedUpcast.depth);

        % Compute, in the TS diagramm domain,
        % the area of the polygon described by the two profiles:
        [s, t, areaValue] = buildPolygon( ...
            salinityDowncast, temperatureDowncast, ...
            salinityUpcast, temperatureUpcast); %#ok<ASGLU>
    end

end
