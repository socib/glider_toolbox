function setupMexSFTP()
%SETUPMEXSFTP  Build mex file for internal functions of SFTP object methods.
%
%  Syntax:
%    SETUPMEXSFTP()
%
%  Description:
%    SETUPMEXSFTP() builds a mex file interface to perform operations through an
%    SFTP connection to a remote server using the API provided by the library 
%    libssh. This interface is used in the implementation of the SFTP methods.
%    If libssh is installed from the official repositories on Debian based 
%    distributions, the mex file is built using the following attributes:
%      TARGET:
%        /path/to/@sftp/private/mexsftp.mex(a64)
%      SOURCES:
%        /path/to/@sftp/private/mexsftp.c
%      INCLUDES:
%        none
%      LIBRARIES:
%        -l ssh
%    Alternatively, it is possible to build the mex file using precompiled 
%    versions of the library for other platforms available at the web site,
%    or a version of the library compiled from sources locally.
%    The header files and the binary files should be located in the respective 
%    directories 'libssh/include/libssh' and 'libssh/lib' in the same directory
%    than the mex file source.
%      TARGET:
%        /path/to/@sftp/private/mexsftp.mex(a64)
%      SOURCES:
%        /path/to/@sftp/private/mexsftp.c
%      INCLUDES:
%        -I /path/to/@sftp/private/libssh/include
%      LIBRARIES:
%        -L /path/to/@sftp/private/libssh/lib
%        -Wl,-rpath=$ORIGIN/libssh/lib
%        -l ssh
%
%  Notes:
%    The libssh library provides a client API for the SFTP protocol. 
%    The official web site of the library is:
%      <https://www.libssh.org/>
%
%    On Debian based systems, the libssh library may be installed from the main
%    section of the official repositories running the following command as root:
%      apt-get install libssh-dev
%
%    This function uses the function MEX to build the target. On GNU/Linux 
%    systems, the build process might fail after a warning if the compiler 
%    version is newer than the latest version supported by MATLAB, even though
%    running the same MEX command on a system shell builds the target properly.
%    The reason is that MATLAB may extend or overwrite the environment variable
%    LD_LIBRARY_PATH to point to its own version of the standard libraries,
%    causing an incompatibility with the version of the compiler.
%    To solve the problem, either build the target from the shell or temporarily
%    overwrite the environment variable LD_LIBRARY_PATH from the MATLAB session.
%
%  References:
%    Aris Adamantiadis and Andreas Schneider, libssh library:
%    <http://www.libssh.org/>
%
%  Examples:
%    % Check that libssh is properly installed on the system
%    % or locally in the private/libssh directory of the @sftp class.
%    setupMexSFTP()
%
%    % Incompatible versions of system compiler and libraries shipped with the
%    % the interpreter may cause build failure.
%    % Try to build the target against system libraries instead of shipped ones.
%    ld_library_path = getenv('LD_LIBRARY_PATH')
%    setenv('LD_LIBRARY_PATH')
%    setupMexSFTP()
%    setenv('LD_LIBRARY_PATH', ld_library_path)
%    clear('ld_library_path')
%
%  See also:
%    MEXSFTP
%    SFTP
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
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
  
  funcname = 'mexsftp';
  funcpath =  which('@sftp/private/mexsftp');
  
  if isempty(funcpath)
    error('glider_toolbox:setup:NotFound', ...
          'Could not find location of %s.', funcname);
  end
  
  prefix = fileparts(funcpath);
  target = fullfile(prefix, [funcname '.' mexext()]);
  sources = fullfile(prefix, [funcname '.c']);
  libssh = 'ssh';
  libsshdir = fullfile(prefix, 'libssh');
  includedir = fullfile(libsshdir, 'include');
  librarydir = fullfile(libsshdir, 'lib');
  rpath = fullfile('\\\$ORIGIN', 'libssh', 'lib');

  if exist(libsshdir, 'dir')
    mex('-output', target, ...
        ['-I' includedir], ...
        ['-L' librarydir], ...
        ['-l' libssh], ...
        ['-Wl,-rpath=' rpath], ...
        sources);
  else
    mex('-output', target, ['-l' libssh], sources);
  end

end
