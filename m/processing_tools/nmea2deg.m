function deg = nmea2deg(nmea)
%NMEA2DEG  Convert NMEA latitude/longitude degrees to decimal degrees.
%
%  DEG = NMEA2DEG(NMEA) Converts the scalar or array NMEA from NMEA
%  latitude/longitude degrees to decimal degrees applying the transformation:
%    
%  Examples:
%
%    nmea2deg(3330.00)
%    nmea = [36015.00 -445.25]
%    deg = nmea2deg(nmea)
%
%  See also:
%    FIX
%    REM
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 1, nargin, 'struct'));
  
  deg = fix(nmea/100) + rem(nmea,100)/60;

end
