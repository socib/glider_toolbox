function qcFlaggedOutput = spikeCheck(data, qcFlag, varargin)
%SPIKECHECK  Checks for spikes within the dataset.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = SPIKECHECK(DATA, QCFLAG, VARARGIN)
%
%  Description:
%    Checks for spikes with self defined thresholds in the varargin. If
%    there is only one varargin argument (three inputs in total), the
%    varargin defines the simple spike threshold as needed in the calcSpike
%    function.
%    If there are 4 varargin arguments (six input in total), the pressure
%    and their specific thresholds will be considered. In this case,
%    varargin{1} is the pressure array (must be same size as data), 
%    varargin{2} defines the pressure divider. The divider defines at which
%    pressure the function should distinguish between the first treshold
%    (varargin{3}) and the second threshold (varargin{4}). Possible
%    applications for this are e.g. temperature and salinity spikes.
%
%  Notes:
%    Clear distinction between 3 and 6 input variables.
%
%  Examples:
%    data = [1 10 3 4 5 6];
%    qcFlag = 6;
%    limit = 2;
%    qcFlaggedOutput = spikeCheck(data, qcFlag, limit)
%    limit = 1;
%    qcFlaggedOutput = spikeCheck(data, qcFlag, limit)
%
%  See also:
%    CALCSPIKE
%    IMPOSSIBLEDATECHECK
%    IMPOSSIBLELOCATIONCHECK
%    NANCHECK
%    VALIDRANGECHECK
%    PERFORMQC
%    PERFORMGRIDDEDQC
%    CONFIGDATAPREPROCESSINGQC
%    CONFIGDATAPROCESSINGQC
%    CONFIGDATAGRIDDEDQC
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

%% Check input.
narginchk(3,6)
validateattributes(data, {'numeric'}, {'nonempty'})
validateattributes(qcFlag, {'numeric'}, {'nonempty'})

originalLength = length(data);

%% Store indizes of non-nan values.
nonNanIndex = find(~isnan(data));

%% Remove nan values
idx = isnan(data);
data(idx) = [];

%% Handle cases.
if nargin == 6
    %temp, salinity
    %[divider thresholdBelow thresholdAbove]
    limit = [varargin{2} varargin{3} varargin{4}];
    pressure = varargin{1};
    pressure(idx) = [];
    qcFlaggedOutput = calcSpike(data, limit, nonNanIndex, qcFlag, originalLength, pressure);
elseif nargin == 3
    %dissOxy, ...
    limit = varargin{1};
    qcFlaggedOutput = calcSpike(data, limit, nonNanIndex, qcFlag, originalLength);
else
    error('Case not defined. Require 3 or 6 input arguments.')
end

end
