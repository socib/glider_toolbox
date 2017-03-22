function qcFlaggedOutput = nanCheck(data, qcFlag)
%NANCHECK  flags NaN values.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = NANCHECK(DATA, QCFLAG)
%
%  Description:
%    return a length(data) array filled with ones for non-NaN and nines for
%    NaN flagged values.
%
%  Notes:
%
%  Examples:
%    data = [10 20 nan 40 50 nan];
%    qcFlag = 9;
%    qcFlaggedOutput = nanCheck(data, qcFlag)
%
%  See also:
%    IMPOSSIBLEDATECHECK
%    IMPOSSIBLELOCATIONCHECK
%    SPIKECHECK
%    VALIDRANGECHECK
%    PERFORMQC
%    CONFIGDATAPREPROCESSINGQC
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2017
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

qcFlaggedOutput = ones(length(data),1);
qcFlaggedOutput(isnan(data)) = qcFlag;

end
