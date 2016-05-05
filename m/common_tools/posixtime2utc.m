function d = posixtime2utc(s)
%POSIXTIME2UTC  Convert POSIX time to corresponding serial date number in UTC.
%
%  Syntax:
%    D = POSIXTIME2UTC(S)
%
%  Description:
%    D = POSIXTIME2UTC(S) returns the serial date numbers D corresponding
%    to the POSIX times in scalar, vector or array S, using the straight 
%    forward method (see note below).
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
  
  d = 719529 + s / 86400;
  
end
