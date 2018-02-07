function wrcprogs = configWRCPrograms(glider_toolbox_dir)
%  CONFIGWRCPROGRAMS  Configure path of the Slocum glider programs provided by WRC.
%
%  Syntax:
%    WRCPROGS = CONFIGWRCPROGRAMS()
%
%  Description:
%    WRCPROGS = CONFIGWRCPROGRAMS() should return a struct with the path to
%    the executables provided by the Webb Research Company to deal with Slocum
%    glider data files. This function replaces the configWRCPrograms and
%    assumes that the external libraries are installed under the
%    GLIDER_TOOLBOX_DIR/ext_lib/bin. Contrary as in previous versions, this
%    function must not be edited. Users must use the configuration files to
%    overwrite the values returned by CONFIGWRCPROGRAMS if their external
%    libraries live in a different path. Read SETUPCONFIGURATION for more
%    details.
%
%    Users can use gtb_install_extlib to install the WRC programs in the
%    default path used by this function.
%  Notes:
%    The executables required are provided by the Webb Research Company and
%    should be available in your system binary path as required by the
%    XBD2DBA function.
%
%  Examples:
%    wrcprogs = configWRCPrograms()
%
%  See also:
%    XBD2DBA
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

  narginchk(1, 1);
  
  wrcprogs.base_dir          = fullfile(glider_toolbox_dir, 'ext_lib', 'bin');
  % This program is needed.
  wrcprogs.dbd2asc           = fullfile('dbd2asc');
  % These programs are optional.
  wrcprogs.dba_merge         = fullfile('dba_merge');
  wrcprogs.dba_sensor_filter = fullfile('dba_sensor_filter');
  wrcprogs.dba_time_filter   = fullfile('dba_time_filter');
  wrcprogs.dba2_orig_matlab  = fullfile('dba2_orig_matlab');
  wrcprogs.rename_dbd_files  = fullfile('rename_dbd_files');

end
