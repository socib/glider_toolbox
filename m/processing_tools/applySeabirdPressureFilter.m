function new_pressure = applySeabirdPressureFilter(time, old_pressure, time_constant)
%APPLYPRESSUREFILTER  Pressure filtering with regular resampling for Seabird sensor.
%
%  Syntax:
%    NEW_PRESSURE = APPLYSEABIRDPRESSUREFILTER(TIME, OLD_PRESSURE, TIME_CONSTANT)
%    NEW_PRESSURE = APPLYSEABIRDPRESSUREFILTER(TIME, OLD_PRESSURE)
%
%  Description:
%    NEW_PRESSURE = APPLYSEABIRDPRESSUREFILTER(TIME, OLD_PRESSURE, TIME_CONSTANT)
%    applies a low pass filter to the pressure time serie in vector OLD_PRESSURE
%    with irregular timestamps in vector TIME. The filter applied is the one in
%    function SEABIRDFILTER with duration parameter given by the scalar
%    TIME_CONSTANT. The filtered pressure is returned in vector NEW_PRESSURE.
%
%    NEW_PRESSURE = APPLYSEABIRDPRESSUREFILTER(TIME, OLD_PRESSURE) applies 
%    the low pass filter with default duration parameter of 4 time units.
%
%    The filtering is performed as follows:
%      - Invalid values (NaN) in input are ignored, but preserved in the result.
%      - The signal is resampled at regular intervals of unit time length.
%        Hence, if TIME is given in seconds, the filter is applied to a new
%        sequence with sampling rate 1 Hz.
%      - The filter in function SEABIRDFILTER is applied to the resampled signal
%        with duration parameter TIME_CONSTANT.
%      - The resulting filtered signal is resampled at the original time
%        instants.
% 
%  Notes:
%    This function is a version of the function APPLYPRESSUREFILTER created by
%    Tomeu Garau. He is the true glider man. Main changes are:
%      - Time constant argument.
%      - Duplicate record handling removal.
%      - Coding style adaptions.
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
%  Authors:
%    Bartolome Garau  tgarau@socib.es

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

  narginchk(2, 3);
  
  % Check if time constant specified.
  if nargin < 3
    time_constant = 4;
  end

  % Initialize output.
  new_pressure = nan(size(old_pressure));
  
  % Filter invalid values in original data.
  % The positive time test is needed to deal with odd data from initial
  % lines in Slocum segment files.
  good_rows = ~isnan(old_pressure) & (time > 0);
  old_pres_signal = old_pressure(good_rows);
  time_range  = time(good_rows);

  % Interpolation routine interp1 requires all nodes to have unique independent
  % variable coordinates. This might not be the case when the CTD timestamp is
  % used. So check for uniqueness and data coherency.
  [time_range_unique, index_from, index_to] = unique(time_range);
  old_pres_unique = old_pres_signal(index_from);
  if any(old_pres_signal ~= old_pres_unique(index_to))
    error('glider_toolbox:applySeabirdFilter:InconsistentData', ...
          'Inconsistent pressure data.');
  end
  
  % Set the pressure time series on a regular time basis of unit length.
  reg_time_range = min(time_range_unique):max(time_range_unique);
  reg_pres_signal = interp1(time_range_unique, old_pres_unique, reg_time_range);
  
  % Filter the regular time series.
  new_pres_signal = seabirdFilter(reg_pres_signal, time_constant, 1);
  
  % Set the time series on its original time instants.
  new_pres_signal = interp1(reg_time_range, new_pres_signal, time_range);

  % Return the filtered signal preserving original invalid values.
  new_pressure(good_rows)  = new_pres_signal;

end
