function d = posixtime2utc(s)
%POSIXTIME2UTC  Convert POSIX time to corresponding serial date number in UTC.
%
%  D = POSIXTIME2UTC(S) returns the serial date numbers D corresponding to the 
%  POSIX times in scalar, vector or array S (using the straight forward method).
%
%  Notes:
%    This function provides a compatibility interface for MATLAB and Octave,
%    computing the conversion using a straight forward linear scaling:
%      D = 719529 + S / 86400
%    This is consistent with the POSIX specification (not counting leap seconds,
%    using the same value for a leap second and its successor).
%
%  Examples:
%    % Get the current UTC time.
%    d = posixtime2utc(posixtime())
%    datestr(d)
%    % Built-in functions return always local time.
%    datestr(now())
%
%  See also:
%    POSIXTIME
%    UTC2POSIXTIME
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 1, nargin, 'struct'));
  
  d = 719529 + s / 86400;
  
end