function qcFlaggedOutput = calcSpike(data, limit, nonNanIndex, qcFlag, originalLength, varargin)
%CALCSPIKE  Flags spikes within the dataset.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = CALCSPIKE(DATA, LIMIT, NONNANINDEX, QCFLAG, ORIGINALLENGTH, VARARGIN)
%
%  Description:
%    Calculates spikes as defined in the SOCIB QC Procedures and flags the
%    values with the defined qcFlag. The remaining values are flagged as
%    good (ones). The combination of both is returned as qcFlaggedOutput.
%    It will be distinguished between five input arguments (no varargin
%    argument) and six (one varargin argument).
%    Five input arguments:
%    -  Simple spike check.
%    -  Just checks if the calculated spike is outside the defined limit or
%    not.
%    Six input arguments:
%    -  Extended spike check.
%    -  Requires pressure data array in varargin{1} and the limits defined
%    in the spikeCheck function order ([pressureDivider, thresholdBelow,
%    thresholdAbove]).
%    -  Calculates the spikes for values below (limit(2)) and above
%    (limit(3)) the defined pressure divider (limit(1)).
%    Flags spikes with the defined qcFlag and the remainder as ones.
%    Returns the flagged output array.
%
%  Notes:
%    Care, if you use 6 input arguments, to define the varargin{1} as an
%    array containing the pressure data, devider and thresholds below and
%    above.
%
%  Examples:
%    data = [1 10 3 4 5 6];
%    limit = 2;
%    nonNanIndex = [1 2 3 4 5 6];
%    qcFlag = 6;
%    originalLength = 6;
%    qcFlaggedOutput = calcSpike(data, limit, nonNanIndex, qcFlag, originalLength)
%    limit = 1;
%    qcFlaggedOutput = calcSpike(data, limit, nonNanIndex, qcFlag, originalLength)
%
%  See also:
%    SPIKECHECK
%    IMPOSSIBLEDATECHECK
%    IMPOSSIBLELOCATIONCHECK
%    NANCHECK
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

%% Check input
narginchk(5,6)
validateattributes(limit, {'numeric'}, {'nonempty'})
validateattributes(qcFlag, {'numeric'}, {'nonempty'})

%% Begin processing.
qcFlaggedOutput = ones(originalLength, 1);

if nargin == 5
    %% Loop through from position 2 to end-1
    for i=2:length(data)-1
        V2 = data(i);
        V1 = data(i-1);
        V3 = data(i+1);

        testValue = abs( V2 - ( V3 + V1 ) / 2 ) - abs( ( V3 - V1 ) /2 );
        if testValue >= limit
            qcFlaggedOutput(nonNanIndex(i)) = qcFlag;
        end
    end

elseif nargin == 6
    pressure = varargin{1};
    pressureDivider = limit(1);
    thresholdBelow = limit(2);
    thresholdAbove = limit(3);

    %% Loop through from position 2 to end-1
    for i=2:length(data)-1
        V2 = data(i);
        V1 = data(i-1);
        V3 = data(i+1);

        testValue = abs( V2 - ( V3 + V1 ) / 2 ) - abs( ( V3 - V1 ) /2 );
        windowMeanPressure = mean([pressure(i-1) pressure(i) pressure(i+1)] );
        if windowMeanPressure > pressureDivider
            if testValue >= thresholdBelow
                qcFlaggedOutput(nonNanIndex(i)) = qcFlag;
            end
        else
            if testValue >= thresholdAbove
                qcFlaggedOutput(nonNanIndex(i)) = qcFlag;
            end
        end
    end
end

end
