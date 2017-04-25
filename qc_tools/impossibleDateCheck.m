function qcFlaggedOutput = impossibleDateCheck(time, qcFlag)
%IMPOSSIBLEDATECHECK  Checks the input for impossible dates.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = IMPOSSIBLEDATECHECK(TIME, QCFLAG)
%
%  Description:
%    The function requires a 1D time array as input and a qcFlag number.
%    It compares the input time entries, if they are within range of the
%    defined lowerThresholdDate (actually 01.01.2007 - no gliders existed
%    before) and the actual time.
%    Returns an array filled with ones of same length like the input data
%    and flags those entries that fail the test with the specified qcFlag.
%
%  Notes:
%  The posixtime mex file is required (as in the socib glider toolbox).
%
%  Examples:
%    time= utc2posixtime([datenum([2005 1 1 0 0 00]), datenum([2015 1 1 0 0 00]), datenum([2025 1 1 0 0 00])]);
%    qcFlag = 4;
%    qcFlaggedOutput = impossibleDateCheck(time, qcFlag)
%
%  See also:
%    NANCHECK
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

narginchk(2,2)

qcFlaggedOutput = ones(length(time), 1);

actualPosixTimeUTC = posixtime();
lowerThresholdDate = datenum([2007  1  1  0  0  00]);
lowerThresholdDatePosixTimeUTC = utc2posixtime(lowerThresholdDate);

idx = find(time <lowerThresholdDatePosixTimeUTC | time > actualPosixTimeUTC);
qcFlaggedOutput(idx(:)) = qcFlag;

end
