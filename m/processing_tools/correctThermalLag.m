function [temp_inside, cond_outside] = correctThermalLag(varargin)
%CORRECTTHERMALLAG  Correct CTD conductivity and temperature sequence from thermal lag effects.
%
%  Syntax:
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIMESTAMP, COND_INSIDE, TEMP_OUTSIDE, PARAMS)
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIMESTAMP, COND_INSIDE, TEMP_OUTSIDE, FLOW_SPEED, PARAMS)
%
%  Description:
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIMESTAMP, COND_INSIDE, TEMP_OUTSIDE, PARAMS)
%    corrects thermal lag in a CTD profile sequence with constant flow speed
%    (pumped CTD) given by vectors TIMESTAMP (sampe timestamp), COND_INSIDE 
%    (conductivity inside CTD cell) and TEMP_OUTSIDE (temperature outside CTD 
%    cell), returning vectors COND_OUTSIDE (conductivity outside CTD cell) and 
%    TEMP_INSIDE (temperature inside CTD cell). TIMESTAMP, COND_INSIDE, 
%    TEMP_OUTSIDE, COND_OUTSIDE and TEMP_OUTSIDE all have the same dimensions. 
%    The correction parameters are given in a two element vector PARAMS, 
%    with the error magnitude (alpha), and the error time constant (tau). 
%    A detailed description of these parameters may be found in the references 
%    listed below (Lueck 1990).
%
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIMESTAMP, DEPTH, PITCH, COND_INSIDE, TEMP_OUTSIDE, PARAMS)
%    performs the same correction but for a CTD profile with variable flow 
%    speed (unpumped CTD), given by FLOW. FLOW should be a vector with the 
%    same dimensions as COND_INSIDE and TEMP_OUTSIDE, with the flow speed 
%    inside the CTD cell in m/s. The correction parameters are given in a 
%    four element vector PARAMS, with the offset and the slope of the error 
%    magnitude (alpha_o and alpha_s), and the offset and the slope of the 
%    error  time constant (tau_o and tau_s). A detailed description of these 
%    parameters may be found in the references listed below (Morison 1994).
%
%  Notes:
%    This function is a recoding of the function by Tomeu Garau with the same 
%    name. He is the true glider man. Main changes are:
%      - Moved flow speed computation to a separate function COMPUTECTDFLOWSPEED.
%      - Added support for pumped CTD profiles (constant flow speed).
%
%  References:
%    Garau, B.; Ruiz, S.; G. Zhang, W.; Pascual, A.; Heslop, E.;
%    Kerfoot, J.; and Tintoré, J.; 2011:
%    Thermal Lag Correction on Slocum CTD Glider Data.
%    Journal of Atmospheric and Oceanic Technology, vol. 28, pages 1065-1071.
%
%    Morison, J.; Andersen, R.; Larson, N.; D'Asaro, E.; and Boyd, T.; 1994:
%    The Correction for Thermal-Lag Effects in Sea-Bird CTD Data.
%    Journal of Atmospheric and Oceanic Technology, vol. 11, pages 1151-1164.
%
%    Lueck, R. G.; and Picklo, J. J.; 1990:
%    Thermal Inertia of Conductivity Cells: Observations with a Sea-Bird cell.
%    Journal of Atmospheric and Oceanic Technology, vol. 7, pages 756–768.
%
%    Lueck, R. G.; 1990:
%    Thermal Inertia of Conductivity Cells: Theory.
%    Journal of Atmospheric and Oceanic Technology, vol. 7, pages 741–755.
%
%  Examples:
%    % Constant flow speed (pumped CTD) profile:
%    [temp_inside, cond_outside] = ...
%      correctThermalLag(timestamp, cond_inside, temp_outside, params)
%    % Variable flow speed (unpumped CTD) profile:
%    [temp_inside, cond_outside] = 
%      correctThermalLag(timestamp, cond_inside, temp_outside, ...
%                        flow_speed, params)
%
%  See also:
%    FINDTHERMALLAGPARAMS
%    COMPUTECTDFLOWSPEED
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

  narginchk(4, 5);
  
  % Parse input arguments.
  switch(nargin)
    case 4
      % Constant flow speed (pumped CTD).
      [timestamp, cond_inside, temp_outside, params] = ...
        varargin{1:4};
      constant_flow = true;
    case 5
      % Variable flow speed (unpumped CTD).
      [timestamp, cond_inside, temp_outside, flow_speed, params] = ...
        varargin{1:5};
      constant_flow = false;
  end
  
  if constant_flow
    % Select full CTD rows
    % The positive time test is needed to deal with odd data from initial
    % lines in Slocum segment files.
    valid = (timestamp(:) > 0) ...
          & ~any(isnan([cond_inside(:) temp_outside(:)]), 2);
    time_val = timestamp(valid);
    temp_val = temp_outside(valid);
    cond_val = cond_inside(valid);
    % Extract parameter values:
    alpha = params(1);
    tau = params(2);
  else
    % Select full CTD rows
    % The positive time test is needed to deal with odd data from initial
    % lines in Slocum segment files.
    valid = (timestamp(:) > 0) ...
          & ~any(isnan([cond_inside(:) temp_outside(:) flow_speed(:)]), 2);
    time_val = timestamp(valid);
    temp_val = temp_outside(valid);
    cond_val = cond_inside(valid);
    flow_val = flow_speed(valid);
    % Extract parameter values:
    alpha_offset = params(1);
    alpha_slope = params(2);
    tau_offset = params(3);
    tau_slope = params(4);
    % Compute dynamic thermal error and error time parameters for variable flow
    % speed. The formula is given in the references above (Morison 1994).
    alpha = alpha_offset + alpha_slope ./ flow_val(1:end-1);
    tau = tau_offset + tau_slope ./ sqrt(flow_val(1:end-1));
  end

  
  % Compute the coefficients of the correction formula.
  % Definitions in references use the Nyquist frequency (half the sampling 
  % frequency). This might be wrong in the original implementation by Tomeu 
  % Garau, where the sampling frequency was used.
  % These are three equivalent formulas for coefficients.
  dtime = diff(time_val);
  % sampling_freq = 1 ./ dtime;
  % nyquist_freq = 0.5 * sampling_freq;
  % coefa = alpha .* (4 * nyquist_freq .* tau) ./ (1 + 4 * nyquist_freq .* tau);
  % coefb = 1 - 2  * (4 * nyquist_freq .* tau) ./ (1 + 4 * nyquist_freq .* tau);
  % coefa = 2 * alpha ./ (2 + dtime .* beta); % from SBE Data Processing.
  % coefb = 1 - 2 .* coefa ./ alpha;          
  coefa = 2 * alpha ./ (2 + dtime ./ tau);  % same using tau instead of beta.
  coefb = 1 - 4 ./ (2 + dtime ./ tau);
  
  
  % Compute the sensitivity of conductivity with respect to temperature.
  % Approximation suggested by SeaBird at section 6 of SBE Data Processing 
  % User's Manual: Data Processing Modules, Cell Thermal Mass.
  % Software Release 7.16a and later. Date: 01/18/08
  % dc_dt = 0.1 .* (1 + 0.006 .* (temp - 20));
  dcond_dtemp = (0.088 + 0.0006 * temp_val);
  
  % Compute auxiliary vector of consecutive temperature differences.
  dtemp = diff(temp_val);
  
  % Compute conductivity and temperature correction using the recursive formula
  % proposed in references. Loop unfolding seems impractical.
  cond_correction = zeros(size(time_val));
  temp_correction = zeros(size(time_val));
  for n = 1:numel(time_val)-1,
    % Compute corrections for next depth level.
    cond_correction(n+1) = ...
      - coefb(n) * cond_correction(n) + coefa(n) * dcond_dtemp(n) * dtemp(n);
    temp_correction(n+1) = ...
      - coefb(n) * temp_correction(n) + coefa(n) * dtemp(n);
  end

  % Apply corrections to valid values in original sequences, 
  % preserving invalid values in the output.
  temp_inside = nan(size(timestamp));
  cond_outside = nan(size(timestamp));
  temp_inside(valid) = temp_val - temp_correction;
  cond_outside(valid) = cond_val + cond_correction;

end
