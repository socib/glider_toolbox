function outputProfile = correctTimeResponse(inputProfile, inputTime, timeConstant)
%CORRECTTIMERESPONSE - Corrects the sensor lag time response of a given input
% This function "advances" an input signal in time, depending on the 
% specified time constant of the sensor that measured it
%
% Syntax: outputProfile = correctTimeResponse(inputProfile, inputTime, timeConstant)
%
% Inputs:
%    inputProfile - A vector of values from a sensor
%    inputTime - A vector of times at which the measurements were performed
%    timeConstant - The parameter that defines the sensor lag
%
% Outputs:
%    outputProfile - A vector of values, sensor lag corrected
%
% Example:
%    outputProfile = correctTimeResponse(inputProfile, inputTime, timeConstant)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: DIFF
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

    % Compute first derivative of input profile wrt time
    deltaProfile = [0; diff(inputProfile)./diff(inputTime)];
    
    % Apply the correction Vout = Vin + tau * 
    outputProfile = inputProfile + timeConstant .* deltaProfile;
    
end