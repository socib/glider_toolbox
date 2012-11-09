function s = utc2posixtime(d)
%UTC2POSIXTIME  Convert serial date number in UTC to POSIX time.
%
%  S = UTC2POSIXTIME(D) returns the POSIX times S corresponding to the serial 
%  date numbers in scalar, vector or array D (using the straight forward method).
%
%  Notes:
%    This function provides a compatibility interface for MATLAB and Octave,
%    computing the conversion using a straight forward linear scaling:
%      S = 86400 * (D - 719529)
%    This is consistent with the POSIX specification (not counting leap seconds,
%    using the same value for a leap second and its successor).
%
%  Examples:
%    % Compare the conversion of current time to the default shell current time.
%    tz_offset = -1;
%    s = utc2posixtime(now()+tz_offset/24)
%    ! date +%s%N
%    fprintf('%.0f\n',fix(1e+9*s))
%
%  See also:
%    POSIXTIME
%    POSIXTIME2UTC
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 1, nargin, 'struct'));
  
  s = 86400 * (d - 719529);
  
end