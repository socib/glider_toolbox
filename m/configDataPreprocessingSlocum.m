function options = configDataPreprocessingSlocum()
%CONFIGDATAPREPROCESSINGSLOCUM  Configure Slocum glider data preprocessing.
%
%  Syntax:
%    OPTIONS = CONFIGDATAPREPROCESSINGSLOCUM()
%
%  OPTIONS = CONFIGDATAPREPROCESSINGSLOCUM() should return a struct setting the
%  options for Slocum glider data preprocessing as needed by the function
%  PREPROCESSGLIDERDATA.
%
%  Examples:
%    options = configDataPreprocessingSlocum()
%
%  See also:
%    PREPROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013-2014
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
  
  options.time_list(1).time = 'm_present_time';
  options.time_list(2).time = 'sci_m_present_time';
  
  options.position_list(1).longitude = 'm_gps_lon';
  options.position_list(1).latitude  = 'm_gps_lat';
  options.position_list(1).conversion = @nmea2deg;
  options.position_list(1).position_status = 'm_gps_status';
  options.position_list(1).position_good = 0;
  options.position_list(2).longitude = 'm_lon';
  options.position_list(2).latitude  = 'm_lat';
  options.position_list(2).conversion = @nmea2deg;
  
  options.depth_list.depth = 'm_depth';
  
  options.attitude_list(1).roll = 'm_roll';
  options.attitude_list(1).pitch = 'm_pitch';
  
  options.heading_list.heading = 'm_heading';

  options.waypoint_list(1).longitude = 'c_wpt_lon';
  options.waypoint_list(1).latitude = 'c_wpt_lat';
  options.waypoint_list(1).conversion = @nmea2deg;
  
  options.water_velocity_list(1).velocity_eastward  = 'm_final_water_vx';
  options.water_velocity_list(1).velocity_northward = 'm_final_water_vy';
  
  options.ctd_list(1).conductivity = 'sci_water_cond';
  options.ctd_list(1).temperature  = 'sci_water_temp';
  options.ctd_list(1).pressure     = 'sci_water_pressure';
  options.ctd_list(1).time         = 'sci_ctd41cp_timestamp';
  options.ctd_list(1).pressure_conversion = @bar2dbar;
  
  options.ctd_list(2).conductivity = 'm_water_cond';
  options.ctd_list(2).temperature  = 'm_water_temp';
  options.ctd_list(2).pressure     = 'm_water_pressure';
  options.ctd_list(2).time         = [];
  options.ctd_list(2).pressure_conversion = @bar2dbar;

  options.oxygen_list(1).oxygen_concentration = 'sci_oxy3835_oxygen';
  options.oxygen_list(1).oxygen_saturation    = 'sci_oxy3835_saturation';
  options.oxygen_list(1).temperature          = 'sci_oxy3835_temp';
  options.oxygen_list(1).time                 = 'sci_oxy3835_timestamp';
  
  options.optics_list(1).chlorophyll = 'sci_flntu_chlor_units';
  options.optics_list(1).turbidity   = 'sci_flntu_turb_units';
  options.optics_list(1).time        = 'sci_flntu_timestamp';
  
  options.extra_sensor_list = struct();
    
end

