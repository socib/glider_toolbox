function [constants, exitflag, residual] = findThermalLagParams(varargin)
%FINDTHERMALLAGPARAMS  Thermal lag parameter estimation for a single pair of casts.
%
%  Syntax:
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2, OPTIONS)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2, OPT1, VAL1, ...)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, COND2, TEMP2, PRES2, FLOW2)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, COND2, TEMP2, PRES2, FLOW2, OPTIONS)
%    CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, COND2, TEMP2, PRES2, FLOW2, OPT1, VAL1, ...)
%    [CONSTANTS, EXITFLAG, RESIDUAL] = FINDTHERMALLAGPARAMS(...)
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2)
%  finds the thermal lag parameters from two CTD profiles with constant flow
%  speed (pumped CTD) given by sequences of time (s), conductivity (S/m), 
%  temperature (ºC) and pressure (dbar) in respective vectors TIME1, COND1, 
%  TEMP1 and PRES1, and TIME2, COND2, TEMP2 and PRES2. The profiles are supposed
%  to measure the same column of water in opposite directions. The computed 
%  parameters are returned in a two element vector CONSTANTS, with the error 
%  magnitude (alpha), and the error time constant (tau). A detailed description 
%  of these parameters may be found in the references listed below (Lueck 1990).
%
%  The function solves the minimization problem of finding the thermal lag 
%  parameters such that the area between profiles of temperature and salinity 
%  is minimal; where salinity is derived from temperature, conductivity and 
%  pressure sequences using SW_SALT with the corrected temperature sequence
%  returned by CORRECTTHERMALLAG. This problem is solved with the function 
%  FMINCON, using default values for the initial guess and the parameter bounds.
%  See OPTIONS description below.
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, DEPTH2, TEMP2, PRES2, FLOW2, ...)
%  performs the same estimation but for a pair of CTD profiles with variable 
%  flow speed (unpumped CTD), given by respective vectors FLOW1 and FLOW2. 
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(..., OPTIONS) and 
%  CONSTANTS = FINDTHERMALLAGPARAMS(..., OPT1, VAL1, ...) allow passing extra 
%  options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS with 
%  field names as option keys and field values as option values.
%  Recognized options are:
%    GRAPHICS: whether graphic output should be produced.
%      A boolean. If true a nice figure showing the minimization process will be
%      displayed. It includes the parameter values, the objective function 
%      value, a temperature-salinity diagram and a pressure-salinity diagram.
%      Default value: false.
%    GUESS: initial guess for minimization function FMINCON.
%      A two or four element vector with the initial guess for each parameter.
%      Default value:
%        For variable flow speed: [0.0135 0.0264 7.1499 2.7858] (Morison 1994).
%        For constant flow speed: [0.0677 11.1431] (see note below).
%    LOWER: lower bounds of parameters for minimization function FMINCON.
%      A four element vector with the lower bound for each parameter.
%      Default value:
%        For variable flow speed: [0 0 0 0] (no correction).
%        For constant flow speed: [0 0] (no correction).
%    UPPER: upper bounds of parameters for minimization function FMINCON.
%      A four element vector with the upper bound for each parameter.
%      Default value:
%        For variable flow speed: [2 1 RANGE(TIME1) RANGE(TIME1)/2].
%        For constant flow speed: [4 2.5*RANGE(TIME1)].
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
%      - Support for CTD profiles with constant flow speed (pumped CTD).
%
%    It remains to be assessed that the constants found minimize the area 
%    between the corrected profiles globally, because the solver might look for
%    local minimizers only.
%
%    Parameters' initial guess values and bounds are taken from original 
%    implementation. Since it did not handle constant flow speed profiles, 
%    the values for this case has been set according to the same reference, 
%    aproximating the constant CTD flow speed by v = 0.4867 m/s:
%      alpha = 0.0135 + 0.0264 / 0.4867        =  0.0677
%        tau = 7.1499 + 2.7858 / sqrt(11.1431) = 11.1431 
%    The flow speed value is estimated from reported Seabird Glider Payload CTD 
%    (GPCTD) specifications as:
%      v = 0.010 / 0.003 * 0.146 = 0.4867 m/s
%    where:
%      Q = 0.010 L/s is the flow rate.
%      L = 0.146 m   is the cell length.
%      V = 0.003 L   is the cell volume.
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
%    % Constant flow speed profiles (pumped CTD):
%    constants = ...
%      findThermalLagParams(time1, cond1, temp1, pres1, 
%                           time2, cond2, temp2, pres2);
%    % Variable flow speed profiles (unpumped CTD):
%    constants = ...
%      findThermalLagParams(time1, cond1, temp1, pres1, flow1, ...
%                           time2, cond2, temp2, pres2, flow2);
%    % Variable flow speed profiles with exit code, residual and extra options.
%    [constants, exitflag, residual] = ...
%      findThermalLagParams(time1, cond1, temp1, pres1, flow1, ...
%                           time2, cond2, temp2, pres2, flow2, ...
%                           options);
%
%  See also:
%    COMPUTECTDFLOWSPEED
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

  error(nargchk(8, 20, nargin, 'struct'));
  
  
  %% Parse basic input arguments.
  % Get numeric (non option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = nargin;
  end
  switch(nargnum)
    case 8
      % Constant flow speed (pumped CTD).
      [time1, cond1, temp1, pres1] = varargin{1:4};
      [time2, cond2, temp2, pres2] = varargin{5:8};
      constant_flow = true;
    case 10
      % Variable flow speed (unpumped CTD).
      [time1, cond1, temp1, pres1, flow1] = varargin{1:5};
      [time2, cond2, temp2, pres2, flow2] = varargin{6:10};
      constant_flow = false;
  end
  
  
  %% Configure default options.
  % For the case of variable flow speed (unpumped CTD)
  % this is equivalent to the original version by Tomeu Garau, 
  % except for the method (it was active-set).
  time_range = min(max(time1) - min(time1), max(time2) - min(time2));
  options.graphics = false;
  if constant_flow
    options.guess = [0.0677 11.1431]; % above parameters applied to GPCTD flow speed.
    options.lower = [0 0]; % no correction.
    options.upper = [4 2.5*time_range]; % above parameters applied to GPCTD flow speed.
  else
    options.guess = [0.0135 0.0264 7.1499 2.7858]; % from Morrison (1994).
    options.lower = [0 0 0 0]; % no correction.
    options.upper = [2 1 time_range time_range/2]; % from old version.
  end
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
  
  
  %% Enable graphical output, if needed.
  % The functions are defined below.
  if options.graphics
    if constant_flow
      [temp_cor1, cond_cor1] = ...
        correctThermalLag(time1, cond1, temp1, options.guess);
      [temp_cor2, cond_cor2] = ...
        correctThermalLag(time2, cond2, temp2, options.guess);
    else
      [temp_cor1, cond_cor1] = ...
        correctThermalLag(time1, cond1, temp1, flow1, options.guess);
      [temp_cor2, cond_cor2] = ...
        correctThermalLag(time2, cond2, temp2, flow2, options.guess);
    end
    salt_cor1 = sw_salt(cond1 * (10 / sw_c3515()), temp_cor1, pres1);
    salt_cor2 = sw_salt(cond2 * (10 / sw_c3515()), temp_cor2, pres2);
    salt1 = sw_salt(cond1 * (10 / sw_c3515()), temp1, pres1);
    salt2 = sw_salt(cond2 * (10 / sw_c3515()), temp2, pres2);
    options.optimopts.OutputFcn = @optimoutUpdateCorrectedData;
    options.optimopts.PlotFcns = ...
      {@optimplotx @optimplotfval ...
       @optimplotTempSalt @optimplotPresSalt ...
       @optimplotTempTime @optimplotCondTime};
  end
  
  
  %% Perform estimation through minimization.
  % Definition of minimization objective function.
  if constant_flow
    objective_function = @(constants) profileArea(...
      sw_salt(cond1 * (10 / sw_c3515()), correctThermalLag(time1, cond1, temp1, constants), pres1), ...
      temp1, ...
      sw_salt(cond2 * (10 / sw_c3515()), correctThermalLag(time2, cond2, temp2, constants), pres2), ...
      temp2);
  else
    objective_function = @(constants) profileArea(...
      sw_salt(cond1 * (10 / sw_c3515()), correctThermalLag(time1, cond1, temp1, flow1, constants), pres1), ...
      temp1, ...
      sw_salt(cond2 * (10 / sw_c3515()), correctThermalLag(time2, cond2, temp2, flow2, constants), pres2), ...
      temp2);
  end

  % Run minimization procedure.
  [constants, residual, exitflag] = ...
    fmincon(objective_function, options.guess, ...
            [], [], [], [], options.lower, options.upper, [], ...
            options.optimopts);
  
  
  %% Definition of auxiliar plotting functions.
  % They should be nested to access cast data.
  function stop = optimoutUpdateCorrectedData(x, ~, state)
  %OPTIMOUTUPDATEPLOTDATA  Update corrected temperature, conductivity an salinity sequences.
    switch state
      case 'init'
      case 'iter'
        if constant_flow
          [temp_cor1, cond_cor1] = correctThermalLag(time1, cond1, temp1, x);
          [temp_cor2, cond_cor2] = correctThermalLag(time2, cond2, temp2, x);
        else
          [temp_cor1, cond_cor1] = correctThermalLag(time1, cond1, temp1, flow1, x);
          [temp_cor2, cond_cor2] = correctThermalLag(time2, cond2, temp2, flow2, x);
        end
        salt_cor1 = sw_salt(cond1 * (10 / sw_c3515()), temp_cor1, pres1);
        salt_cor2 = sw_salt(cond2 * (10 / sw_c3515()), temp_cor2, pres2);
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

  % Temperature-salinity diagram.
  function stop = optimplotTempSalt(~, ~, state)
  %OPTIMPLOTTEMPSALT  Temperature-salinity diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = ~(isnan(salt_cor1) | isnan(temp1));
        valid_cor2 = ~(isnan(salt_cor2) | isnan(temp2));
        valid1 = ~(isnan(salt1) | isnan(temp1));
        valid2 = ~(isnan(salt2) | isnan(temp2));
        hold off;
        plot(salt_cor1(valid_cor1), temp1(valid_cor1), '-r');
        hold on;
        plot(salt_cor2(valid_cor2), temp2(valid_cor2), '-b');
        plot(salt1(valid1), temp1(valid1), ':r');
        plot(salt2(valid2), temp2(valid2), ':b');
        title('Temperature-Salinity diagram');
        xlabel('Salinity');
        ylabel('Temperature');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Pressure-salinity diagram.
  function stop = optimplotPresSalt(~, ~, state)
  %OPTIMPLOTPRESSALT  Pressure-salinity diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = ~(isnan(salt_cor1) | isnan(pres1));
        valid_cor2 = ~(isnan(salt_cor2) | isnan(pres2));
        valid1 = ~(isnan(salt1) | isnan(pres1));
        valid2 = ~(isnan(salt2) | isnan(pres2));
        hold off;
        plot(salt_cor1(valid_cor1), pres1(valid_cor1), '-r');
        hold on;
        plot(salt_cor2(valid_cor2), pres2(valid_cor2), '-b');
        plot(salt1(valid1), pres1(valid1), ':r');
        plot(salt2(valid2), pres2(valid2), ':b');
        title('Pressure-Salinity diagram');
        xlabel('Salinity');
        ylabel('Pressure');
        set(gca, 'YDir', 'reverse')
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Temperature-time diagram.
  function stop = optimplotTempTime(~, ~, state)
  %OPTIMPLOTTEMPTIME  Temperature-time diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = (time1 > 0) & ~isnan(temp_cor1);
        valid_cor2 = (time2 > 0) & ~isnan(temp_cor2);
        valid1 = (time1 > 0) & ~isnan(temp1);
        valid2 = (time2 > 0) & ~isnan(temp2);
        hold off;
        time_offset = min(min(time1(valid1)), min(time2(valid2)));
        plot(time1(valid_cor1) - time_offset, temp_cor1(valid_cor1), '-r');
        hold on;
        plot(time2(valid_cor2) - time_offset, temp_cor2(valid_cor2), '-b');
        plot(time1(valid1) - time_offset, temp1(valid1), ':r');
        plot(time2(valid2) - time_offset, temp2(valid2), ':b');
        title('Temperature-Time diagram');
        xlabel('Time');
        ylabel('Temperature');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Conductivity-time diagram.
  function stop = optimplotCondTime(~, ~, state)
  %OPTIMPLOTCONDTIME  Conductivity-time diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = (time1 > 0) & ~isnan(cond_cor1);
        valid_cor2 = (time2 > 0) & ~isnan(cond_cor2);
        valid1 = (time1 > 0) & ~isnan(cond1);
        valid2 = (time2 > 0) & ~isnan(cond2);
        hold off;
        time_offset = min(min(time1(valid1)), min(time2(valid2)));
        plot(time1(valid_cor1) - time_offset, cond_cor1(valid_cor1), '-r');
        hold on;
        plot(time2(valid_cor2) - time_offset, cond_cor2(valid_cor2), '-b');
        plot(time1(valid1) - time_offset, cond1(valid1), ':r');
        plot(time2(valid2) - time_offset, cond2(valid2), ':b');        
        title('Conductivity-Time diagram');
        xlabel('Time');
        ylabel('Conductivity');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

end
