function [cond_outside, temp_inside] = correctThermalLag(varargin)
%CORRECTTHERMALLAG  Correct CTD conductivity and temperature sequence from thermal lag effects.
%
%  [COND_OUTSIDE, TEMP_INSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
%  corrects thermal lag from a vertical CTD profile sequence given by vectors 
%  TIME (timestamp), DEPTH (depth or pressure), COND_INSIDE (conductivity inside
%  CTD cell) and TEMP_OUTSIDE (temperature outside CTD cell), returning vectors 
%  COND_OUTSIDE (conductivity outside CTD cell) and TEMP_INSIDE (temperature 
%  inside CTD cell). TIME, DEPTH, COND_INSIDE, TEMP_OUTSIDE, COND_OUTSIDE and 
%  TEMP_OUTSIDE all have the same dimensions. The correction parameters are
%  given in a four element vector CONSTANTS, with the offset and the slope of
%  the error magnitude (alpha_o and alpha_s), and the offset and the slope of 
%  the error time constant (tau_o and tau_s). A detailed description of these 
%  parameters may be found in the references listed below.
%
%  [COND_OUTSIDE, TEMP_INSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, PITCH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
%  performs the same correction but for a non vertical profile, with pitch angle
%  given by PITCH in radians. PITCH may be either a vector with the same 
%  dimensions as TIME, DEPTH, COND_INSIDE and TEMP_OUTSIDE, or a scalar taken to
%  be the constant pitch across the whole profile.
%
%  Notes:
%    This functions is a recoding of the function by Tomeu Garau with the same 
%    name. He is the true glider man.
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
%    % Vertical profile:
%    [cond_outside, temp_inside] = ...
%      correctThermalLag(time, depth, cond_inside, temp_outside, constants)
%
%    % Tilted profile:
%    [cond_outside, temp_inside] = ...
%      correctThermalLag(time, depth, pitch, cond_inside, temp_outside, constants)
%
%  See also:
%    FINDTHERMALLAGPARAMS
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(5, 6, nargin, 'struct'));
  
  switch(nargin)
    case 5
      time = varargin{1};
      depth = varargin{2};
      cond_inside = varargin{3};
      temp_outside = varargin{4};
      constants = varargin{5};
      pitch = pi/2; % vertical profile.
    case 6
      time = varargin{1};
      depth = varargin{2};
      pitch = varargin{3};
      cond_inside = varargin{4};
      temp_outside = varargin{5};
      constants = varargin{6};
  end
  
  % Set constant pitch across the whole sequence, if needed.
  if isscalar(pitch)
    pitch = repmat(pitch, size(time));
  end
  
  % Extract parameter values:
  alpha_offset = constants(1);
  alpha_slope = constants(2);
  tau_offset = constants(3);
  tau_slope = constants(4);
  
  % Select full CTD rows.
  valid = ...
    ~any(isnan([time(:) depth(:) pitch(:) cond_inside(:) temp_outside(:)], 2));
  time_val = time(valid);
  depth_val = depth(valid);
  pitch_val = pitch(valid);
  temp_val = temp_outside(valid);
  
  % Compute glider surge speed from the vertical speed and the pitch.
  % For Slocum data, pitch is positive when nose is up (so positive z is down).
  % when pitch is zero, and surge speed is null.
  ddepth = diff(depth_val);
  dtime = diff(time_val);
  vertical_speed = ddepth ./ dtime;
  sin_pitch = sin(pitch_val);
  surge_speed = vertical_speed ./ sin_pitch(1:end-1);
  % Deal whith numerical zero pitch values.
  % small_pitch_sel = (abs(pitch_val) < small_pitch_threshold);
  % surge_speed(small_pitch_sel) = 0;
  
  % Compute flow speed inside cell from surge speed.
  % The original comment in Tomeu Garau's code was:
  %   The relative coefficient between the flow speed inside and outside
  %   of the conductivity cell. This is still uncertain (ask Gordon for origin).
  %   Here are three choices for first three orders polynomial.
  speed_factor_polynoms = [0.00, 0.00, 0.40;  % 0th order degree.
                           0.00, 0.03, 0.45;  % 1st order degree.
                           1.58, 1.15, 0.70]; % 2nd order degree.
  % First order approximation, second row of the matrix.
  speed_factor_degree_choice = 1; 
  speed_factor = polyval(speed_factor_polynoms(speed_factor_degree_choice,:), ...
                         surge_speed);
  abs_flow_speed = abs(speed_factor .* surge_speed);
  
  % Compute dynamic thermal error and error time parameters for variable flow
  % speed. The formula is given in the references above.
  alpha = alpha_offset + alpha_slope ./ abs_flow_speed;
  tau = tau_offset + tau_slope ./ sqrt(abs_flow_speed);

  % Compute the Nyquist frequency (half the sampling frequency). 
  % This might be wrong in the original implementation by Tomeu Garau,
  % where the sampling frequency was used.
  sampling_freq = 1 ./ dtime;
  nyquist_freq = 0.5 * sampling_freq;
  
  % Compute the coefficients of the correction formula.
  % These are three equivalent forumulas for the first coefficient.
  % coefa = 2 * alpha ./ (2 + dtime .* beta); % from SBE Data Processing.
  % coefa = 2 * alpha ./ (2 + dtime ./ tau);  % same using tau instead of beta.
  coefa = 4 * nyquist_freq .* alpha .* tau ./ (1 + 4  * nyquist_freq .* tau);
  coefb = 1 - 2 .* coefa ./ alpha;
  
  % Compute the sensitivity of conductivity with respect to temperature.
  % Approximation suggested by SeaBird at section 6 of SBE Data Processing 
  % User's Manual: Data Processing Modules, Cell Thermal Mass.
  % Software Release 7.16a and later. Date: 01/18/08
  % dc_dt = 0.1 .* (1 + 0.006 .* (temp - 20));
  dc_dt = (0.088 + 0.0006 * temp_val);
  
  % Compute auxiliary vector of consecutive temperature differences.
  dtemp = diff(temp_val);
  
  % Compute conductivity and temperature correction using the recursive formula
  % proposed in references. Loop unfolding seemps impractical.
  cond_correction = zeros(size(valid));
  temp_correction = zeros(size(valid));
  for n = 1:numel(time)-1,
    % Compute corrections for next depth level
    cond_correction(n+1) = ...
      - coeff_b(n) .* cond_correction(n) ...
      + coeff_a(n) .* dc_dt(n) .* dtime .* dtemp(n);
    temp_correction(n+1) = ...
      - coefb(n) .* temp_correction(n) ...
      + coefa(n) .* dtemp(n);
  end;

  % Apply corrections to valid values in original sequences, 
  % preserving invalid values in the output.
  cond_outside = nan(size(time));
  temp_inside = nan(size(time));
  cond_outside(valid) = cond_inside(valid) + cond_correction;
  temp_inside(valid) = temp_outside(valid) + temp_correction;

end
