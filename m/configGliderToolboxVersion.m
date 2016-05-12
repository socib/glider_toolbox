function version = configGliderToolboxVersion()
%CONFIGGLIDERTOOLBOXVERSION  Configure version of the currently toolbox in use.
%
%  Syntax:
%    VERSION = CONFIGGLIDERTOOLBOXVERSION()
%
%  Description:
%    VERSION = CONFIGGLIDERTOOLBOXVERSION() should return the identifier
%    of the current version of the toolbox (see note on versions below).
%
%  Notes:
%    It is highly recommended to modify the returned version when using a forked
%    version of the toolbox. The recommended way is to compose the custom 
%    version identifier by adding a suffix to the identifier of the version on
%    which the fork is based separated by a hyphen. If your version is on a 
%    public repository under version control, it might be useful to use the same
%    reference identifier (branch and commit id, tag, revision...) as suffix.
%    
%  Examples:
%    version = configGliderToolboxVersion()
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
  
  version = '1.2.0';

end
