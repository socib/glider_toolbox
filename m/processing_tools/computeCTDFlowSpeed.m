function flow = computeCTDFlowSpeed(varargin)
%COMPUTECTDFLOWSPEED  Compute flow speed along CTD cell.
%
%  Syntax:
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH)
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, PITCH)
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, OPTIONS)
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, OPT1, VAL1, ...)
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, PITCH, OPTIONS)
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, PITCH, OPT1, VAL1, ...)
%
%  Description:
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH) computes the flow speed 
%    through the cell of a CTD in a vertical profile sequence given by vectors 
%    TIMESTAMP (timestamp) and DEPTH (depth), and returns it in vector FLOW.
%    All these vectors should have the same dimensions.
%
%    FLOW = COMPUTECTDFLOWSPEED(TIMESTAMP, DEPTH, PITCH) performs the same 
%    correction but for a non-vertical profile, with pitch angle given by PITCH 
%    in radians. PITCH may be either a vector with the same dimensions as 
%    TIMESTAMP and DEPTH, or a scalar taken to be the constant pitch across the 
%    whole profile sequence.
%
%    FLOW = COMPUTECTDFLOWSPEED(..., OPTIONS) and 
%    FLOW = COMPUTECTDFLOWSPEED(..., OPT1, VAL1, ...) allow passing extra 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS 
%    with field names as option keys and field values as option values.
%    Recognized options are:
%      FACTORPOLY: flow speed factor polynomial.
%        Vector with the coefficients of the polynomial that returns the flow
%        speed factor whem evaluated by POLYVAL at each surge speed value.
%        See note on flow speed computation below.
%        Default value:  [0.00 0.03 1.15] (see note below).
%      MINVEL: minimum vertical velocity threshold.
%        Scalar with the minimum vertical velocity threshold below which the 
%        aproximated surge speed value is supposed to be unreliable. On samples 
%        with an absolute vertical velocity value less than given threshold 
%        flow speed is invalid (NaN).
%        Default value: 0 (all samples are valid)
%      MINPITCH: minimum pitch threshold.
%        Scalar with the minimum pitch threshold in radians below which the 
%        aproximated surge speed value is supposed to be unreliable. On samples 
%        with an absolute pitch value lesser than given threshold flow speed is 
%        invalid (NaN).
%        Default value: 0 (all samples are valid)
%
%  Notes:
%    This function is based on the flow speed computation code by Tomeu Garau in
%    function CORRECTTHERMALLAG. Main changes are:
%      - Changed vertical velocity approximation method (central instead of 
%        forward differences).
%      - Added support for discarding regions with low velocity or low pitch.
%
%    The approximate flow speed is computed from the absolute value of the
%    vertical velocity. The vertical velocity is approximated using central
%    differences, but accounting for the possibly unevenly spaced samples.
%    In non-vertical profiles with given pitch, the vertical velocity is scaled
%    by the sine of the pitch angle. The absolute value of this intermediate
%    quantity is called surge speed. To obtain the flow speed, each surge speed
%    value is scaled by a factor resulting from the evaluation of the given 
%    polynomial at the surge speed value. If no polynomial given, the surge 
%    speed is not scaled and equals the flow speed. 
%    The note on Garau's original code was:
%      % The relative coefficient between the flow speed inside and outside of 
%      % the conductivity cell. This is still uncertain (ask Gordon for origin).
%      % Here are three choices for first three orders polynomial.
%      speed_factor_polynoms = [0.00, 0.00, 0.40;  % 0th order degree.
%                               0.00, 0.03, 0.45;  % 1st order degree.
%                               1.58, 1.15, 0.70]; % 2nd order degree.
%      % First order approximation, second row of the matrix.
%    Surge speed is supposed to be unreliable when the vertical velocity or the
%    pitch is too low, so the flow speed is left undefined. In October 2013
%    Gerd Krahmann noted that there might be a bug in the original 
%    implementation, and the matrix of polynomial coefficients (above) should be
%    transposed:
%      speed_factor_polynoms = [0.00, 0.00, 1.58;  % 0th order degree.
%                               0.00, 0.03, 1.15;  % 1st order degree.
%                               0.40, 0.45, 0.70]; % 2nd order degree.
%
%  Examples:
%    % Vertical profile:
%    flow = computeCTDFlowSpeed(timestamp, depth, pitch)
%    % Tilted profile:
%    flow = computeCTDFlowSpeed(timestamp, depth, 25)
%    flow = computeCTDFlowSpeed(timestamp, depth, pitch)
%    % No flow speed factor scaling:
%    flow = computeCTDFlowSpeed(timestamp, depth, pitch, 'factorpoly', [])
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

  narginchk(2, 9);
  
  
  %% Parse mandatory input arguments.
  % Get numeric (non-option) arguments.
  narginnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(narginnum)
    narginnum = nargin;
  end
  switch(narginnum)
    case 2
      % Vertical profile.
      [timestamp, depth] = varargin{1:2};
      pitch = [];
    case 3
      % Tilted profile.
      [timestamp, depth, pitch] = varargin{1:3};
    otherwise
      % Bad arguments.
      error('glider_toolbox:computeCTDFlowSpeed:InvalidArguments', ...
            'Invalid arguments (first 2 or 3 arguments should be numeric).');
  end
  
  
  %% Configure default options.
  % This is NOT equivalent to the original version by Tomeu Garau.
  % The 1st degree flow speed factor polynomial is chosen, but using the proper
  % coefficients as noted by Gerd Krahmann.
  options.factorpoly = [0.00, 0.03, 1.15];
  options.minvel = 0.0;
  options.minpitch = 0.0;
  
  
  %% Parse option arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin(narginnum+1:end);
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:findCTDFlowSpeed:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findCTDFlowSpeed:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end

  
  %% Select full CTD rows.
  % The positive timestamp test is needed to deal with odd data from initial
  % lines in Slocum segment files.
  if numel(pitch) > 1
    valid = (timestamp(:) > 0) & ~isnan(depth(:)) & ~isnan(pitch(:));
    timestamp_val = timestamp(valid);
    depth_val = depth(valid);
    pitch_val = pitch(valid);
  else
    valid = (timestamp(:) > 0) & ~isnan(depth(:));
    timestamp_val = timestamp(valid);
    depth_val = depth(valid);
    pitch_val = pitch;
  end
  
  
  %% Compute glider surge speed from the vertical speed and the pitch if any.
  % For Slocum data, pitch is positive when nose is up (so positive z is down).
  % Use central differences scheme to compute 2nd order approximation, 
  % but adapted to deal with irregular time sampling.
  vertical_velocity = zeros(size(timestamp_val));
  dd = diff(depth_val);
  dt = diff(timestamp_val);
  ddt = timestamp_val(3:end) - timestamp_val(1:end-2);
  dd_dt = dd ./ dt;
  n = numel(timestamp_val);
  if n > 1
    vertical_velocity([1 end]) = dd([1 end]) ./ dt([1 end]);
  end
  if n > 2
    vertical_velocity(2:end-1) = ...
      (dt(2:end) .* dd_dt(1:end-1) + dt(1:end-1) .* dd_dt(2:end)) ./ ddt;
    % vertical_velocity(2:end-1) = (1.0 - dt(1:end-1)./ddt) .* dd_dt(1:end-1) ...
    %                            + (1.0 - dt(2:end  )./ddt) .* dd_dt(2:end  );
  end
  if isempty(pitch)
    surge_speed = abs(vertical_velocity);
  else
    surge_speed = abs(vertical_velocity ./ sin(pitch_val));
  end
  
  
  %% Discard unreliable surge speed estimates:
  low_vel = abs(vertical_velocity) < options.minvel;
  low_pitch = abs(pitch_val) < options.minpitch; 
  surge_speed(low_vel | low_pitch) = nan;
  
  
  %% Compute flow speed inside cell from surge speed.
  % Do not scale surge speed if no polynomial is given.
  if isempty(options.factorpoly)
    flow_factor = 1;
  else
    flow_factor = polyval(options.factorpoly, surge_speed);
  end
  flow = nan(size(timestamp));
  flow(valid) = flow_factor .* surge_speed;

end
