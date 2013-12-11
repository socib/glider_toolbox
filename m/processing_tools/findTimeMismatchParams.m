function [params, exitflag, residual] = findTimeMismatchParams(varargin)
%FINDTIMEMISMATCHPARAMS  Sensor time mismatch paramater estimation for profiles.
%
%  Syntax:
%    PARAMS = FINDTIMEMISMATCHPARAMS(TIME, DATA1, DATA2)
%    PARAMS = FINDTIMEMISMATCHPARAMS(TIME, DATA1, DATA2, FLOW)
%    PARAMS = FINDTIMEMISMATCHPARAMS(..., OPTIONS)
%    PARAMS = FINDTIMEMISMATCHPARAMS(..., OPT1, VAL1, ...)
%    [PARAMS, EXITFLAG, RESIDUAL] = FINDTIMEMISMATCHPARAMS(...)
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, DATA1, DATA2) finds the time mismatch
%  constant (tau) for data sequences given by vectors TIME, DATA1, and DATA2.
%  The data sequences DATA1 and DATA2 are supposed to be the sampled values at
%  time instants TIME. Based on the assumption that the gradient of both
%  sequences should be as correlated as possible, it finds the sensor time
%  lag parameter, such that the correlation between the gradients of the aligned
%  sequences is maximum.
%
%  The function solves the minimization problem of finding the time constant TAU
%  such that the opposite of the correlation between GRADIENTU(DATA1, TIME) and
%  GRADIENTU(CORRECTSENSORLAG(TIME, DATA2, TAU), TIME) is minimal. This problem
%  is solved with the function FMINCON using default values for the initial
%  guess and the parameter bounds. See OPTIONS description below.
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(TIME1, DATA1, DATA2, FLOW) performs the same
%  estimation but for a data sequence with variable flow speed given by vector
%  FLOW. The estimated parameters are returned in a two element vector PARAMS
%  with the offset and the slope of the time mismatch parameter with respect to
%  the inverse flow speed.
%
%  PARAMS = FINDTIMEMISMATCHPARAMS(..., OPTIONS) and
%  PARAMS = FINDTIMEMISMATCHPARAMS(..., OPT1, VAL1, ...) allow passing extra
%  options given either as key-value pairs OPT1, VAL1... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    GRAPHICS: whether graphic output should be produced.
%      A boolean. If true a nice figure showing the minimization process will be
%      displayed. It includes the parameter values, the objective function
%      value, a (scaled) value-time diagram of both sequences, and a (scaled)
%      gradient-time diagram.
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
%    It remains to be assessed that the parameters found maximize the
%    correlation between the corrected profiles globally, because the solver
%    might look for local minimizers only.
%
%  Examples:
%    % Constant flow speed profiles (pumped CTD):
%    data = load('private/test/ctd_sharp_pumped.dat');
%    profile = data(:, 10);
%    time = data(profile==3, 1);
%    cond = data(profile==3, 2);
%    temp = data(profile==3, 3);
%    params = findTimeMismatchParams(time, cond, temp)
%
%    % Variable flow speed profiles (unpumped CTD):
%    data = load('private/test/ctd_sharp_unpumped.dat');
%    profile = data(:, 10);
%    time = data(profile==3, 1);
%    cond = data(profile==3, 2);
%    temp = data(profile==3, 3);
%    pres = data(profile==3, 4);
%    ptch = data(profile==3, 5);
%    lati = data(profile==3, 8);
%    dpth = sw_dpth(pres, lati);
%    flow = computeCTDFlowSpeed(time, dpth, ptch, 'minpitch', deg2rad(11));
%    params = findTimeMismatchParams(time, cond, temp, flow)
%
%    % Variable flow speed profiles with exit code, residual and extra options.
%    [params, exitflag, residual] = ...
%      findTimeMismatchParams(time, cond, temp, flow, 'graphics', true)
%
%  See also:
%    FMINCON
%    OPTIMSET
%    CORRECTSENSORLAG
%    GRADIENTU
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

  error(nargchk(3, 14, nargin, 'struct'));


  %% Parse basic input arguments.
  % Get numeric (non option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = nargin;
  end
  switch(nargnum)
    case 3
      % Constant flow speed (pumped CTD).
      [timestamp, data1, data2] = varargin{1:3};
      constant_flow = true;
    case 4
      % Variable flow speed (unpumped CTD).
      [timestamp, data1, data2, flow] = varargin{1:4};
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


  %% Parse extra arguments.
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
    error('glider_toolbox:findTimeMismatchParams:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findTimeMismatchParams:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end


  %% Enable graphical output, if needed.
  % The functions are defined below.
  if options.graphics
    options.optimopts.OutputFcn = @optimoutUpdateCorrectedData;
    options.optimopts.PlotFcns = ...
      {@optimplotx @optimplotfval @optimplotDataTime @optimplotGradTime};
  end


  %% Initialize variables shared by objective and/or plotting functions.
  % This is just to expose them in this scope,
  % but might save some memory operations, too.
  valid1 = (timestamp > 0) & ~isnan(data1);
  grad1 = nan(size(data1));
  grad1(valid1) = gradientu(data1(valid1), timestamp(valid1));
  valid2 = (timestamp > 0) & ~isnan(data2);
  grad2 = nan(size(data2));
  grad2(valid2) = gradientu(data2(valid2), timestamp(valid2));
  if constant_flow
    data2_cor = correctSensorLag(timestamp, data2, options.guess);
  else
    data2_cor = correctSensorLag(timestamp, data2, flow, options.guess);
  end
  valid2_cor = (timestamp > 0) & ~isnan(data2_cor);
  grad2_cor = nan(size(data2_cor));
  grad2_cor(valid2_cor) = ...
    gradientu(data2_cor(valid2_cor), timestamp(valid2_cor));


  %% Perform estimation through minimization.
  % Definition of minimization objective function.
  objective_function = @optimobjGradCor;

  % Run minimization procedure.
  [params, residual, exitflag] = ...
    fmincon(objective_function, options.guess, ...
            [], [], [], [], options.lower, options.upper, [], ...
            options.optimopts);


  %% Definition of auxiliary objective and plotting functions.
  % They should be nested to access cast data.
  function mgradcor = optimobjGradCor(params)
  %OPTIMOBJGRADCROSSCOV Compute opposite of correlation of data gradients.
    if constant_flow
      data2_cor = correctSensorLag(timestamp, data2, params);
    else
      data2_cor = correctSensorLag(timestamp, data2, flow, params);
    end
    valid2_cor = (timestamp > 0) & ~isnan(data2_cor);
    grad2_cor = nan(size(data2_cor));
    grad2_cor(valid2_cor) = ...
      gradientu(data2_cor(valid2_cor), timestamp(valid2_cor));
    grad_corr_mat = corrcoef(grad1, grad2_cor, 'rows', 'complete');
    mgradcor = -grad_corr_mat(1,2);
  end

  function stop = optimoutUpdateCorrectedData(params, ~, state)
  %OPTIMOUTUPDATEPLOTDATA  Update corrected data sequences.
    switch state
      case 'init'
      case 'iter'
        if constant_flow
          data2_cor = correctSensorLag(timestamp, data2, params);
        else
          data2_cor = correctSensorLag(timestamp, data2, flow, params);
        end
        valid2_cor = (timestamp > 0) & ~isnan(data2_cor);
        grad2_cor = nan;
        grad2_cor(valid2_cor) = ...
          gradientu(data2_cor(valid2_cor), timestamp(valid2_cor));
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

  % Time-gradient diagram.
  function stop = optimplotGradTime(~, ~, state)
  %OPTIMPLOTGRADTIME  Gradient-time diagram for a pair of casts.
    switch state
      case 'init'
      case 'iter'
        time_offset = min(timestamp(valid1 | valid2 | valid2_cor));
        grad1_offset = mean(grad1(valid1));
        grad2_offset = mean(grad2(valid2));
        grad2_cor_offset = mean(grad2_cor(valid2_cor));
        grad1_scale = std(grad1(valid1));
        grad2_scale = std(grad2(valid2));
        grad2_cor_scale = std(grad2_cor(valid2_cor));
        plot(timestamp(valid1) - time_offset, (grad1(valid1) - grad1_offset) / grad1_scale, '.:r', ...
             timestamp(valid2) - time_offset, (grad2(valid2) - grad2_offset) / grad2_scale, '.:b', ...
             timestamp(valid2_cor) - time_offset, (grad2_cor(valid2_cor) - grad2_cor_offset) / grad2_cor_scale, '-b');
        title('Gradient-Time diagram');
        xlabel('Time');
        ylabel('Gradients (scaled)');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

  % Data sequence plot.
  function stop = optimplotDataTime(~, ~, state)
  %OPTIMPLOTDATATIME  Data-time diagram for a pair of casts.
    switch state
      case 'init'
      case 'iter'
        time_offset = min(timestamp(valid1 | valid2 | valid2_cor));
        data1_scale = (max(data1(valid1)) - min(data1(valid1))) ...
                    / (max(data2(valid2)) - min(data2(valid2)));
        data1_offset = min(data1(valid1)) - min(data2(valid2)) * data1_scale;
        plot(timestamp(valid1) - time_offset, (data1(valid1) - data1_offset) / data1_scale, '.:r', ...
             timestamp(valid2) - time_offset, data2(valid2), '.:b', ...
             timestamp(valid2_cor) - time_offset, data2_cor(valid2_cor), '-b');
        title('Data-Time diagram');
        xlabel('Time');
        ylabel('Data (scaled)');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end

end
