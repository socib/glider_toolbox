function lag = computeTCLag(timeProfile, tempProfile, condProfile)
%COMPUTETCLAG - Compute time lag between Temperature and conductivity signals
% This function simulates a high frequency sampling, differenciates
% the input signals to remove trends, computes the cross-correlation
% between the T & C signals, and provides the lag at which the correlation
% is higher
%
% Syntax: lag = computeTCLag(timeProfile, tempProfile, condProfile)
%
% Inputs:
%    timeProfile - Description
%    tempProfile - Description
%    condProfile - Description
%
% Outputs:
%    lag - Description
%
% Example:
%    lag = computeTCLag(timeProfile, tempProfile, condProfile)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: CROSSCORR, DIFF, INTERP1
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%
    % Simulate we got data at 12Hz
    newTimeRange = min(timeProfile):(1/12):max(timeProfile);
    tempProfile = interp1(timeProfile, tempProfile, newTimeRange, 'cubic', 'extrap');
    condProfile = interp1(timeProfile, condProfile, newTimeRange, 'cubic', 'extrap');
    
    % Differenciate to remove low freqs, trends, etc.
    dTemp = diff(tempProfile);
    dCond = diff(condProfile);

    % Find the lag correlation with a moving window
    windowLength = 144; % 12Hz data - 12 seconds time lag
    for iniWin = 1:(length(dTemp)-windowLength),
        r = iniWin:(iniWin+windowLength-1);
        crosscorr(dTemp(r), dCond(r));
        [XCF,Lags] = crosscorr(dTemp, dCond);
        [~, idx] = max(XCF);
        lag(iniWin + floor(windowLength/2)) = Lags(idx); %#ok<AGROW>
    end;

return;
