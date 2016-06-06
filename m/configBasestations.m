function basestations = configBasestations()
%CONFIGBASESTATIONS  Configure basestation parameters for glider data processing.
%
%  Syntax:
%    BASESTATIONS = CONFIGBASESTATIONS()
%
%  Description:
%    BASESTATIONS = CONFIGBASESTATIONS() should return a struct array with the
%    access parameters for the basestations containing Seaglider glider data, as
%    needed by the function GETBASESTATIONFILES.
%
%  Notes:
%    Edit this file filling in the parameters of your basestations.
%    Once configured, this file will contain private data, so you should not
%    make it public.
%
%  Examples:
%    basestations = configBasestations()
%
%  See also:
%    GETBASESTATIONFILES
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

  basestations(1).url  = 'http://mybasestation01.myportal.mydomain';
  basestations(1).user = 'myself';
  basestations(1).pass = 'top_secret';

  basestations(2).url  = 'http://mybasestation02.myportal.mydomain';
  basestations(2).user = 'myself';
  basestations(2).conn = @sftp;

end
