function outputSignal = seabirdFilter(inputSignal, timeConstant, samplingPeriod)
%SEABIRDFILTER - Applies a low-pass filter to an input signal
%
% The filter runs a low-pass filter on an input signal. A low-pass filter
% smoothes high frequency (rapidly changing) data. To produce zero phase
% (no time shift), the filter is first run forward through the data and then run
% backward through the data. This removes any delays caused by the filter.
% This filter is described in SeaBird Data Processing Manual (page 91).
%
% Syntax: outputSignal = seabirdFilter(inputSignal, timeConstant, samplingPeriod)
%
% Inputs:
%    inputSignal    - Signal to be filtered
%    timeConstant   - Duration of the filter (in s)
%    samplingPeriod - Sampling period of the input signal (in s)
%
% Outputs:
%    outputSignal - inputSignal filtered with desired parameters
%
% Example:
%
%    dataSize = 500;
%    samplingPeriod = 2;
%    time = (0:(dataSize-1))' * samplingPeriod;
%
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
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: BUTTER, BUTTORD, CHEBY1, FILTER

% Author: Bartolome Garau
% email: tomeu.garau@socib.es
% Website: http://www.socib.es
% Dec 2010; Last revision: 23-Dec-2010

%------------- BEGIN CODE --------------

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
        outputSignal = nan(size(theSignal));
        outputSignal(1) = theSignal(1);
        % Loop through the scans, recursive filter
        for scanIdx = 2:length(theSignal)
            outputSignal(scanIdx) = ...
                A .* (theSignal(scanIdx) + theSignal(scanIdx - 1)) -...
                B .* outputSignal(scanIdx - 1);
        end;
        % Make the signal to be filtered the output
        % from the first filter pass, but turned upside down
        theSignal = flipud(outputSignal);
    end;

    % The result from the second filter pass is in theSignal,
    % so reshape it to be same size as input signal
    outputSignal = reshape(theSignal, origSize);

end
