function m = cm2m(cm)
%BAR2DBAR  Convert metric distance from centimeters to meters.
%
%  Syntax:
%    M = CM2M(CM)
%
%  Description:
%    M = CM2M(CM) converts metric readings in array CM from centimeters to
%    meters by multiplying by 0.01.
%
%  Notes:
%    This is simply a convenience function to call the conversion with an
%    explicit name.
%
%  Examples:
%    m = cm2m(cm)
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

  error(nargchk(nargin, 1, 1, 'struct'));

  m = cm * 0.01;

end
