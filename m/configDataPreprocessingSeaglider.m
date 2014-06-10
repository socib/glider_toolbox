function options = configDataPreprocessingSeaglider()
%CONFIGDATAPREPROCESSINGSEAGLIDER  Configure Seaglider glider data preprocessing.
%
%  Syntax:
%    OPTIONS = CONFIGDATAPREPROCESSINGSEAGLIDER()
%
%  OPTIONS = CONFIGDATAPREPROCESSINGSEAGLIDER() should return a struct setting 
%  the options for Seaglider glider data preprocessing as needed by the function
%  PREPROCESSGLIDERDATA.
%
%  Examples:
%    options = configDataPreprocessingSeaglider()
%
%  See also:
%    PREPROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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
  
  options = struct();
  
  options.sg_dive_params = { ...
    'TGT_LATLONG_tgt_lon' 'TGT_LATLONG_tgt_lat' ...
    'CURRENT_cur_dir' 'CURRENT_cur_spd' 'CURRENT_cur_val' };
  
  options.time_list(1).time = 'elaps_t';
  
  options.position_list(1).longitude = 'GPSFIX_fixlon';
  options.position_list(1).latitude  = 'GPSFIX_fixlat';
  options.position_list(1).conversion = @nmea2deg;
  options.position_list(1).date = 'GPSFIX_ddmmyy';
  options.position_list(1).time = 'GPSFIX_hhmmss';
  options.position_list(1).time_conversion = ...
    @(d,t)(utc2posixtime(fillSGMissingGPSDate(d,t)));
  
  options.depth_list = struct('depth', {});
  
  options.attitude_list(1).roll = 'rollAng';
  options.attitude_list(1).pitch = 'pitchAng';
  options.attitude_list(1).conversion = @deg2rad;
  
  options.heading_list.heading = 'head';
  options.attitude_list(1).conversion = @deg2rad;

  options.waypoint_list(1).longitude = 'TGT_LATLONG_tgt_lon';
  options.waypoint_list(1).latitude = 'TGT_LATLONG_tgt_lat';
  options.waypoint_list(1).conversion = @nmea2deg;
  
  options.water_velocity_list(1).velocity_eastward  = 'CURRENT_cur_spd';
  options.water_velocity_list(1).velocity_northward = 'CURRENT_cur_dir';
  options.water_velocity_list(1).conversion = @sgcur2cart;
  
  options.ctd_list(1).conductivity = 'sbect_condFreq';
  options.ctd_list(1).temperature  = 'sbect_tempFreq';
  options.ctd_list(1).pressure     = 'depth';
  options.ctd_list(1).time         = 'sci_ctd41cp_timestamp';
  options.ctd_list(1).pressure_conversion = @sgdepth2pres;
  options.ctd_list(1).calibration = @calibrateSBECT;
  
  options.oxygen_list(1).oxygen_concentration = 'aa1_O2';
  options.oxygen_list(1).oxygen_saturation    = 'aa1_AirSat';
  options.oxygen_list(1).temperature          = 'aa1_Temp';
  
  options.optics_list(1).chlorophyll = 'wl1_Chlsig1';
  options.optics_list(1).cdom        = 'wl1_Cdomsig1';
  options.optics_list(1).scatter_650 = 'wl1_sig1';
  options.optics_list(1).calibration = 'calibrateWLECOBbFl2';
  
  options.extra_sensor_list = struct();
    
end

