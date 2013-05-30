function setupMexPoly2tri()
%CONFIGMEXPOLY2TRI  Build mex file for polygon triangulation function POLY2TRI.
%
%  Syntax:
%    SETUPMEXPOLY2TRI()
%
%  SETUPMEXPOLY2TRI() builds a mex file implementing the function POLY2TRI,
%  that performs polygon triangulation based on the General Polygon Clipper 
%  library (GPC). GPC should be installed from the non-free section of the 
%  official repositories on Debian based distributions, in which case the mex
%  file is built using the following attributes:
%    TARGET:
%      mex_tools/poly2tri.mex(a64)
%    SOURCES:
%      mex_tools/poly2tri.c
%    INCLUDES:
%      /usr/include/gpcl/gpc.h
%    LIBRARIES:
%      /usr/lib/libgpcl.so
%  Alternatively, it is possible to build the mex file using the GPC sources 
%  directly. This is useful on systems that do not distribute the GPC library,
%  or to use a version of GPC different from the one installed in the system.
%  The GPC sources should be downloaded from the official web site and extracted
%  to a directory called 'gpcl' in the same directory than the mex file source:
%    TARGET:
%      mex_tools/poly2tri.mex(a64)
%    SOURCES:
%      mex_tools/poly2tri.c mex_tools/gpcl/gpc.c
%    INCLUDES:
%      mex_tools/gpcl/gpc.h
%    LIBRARIES:
%      none
%  Please note that when using this build rule, mex file and library sources are
%  compiled together. Hence, the resulting binary might be slightly bigger.
%
%  Notes:
%    GPC is a library developed by Alan Murta at the University of Manchester,
%    freely available for non profit use:
%      http://www.cs.man.ac.uk/~amurta/software/index.html#gpc
%
%    On Debian based systems, GPC library may be installed from the non-free
%    section of the official repositories running the following command as root:
%      apt-get install libgpcl-dev
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
%    POLY2TRI
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

  if exist('mex_tools/gpcl/gpc.h', 'file') && ...
     exist('mex_tools/gpcl/gpc.c', 'file')
    mex -outdir mex_tools mex_tools/poly2tri.c mex_tools/gpcl/gpc.c
  else
    mex -outdir mex_tools -lgpcl mex_tools/poly2tri.c
  end

end
