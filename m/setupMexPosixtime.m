function setupMexPosixtime()
%CONFIGMEXPOSIXTIME  Build mex file for getting current system POSIX time.
%
%  Syntax:
%    SETUPMEXPOSIXTIME()
%
%  SETUPMEXPOSIXTIME() builds a mex file implementing the function POSIXTIME,
%  that gets the system current POSIX time from the standard C library.
%    TARGET:
%      mex_tools/posixtime.mex(a64)
%    SOURCES:
%      mex_tools/posixtime.c
%    INCLUDES:
%      none
%    LIBRARIES:
%      none
%
%  Notes:
%    The system time is get by the C function TIME.
%
%    This function uses the function MEX to build the target. On GNU/Linux 
%    systems, the build process might fail after a warning if the compiler 
%    version is newer than the latest version supported by MATLAB, even though
%    running the same MEX command on a system shell builds the target properly.
%    The reason is that MATLAB may extent or overwrite the environment variable
%    LD_LIBRARY_PATH to point to its own version of the standard libraries,
%    causing an incompatibility with the version of the compiler.
%    To solve the problem, either build the target from the shell or temporarily
%    overwrite the environment variable LD_LIBRARY_PATH from the MATLAB session.
%
%  Examples:
%    % Check that GPC development files are installed on your system,
%    % or that GPC sources are present in the directory private/gpcl
%    setupMexPoly2tri()
%
%    % Incompatible versions of compiler and shipped may cause build failure.
%    % Try to build the target against system libraries instead of shipped ones.
%    ld_library_path = getenv('LD_LIBRARY_PATH')
%    setenv('LD_LIBRARY_PATH')
%    setupMexPoly2tri()
%    setenv('LD_LIBRARY_PATH', ld_library_path)
%    clear('ld_library_path')
%
%  References:
%    Alan Murta, GPC - General Polygon Clipper library:
%    http://www.cs.man.ac.uk/~amurta/software/index.html#gpc
%
%  See also:
%    POSIXTIME
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

  error(nargchk(0, 0, nargin, 'struct'));

  mex -outdir mex_tools mex_tools/posixtime.c

end
