function new_pressure = applySeabirdPressureFilter(time, old_pressure, time_constant)
%APPLYPRESSUREFILTER  Pressure filtering with regular resampling for Seabird sensor.
%
%  NEW_PRESSURE = APPLYSEABIRDPRESSUREFILTER(TIME, OLD_PRESSURE, TIME_CONSTANT)
%  applies a low pass filter to the pressure time serie in vector OLD_PRESSURE
%  with irregular timestamps in vector TIME. The filter applied is the function 
%  SEABIRDFILTER with duration parameter given by double TIME_CONSTANT.
%  The filtered pressure is returned in vector NEW_PRESSURE.
%
%  NEW_PRESSURE = APPLYPRESSUREFILTER(TIME, OLD_PRESSURE) applies the low pass
%  filter with default duration parameter of 4 time units.
%
%  The filtering is performed as follows:
%    - Invalid (nan) values in input are ignored, but preserved in the result.
%    - The signal is resampled at regular intervals of unit time length.
%      Hence, if TIME is given in seconds, the filter is applied to a new
%      sequence with sampling rate 1 Hz.
%    - The filter in function SEABIRDFILTER is applied to the resampled signal
%      with duration parameter TIME_CONSTANT.
%    - The resulting filtered signal is resampled at the original time instants.
% 
%  Notes:
%    This function is a version of the function APPLYPRESSUREFILTER created by
%    Tomeu Garau. He is the true glider man. Introduced changes are time 
%    constant argument, duplicate record handling removal, and coding style
%    adaptions.
%
%  Examples:
%    % Use default time constant parameter (4 seconds).
%    new_pressure = applySeabirdPressureFilter(time, old_pressure)
%    % Use custom time constant parameter.
%    new_pressure = applySeabirdPressureFilter(time, old_pressure, 6)
% 
%  See also:
%    SEABIRDFILTER
%    INTERP1
%
%  Author: Bartolome Garau
%  Email: tgarau@socib.es

  error(nargchk(2, 3, nargin, 'struct'));
  
  % Check if time constant specified.
  if nargin < 3
    time_constant = 4;
  end

  % Initialize output.
  new_pressure = old_pressure;
  
  % Denan original data.
  good_rows = ~isnan(old_pressure);
  old_pres_signal = old_pressure(good_rows);
  time_range  = time(good_rows);

  % Set the pressure time series on a regular time basis of unit length.
  reg_time_range = min(time_range):max(time_range);
  reg_pres_signal = interp1(time_range, old_pres_signal, reg_time_range);
  
  % Filter the regular time series.
  new_pres_signal = seabirdFilter(reg_pres_signal, time_constant, 1);
  
  % Set the time series on its original time instants.
  new_pres_signal = interp1(reg_time_range, new_pres_signal, time_range);

  % Return the filtered signal preserving origina nan values.
  new_pressure(good_rows)  = new_pres_signal;

end