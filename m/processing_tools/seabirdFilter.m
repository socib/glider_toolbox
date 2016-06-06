function outputSignal = seabirdFilter(inputSignal, timeConstant, samplingPeriod)
%SEABIRDFILTER  Applies a low-pass filter to an input signal
%
%  Syntax:
%    outputSignal = seabirdFilter(inputSignal, timeConstant, samplingPeriod)
%
%  Description:
%    The filter runs a low-pass filter on an input signal. A low-pass filter
%    smoothes high frequency (rapidly changing) data. To produce zero phase
%    (no time shift), the filter is first run forward through the data and then
%    run backward through the data, so that no delays are caused by the filter.
%    This filter is described in SeaBird Data Processing Manual (page 91).
%
%  Inputs:
%    inputSignal    - Signal to be filtered
%    timeConstant   - Duration of the filter (in s)
%    samplingPeriod - Sampling period of the input signal (in s)
%
%  Outputs:
%    outputSignal - inputSignal filtered with desired parameters
%
%  Example:
%    dataSize = 500;
%    samplingPeriod = 2;
%    time = (0:(dataSize-1))' * samplingPeriod;
%    originalSignal = 100 * (1 + sin(linspace(0, 2 * pi, dataSize)'));
%    someNoise      =  10 * (rand(dataSize, 1) - 0.5);
%    inputSignal    = originalSignal + someNoise;
%    outputSignal   = seabirdFilter(inputSignal, 4, samplingPeriod);
%    figure(1); clf;
%    plotHandle = ...
%       plot(time, originalSignal, 'k', ...
%            time, inputSignal,    'b', ...
%            time, outputSignal,   'r');
%    legend(plotHandle, 'original signal', 'noisy signal', 'filtered signal');
%    xlabel('Time (secs)');
%    ylabel('Depth (meters)');
%    title('Glider depth');
%
%  See also:
%    BUTTER
%    BUTTORD
%    CHEBY1
%    FILTER
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%  Dec 2010; Last revision: 23-Dec-2010
%
% Authors:
%   Bartolome Garau  <tomeu.garau@socib.es>

%  Copyright (C) 2013-2016
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
%  along with this program.  If not, see <http://www.gnu.org/licenses/>."

  % Store original size of input signal and
  % make sure it is a column vector (later will be flipped ud)
  origSize    = size(inputSignal);
  inputSignal = inputSignal(:);

  % Precompute some filter constants
  magicNumber = 2 * timeConstant / samplingPeriod;
  A = 1 / ( 1 + magicNumber);
  B = (1 - magicNumber) * A;

  % Pass the filter twice, first forward and then backward
  % to produce zero phase and thus avoid delays
  theSignal = inputSignal;
  for filterPass = 1:2
    outputSignal = theSignal;
    % Loop through the scans, recursive filter
    for scanIdx = 2:length(theSignal)
        outputSignal(scanIdx) = ...
            A .* (theSignal(scanIdx) + theSignal(scanIdx - 1)) -...
            B .* outputSignal(scanIdx - 1);
    end
    % Make the signal to be filtered the output
    % from the first filter pass, but turned upside down
    theSignal = flipud(outputSignal);
  end

  % The result from the second filter pass is in theSignal,
  % so reshape it to be same size as input signal
  outputSignal = reshape(theSignal, origSize);

end
