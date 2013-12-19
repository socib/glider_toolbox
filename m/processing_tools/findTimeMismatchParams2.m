function [params, exitflag, residual] = findTimeMismatchParams2(varargin)
%FINDTIMEMISMATCHPARAMS  Sensor time mismatch paramater estimation for a single pair of casts.
%
%  Syntax:
%    PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2)
%    PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, COND2, TEMP2, PRES2, FLOW2)
%    PARAMS = FINDTIMEMISMATCHPARAMS(..., OPTIONS)
%    PARAMS = FINDTIMEMISMATCHPARAMS(..., OPT1, VAL1, ...)
%    [PARAMS, EXITFLAG, RESIDUAL] = FINDTIMEMISMATCHPARAMS(...)
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, COND1, TEMP1, PRES1, TIME2, COND2, TEMP2, PRES2)
%  finds the time mismatch constant (tau) from two CTD profiles with constant flow
%  speed (pumped CTD) given by sequences of time (s), conductivity (S/m), 
%  temperature (deg C) and pressure (dbar) in respective vectors TIME1, COND1, 
%  TEMP1 and PRES1, and TIME2, COND2, TEMP2 and PRES2. The profiles are supposed
%  to measure the same column of water in opposite directions.
%
%  The function solves the minimization problem of finding the time constant TAU
%  such that the length of the profiles of temperature and salinity is minimal;
%  where salinity is derived from temperature, conductivity and pressure 
%  sequences using SW_SALT with the corrected temperature sequence returned by 
%  CORRECTSENSORLAG. This problem is solved with the function FMINCON, using 
%  default values for the initial guess and the parameter bounds. See OPTIONS 
%  description below.
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, COND1, TEMP1, PRES1, FLOW1, TIME2, DEPTH2, TEMP2, PRES2, FLOW2, ...)
%  performs the same estimation but for a pair of CTD profiles with variable 
%  flow speed (unpumped CTD), given by respective vectors FLOW1 and FLOW2.
%  The estimated parameters are returned in a two element vector PARAMS with the
%  offset and the slope of the time mismatch parameter with respect to the 
% inverse flow speed.
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(..., OPTIONS) and 
%  PARAMS = FINDTIMEMISMATCHPARAMS(..., OPT1, VAL1, ...) allow passing extra 
%  options given in key-value pairs OPT1, VAL1... or in struct OPTIONS with 
%  field names as option keys and field values as option values.
%  Recognized options are:
%    GRAPHICS: whether graphic output should be produced.
%      A boolean. If true a nice figure showing the minimization process will be
%      displayed. It includes the parameter values, the objective function 
%      value, a temperature-salinity diagram, a pressure-salinity diagram, 
%      a temperature-time plot, and a conductivity-time plot.
%      Default value: false.
%    GUESS: initial guess for minimization function FMINCON.
%      A one or two element vector with the initial guess for each parameter.
%      Default value:
%        For constant flow speed: 0.5
%        For variable flow speed: [0.3568 0.07]
%    LOWER: lower bounds of parameters for minimization function FMINCON.
%      A one or two element vector with the lower bound for each parameter.
%      Default value:
%        For constant flow speed: -16
%        For variable flow speed: [-16 -7.5]
%    UPPER: upper bounds of parameters for minimization function FMINCON.
%      A one or two element vector with the upper bound for each parameter.
%      Default value:
%        For constant flow speed: 16
%        For variable flow speed: [16 7.5]
%    OPTIMOPTS: extra options for the minimization function FMINCON.
%      An option struct as needed by the function FMINCON.
%      Default value: default options for FMINCON, except for:
%        'Algorithm'  : 'interior-point'
%        'FinDiffType': 'central'
%        'TolFun'     : 1e-6
%        'TolCon'     : 1e-5
%        'TolX'       : 1e-8
%        'Display'    : 'off'
%
%  [PARAMS, EXITFLAG, RESIDUAL] = FINDTIMEMISMATCHPARAMS(...) also returns the 
%  exit code of the minimization function FMINCON in EXITFLAG, and the resulting
%  residual area in RESIDUAL. EXITFLAG is positive when minimization succeeds.
%
%  Notes:
%    It remains to be assessed that the parameters found minimize the length of
%    the corrected profiles globally, because the solver might look for local
%    minimizers only.
%
%  Examples:
%    % Constant flow speed profiles (pumped CTD):
%    data = load('private/test/ctd_sharp_pumped.dat');
%    profile = data(:, 10);
%    time1 = data(profile==1, 1);
%    cond1 = data(profile==1, 2);
%    temp1 = data(profile==1, 3);
%    pres1 = data(profile==1, 4);
%    time2 = data(profile==2, 1);
%    cond2 = data(profile==2, 2);
%    temp2 = data(profile==2, 3);
%    pres2 = data(profile==2, 4);
%    params = findTimeMismatchParams2(time1, cond1, temp1, pres1, ...
%                                     time2, cond2, temp2, pres2)
%
%    % Variable flow speed profiles (unpumped CTD):
%    data = load('private/test/ctd_sharp_unpumped.dat');
%    profile = data(:, 10);
%    time1 = data(profile==1, 1);
%    cond1 = data(profile==1, 2);
%    temp1 = data(profile==1, 3);
%    pres1 = data(profile==1, 4);
%    ptch1 = data(profile==1, 5);
%    lati1 = data(profile==1, 8);
%    dpth1 = sw_dpth(pres1, lati1);
%    flow1 = computeCTDFlowSpeed(time1, dpth1, ptch1, 'minpitch', deg2rad(11));
%    time2 = data(profile==2, 1);
%    cond2 = data(profile==2, 2);
%    temp2 = data(profile==2, 3);
%    pres2 = data(profile==2, 4);
%    ptch2 = data(profile==2, 5);
%    lati2 = data(profile==2, 8);
%    dpth2 = sw_dpth(pres2, lati2);
%    flow2 = computeCTDFlowSpeed(time2, dpth2, ptch2, 'minpitch', deg2rad(11));
%    params = findTimeMismatchParams2(time1, cond1, temp1, pres1, flow1, ...
%                                     time2, cond2, temp2, pres2, flow2)
%
%    % Variable flow speed profiles with exit code, residual and extra options.
%    [params, exitflag, residual] = ...
%      findTimeMismatchParams2(time1, cond1, temp1, pres1, flow1, ...
%                              time2, cond2, temp2, pres2, flow2, ...
%                              'graphics', 'true')
%
%  See also:
%    FMINCON
%    OPTIMSET
%    CORRECTSENSORLAG
%    SW_SALT
%    SW_DENS
%    COMPUTECTDFLOWSPEED
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
  options.graphics = false;
  if constant_flow
    options.guess = 0.5;
    options.lower = -16;
    options.upper = 16;
  else
    options.guess = [0.3568 0.07];
    options.lower = [-16 -7.5];
    options.upper = [16 7.5];
  end
  options.optimopts = optimset(optimset('fmincon'), ...
                               'Algorithm', 'interior-point', ...
                               'TolFun', 1e-6, 'TolCon', 1e-5, 'TolX', 1e-8, ...
                               'FinDiffType', 'central', ...
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
    error('glider_toolbox:findTimeMismatchParams2:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findTimeMismatchParams2:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Enable graphical output, if needed.
  % The functions are defined below.
  if options.graphics
    if constant_flow
      temp_cor1 = correctSensorLag(time1, temp1, options.guess);
      temp_cor2 = correctSensorLag(time2, temp2, options.guess);
    else
      temp_cor1 = correctSensorLag(time1, temp1, flow1, options.guess);
      temp_cor2 = correctSensorLag(time2, temp2, flow2, options.guess);
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
  objective_function = @optimobjTSLength;

  % Run minimization procedure.
  [params, residual, exitflag] = ...
    fmincon(objective_function, options.guess, ...
            [], [], [], [], options.lower, options.upper, [], ...
            options.optimopts);
  
  
  %% Definition of auxiliary objective and plotting functions.  
  % They should be nested to access cast data.
  function length = optimobjTSLength(params)
  %OPTIMOBJTSAREA Compute area enclosed by profiles in TS diagram.
    if constant_flow
      temp_cor1 = correctSensorLag(time1, temp1, params);
      temp_cor2 = correctSensorLag(time2, temp2, params);
    else
      temp_cor1 = correctSensorLag(time1, temp1, flow1, params);
      temp_cor2 = correctSensorLag(time2, temp2, flow2, params);
    end
    salt_cor1 = sw_salt(cond1 * (10 / sw_c3515()), temp_cor1, pres1);
    salt_cor2 = sw_salt(cond2 * (10 / sw_c3515()), temp_cor2, pres2);
    length = ...
      profileLength(salt_cor1, pres1) + profileLength(salt_cor2, pres2);
  end
  
  function stop = optimoutUpdateCorrectedData(params, ~, state)
  %OPTIMOUTUPDATEPLOTDATA  Update corrected data sequences.
    switch state
      case 'init'
      case 'iter'
        if constant_flow
          temp_cor1 = correctSensorLag(time1, temp1, params);
          temp_cor2 = correctSensorLag(time2, temp2, params);
        else
          temp_cor1 = correctSensorLag(time1, temp1, flow1, params);
          temp_cor2 = correctSensorLag(time2, temp2, flow2, params);
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
        plot(salt1(valid1), temp1(valid1), ':r', ...
             salt2(valid2), temp2(valid2), ':b', ...
             salt_cor1(valid_cor1), temp1(valid_cor1), '-r', ...
             salt_cor2(valid_cor2), temp2(valid_cor2), '-b');
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
        plot(salt1(valid1), pres1(valid1), ':r', ...
             salt2(valid2), pres2(valid2), ':b', ...
             salt_cor1(valid_cor1), pres1(valid_cor1), '-r', ...
             salt_cor2(valid_cor2), pres2(valid_cor2), '-b');
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
        time_offset = min(min(time1(valid1)), min(time2(valid2)));
        plot(time1(valid1) - time_offset, temp1(valid1), ':r', ...
             time2(valid2) - time_offset, temp2(valid2), ':b', ...
             time1(valid_cor1) - time_offset, temp_cor1(valid_cor1), '-r', ...
             time2(valid_cor2) - time_offset, temp_cor2(valid_cor2), '-b');
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
        valid1 = (time1 > 0) & ~isnan(cond1);
        valid2 = (time2 > 0) & ~isnan(cond2);
        time_offset = min(min(time1(valid1)), min(time2(valid2)));
        plot(time1(valid1) - time_offset, cond1(valid1), ':r', ...
             time2(valid2) - time_offset, cond2(valid2), ':b');     
        title('Conductivity-Time diagram');
        xlabel('Time');
        ylabel('Conductivity');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
end
