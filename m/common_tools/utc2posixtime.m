function s = utc2posixtime(d)
%UTC2POSIXTIME  Convert serial date number in UTC to POSIX time.
%
%  Syntax:
%    S = UTC2POSIXTIME(D)
%
%  Description:
%    S = UTC2POSIXTIME(D) returns the POSIX times S corresponding to the serial 
%    date numbers in scalar, vector or array D, using the straight forward
%    method (see note below).
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
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  error(nargchk(1, 1, nargin, 'struct'));
  
  s = 86400 * (d - 719529);
  
end
