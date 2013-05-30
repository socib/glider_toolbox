function [constants, exitflag, residual] = findThermalLagParams(varargin)
%FINDTHERMALLAGPARAMS  Thermal lag parameter estimation for a single pair of casts.
%
%  Syntax:
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, COND2, TEMP2, PRES2)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, COND2, TEMP2, PRES2, OPTIONS)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, COND2, TEMP2, PRES2, OPT1, VAL1, ...)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, PITCH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, PITCH2, COND2, TEMP2, PRES2)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, PITCH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, PITCH2, COND2, TEMP2, PRES2, OPTIONS)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, PITCH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, PITCH2, COND2, TEMP2, PRES2, OPT1, VAL1, ...)
%    [CONSTANTS, EXITFLAG, RESIDUAL] = FINDTHERMALLAGPARAMS(...)
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, COND2, PRES2, TEMP2)
%  finds the thermal lag parameters from two vertical profiles given by 
%  sequences of time (s), depth (m), conductivity (S/m), temperature (ºC) and 
%  pressure (dbar) in repective vectors TIME1, DEPTH1, COND1 and TEMP1, and 
%  TIME2, DEPTH2, COND2 and TEMP2. The computed parameters are returned in a 
%  four element vector CONSTANTS, with the offset and the slope of the error 
%  magnitude (ALPHA_O and ALPHA_S), and the offset and the slope of the error 
%  time (TAU_O and TAU_S). With these parameters, the error magnitude and the 
%  error time, depending on the flow speed (V), may be estimated as:
%    ALPHA = ALPHA_O + ALPHA_S / V
%      TAU =   TAU_O +   TAU_S / SQRT(V)
%  The profiles are supposed to measure the same column of water in opposite 
%  directions.
%
%  The function solves the minimization problem of finding the thermal lag 
%  parameters such that the area between profiles of temperature and salinity 
%  is minimal; where salinity is derived from temperature, conductivity and 
%  pressure sequences using SW_SALT with the corrected temperature sequence
%  returned by CORRECTTHERMALLAG. This problem is solved with the function 
%  FMINCON, using default values for the initial guess and the parameter bounds.
%  See OPTIONS description below.
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, PITCH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, PITCH2, COND2, TEMP2, PRES2, ...)
%  performs the same correction but for non vertical profiles, with pitch angle
%  (rad) given by PITCH1 and PITCH2 radians. TIME1, DEPTH1, COND1 and TEMP1, 
%  and TIME2, DEPTH2, COND2 and TEMP2 should have the same dimensions.
%  PITCH1 and PITCH2 may be either a vector a with the same dimensions or a 
%  scalar taken to be the constant pitch across the respective profile.
%
%  CONSTANTS = FINDSENSORLAGPARAMS(..., OPTIONS) and 
%  CONSTANTS = FINDSENSORLAGPARAMS(..., OPT1, VAL1, ...) allow passing extra 
%  options given either as key-value pairs OPT1, VAL1... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    GRAPHICS: whether graphic output should be produced.
%      A boolean. If true a nice figure showing the minimization process will be
%      displayed. It includes the parameter values, the objective function 
%      value, the temperature-salinity diagram and the depth-salinity diagram.
%      Default value: false.
%    GUESS: initial guess for minimization function FMINCON.
%      A four element vector with the initial guess for each parameter.
%      Default value: [0.0135 0.0264 7.1499 2.7858] (Morison 1994).
%    LOWER: lower bounds of parameters for minimization function FMINCON.
%      A four element vector with the lower bound for each parameter.
%      Default value: [0 0 0 0] (no correction).
%    UPPER: upper bounds of parameters for minimization function FMINCON.
%      A four element vector with the upper bound for each parameter.
%      Default value: [2 1 RANGE(TIME1) RANGE(TIME1)/2].
%    OPTIMOPTS: extra options for the minimization function FMINCON.
%      A option struct as needed by the function FMINCON.
%      Default value: default options for FMINCON, except for:
%       'Algorithm': 'interior-point'
%       'TolFun': 1e-4
%       'TolCon': 1e-5
%       'TolX': 1e-5
%       'Display': 'off'
%
%  [CONSTANTS, EXITFLAG, RESIDUAL] = FINDTHERMALLAGPARAMS(...) also returns the 
%  exit code of the minimization function FMINCON in EXITFLAG, and the resulting
%  residual area in RESIDUAL. EXITFLAG is positive when minimization succeeds.
%
%  Notes:
%    This function is an improved version of a previous function by Tomeu Garau,
%    called ADJUSTTHERMALLAGPARAMS. He is the true glider man.
%    Introduced changes are:
%      - Different minimization algorithm (interior-point instead of active-set).
%      - Support for custom minimization options.
%      - Optional predefined graphical output.
%
%    It remains to be assessed that the constants found minimize the area 
%    between the corrected profiles globally, because the solver might look for
%    local minimizers only.
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
%    % Vertical profiles.
%    constants = ...
%      findThermalLagParams(time1, depth1, cond1, temp1, pres1, ...
%                           time2, depth2, cond2, temp2, pres2);
%    % Tilted profiles.
%    constants = ...
%      findThermalLagParams(time1, depth1, pitch1, cond1, temp1, pres1, ...
%                           time2, depth2, pitch2, cond2, temp2, pres2);
%    % Tilted profiles with exit code, residual and extra options.
%    [constants, exitflag, residual] = ...
%      findThermalLagParams(time1, depth1, pitch1, cond1, temp1, pres1, ...
%                           time2, depth2, pitch2, cond2, temp2, pres2, ...
%                           options);
%
%  See also:
%    CORRECTTHERMALLAG
%    SW_SALT
%    OPTIMSET
%    FMINCON
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  error(nargchk(10, 22, nargin, 'struct'));
  
  
  %% Parse basic input arguments.
  % Get numeric (non option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = nargin;
  end
  switch(nargnum)
    case 10
      % Vertical profile.
      [time1, depth1, cond1, temp1, pres1] = varargin{1:5};
      [time2, depth2, cond2, temp2, pres2] = varargin{6:10};
      pitch1 = pi/2;
      pitch2 = pi/2;
    case 12
      % Tilted profile.
      [time1, depth1, pitch1, cond1, temp1, pres1] = varargin{1:6};
      [time2, depth2, pitch2, cond2, temp2, pres2] = varargin{7:12};
  end
  
  
  %% Configure default options.
  % This is equivalent to the original version by Tomeu Garau, except for the
  % method (it was active-set).
  options.graphics = false;
  options.guess = [0.0135 0.0264 7.1499 2.7858]; % from Morrison (1994).
  options.lower = [0 0 0 0]; % no correction.
  options.upper = [2 1 range(time1) range(time1)/2]; % from old version.
  options.optimopts = optimset(optimset('fmincon'), ...
                               'Algorithm', 'interior-point', ...
                               'TolFun', 1e-4, 'TolCon', 1e-5, 'TolX', 1e-5, ...
                               'Display', 'off');
  
  
  %% Parse option arguments.
  % Get option key-value pairs in any accepted call signature.
  argopt = varargin(nargnum+1:end);
  if isscalar(argopt) && isstruct(argopt{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopt{1});
    opt_val_list = struct2cell(argopt{1});
  elseif mod(numel(argopt), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopt(1:2:end);
    opt_val_list = argopt(2:2:end);
  else
    error('glider_toolbox:findThermalLagParams:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findThermalLagParams:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Enable graphical output, if needed
  % The functions are defined below.
  if options.graphics
     options.optimopts.PlotFcns = ...
       {@optimplotx @optimplotfval ...
        @optimplotTempSalt @optimplotDpthSalt ...
        @optimplotTempTime @optimplotCondTime};
  end
  
  
  %% Perform estimation through minimization.
  % Definition of minimization objective function.
  objective_function = @(constants) profileArea(...
    sw_salt(cond1 * (10 / sw_c3515()), correctThermalLag(time1, depth1, pitch1, cond1, temp1, constants), pres1), ...
    temp1, ...
    sw_salt(cond2 * (10 / sw_c3515()), correctThermalLag(time2, depth2, pitch2, cond2, temp2, constants), pres2), ...
    temp2);

  % Run minimization procedure.
  [constants, residual, exitflag] = ...
    fmincon(objective_function, options.guess, ...
            [], [], [], [], options.lower, options.upper, [], ...
            options.optimopts);
  
  
  %% Definition of auxiliar plotting functions.
  % They should be nested to access cast data.
  % Temperature-salinity diagram.
  function stop = optimplotTempSalt(x, ~, state)
  %OPTIMPLOTTEMPSALT  Temperature-salinity diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        plot(sw_salt(cond1 * (10 / sw_c3515()), correctThermalLag(time1, depth1, pitch1, cond1, temp1, x), pres1), ...
             temp1, ...
             '-r');
        hold on;
        plot(sw_salt(cond2 * (10 / sw_c3515()), correctThermalLag(time2, depth2, pitch2, cond2, temp2, x), pres2), ...
             temp2, ...
             '-b');
        plot(sw_salt(cond1 * (10 / sw_c3515()), temp1, pres1), temp1, ':r');
        plot(sw_salt(cond2 * (10 / sw_c3515()), temp2, pres2), temp2, ':b');
        title('Temperature-Salinity diagram');
        xlabel('Salinity');
        ylabel('Temperature');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Depth-salinity diagram.
  function stop = optimplotDpthSalt(x, ~, state)
  %OPTIMPLOTDPTHSALT  Depth-salinity diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        plot(sw_salt(cond1 * (10 / sw_c3515()), correctThermalLag(time1, depth1, pitch1, cond1, temp1, x), pres1), ...
             depth1, ...
             '-r');
        hold on;
        plot(sw_salt(cond2 * (10 / sw_c3515()), correctThermalLag(time2, depth2, pitch2, cond2, temp2, x), pres2), ...
             depth2, ...
             '-b');
        plot(sw_salt(cond1 * (10 / sw_c3515()), temp1, pres1), depth1, ':r');
        plot(sw_salt(cond2 * (10 / sw_c3515()), temp2, pres2), depth2, ':b');
        title('Depth-Salinity diagram');
        xlabel('Salinity');
        ylabel('Depth');
        set(gca, 'YDir', 'reverse')
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Temperature-time diagram.
  function stop = optimplotTempTime(x, ~, state)
  %OPTIMPLOTTEMPTIME  Temperature-time diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        time_offset = min(min(time1), min(time2));
        [temp_cor1, ~] = correctThermalLag(time1, depth1, pitch1, cond1, temp1, x);
        [temp_cor2, ~] = correctThermalLag(time2, depth2, pitch2, cond2, temp2, x);
        plot(time1 - time_offset, temp_cor1, '-r');
        hold on;
        plot(time2 - time_offset, temp_cor2, '-b');
        plot(time1 - time_offset, temp1, ':r');
        plot(time2 - time_offset, temp2, ':b');
        title('Temperature-Time diagram');
        xlabel('Time');
        ylabel('Temperature');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Conductivity-time diagram.
  function stop = optimplotCondTime(x, ~, state)
  %OPTIMPLOTCONDTIME  Conductivity-time diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        time_offset = min(min(time1), min(time2));
        [~, cond_cor1] = correctThermalLag(time1, depth1, pitch1, cond1, temp1, x);
        [~, cond_cor2] = correctThermalLag(time2, depth2, pitch2, cond2, temp2, x);
        plot(time1 - time_offset, cond_cor1, '-r');
        hold on;
        plot(time2 - time_offset, cond_cor2, '-b');
        plot(time1 - time_offset, cond1, ':r');
        plot(time2 - time_offset, cond2, ':b');        
        title('Conductivity-Time diagram');
        xlabel('Time');
        ylabel('Conductivity');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

end
