function cor = correctSensorLag(time, raw, constant)
%CORRECTSENSORLAG  Correct data sequence from sensor lag effects.
%
%  Syntax:
%    COR = CORRECTSENSORLAG(TIME, RAW, CONSTANT)
%
%  COR = CORRECTSENSORLAG(TIME, RAW, CONSTANT) corrects the sequence in vector
%  RAW with timestamp in vector TIME from sensor lag effects. The correction is
%  done advancing the signal in time with a first order approximation. The
%  signal is advanced CONSTANT time units.
%
%  Notes:
%    This function is a rewording of a previous function by Tomeu Garau,
%    called CORRECTTIMERESPONSE. He is the true glider man.
%
%    Invalid values (NaN) in input sequence are ignored but preserved in output.
%
%    The first order approximation is done using forward differences with the 
%    function DIFF.
%
%  Examples:
%    time = 0:25
%    raw = exp(-0.5*(time-15).^2/4^2)
%    raw([5 6 10 19 20 21]) = nan
%    cor1 = correctSensorLag(time, raw, 1)
%    cor2 = correctSensorLag(time, raw, 2)
%    figure
%    hold on
%    plot(time, raw, 'k')
%    plot(time, cor1, 'b')
%    plot(time, cor2, 'r')
%
%  See also:
%    FINDSENSORLAGPARAMS
%    GRADIENT
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

  error(nargchk(3, 3, nargin, 'struct'));

  cor = nan(size(raw));
  val = find(~isnan(raw) & (time > 0)); % Positive time check to filter out bad initial lines on Slocum data.
  [time_unique, index_from, index_to] = unique(time(val));
  raw_unique = raw(val(index_from));
  if any(raw(val) ~= raw_unique(index_to))
    error('glider_toolbox:correctSensorLag:InconsistentData', ...
          'Inconsistent sensor data.');
  end
  if numel(time_unique) > 1
    % del = [0; diff(raw(val)) ./ diff(time(val))];
    % cor(val) = raw(val) + constant * del;
    cor(val) = interp1(time_unique, raw_unique, time(val) + constant, ...
                       'spline', 'extrap');
  end

end
