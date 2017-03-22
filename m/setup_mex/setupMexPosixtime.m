function setupMexPosixtime()
%SETUPMEXPOSIXTIME  Build mex file for system POSIX time function POSIXTIME.
%
%  Syntax:
%    SETUPMEXPOSIXTIME()
%
%  Description:
%    SETUPMEXPOSIXTIME() builds a mex file implementing the function POSIXTIME,
%    that gets the system current POSIX time from the standard C library.
%      TARGET:
%        /path/to/posixtime.mex(a64)
%      SOURCES:
%        /path/to/posixtime.c
%      INCLUDES:
%        none
%      LIBRARIES:
%        none
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
%    % Compile interface function for low level C function TIME.
%    setupMexPosixtime();
%
%    % Incompatible versions of system compiler and libraries shipped with the
%    % interpreter may cause build failure.
%    % Try to build the target against system libraries instead of shipped ones.
%    ld_library_path = getenv('LD_LIBRARY_PATH')
%    setenv('LD_LIBRARY_PATH')
%    setupMexPosixtime()
%    setenv('LD_LIBRARY_PATH', ld_library_path)
%    clear('ld_library_path')
%
%  See also:
%    POSIXTIME
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
  
  funcname = 'posixtime';
  funcpath = which(funcname);
  
  if isempty(funcpath)
    error('glider_toolbox:setup:NotFound', ...
          'Could not find location of %s.', funcname);
  end
  
  prefix = fileparts(funcpath);
  target = fullfile(prefix, [funcname '.' mexext()]);
  sources = fullfile(prefix, [funcname '.c']);
  
  mex('-output', target, sources);

end
