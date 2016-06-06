function [params, exitflag, residual] = findSensorLagParams(varargin)
%FINDSENSORLAGPARAMS  Sensor lag parameter estimation for profiles.
%
%  Syntax:
%    PARAMS = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2)
%    PARAMS = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, FLOW1, TIME2, DEPTH2, DATA2, FLOW2)
%    PARAMS = FINDSENSORLAGPARAMS(..., OPTIONS)
%    PARAMS = FINDSENSORLAGPARAMS(..., OPT1, VAL1, ...)
%    [PARAMS, EXITFLAG, RESIDUAL] = FINDSENSORLAGPARAMS(...)
%
%  Description:
%    PARAMS = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2)
%    finds the sensor lag parameter for two profiles with constant flow speed
%    given by vectors TIME1, DEPTH1 and DATA1, and TIME2, DEPTH2 and DATA2.
%    The profiles are supposed to measure the same column of water in opposite
%    directions. 
%
%    Under the assumption that both profiles should be as similar as possible,
%    the function solves the minimization problem of finding the time constant
%    such that the area between corrected profiles returned by CORRECTSENSORLAG
%    is minimal. This problem is solved by function FMINCON using default 
%    values for the parameter bounds. See OPTIONS description below.
%
%    PARAMS = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, FLOW1, TIME2, DEPTH2, DATA2, FLOW2)
%    performs the same estimation but for a pair profiles with variable flow 
%    speed given by respective vectors FLOW1 and FLOW2. The estimated parameters
%    are returned in a two element vector PARAMS with the offset and the slope
%    of the sensor lag parameter with respect to the inverse flow speed.
%
%    PARAMS = FINDSENSORLAGPARAMS(..., OPTIONS) and 
%    PARAMS = FINDSENSORLAGPARAMS(..., OPT1, VAL1, ...) allow passing extra 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS
%    with field names as option keys and field values as option values.
%    Recognized options are:
%      GRAPHICS: whether graphic output should be produced.
%        A boolean setting whether a nice figure showing the evolution of the 
%        minimization process will be displayed. It includes plots for the 
%        parameter value, the objective function value, a value-time diagram of 
%        both sequences, and a depth-value diagram.
%        Default value: false.
%      GUESS: initial guess for minimization function FMINCON.
%        A one or two element vector with the initial guess for each parameter.
%        Default value:
%          For constant flow speed: 0.5
%          For variable flow speed: [0.3568 0.07]
%      LOWER: lower bounds of parameters for minimization function FMINCON.
%        A one or two element vector with the lower bound for each parameter.
%        Default value:
%          For constant flow speed: 0 (no correction)
%          For variable flow speed: [0 0] (no correction)
%      UPPER: upper bounds of parameters for minimization function FMINCON.
%        A one or two element vector with the upper bound for each parameter.
%        Default value:
%          For constant flow speed: 16
%          For variable flow speed: [16 7.5]
%      OPTIMOPTS: extra options for the minimization function FMINCON.
%        An option struct as needed by the function FMINCON.
%        Default value: default options for FMINCON, except for:
%          'Algorithm'  : 'interior-point'
%          'FinDiffType': 'central'
%          'TolFun'     : 1e-4
%          'TolCon'     : 1e-5
%          'TolX'       : 1e-5
%          'Display'    : 'off'
%
%    [PARAMS, EXITFLAG, RESIDUAL] = FINDSENSORLAGPARAMS(...) also returns the 
%    exit code of the minimization function FMINCON in EXITFLAG, and the 
%    residual area in RESIDUAL. EXITFLAG is positive when minimization succeeds.
%
%  Notes:
%    This function is an improved version of a previous function by Tomeu Garau,
%    called ADJUSTTIMECONSTANT. He is the true glider man. Main changes are:
%      - Support for dynamic senosr lag parameter for sequences with variable 
%        flow speed.
%      - Different minimization algorithm (interior-point instead of active-set).
%      - Support for custom minimization options.
%      - Optional predefined graphical output.
%
%    It remains to be assessed that the time constant found minimizes the area 
%    between the corrected profiles globally, because the solver looks for local
%    minimizers only.
%
%  Examples:
%    % Constant flow speed profiles (pumped CTD):
%    data = load('private/test/ctd_sharp_pumped.dat');
%    profile = data(:, 10);
%    time1 = data(profile==3, 1);
%    temp1 = data(profile==3, 3);
%    pres1 = data(profile==3, 4);
%    time2 = data(profile==4, 1);
%    temp2 = data(profile==4, 3);
%    pres2 = data(profile==4, 4);
%    params = findSensorLagParams(time1, pres1, temp1, time2, pres2, temp2)
%
%    % Variable flow speed profiles (unpumped CTD):
%    data = load('private/test/ctd_sharp_unpumped.dat');
%    profile = data(:, 10);
%    time1 = data(profile==17, 1);
%    temp1 = data(profile==17, 3);
%    pres1 = data(profile==17, 4);
%    ptch1 = data(profile==17, 5);
%    lati1 = data(profile==17, 8);
%    dpth1 = sw_dpth(pres1, lati1);
%    flow1 = computeCTDFlowSpeed(time1, dpth1, ptch1, 'minpitch', deg2rad(11));
%    time2 = data(profile==18, 1);
%    temp2 = data(profile==18, 3);
%    pres2 = data(profile==18, 4);
%    ptch2 = data(profile==18, 5);
%    lati2 = data(profile==18, 8);
%    dpth2 = sw_dpth(pres2, lati2);
%    flow2 = computeCTDFlowSpeed(time2, dpth2, ptch2, 'minpitch', deg2rad(11));
%    params = findSensorLagParams(time1, pres1, temp1, flow1, ...
%                                 time2, pres2, temp2, flow2)
%
%    % Variable flow speed profiles with exit code, residual and extra options.
%    [params, exitflag, residual] = ...
%      findSensorLagParams(time1, pres1, temp1, flow1, ...
%                          time2, pres2, temp2, flow2, ...
%                          'graphics', 'true')
%
%  See also:
%    FMINCON
%    OPTIMSET
%    CORRECTSENSORLAG
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

  error(nargchk(6, 18, nargin, 'struct'));
  
  
  %% Parse basic input arguments.
  % Get numeric (non-option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = nargin;
  end
  switch(nargnum)
    case 6
      % Constant flow speed (pumped CTD).
      [time1, depth1, data1] = varargin{1:3};
      [time2, depth2, data2] = varargin{4:6};
      constant_flow = true;
    case 8
      % Variable flow speed (unpumped CTD).
      [time1, depth1, data1, flow1] = varargin{1:4};
      [time2, depth2, data2, flow2] = varargin{5:8};
      constant_flow = false;
  end
  
  
  %% Configure default options.
  options.graphics = false;
  if constant_flow
    options.guess = 0.5; % from original implementation.
    options.lower = 0; % no correction.
    options.upper = 16;  % from original implementation.
  else
    options.guess = [0.3568 0.07];
    options.lower = [0 0];
    options.upper = [16 7.5];
  end
  options.optimopts = optimset(optimset('fmincon'), ...
                               'Algorithm', 'interior-point', ...
                               'TolFun', 1e-4, 'TolCon', 1e-5, 'TolX', 1e-5, ...
                               'FinDiffType', 'central', ...
                               'Display', 'off');
  
  
  %% Parse extra arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin(nargnum+1:end);
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
    error('glider_toolbox:findSensorLagParams:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findSensorLagParams:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Enable graphical output, if needed.
  % The functions are defined below.
  if options.graphics
    if constant_flow
      data_cor1 = correctSensorLag(time1, data1, options.guess);
      data_cor2 = correctSensorLag(time2, data2, options.guess);
    else
      data_cor1 = correctSensorLag(time1, data1, flow1, options.guess);
      data_cor2 = correctSensorLag(time2, data2, flow2, options.guess);
    end
    options.optimopts.OutputFcn = @optimoutUpdateCorrectedData;
    options.optimopts.PlotFcns = ...
      {@optimplotx @optimplotfval @optimplotDataTime @optimplotDepthData};
  end
  
  
  %% Perform estimation through minimization.
  % Definition of minimization objective function.
  objective_function = @optimobjDepthValueArea;

  % Run minimization procedure.
  [params, residual, exitflag] = ...
    fmincon(objective_function, options.guess, ...
            [], [], [], [], options.lower, options.upper, [], ...
            options.optimopts);
  
  % This is the equivalent version of the original code by Tomeu Garau,
  % with external constant functions inlined and coding style adaptions:
  %{
  options = optimset(optimset('fmincon'), ...
    'LargeScale', 'off',           ...
    'Algorithm',  'active-set',    ...
    'TolFun',     1e-4,            ...
    'TolCon',     1e-5,            ...
    'TolX',       1e-5,            ...
    ... % 'Plotfcns',   [], % {@optimplotfval, @optimplotfirstorderopt, @optimplotx});
    'Display',    'off');
  first_guess = 0.5;
  upper_bound = 16;
  lower_bound = eps;
  constant = fmincon(@objective_function, first_guess, [], [], [], [], ...
                     lower_bound, upper_bound, [], options);
  %}

  
  %% Definition of auxiliary objective and plotting functions.  
  % They should be nested to access cast data.
  function area = optimobjDepthValueArea(params)
  %OPTIMOBJDEPTHVALUEAREA Compute area enclosed by profiles in depth-value diagram.
    if constant_flow
      data_cor1 = correctSensorLag(time1, data1, params);
      data_cor2 = correctSensorLag(time2, data2, params);
    else
      data_cor1 = correctSensorLag(time1, data1, flow1, params);
      data_cor2 = correctSensorLag(time2, data2, flow2, params);
    end
    depth_min = max(min(depth1), min(depth2));
    depth_max = min(max(depth1), max(depth2));
    depth_mask1 = (depth_min <= depth1) & (depth1 <= depth_max);
    depth_mask2 = (depth_min <= depth2) & (depth2 <= depth_max);
    min_idx1 = find(depth_mask1, 1, 'first');
    min_idx2 = find(depth_mask2, 1, 'first');
    max_idx1 = find(depth_mask1, 1, 'last');
    max_idx2 = find(depth_mask2, 1, 'last');
    area = ...
      profileArea(data_cor1(min_idx1:max_idx1), depth1(min_idx1:max_idx1), ...
                  data_cor2(min_idx2:max_idx2), depth2(min_idx2:max_idx2));
  end
  
  function stop = optimoutUpdateCorrectedData(params, ~, state)
  %OPTIMOUTUPDATEPLOTDATA  Update corrected data sequences.
    switch state
      case 'init'
      case 'iter'
        if constant_flow
          data_cor1 = correctSensorLag(time1, data1, params);
          data_cor2 = correctSensorLag(time2, data2, params);
        else
          data_cor1 = correctSensorLag(time1, data1, flow1, params);
          data_cor2 = correctSensorLag(time2, data2, flow2, params);
        end
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Depth-value diagram.
  function stop = optimplotDepthData(~, ~, state)
  %OPTIMPLOTDEPTHDATA  Depth-value diagram for a pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = ~(isnan(data_cor1) | isnan(depth1));
        valid_cor2 = ~(isnan(data_cor2) | isnan(depth2));
        valid1 = ~(isnan(data1) | isnan(depth1));
        valid2 = ~(isnan(data2) | isnan(depth2));
        plot(data_cor1(valid_cor1), depth1(valid_cor1), '-r', ...
             data_cor2(valid_cor2), depth2(valid_cor2), '-b', ...
             data1(valid1), depth1(valid1), ':r', ...
             data2(valid2), depth2(valid2), ':b');
        title('Depth-Data diagram');
        xlabel('Data');
        ylabel('Depth');
        set(gca, 'YDir', 'reverse')
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Value-time diagram.
  function stop = optimplotDataTime(~, ~, state)
  %OPTIMPLOTDATATIME  Value-time diagram for a pair of casts.
    switch state
      case 'init'
      case 'iter'
        valid_cor1 = (time1 > 0) & ~isnan(data_cor1);
        valid_cor2 = (time2 > 0) & ~isnan(data_cor2);
        valid1 = (time1 > 0) & ~isnan(data1);
        valid2 = (time2 > 0) & ~isnan(data2);
        time_offset = min(min(time1(valid1)), min(time2(valid2)));
        plot(time1(valid_cor1) - time_offset, data_cor1(valid_cor1), '-r', ...
             time2(valid_cor2) - time_offset, data_cor2(valid_cor2), '-b', ...
             time1(valid1) - time_offset, data1(valid1), ':r', ...
             time2(valid2) - time_offset, data2(valid2), ':b');
        title('Data-Time diagram');
        xlabel('Time');
        ylabel('Data');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
end
