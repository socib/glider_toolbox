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
%    Invalid values (NaN) in input sequence are ignored but preserved in output.
%
%    The first order approximation is done using forward differences with the 
%    function DIFF.
%
%    This function is a rewording of a previous function by Tomeu Garau,
%    called CORRECTTIMERESPONSE. He is the true glider man.
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
