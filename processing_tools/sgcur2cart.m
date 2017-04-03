function [eastward, northward] = sgcur2cart(speed, direction)
%SGCUR2CART  Transform Seaglider water velocity speed and direction estimates to eastward and northward components. 
%
%  Syntax:
%    [EASTWARD, NORTHWARD] = SGCUR2CART(SPEED, DIRECTION)
%
%  Description:
%    [EASTWARD, NORTHWARD] = SGCUR2CART(SPEED, DIRECTION) computes the eastward
%    and northward components of the sea water velocity (m s-1) from magnitude
%    and direction estimates in SPEED (m s-1) and DIRECTION (degrees)
%    provided by Seaglider gliders. All arguments are the same size.
%
%  Notes:
%    This is just a convenience function to give a name to the conversion.
%    It is a shortcut to the built-in polar to cartesian conversion, POL2CART,
%    with needed angular unit conversion and order shift of output arguments.
%
%  Examples:
%    [eastward, northward] = sgcur2cart(speed, direction)
%
%  See also:
%    POL2CART
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

  error(nargchk(2, 2, nargin, 'struct'));
  
  [northward, eastward] = pol2cart(deg2rad(direction), speed);

end
