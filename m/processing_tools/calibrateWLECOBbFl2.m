function [chlr, cdom, scat] = calibrateWLECOBbFl2(chlr_cnts, cdom_cnts, scat_cnts, chlr_coefs, cdom_coefs, scat_coefs)
%CALIBRATEWLECOBBFL2  Calibrate WET Labs ECO Triplet Puck.
%
%  Syntax:
%    [CHLR, CDOM, SCAT] = CALIBRATEWLECOBBFL2(CHLR_CNTS, CDOM_CNTS, SCAT_CNTS, CHLR_COEFS, CDOM_COEFS, SCAT_COEFS)
%
%  Description:
%    [CHLR, CDOM, SCAT] = CALIBRATEWLECOBBFL2(CHLR_CNTS, CDOM_CNTS, SCAT_CNTS, CHLR_COEFS, CDOM_COEFS, SCAT_COEFS) 
%    applies the affine transformation (scale and offset) described in WET Labs 
%    calibration sheet to convert raw measurements (counts) of chlorophyll 
%    concentration, CDOM concetration and scattering in arrays CHLR_CNTS, 
%    CDOM_CNTS and SCAT_CNTS to engineering units (ug l-1, ppb and  m-1 sr-1) 
%    in arrays CHLR, CDOM, SCAT, using the calibration coefficients in arrays 
%    or structs CHLR_COEFS, CDOM_COEFS and SCAT_COEFS.
%
%    The calibration equation of each signal is a simple offset and scale:
%      CHLR = CHLR_SF*(CHLR_CNTS - CHLR_DC)
%      CDOM = CDOM_SF*(CDOM_CNTS - CDOM_DC)
%      SCAT = SCAT_SF*(SCAT_CNTS - SCAT_DC)
%    where
%      CHLR_SF and CHLR_DC: chlorophyll scale factor and dark counts.
%        These should be fields of struct CHLR_COEFS, shortened to SF and DC,
%        or its elements if it is an array (in that order).
%      CDOM_SF and CDOM_DC: CDOM scale factor and dark counts.
%        These should be fields of struct CDOM_COEF, shortened to SF and DC,
%        or its elements if it is an array (in that order).
%      SCAT_SF and SCAT_DC: scattering scale factor and dark counts.
%        These should be fields of struct SCAT_COEFS, shortened to SF and DC,
%        or its elements if it is an array (in that order).
%
%  Notes:
%    The equations and coefficients are provided in the calibration sheets of
%    the ECO Triplet Puck shipped with Seaglider gliders. They also appear in 
%    the basestation file 'sg_calib_constants.m'.
%
%  Examples:
%    chlr_cnts = [50 51 51 57 63 80 83 83 81 72 68 67 64 57 56 54 52 51 50]
%    cdom_cnts = [45 49 50 50 51 56 57 59 57 60 57 61 58 58 58 57 57 60 56]
%    scat_cnts = [81 79 78 78 81 83 86 83 76 73 75 71 71 72 73 73 81 71 70]
%    chlr_coefs = [0.0118   38]
%    cdom_coefs = [0.0878   40]
%    scat_coefs = [3.51e-06 33]
%    [chlr, cdom, scat] = ...
%      calibrateWLECOBbFl2(chlr_cnts, cdom_cnts, scat_cnts, ...
%                          chlr_coefs, cdom_coefs, scat_coefs)
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

  error(nargchk(nargin, 6, 6, 'struct'));
  
  if isstruct(chlr_coefs)
    sd_chlr = [chlr_coefs.sf chlr_coefs.dc];
  else
    sd_chlr = chlr_coefs([1 2]);
  end
  if isstruct(cdom_coefs)
    sd_cdom = [cdom_coefs.sf cdom_coefs.dc];
  else
    sd_cdom = cdom_coefs([1 2]);
  end
  if isstruct(scat_coefs)
    sd_scat = [scat_coefs.sf scat_coefs.dc];
  else
    sd_scat = scat_coefs([1 2]);
  end
  
  chlr = sd_chlr(1)*(chlr_cnts - sd_chlr(2));
  cdom = sd_cdom(1)*(cdom_cnts - sd_cdom(2));
  scat = sd_scat(1)*(scat_cnts - sd_scat(2));

end
