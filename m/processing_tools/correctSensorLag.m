function cor = correctSensorLag(varargin)
%CORRECTSENSORLAG  Correct data sequence from sensor lag effects.
%
%  Syntax:
%    COR = CORRECTSENSORLAG(TIME, RAW, PARAMS)
%    COR = CORRECTSENSORLAG(TIME, RAW, FLOW, PARAMS)
%
%  Description:
%    COR = CORRECTSENSORLAG(TIME, RAW, PARAMS) corrects the sequence in vector
%    RAW with timestamp in vector TIME and constant flow speed from sensor lag 
%    effects. The correction is done advancing the signal in time using linear
%    interpolation. PARAMS should be a scalar with the number of time units the
%    signal should be shifted.
%
%    COR = CORRECTSENSORLAG(TIME, RAW, FLOW, PARAMS) performs the same 
%    correction but for a sequence with variable flow speed, given by FLOW. 
%    FLOW should be a vector with the same dimensions as TIME and RAW. 
%    PARAMS should be a two element vector with the offset and the slope 
%    of the time lag parameter with respect to the inverse flow speed.
%
%  Notes:
%    This function is a recoding of a previous function by Tomeu Garau, called 
%    CORRECTTIMERESPONSE. He is the true glider man. Main changes are:
%      - Different correction using shift by interpolation instead of gradient.
%      - Support for dynamic time lag parameters for sequences with variable 
%        flow speed.
%
%    Invalid values (NaN) in input sequence are ignored but preserved in output.
%
%    The first order approximation was done using forward differences with the 
%    function DIFF.
%
%  Examples:
%    % Example sequence:
%    time = 0:25
%    tru = exp(-0.5*(time-10).^2/4^2)
%
%    % Correct a sequence with a lag of 5 time units and constant flow speed:
%    tau = 5
%    raw = exp(-0.5*(time-10-tau).^2/4^2)
%    raw([5 6 10 19 20 21]) = nan
%    cor1 = correctSensorLag(time, raw, 3)
%    cor2 = correctSensorLag(time, raw, tau)
%    subplot(2, 1, 1)
%    plot(time, tru, 'k--', time, raw, 'k', time, cor1, 'b', time, cor2, 'r')
%    legend('true', ...
%           sprintf('raw (delay params %.2f)', tau), ...
%           sprintf('corrected 1 (shift params %.2f)', 3), ...
%           sprintf('corrected 2 (shift params %.2f)', tau))
%    title('constant flow speed')
%
%    % Correct a sequence with a lag of 5 time units and variable flow speed:
%    flow = 0.4 + 0.1 * randn(size(time))
%    tau_offset = 1.5
%    tau_scale = 0.2
%    tau = tau_offset + tau_scale ./ flow
%    raw = exp(-0.5*((time-10-tau).^2)/4^2)
%    raw([5 6 10 19 20 21]) = nan
%    cor1 = correctSensorLag(time, raw, flow, [1.0 0.1])
%    cor2 = correctSensorLag(time, raw, flow, [tau_offset tau_scale])
%    subplot(2, 1, 2)
%    plot(time, tru, 'k--', time, raw, 'k', time, cor1, 'b', time, cor2, 'r')
%    legend('true', ...
%           sprintf('raw (delay params %.2f %.2f)', tau_offset, tau_scale), ...
%           sprintf('corrected 1 (shift params %.2f %.2f)', 1.0, 0.1), ...
%           sprintf('corrected 2 (shift params %.2f %.2f)', tau_offset, tau_scale))
%    title('variable flow speed')
%
%  See also:
%    FINDSENSORLAGPARAMS
%    INTERP1
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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

  error(nargchk(3, 4, nargin, 'struct'));

  % Parse input arguments.
  switch(nargin)
    case 3
      % Constant flow speed.
      [timestamp, raw, params] = varargin{:};
      constant_flow = true;
    case 4
      % Variable flow speed.
      [timestamp, raw, flow, params] = varargin{:};
      constant_flow = false;
  end
  
  if constant_flow
    % Positive time check to filter out bad initial lines on Slocum data.
    valid = (timestamp > 0) & ~isnan(raw); 
    % Time lag parameter is a constant scalar.
    tau = params;
  else
    % Positive time check to filter out bad initial lines on Slocum data.
    valid = (timestamp > 0) & ~(isnan(raw) | isnan(flow));
    % Compute dynamic time lag parameter inversely proportional to flow speed.
    tau_offset = params(1);
    tau_slope = params(2);
    tau = tau_offset + tau_slope ./ flow(valid);
  end
  
  cor = nan(size(raw));
  timestamp_valid = timestamp(valid);
  raw_valid = raw(valid);
  [timestamp_unique, index_from, index_to] = unique(timestamp_valid);
  raw_unique = raw_valid(index_from);
  if any(raw_valid ~= raw_unique(index_to))
    error('glider_toolbox:correctSensorLag:InconsistentData', ...
          'Inconsistent sensor data.');
  end
  if numel(timestamp_unique) > 1
    % del = [0; diff(raw_valid) ./ diff(timestamp_valid)];
    % cor(valid) = raw_val + tau .* del;
    cor(valid) = interp1(timestamp_unique, raw_unique, ...
                         timestamp_valid + tau, 'linear', 'extrap');
  end

end
