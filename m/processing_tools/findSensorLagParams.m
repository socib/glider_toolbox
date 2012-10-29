function time_constant = findSensorLagParams(time1, depth1, data1, time2, depth2, data2, options)
%FINDSENSORLAGPARAMS  Sensor lag time constant adjustment for profiles.
%
%  TIME_CONSTANT = FINDSENSORLAGPARAMS(TIME1, DEPTH1, DATA1, TIME2, DEPTH2, DATA2)
%  finds the sensor lag time constant from the two profile sequences given by 
%  vectors TIME1, DEPTH1 and DATA1, and TIME2, DEPTH2 and DATA2. The profiles
%  are supposed to measure the same to measure the same column of water in 
%  opposite directions. Based on the assumption that both profiles should be as 
%  similar as possible, it finds the sensor time lag parameter, such that the 
%  area in a value-depth diagram between the corrected profiles is minimum. 
%
%  TIME_CONSTANT = FINDSENSORLAGPARAMS(..., OPTIONS) allows passing non default
%  options the internal minimization function FMINBND used to solve the
%  minimization problem stated above.
%
%  Notes:
%    This function is simply a reworded version of a previous function by Tomeu
%    Garau, called  ADJUSTIMECONSTANT. He is the true glider man.
%
%    The function solves the minimization problem of finding the time constant
%    such that the area between corrected profiles returned by CORRECTSENSORLAG
%    is minimal. This problem is solved with the function FMINBND restricting
%    the time constant to be non negative.
%
%    It remains to be assessed that the time constant found minimizes the area 
%    between the corrected profiles globally, because the solver looks for local
%    minimizers only.
%
%  Examples:
%    time_constant = findSensorLagParams(time1, depth1, data1, time2, depth2, data2)
%
%  See also:
%    CORRECTSENSORLAG
%    FMINBND
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(6, 7, nargin, 'struct'));
  
  % This is the equivalent version of the original code by Tomeu Garau,
  % with external constant functions inlined and coding style adaptions:
  %{
  options = optimset(optimset('fimncon'), ...
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
  time_constant = fmincon(@prof_area, first_guess, [], [], [], [], ...
                          lower_bound, upper_bound, [], options);
  %}
  
  if nargin < 7
    options = optimset('fminbnd');
  end

  lb = 0;
  ub = realmax();
  target_function = ...
    @(constant) profileArea(depth1, correctSensorLag(time1, data1, constant), ...
                            depth2, correctSensorLag(time2, data2, constant));
  [time_constant, fval, exitflag] = fminbnd(target_function, lb, ub, options);
  if exitflag ~= 1
    warning('glider_toolbox:findSensorLagParams:MinimizationError', ...
            'Minimization did not converge, residual area: %f.', fval);
  end

end
