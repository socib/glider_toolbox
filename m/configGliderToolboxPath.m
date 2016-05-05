function [glider_toolbox_dir] = configGliderToolboxPath()
%CONFIGGLIDERTOOLBOXPATH  Configure path to include the glider toolbox.
%
%  Syntax:
%    GLIDER_TOOLBOX_DIR = CONFIGGLIDERTOOLBOXPATH()
%
%  Description:
%    GLIDER_TOOLBOX_DIR = CONFIGGLIDERTOOLBOXPATH() adds the directory
%    containing this function and all its subdirectories to the workspace
%    path and returns the full directory path.
%
%  Examples:
%    glider_toolbox_dir = configGliderToolboxPath()
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

  [glider_toolbox_dir, ~, ~] = fileparts(mfilename('fullpath'));
  addpath(genpath(glider_toolbox_dir));

end
