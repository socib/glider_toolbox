function [correctedProfileData, varargout] = correctThermalLag(basicProfileData, varargin)
%CORRECTTHERMALLAG - CTDs Thermal lag correction.
% This function receives as input parameter a CTD profile, and applies a
% thermal lag correction on it.
% The correction applied uses the recursive scheme described in
% Morison, J., R. Andersen, N. Larson, E. D'Asaro, and T. Boyd, 1994:
% The Correction for Thermal-Lag Effects in Sea-Bird CTD Data.
% Journal of Atmospheric and Oceanic Technology, vol. 11, pages 1151�1164.
%
% Syntax:
%    correctedProfileData = correctThermalLag(basicProfileData)
%    correctedProfileData = correctThermalLag(basicProfileData, correctionParams)
%    [correctedProfileData, correctionParams] = correctThermalLag(basicProfileData)
%
% Inputs:
%    basicProfileData - A profile structure*
%    correctionParams - The set of parameters to be used in the correction*
%
% Outputs:
%    correctedProfileData - A profile structure*
%    correctionParams - The set of parameters used in the correction*
%
% * Profile structure: A struct that contains several fields,
%   all of them column vectors with the same length:
%   - ptime: Present time instant at which this row was collected
%   - depth: Depth (pressure in decibars) measured by the CTD
%   - temp: Temperature measured by the CTD
%   - cond: Conductivity measured by the CTD
%   - pitch: Pitch angle of the glider (optional)
%   The output profile has the same information of the input plus
%   two fields with the corrected profile properties:
%   - condOutCell: corrected conductivity, removing the effects of the
%     temperature difference between the outer and inner parts of the
%     conductivity cell.
%   - tempInCell: corrected temperature, that is, the temperature of
%     the water mass lying inside the conductivity cell.
%
%   From this information, the user can choose which one of the two
%   corrections to use in order to compute salinity:
%   - Combine 'condOutCell' with 'temp' (Expected values outside of the
%     conductivity cell).
%   - Combine 'cond' with 'tempInCell' (Expected values inside of the
%     conductivity cell).
%
% * Correction parameters: A vector of four elements, consisting in
%   alpha_offset, alpha_slope, tau_offset and tau_slope.
%   These parameters are used to compute alpha and tau,
%   the amplitude and time constant respectively, which are inversely
%   proportional to the flow speed.
%
% Example:
%   correctedProfileData = correctThermalLag(basicProfileData) corrects the
%   profile information contained in the input 'basicProfileData',
%   using Morison parameters
%
%   correctedProfileData = correctThermalLag(basicProfileData, correctionParams)
%   corrects the profile information contained in 'basicProfileData',
%   using correctionParams as the parameters to be used
%   during the correction.
%
%   [correctedProfileData, correctionParams] = correctThermalLag(basicProfileData)
%   corrects the profile information contained in 'basicProfileData', and
%   provides in the output the correction parameters used for the correction.
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ADJUSTTHERMALLAGPARAMS
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

    % Extract the information contained in the profile
    time  = basicProfileData.ptime;
    depth = basicProfileData.depth;
    temp  = basicProfileData.temp;
    cond  = basicProfileData.cond;
    if isfield(basicProfileData, 'pitch'),
        pitch = basicProfileData.pitch * pi / 180;
    else
        pitch = (26 * pi / 180) * ones(size(depth));
    end;

    % Copy the original fields into the output struct
    correctedProfileData = basicProfileData;
    if numel(time) <= 1
        correctedProfileData.condOutCell = correctedProfileData.cond;
        correctedProfileData.tempInCell  = correctedProfileData.temp;
        return;
    end;

    if nargin == 1, % Only basicProfileData is provided as input

        % These values are proposed in Morison94
        alpha_offset = 0.0135;
        alpha_slope  = 0.0264;
          tau_offset = 7.1499;
          tau_slope  = 2.7858;

    elseif nargin == 2, % Profile + Offset and slope for alpha and tau are given

        paramVector  = varargin{1};
        alpha_offset = paramVector(1);
        alpha_slope  = paramVector(2);
          tau_offset = paramVector(3);
          tau_slope  = paramVector(4);

    else
        disp('Incorrect number of parameters. Type ''help correctThermalLag'' for more information');
        return;
    end;

    % Some initial precomputations
    deltaTime    = abs(diff(time));
    deltaTemp    =     diff(temp) ;
    samplingFreq = 1 ./ deltaTime ;

    % Calculate the surge speed from the depth rate and pitch
    deltaDepth = abs(diff(depth)); % does not matter if downcast or upcast
    depthRate  = deltaDepth ./ deltaTime;
    pitchSinus = sin(pitch);
    surgeSpeed = depthRate ./ pitchSinus(1:end-1);

    % The relative coefficient between the flow speed inside and outside
    % of the conductivity cell. This is still uncertain (ask Gordon for origin).
    % Here are three choices for first three orders polynomial.
    speedFactorPols = [0.00, 0.00, 0.40;  % 0th order degree
                       0.00, 0.03, 0.45;  % 1st order degree
                       1.58, 1.15, 0.70]; % 2nd order degree

    selectedDegree = 1; % First order approximation, second row of the matrix
    speedFactor = polyval(speedFactorPols(selectedDegree+1, :), surgeSpeed);
    flowSpeed = abs(speedFactor .* surgeSpeed) + eps; % Avoid division by zero

    % The alpha and tau parameters, as suggested in the reference paper,
    % depend on the flow with tne next expressions
    alpha = alpha_offset + alpha_slope ./      flowSpeed ;
    tau   =   tau_offset +   tau_slope ./ sqrt(flowSpeed);

    % Relation between a and b coefficients with respect to alpha and tau
    coefa = 4 .* samplingFreq .* alpha .* tau ./ (1 + 4 .* samplingFreq .* tau);
    coefb = 1 - 2 .* coefa ./ alpha;

    % Sensitivity of conductivity with respect to temperature,
    % approximation suggested by SeaBird: SBE Data Processing User�s Manual
    % at Section 6: Data Processing Modules, Cell Thermal Mass
    % Software Release 7.16a and later. Date: 01/18/08
    % dCdT = 0.1 .* (1 + 0.006 .* (temp - 20));
    dCdT = 0.088 + 0.0006 * temp;

    % Recursive processing of the corrections
    condCorrection = zeros(size(cond));
    tempCorrection = zeros(size(temp));

    for depthLevel = 1:length(depth)-1,
        % Compute corrections for next depth level
        condCorrection(depthLevel+1) = ...
          - coefb(depthLevel) .* condCorrection(depthLevel) + ...
            coefa(depthLevel) .* dCdT(depthLevel) .* deltaTemp(depthLevel);
        tempCorrection(depthLevel+1) = ...
          - coefb(depthLevel) .* tempCorrection(depthLevel) + ...
            coefa(depthLevel) .* deltaTemp(depthLevel);
    end;

    % Apply corrections and save them as fields in the output struct
    correctedProfileData.condOutCell = cond + condCorrection;
    correctedProfileData.tempInCell  = temp - tempCorrection;

    if nargout == 2, % If required, output alpha and tau offsets and slopes
        varargout{1} = [alpha_offset, alpha_slope, tau_offset, tau_slope];
    end;
    if nargout == 3, % If required, output also alpha and tau parameters
        varargout{2} = [alpha, tau];
    end;

return;
