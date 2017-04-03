function qcFlaggedOutput = impossibleLocationCheck(lat, lon, qcFlag)
%IMPOSSIBLELOCATIONCHECK  Checks for impossible locations.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = IMPOSSIBLELOCATIONCHECK(LAT, LON, QCFLAG)
%
%  Description:
%    The arguments lat and lon must be two one dimensional data arrays. The
%    qcFlag is expected to be a number.
%    Checks, if latitude and longitude are between -90, 90 and -180, 180
%    are. If the check fails for data entries, they are marked with the
%    defined qcFlag. The remainder is flagged as good (one).
%
%  Notes:
%    Latitude and longitude are assumed to be co-aligned.
%
%  Examples:
%    qcFlaggedOutput = impossibleLocationCheck(lat, lon, qcFlag)
%    lat = [89   90     91   89    0   0   0 -89 -90 -91 -89];
%    lon = [-179 -180 -181 -181 -181 180 181   0   0   0   0];
%    qcFlag = 4;
%    expectedOutput = [1 1 4 4 4 1 4 1 1 4 1]'
%    qcFlaggedOutput = impossibleLocationCheck(lat, lon, qcFlag)
%
%  See also:
%    IMPOSSIBLEDATECHECK
%    NANCHECK
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

narginchk(3,3)

if ( length(lat) ~= length(lon) )
    error('glider_toolbox:impossibleLocationCheck:dimensionDiverse', ...
          'lat and lon not same dimension.')
end

qcFlaggedOutput = ones(length(lat), 1);
idx = find(lat <-90 | lon <-180 |lat >90 | lon>180);
qcFlaggedOutput(idx(:)) = qcFlag;

end
