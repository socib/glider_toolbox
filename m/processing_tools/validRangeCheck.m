function qcFlaggedOutput = validRangeCheck(data, minRange, maxRange, qcFlag, varargin)
%VALIDRANGECHECK  Checks if input array is within valid ranges.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = VALIDRANGECHECK(DATA, MINRANGE, MAXRANGE, QCFLAG, VARARGIN)
%
%  Description:
%    Returns flagged array of same length as the input data array. Flagged
%    values are marked with the qcFlag number. Checks for data entry, if it
%    is between minRange and maxRange.
%    Two cases possible:
%    No varargin argument (4 input arguments):
%       -   Casual case. Just checks, if the data entries are between the
%           ranges.
%    Two additional arguments (6 input arguments):
%       -   Requires a varargin{1} depth array and depthRanges
%       (varargin{2}). Furthermore, minRange and maxRange must be of the
%       same dimension as varargin{2}. See also configDataPreprocessingQC
%       for details.
%       -   Checks if the data is within the defined range in the defined
%       depths. See also the example.
%    Edit 12.01.2016: Changed >= and <= to > and < respectively. Probably
%    a problem with zero measurements at optical sensors (since sensors can
%    measure zero, if they are in deep water).
%
%  Notes:
%    Care, that if 6 input arguments are used (specific validRange test),
%    the same dimensions for minRange, maxRange and depthRanges are used.
%    See configDataPreprocessingQC for details. Only valid for 1D data
%    arrays.
%
%  Examples:
%    qcFlaggedOutput = validRangeCheck(data, minRange, maxRange, qcFlag)
%
%    data = [1 2 3 4 5 6 7 8 9 10];
%    minRange = 3;
%    maxRange = 8;
%    qcFlag = 4;
%    expectedOutput = [4 4 4 1 1 1 1 4 4 4]'
%    qcFlaggedOutput = validRangeCheck(data, minRange, maxRange, qcFlag)

%    data = [0 -1 2 3 3 2 1 -1 0];
%    minRange = [0; 3];
%    maxRange = [0; 4];
%    qcFlag = 4;
%    depth = [0 10 20 30 40 50 60 70 80];
%    depthRange = [0, 30; 30, 80];
%    expectedOutout = [4 4 4 4 1 1 1 4 4]
%    qcFlaggedOutput = validRangeCheck(data, minRange, maxRange, qcFlag, depth, depthRange)
%
%  See also:
%    PERFORMQC
%    PERFORMGRIDDEDQC
%    CONFIGDATAPREPROCESSEDQC
%    CONFIGDATAPROCESSEDQC
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
narginchk(4,10)
validateattributes(data, {'numeric'}, {'nonempty'})
validateattributes(minRange, {'numeric'}, {'nonempty'})
validateattributes(maxRange, {'numeric'}, {'nonempty'})
validateattributes(qcFlag, {'numeric'}, {'nonempty'})

%% Begin processing.
if nargin==4 
    idxAboveThreshold = find(data > maxRange);
    idxBelowThreshold = find(data < minRange);

    idx = [idxAboveThreshold; idxBelowThreshold];

    qcFlaggedOutput = ones(length(data), 1);
    qcFlaggedOutput(idx) = qcFlag;
elseif nargin==6
    depth = varargin{1};
    depthRanges = varargin{2};
    % check for same dimension of min, max, depthRanges
    if length(minRange)~=length(maxRange) || length(maxRange)~=length(depthRanges(:,1))
        error('dimensions of min, max and varargin failed')
    end
    qcFlaggedOutput = ones(length(data), 1);
    
    for i=1:numel(depthRanges(:,1))
        startRange = depthRanges(i,1);
        endRange = depthRanges(i,2);
        tempDepthIndex = find(depth >= startRange & depth < endRange);
        if ~isempty(tempDepthIndex)
            qcFlaggedOutput(tempDepthIndex) = validRangeCheck(data(tempDepthIndex), minRange(i), maxRange(i), qcFlag);
        end
    end
    
end

end
