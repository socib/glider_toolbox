function processing_options = configDataProcessing()
%CONFIGDATAPROCESSING  Configure glider data processing.
%
%  PROCESSING_OPTIONS = CONFIGDATAPROCESSING() should return a struct setting 
%  the options for glider data processing as needed by the function
%  PROCESSGLIDERDATA.
%
%  Examples:
%    preprocessing_options = configDataProcessing()
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
  
  processing_options = struct();
  
  processing_options.time_sensor_list = {'m_present_time' 'sci_m_present_time'};
  
  processing_options.position_sensor_list(1).latitude  = 'm_gps_lat';
  processing_options.position_sensor_list(1).longitude = 'm_gps_lon';
  processing_options.position_sensor_list(2).latitude  = 'm_lat';
  processing_options.position_sensor_list(2).longitude = 'm_lon';
  
  processing_options.depth_sensor_list = {'m_depth'};
  
  processing_options.pitch_sensor_list = {'m_pitch'};
  
  processing_options.waypoint_sensor_list(1).latitude = 'c_wpt_lat';
  processing_options.waypoint_sensor_list(1).longitude = 'c_wpt_lon';
  
  processing_options.water_velocity_sensor_list(1).velocity_eastward  = 'm_final_water_vx';
  processing_options.water_velocity_sensor_list(1).velocity_northward = 'm_final_water_vy';
  
  processing_options.ctd_sensor_list(1).conductivity = 'sci_water_cond';
  processing_options.ctd_sensor_list(1).temperature  = 'sci_water_temp';
  processing_options.ctd_sensor_list(1).pressure     = 'sci_water_pressure';
  processing_options.ctd_sensor_list(1).time         = 'sci_ctd41cp_timestamp';
  processing_options.ctd_sensor_list(2).conductivity = 'm_water_cond';
  processing_options.ctd_sensor_list(2).temperature  = 'm_water_temp';
  processing_options.ctd_sensor_list(2).pressure     = 'm_water_pressure';
  processing_options.ctd_sensor_list(2).time         = [];

  processing_options.flntu_sensor_list(1).chlorophyll = 'sci_flntu_chlor_units';
  processing_options.flntu_sensor_list(1).turbidity = 'sci_flntu_turb_units';
  
  processing_options.oxygen_sensor_list(1).oxygen_concentration = 'sci_oxy3835_oxygen';
  processing_options.oxygen_sensor_list(1).oxygen_saturation = 'sci_oxy3835_saturation';
  
  processing_options.extra_sensor_list = struct();
  
  processing_options.time_filling = true;
  processing_options.position_filling = true;
  processing_options.depth_filling = true;
  processing_options.pitch_filling = true;
  processing_options.waypoint_filling = true;
  
  processing_options.pressure_conversion = true;
  processing_options.pressure_filtering = true;
  processing_options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  processing_options.depth_ctd_derivation = true;
  
  processing_options.profiling_sequence = {'depth_ctd' 'depth'};
  processing_options.profiling_sequence_filling = true;
  processing_options.profile_min_range = 10;
  processing_options.profile_max_gap_ratio = 0.8;
  
  processing_options.sensor_lag_list = ...
     struct('corrected', {}, 'original', {}, 'parameters', {});
  
  processing_options.thermal_lag_list(1).conductivity_corrected = 'conductivity_corrected_thermal';
  processing_options.thermal_lag_list(1).temperature_corrected  = 'temperature_corrected_thermal';
  processing_options.thermal_lag_list(1).conductivity_original  = 'conductivity';
  processing_options.thermal_lag_list(1).temperature_original   = 'temperature';
  processing_options.thermal_lag_list(1).pressure_original      = 'pressure';
  processing_options.thermal_lag_list(1).parameters             = 'auto';

  processing_options.salinity_list(1).salinity     = 'salinity';
  processing_options.salinity_list(1).conductivity = 'conductivity';
  processing_options.salinity_list(1).temperature  = 'temperature';
  processing_options.salinity_list(1).pressure     = 'pressure';
  processing_options.salinity_list(2).salinity     = 'salinity_corrected_thermal';
  processing_options.salinity_list(2).conductivity = 'conductivity';
  processing_options.salinity_list(2).temperature  = 'temperature_corrected_thermal';
  processing_options.salinity_list(2).pressure     = 'pressure';
  
  processing_options.density_list(1).density     = 'density';
  processing_options.density_list(1).salinity    = 'salinity';
  processing_options.density_list(1).temperature = 'temperature';
  processing_options.density_list(1).pressure    = 'pressure';
  processing_options.density_list(2).density     = 'density_corrected_thermal';
  processing_options.density_list(2).salinity    = 'salinity_corrected_thermal';
  processing_options.density_list(2).temperature = 'temperature';
  processing_options.density_list(2).pressure    = 'pressure';

end
