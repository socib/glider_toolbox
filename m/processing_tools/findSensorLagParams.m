function [constant, exitflag, residual] = findSensorLagParams(time1, depth1, data1, time2, depth2, data2, varargin)
%FINDSENSORLAGPARAMS  Sensor lag time constant adjustment for profiles.
%
%  Syntax:
%    CONSTANT = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2)
%    CONSTANT = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2, OPTIONS)
%    CONSTANT = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2, OPT1, VAL1, ...)
%    [CONSTANT, EXITFLAG, RESIDUAL] = FINDSENSORLAGPARAMS(...)
%
%  CONSTANT = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2)
%  finds the sensor lag time constant from the two profile sequences given by 
%  vectors TIME1, DEPTH1 and DATA1, and TIME2, DEPTH2 and DATA2. The profiles
%  are supposed to measure the same to measure the same column of water in 
%  opposite directions. Based on the assumption that both profiles should be as 
%  similar as possible, it finds the sensor time lag parameter, such that the 
%  area in a value-depth diagram between the corrected profiles is minimum.
%
%  The function solves the minimization problem of finding the time constant
%  such that the area between corrected profiles returned by CORRECTSENSORLAG
%  is minimal. This problem is solved with the function FMINBND using default 
%  values for the parameter bounds. See OPTIONS description below.
%
%  CONSTANT = FINDSENSORLAGPARAMS(..., OPTIONS) and 
%  CONSTANT = FINDSENSORLAGPARAMS(..., OPT1, VAL1, ...) allow passing extra 
%  options given either as key-value pairs OPT1, VAL1... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    GRAPHICS: whether graphic output should be produced.
%      A boolean. If true a nice figure showing the minimization process will be
%      displayed. It includes the parameter value, the objective function value,
%      the time serie of the data and the depth-data diagram.
%      Default value: false.
%    LOWER: lower bound of parameter for minimization function FMINBND.
%      A number with the lower bound for the sensor lag parameter.
%      Default value: 0 (no correction).
%    UPPER: upper bound of parameter for minimization function FMINBND.
%      A four element vector with the upper bound for each parameter.
%      Default value: 16.
%    OPTIMOPTS: extra options for the minimization function FMINBND.
%      A option struct as needed by the function FMINBND.
%      Default value: default options for FMINBND, except for:
%       'TolX': 1e-5
%       'Display': 'off'
%
%  [CONSTANT, EXITFLAG, RESIDUAL] = FINDSENSORLAGPARAMS(...) also returns the 
%  exit code of the minimization function FMINBND in EXITFLAG, and the resulting
%  residual area in RESIDUAL. EXITFLAG is positive when minimization succeeds.
%
%  Notes:
%    This function is slightly modified version of a previous function by Tomeu
%    Garau, called  ADJUSTIMECONSTANT. He is the true glider man.
%    Introduced changes are:
%      - Different minimization function (FMINBND instead of FMINCON).
%      - No initial guess (since FMINBND does not need it).
%      - Support for custom minimization options.
%      - Optional predefined graphical output.
%
%    It remains to be assessed that the time constant found minimizes the area 
%    between the corrected profiles globally, because the solver looks for local
%    minimizers only.
%
%  Examples:
%    constant = findSensorLagParams(time1, depth1, data1, time2, depth2, data2)
%    [constant, exitflag, residual] = ...
%      findSensorLagParams(time1, depth1, data1, time2, depth2, data2, options)
%
%  See also:
%    CORRECTSENSORLAG
%    FMINCON
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(6, 16, nargin, 'struct'));
  
  
  %% Configure default options.
  options.graphics = false;
  options.guess = 0.5;
  options.lower = 0;
  options.upper = 16;
  options.optimopts = optimset(optimset('fminbnd'), ...
                               'TolX', 1e-5, ...
                               'Display', 'off');

                             
  %% Parse extra arguments.
  % Get option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(varargin{1});
    opt_val_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = varargin(1:2:end);
    opt_val_list = varargin(2:2:end);
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
    options.optimopts.PlotFcns = ...
      {@optimplotx @optimplotfval @optimplotValueTime @optimplotDepthValue};
  end

  
  %% Perform estimation through minimization.
  % Definition of minimization objective function.
  objective_function = ...
    @(constant) profileArea(depth1, correctSensorLag(time1, data1, constant), ...
                            depth2, correctSensorLag(time2, data2, constant));

  % Run minimization procedure.
  [constant, residual, exitflag] = ...
    fminbnd(objective_function, options.lower, options.upper, ...
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

  
  %% Definition of auxiliar plotting functions.
  % They should be nested to access sensor data.
  
  % Value sequence plot.
  function stop = optimplotValueTime(x, ~, state)
  %OPTIMPLOTVALUETIME  Value-Time diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        time_offset = min(min(time1), min(time2));
        plot(time1 - time_offset, correctSensorLag(time1, data1, x), '-r');
        hold on;
        plot(time2 - time_offset, correctSensorLag(time2, data2, x), '-b');
        plot(time1 - time_offset, data1, ':r');
        plot(time2 - time_offset, data2, ':b');
        title('Value-Time diagram');
        xlabel('Time');
        ylabel('Value');
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
  % Depth-Value diagram.
  function stop = optimplotDepthValue(x, ~, state)
  %OPTIMPLOTDEPTHVALUE  Depth-Value diagram for pair of casts.
    switch state
      case 'init'
      case 'iter'
        hold off;
        plot(correctSensorLag(time1, data1, x), depth1, '-r');
        hold on;
        plot(correctSensorLag(time2, data2, x), depth2, '-b');
        plot(data1, depth1, ':r');
        plot(data2, depth2, ':b');
        title('Depth-Value diagram');
        xlabel('Value');
        ylabel('Depth');
        set(gca, 'YDir', 'reverse')
      case 'interrupt'
      case 'done'
    end
    stop = false;
  end
  
end
