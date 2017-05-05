function pres = sgdepth2pres(depth)
%SGDEPTH2PRES  Reverse Seaglider pressure to depth conversion.
%
%  Syntax:
%    PRES = SGDEPTH2PRES(DEPTH)
%
%  Description:
%    PRES = SGDEPTH2PRES(DEPTH) converts depth estimates (cm) in array DEPTH to 
%    pressure readings in engineering units (dbar) in array PRES, reversing the 
%    on board conversion performed by a Seaglider glider (see note below).
%
%  Notes:
%    Seaglider gliders do not report pressure measurements. Instead, the 
%    pressure readings are converted to approximate depth values using a 
%    constant scale factor of 0.685 psig/m. This function reverses that
%    conversion using that factor and 14.503774 psi/bar.
%
%  Examples:
%    pres = sgdepth2pres(depth)
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

  psig2m = 0.685;
  bar2psi = 14.503774;
  pres = depth / (psig2m * bar2psi * 10);

end
