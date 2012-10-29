function constants = findThermalLagParams(varargin)
%FINDTHERMALLAGPARAMS  One-line description here, please.
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, COND2, PRES2, TEMP2)
%  finds the thermal lag parameters from two vertical profiles given by 
%  sequences of time (s), depth(m), conductivity (S/m), temperature (ºC) and 
%  pressure (dbar) in repective vectors TIME1, DEPTH1, COND1 and TEMP1, and 
%  TIME2, DEPTH2, COND2 and TEMP2. The computed parameters are returned in a 
%  four element vector CONSTANTS, with the offset and the slope of the error 
%  magnitude (ALPHA_O and ALPHA_S), and the offset and the slope of the error 
%  time (TAU_O and TAU_S). With these parameters, the error magnitude and the 
%  error time, depending on the flow speed, may be estimated as:
%    ALPHA = ALPHA_O + ALPHA_S / V
%      TAU =   TAU_0 +   TAU_S / SQRT(V)
%
%  The profiles are supposed to measure the same column of water in opposite 
%  directions. Based on the assumption that both profiles should be as similar 
%  as possible, it finds the thermal lag parameters such that the area between
%  the corrected profiles in a temperature-salinity diagram is minimum.
%
%  CONSTANTS = FINDTHERMALLAGPARAMS(TIME1, DEPTH1, PITCH1, COND1, TEMP1, PRES1, TIME2, DEPTH2, PITCH2, COND2, TEMP2, PRES2)
%  performs the same correction but for non vertical profiles, with pitch angle
%  given by PITCH1 and PITCH2 in radians. PITCH1 and PITCH2 may be either a
%  vector a with the same dimensions as TIME1, DEPTH1, COND1 and TEMP1, and
%  TIME2, DEPTH2, COND2 and TEMP2, respectively; or a scalar taken to be the 
%  constant pitch across the respective profile.
%
%  CONSTANTS = FINDSENSORLAGPARAMS(..., OPTIONS) allows passing non default
%  options to the internal minimization function FMINSEARCH used to solve the
%  minimization problem stated above.
%
%  Notes:
%    This function is simply a reworded version of a previous function by Tomeu
%    Garau, called  ADJUSTTHERMALLAGPARAMS. He is the true glider man.
%
%    The function solves the minimization problem of finding the thermal lag 
%    parameters such that the area between profiles of temperature and salinity 
%    derived using SW_SALT from corrected temperature and conductivity sequences
%    returned by CORRECTTHERMALLAG is minimal. This problem is solved with the 
%    function FMINSEARCH, using the following values from Morison (1994):
%    [0.0135 0.0264 7.1499 2.7858]
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
%
%    % Vertical profiles.
%    constants = ...
%      findThermalLagParams(time1, depth1, cond1, temp1, pres1, ...
%                           time2, depth2, cond2, temp2, pres2);
%    % Tilted profiles.
%    constants = ...
%      findThermalLagParams(time1, depth1, pitch1, cond1, temp1, pres1, ...
%                           time2, depth2, pitch2, cond2, temp2, pres2);
%    % Tilted profiles with extra options to plot values at each iteration.
%    constants = ...
%      findThermalLagParams(time1, depth1, pitch1, cond1, temp1, pres1, ...
%                           time2, depth2, pitch2, cond2, temp2, pres2, ...
%                           options);
%
%  See also:
%    CORRECTTHERMALLAG
%    OPTIMSET
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(11, 13, nargin, 'struct'));

  switch(nargin)
    case 10
      [time1, depth1, cond1, temp1, pres1] = varargin{1:5};
      [time2, depth2, cond2, temp2, pres2] = varargin{6:10};
      options = optimset('fminsearch');
      % Vertical profile.
      pitch1 = pi/2;
      pitch2 = pi/2;
    case 11
      [time1, depth1, cond1,  temp1] = varargin{1:5};
      [time2, depth2, cond2,  temp2] = varargin{6:10};
      options = varargin{11};
      % Vertical profile.
      pitch1 = pi/2;
      pitch2 = pi/2;
    case 12
      [time1, depth1, pitch1, cond1, temp1, pres1] = varargin{1:6};
      [time2, depth2, pitch2, cond2, temp2, pres2] = varargin{7:12};
      options = optimset('fminsearch');
    case 13
      [time1, depth1, pitch1, cond1, temp1, pres1] = varargin{1:6};
      [time2, depth2, pitch2, cond2, temp2, pres2] = varargin{7:12};
      options = varargin{13};
  end
  
  
  % This is the equivalent version of the original code by Tomeu Garau,
  % with external constant functions inlined and coding style adaptions:
  %{
  % Minimize the area between the two profiles in the TS Diagram
  % Starting guess of the solution: get the parameters estimated
  % from the correction of one of the profiles.
  % The selection of the profile is arbitrary.  
  options = optimset(optimset('fimncon'), ...
    'LargeScale', 'off',           ...
    'Algorithm',  'active-set',    ...
    'TolFun',     1e-4,            ...
    'TolCon',     1e-5,            ...
    'TolX',       1e-5,            ...
    ... % 'Plotfcns',   [], % {@optimplotfval, @optimplotfirstorderopt, @optimplotx});
    'Display',    'off');
  [~, first_guess] = correctThermalLag(downcast);
  max_time = max(time1) - min(time1);
  upper_bound = [2, 1, max_time, max_time/2];
  lower_bound = eps * ones(size(first_guess));
  constants = fmincon(@ts_area, fg, [], [], [], [], lower_bound, upper_bound, [], options);
  %}
  
  % Target function.
  target_function = @(constants) profileArea(...
    temp1, ...
    sw_salt(correctThermalLag(time1, depth1, pitch1, cond1, temp1, constants) * (10 / sw_c3515()), temp1, pres1), ...
    temp2, ...
    sw_salt(correctThermalLag(time2, depth2, pitch2, cond2, temp2, constants) * (10 / sw_c3515()), temp2, pres2));
  % First guess from Morison (1994).
  fg = [0.0135 0.0264 7.1499 2.7858];
  [constants, fval, exitflag] = fminsearch(target_function, fg, options);
  if exitflag ~= 1
    warning('glider_toolbox:findThermalLagParams:MinimizationError', ...
            'Minimization did not converge, residual area: %f.', fval);
  end

end
