function [temp_inside, cond_outside] = correctThermalLag(varargin)
%CORRECTTHERMALLAG  Correct CTD conductivity and temperature sequence from thermal lag effects.
%
%  Syntax:
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
%    [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, PITCH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
%
%  [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
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
%  [TEMP_INSIDE, COND_OUTSIDE] = CORRECTTHERMALLAG(TIME, DEPTH, PITCH, COND_INSIDE, TEMP_OUTSIDE, CONSTANTS)
%  performs the same correction but for a non vertical profile, with pitch angle
%  given by PITCH in radians. PITCH may be either a vector with the same 
%  dimensions as TIME, DEPTH, COND_INSIDE and TEMP_OUTSIDE, or a scalar taken to
%  be the constant pitch across the whole profile.
%
%  Notes:
%    This function is a recoding of the function by Tomeu Garau with the same 
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
%    [temp_inside, cond_outside] = ...
%      correctThermalLag(time, depth, cond_inside, temp_outside, constants)
%    % Tilted profile:
%    [temp_inside, cond_outside] = ...
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
  % The positive time test is needed to deal with odd data from initial
  % lines in Slocum segment files.
  valid = ...
    ~any(isnan([time(:) depth(:) pitch(:) cond_inside(:) temp_outside(:)]), 2) ...
    & (time > 0);
  time_val = time(valid);
  depth_val = depth(valid);
  pitch_val = pitch(valid);
  temp_val = temp_outside(valid);
  cond_val = cond_inside(valid);
  
  % Compute glider surge speed from the vertical speed and the pitch.
  % For Slocum data, pitch is positive when nose is up (so positive z is down).
  % Reshape PITCH_VAL(1:end-1) to avoid dimension mismatch error when computing
  % surge speed in empty or single row profiles.
  ddepth = diff(depth_val);
  dtime = diff(time_val);
  vertical_velocity = ddepth ./ dtime;
  sin_pitch = reshape(sin(pitch_val(1:end-1)), size(vertical_velocity));  
  surge_speed = abs(vertical_velocity ./ sin_pitch);
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
  speed_factor = ...
    polyval(speed_factor_polynoms(speed_factor_degree_choice+1,:), surge_speed);
  flow_speed = speed_factor .* surge_speed;
  
  % Compute dynamic thermal error and error time parameters for variable flow
  % speed. The formula is given in the references above.
  alpha = alpha_offset + alpha_slope ./ flow_speed;
  tau = tau_offset + tau_slope ./ sqrt(flow_speed);

  % Compute the Nyquist frequency (half the sampling frequency). 
  % This might be wrong in the original implementation by Tomeu Garau,
  % where the sampling frequency was used.
  sampling_freq = 1 ./ dtime;
  nyquist_freq = 0.5 * sampling_freq;
  
  % Compute the coefficients of the correction formula.
  % These are three equivalent forumulas for the first coefficient.
  % coefa = 2 * alpha ./ (2 + dtime .* beta); % from SBE Data Processing.
  % coefa = 2 * alpha ./ (2 + dtime ./ tau);  % same using tau instead of beta.
  coefa = 4 * nyquist_freq .* alpha .* tau ./ (1 + 4 * nyquist_freq .* tau);
  coefb = 1 - 2 * (4 * nyquist_freq .* tau) ./ (1 + 4 * nyquist_freq .* tau);
  % coefb = 1 - 2 .* coefa ./ alpha;
  
  
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
  end;

  % Apply corrections to valid values in original sequences, 
  % preserving invalid values in the output.
  temp_inside = nan(size(time));
  cond_outside = nan(size(time));
  temp_inside(valid) = temp_val - temp_correction;
  cond_outside(valid) = cond_val + cond_correction;

end
