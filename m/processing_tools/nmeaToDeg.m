function degreesValue = nmeaToDeg(nmeaValue)
%NMEATODEG - Converts a NMEA float number to decimal degrees
% This function converts the input value from NMEA format to decimal
% degrees, assuming NMEA value will be <degrees>*100 + <decimal minutes>
%
% Syntax: degreesValue = nmeaToDeg(nmeaValue)
%
% Inputs:
%    nmeaValue - coordinate value expressed in NMEA format deg * 100 + min
%
% Outputs:
%    degreesValue - decimal degrees value
%
% Example:
%    degreesValue = nmeaToDeg(3930.000) will provide an output 39.
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: SIGN, ABS, FLOOR
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 21-Feb-2011
%
    valSign = sign(nmeaValue);
    absVal  = abs(nmeaValue);
    valDeg  = floor(absVal / 100);
    valMin  = (absVal - valDeg * 100);
    degreesValue = valSign .* (valDeg + valMin / 60);
    degreesValue(absVal > 18000) = nan;

    return;
