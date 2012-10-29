function cor = correctSensorLag(time, raw, constant)
%CORRECTSENSORLAG   Correct data sequence from sensor lag effects.
%
%  COR = CORRECTSENSORLAG(TIME, RAW, CONSTANT) corrects the sequence in vector
%  RAW with timestamp in vector TIME from sensor lag effects. The correction is
%  done advancing the signal in time with a first order approximation. The
%  signal is advanced CONSTANT time units.
%
%  Notes:
%    Invalid values (NaN) in input sequence are ignored but preserved in output.
%
%    The first order approximation is done using the function GRADIENT.
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
  val = ~(isnan(time) | isnan(raw));
  if any(val)
    del = gradient(raw(val), time(val));
    % del = [diff(raw(val)) ./ diff(time(val)) 0];
    cor(val) = raw(val) + constant * del;
  end

end
