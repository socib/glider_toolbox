function t = posixtime()
%POSIXTIME  Current POSIX time using low level utilities.
%
%  Syntax:
%    T = POSIXTIME()
%
%  Description:
%    T = POSIXTIME() returns the current POSIX time: the number of seconds since
%    1970-01-01 00:00:00 UTC, not counting the effects of leap seconds.
%
%  Notes:
%    This function provides a compatibility interface for MATLAB and Octave,
%    computing the POSIX time using lower level tools available in each system:
%    In Octave, through the built-in interface to the ANSI C function TIME.    
%    In MATLAB, through a mex file interface to the ANSI C function TIME.
%
%  Examples:
%    t = posixtime()
%    datestr(posixtime2utc(t))
%    datestr(now())
%    
%  See also:
%    POSIXTIME2UTC
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

  error(nargchk(0, 0, nargin, 'struct'));

  % Consider making the variable persistent
  % (the needed emptiness check may be more expensive than the existence check).
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  if ISOCTAVE
    t = time();
  else
    error('glider_toolbox:posixtime:MissingMexFile', ...
          'Missing required mex file.');
  end

end
