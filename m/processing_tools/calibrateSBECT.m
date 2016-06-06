function [temp, cond] = calibrateSBECT(temp_freq, cond_freq, pres, temp_coefs, cond_coefs)
%CALIBRATESBECT  Calibrate Seabird Electronics CT sail.
%
%  Syntax:
%    [TEMP, COND] = CALIBRATESBECT(TEMP_FREQ, COND_FREQ, PRES, TEMP_COEFS, COND_COEFS)
%
%  Description:
%    [TEMP, COND] = CALIBRATESBECT(TEMP_FREQ, COND_FREQ, PRES, TEMP_COEFS, COND_COEFS) 
%    applies the equations described in Seabird Electronics calibration sheet
%    to convert the temperature and conductivity raw measurements (Hz) in arrays
%    TEMP_FREQ and COND_FREQ to engineering units (ITS90 ºC and Siemens/m)
%    in arrays TEMP and COND, using the pressure readings in PRES (dbar) and the 
%    calibration coefficients in arrays or structs TEMP_COEFS and COND_COEFS.
%
%    The calibration equations are:
%      TEMP = 1/(T_G + T_H*ln(1/F_T) + T_I*ln(1/F_T)^2 + T_J*ln(1/F_T)^3) - 273.15
%      COND = 0.1*(C_G + C_H*F_C^2 + C_I*F_C^3 + C_J*F_C^4)/(1 + CTCOR*TEMP + CPCOR*PRES)
%    where
%      F_T: temperature signal frequency in kHz (TEMP_FREQ * 1e-3).
%      F_C: conductivity signal frequency in kHz (COND_FREQ * 1e-3).
%      T_G, T_H, T_I, T_J: temperature calibration coefficients.
%        These should be fields of struct TEMP_COEFS or its elements if it 
%        is an array (in that order).
%      C_G, C_H, C_I, C_J, CTCOR, CPCOR: conductivity calibration coefficients.
%        These should be fields of struct COND_COEFS or its elements if it 
%        is an array (in that order).
%
%  Notes:
%    The equations and coefficients are provided in the calibration sheets of
%    the CT sails shipped with Seaglider gliders. They also appear in the
%    basestation file 'sg_calib_constants.m'.
%
%  Examples:
%    temp_true = [1.0      4.5     15.0     18.5     24.0     29.0     32.5     ]
%    cond_true = [2.97836  3.28569  4.26827  4.61375  5.17227  5.69472  6.06756 ]
%    pres = 0;
%    temp_freq = [3387.875 3668.209 4609.999 4959.066 5544.757 6117.756 6542.459]
%    cond_freq = [5987.16  6214.10  6888.93  7110.73  7455.09  7763.03  7975.39 ]
%    temp_coefs = [ 4.38052489e-3  6.25478746e-4  2.34258763e-5  2.50671271e-6]
%    cond_coefs = [-9.92304872     1.11163373    -2.02979731e-3  2.29265437e-4 -9.57e-8  3.25e-6]
%    [temp, cond] = calibrateSBECT(temp_freq, cond_freq, pres, temp_coefs, cond_coefs)
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
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
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(nargin, 5, 5, 'struct'));
  
  if isstruct(temp_coefs)
    jihg_temp = [temp_coefs.t_j temp_coefs.t_i temp_coefs.t_h temp_coefs.t_g];
  else
    jihg_temp = temp_coefs([4 3 2 1]);
  end
  
  if isstruct(cond_coefs)
    jih0g_cond = [cond_coefs.c_j cond_coefs.c_i cond_coefs.c_h 0 cond_coefs.c_g];
    ctcor = cond_coefs.ctcor;
    cpcor = cond_coefs.cpcor;
  else
    jih0g_cond = [cond_coefs([4 3 2]) 0 cond_coefs(1)];
    ctcor = cond_coefs(5);
    cpcor = cond_coefs(6);
  end
  
  temp = 1 ./ polyval(jihg_temp, log(1000 ./ temp_freq)) - 273.15;
  cond = 0.1 * ...
    polyval(jih0g_cond, cond_freq ./ 1000) ./ (1 + ctcor * temp + cpcor * pres);

end
