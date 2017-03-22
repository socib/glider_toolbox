function preprocessing_options = configDataPreprocessingSeaglider()
%CONFIGDATAPREPROCESSINGSEAGLIDER  Configure Seaglider glider data preprocessing.
%
%  Syntax:
%    PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSINGSEAGLIDER()
%
%  Description:
%    PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSINGSEAGLIDER() should return 
%    a struct setting the options for Seaglider glider data preprocessing 
%    as needed by the function PREPROCESSGLIDERDATA.
%
%  Examples:
%    preprocessing_options = configDataPreprocessingSeaglider()
%
%  See also:
%    PREPROCESSGLIDERDATA
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(0, 0, nargin, 'struct'));
  
  preprocessing_options = struct();
  
  preprocessing_options.sg_dive_params = { ...
    'TGT_LATLONG_tgt_lon' 'TGT_LATLONG_tgt_lat' ...
    'CURRENT_cur_dir' 'CURRENT_cur_spd' 'CURRENT_cur_val' };
  
  preprocessing_options.time_list(1).time = 'elaps_t';
  
  preprocessing_options.position_list(1).longitude = 'GPSFIX_fixlon';
  preprocessing_options.position_list(1).latitude  = 'GPSFIX_fixlat';
  preprocessing_options.position_list(1).conversion = @nmea2deg;
  preprocessing_options.position_list(1).date = 'GPSFIX_ddmmyy';
  preprocessing_options.position_list(1).time = 'GPSFIX_hhmmss';
  preprocessing_options.position_list(1).time_conversion = ...
    @(d,t)(utc2posixtime(fillSGMissingGPSDate(d,t)));
  
  preprocessing_options.depth_list(1).depth = 'depth';
  preprocessing_options.depth_list(1).conversion = @cm2m;
  
  preprocessing_options.attitude_list(1).roll = 'rollAng';
  preprocessing_options.attitude_list(1).pitch = 'pitchAng';
  preprocessing_options.attitude_list(1).conversion = @deg2rad;
  
  preprocessing_options.heading_list(1).heading = 'head';
  preprocessing_options.heading_list(1).conversion = @deg2rad;

  preprocessing_options.waypoint_list(1).longitude = 'TGT_LATLONG_tgt_lon';
  preprocessing_options.waypoint_list(1).latitude = 'TGT_LATLONG_tgt_lat';
  preprocessing_options.waypoint_list(1).conversion = @nmea2deg;
  
  preprocessing_options.water_velocity_list(1).velocity_eastward  = 'CURRENT_cur_spd';
  preprocessing_options.water_velocity_list(1).velocity_northward = 'CURRENT_cur_dir';
  preprocessing_options.water_velocity_list(1).conversion = @sgcur2cart;
  
  preprocessing_options.ctd_list(1).conductivity = 'sbect_condFreq';
  preprocessing_options.ctd_list(1).temperature  = 'sbect_tempFreq';
  preprocessing_options.ctd_list(1).pressure     = 'depth';
  preprocessing_options.ctd_list(1).pressure_conversion = @sgdepth2pres;
  preprocessing_options.ctd_list(1).calibration = @calibrateSBECT;
  
  preprocessing_options.oxygen_list(1).oxygen_concentration = 'aa1_O2';
  preprocessing_options.oxygen_list(1).oxygen_saturation    = 'aa1_AirSat';
  preprocessing_options.oxygen_list(1).temperature          = 'aa1_Temp';
  
  preprocessing_options.optics_list(1).chlorophyll = 'wl1_Chlsig1';
  preprocessing_options.optics_list(1).cdom        = 'wl1_Cdomsig1';
  preprocessing_options.optics_list(1).scatter_650 = 'wl1_sig1';
  preprocessing_options.optics_list(1).calibration = 'calibrateWLECOBbFl2';
  preprocessing_options.optics_list(2).chlorophyll = 'wlbbfl2vmt_Chlsig';
  preprocessing_options.optics_list(2).cdom        = 'wlbbfl2vmt_Cdomsig';
  preprocessing_options.optics_list(2).scatter_650 = 'wlbbfl2vmt_wl650sig';  
  preprocessing_options.optics_list(2).calibration = 'calibrateWLECOBbFl2';
  preprocessing_options.optics_list(3).chlorophyll = 'wlbbfl2vmt_Chlsig';
  preprocessing_options.optics_list(3).cdom        = 'wlbbfl2vmt_Cdomsig';
  preprocessing_options.optics_list(3).scatter_650 = 'wlbbfl2vmt_wl600sig';  
  preprocessing_options.optics_list(3).calibration = 'calibrateWLECOBbFl2';
  
  preprocessing_options.extra_sensor_list = struct();

end

