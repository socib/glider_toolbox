function slocum_options = configDTFileOptionsSlocum()
%CONFIGDTFILEOPTIONSSLOCUM  Configure conversion and loading options for Slocum files in delayed time.
%
%  Syntax:
%    SLOCUM_OPTIONS = CONFIGDTFILEOPTIONSSLOCUM()
%
%  Description:
%    SLOCUM_OPTIONS = CONFIGDTFILEOPTIONSSLOCUM() should return a struct 
%    with the parameters that control which are the deployment files, 
%    whether they need to be converted, and which files and data should be used
%    in delayed time mode. The returned struct should have the following fields:
%      FORMAT_CONVERSION: boolean specifying whether data is in binary files
%        that should be converted to human readable format.
%      XBD_NAME_PATTERN: string with the name pattern of binary data files as
%        needed by script MAIN_GLIDER_DATA_PROCESSING_DT.
%        The name of a binary file should match this pattern to be converted,
%        and the conversion to ascii format renames it according to
%        this pattern and the replacement string in next field.
%      DBA_NAME_REPLACEMENT: string with the name pattern replacement to use
%        when converting binary files to ascii.
%      DBA_NAME_PATTERN_NAV: string with the name pattern of navigation ascii 
%        files to be loaded for processing by function LOADSLOCUMDATA.
%        The name of an ascii file should match this pattern to be loaded 
%        as a navigation file.
%      DBA_NAME_PATTERN_SCI: string with the name pattern of science ascii
%        files to be loaded for processing by function LOADSLOCUMDATA.
%        The name of an ascii file should match this pattern to be loaded
%        as a science file.
%      DBA_TIME_SENSOR_NAV: string with the name of the timestamp sensor to use
%        in navigation files when combining data from a set of ascii files.
%      DBA_TIME_SENSOR_SCI: string with the name of the timestamp sensor to use
%        in science files when combining data from a set of ascii files.
%      DBA_SENSORS: string cell array with the name of the sensors to include
%        in the processing. Restricting the list of sensors to load may reduce
%        the memory footprint.
%
%  Examples:
%    slocum_options = configDTFileOptionsSlocum()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    LOADSLOCUMDATA
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

  narginchk(0, 0);
  
  % Binary file conversion to text format
  % (disable it when reprocessing deployments with no new binary data):
  slocum_options.format_conversion = 1;
  
  % All binary files, renamed or not:
  % slocum_options.xbd_name_pattern = '^(.*)\.([smdtne]bd)$';
  % Already renamed binary files of all sizes:
  slocum_options.xbd_name_pattern = '^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$';
  
  % xbd to dba name replacement:
  slocum_options.dba_name_replace = '$1-$2.dba';
  
  % Navigation files to use (restrict the character set if needed):
  % slocum_options.dba_name_pattern_nav = '^.*-[smd]bd\.dba$';
  slocum_options.dba_name_pattern_nav = '^.*-dbd\.dba$';
  
  % Science files to use: (restrict the character set if needed):
  % slocum_options.dba_name_pattern_sci = '^.*-[tne]bd\.dba$';
  slocum_options.dba_name_pattern_sci = '^.*-ebd\.dba$';
  
  % Time sensor column in navigation files:
  slocum_options.dba_time_sensor_nav = 'm_present_time';
  
  % Time sensor column in science files:
  slocum_options.dba_time_sensor_sci = 'sci_m_present_time';
  
  % Sensors to load:
  slocum_options.dba_sensors = {
    'm_present_time'
    'm_lat'
    'm_lon'
    'm_gps_lat'
    'm_gps_lon'
    'm_gps_status'
    'c_wpt_lat'
    'c_wpt_lon'
    'm_roll'
    'm_pitch'
    'm_heading'
    'm_depth'
    'm_final_water_vx'
    'm_final_water_vy'
    'sci_m_present_time'
    'sci_ctd41cp_timestamp'
    'sci_water_pressure'
    'sci_water_cond'
    'sci_water_temp'
    'sci_flntu_chlor_units'
    'sci_flntu_turb_units'
    'sci_flntu_temp'
    'sci_flntu_timestamp'
    'sci_oxy3835_oxygen'
    'sci_oxy3835_saturation'
    'sci_oxy3835_temp'
    'sci_oxy3835_timestamp'
    'sci_oxy4_oxygen'
    'sci_oxy4_saturation'
    'sci_oxy4_temp'
    'sci_oxy4_timestamp'
    % Other sensors of technical interest:
    'c_air_pump'
    'c_alt_time'
    'c_battpos'
    'c_climb_target_depth'
    'c_de_oil_vol'
    'c_dive_target_depth'
    'c_fin'
    'c_flntu_on'
    'c_heading'
    'c_iridium_current_num'
    'c_iridium_on'
    'c_iridium_phone_num'
    'c_iridium_phone_num_alt'
    'c_oxy3835_on'
    'c_oxy4_on'
    'c_pitch'
    'c_profile_on'
    'c_science_on'
    'm_air_fill'
    'm_altimeter_status'
    'm_altitude'
    'm_argos_is_xmitting'
    'm_argos_on'
    'm_argos_sent_data'
    'm_avg_downward_inflection_time'
    'm_avg_speed'
    'm_avg_upward_inflection_time'
    'm_battery'
    'm_battery_inst'
    'm_battpos'
    'm_certainly_at_surface'
    'm_coulomb_amphr'
    'm_coulomb_amphr_total'
    'm_coulomb_current'
    'm_cycle_number'
    'm_de_oil_vol'
    'm_device_error'
    'm_device_oddity'
    'm_device_warning'
    'm_disk_usage'
    'm_dist_to_wpt'
    'm_fin'
    'm_free_heap'
    'm_gps_dist_from_dr'
    'm_gps_on'
    'm_initial_water_vx'
    'm_initial_water_vy'
    'm_iridium_call_num'
    'm_iridium_on'
    'm_iridium_status'
    'm_is_battpos_moving'
    'm_is_de_pump_moving'
    'm_leak'
    'm_mission_avg_speed_climbing'
    'm_mission_avg_speed_diving'
    'm_num_half_yos_in_segment'
    'm_pressure'
    'm_science_clothesline_lag'
    'm_science_on'
    'm_spare_heap'
    'm_stable_comms'
    'm_speed'
    'm_thermal_valve'
    'm_tot_horz_dist'
    'm_tot_num_inflections'
    'm_vacuum'
    'm_vacuum_air_pump_on'
    'm_water_cond'
    'm_water_delta_vx'
    'm_water_delta_vy'
    'm_water_depth'
    'm_water_pressure'
    'm_water_temp'
    'm_water_vx'
    'm_water_vy'
    'sci_flntu_chlor_ref'
    'sci_flntu_chlor_sig'
    'sci_flntu_temp'
    'sci_flntu_turb_ref'
    'sci_flntu_turb_sig'
    'sci_m_disk_usage'
    'sci_m_spare_heap'
    'u_alt_min_depth'
    'u_flntu_chlor_do'
    'u_flntu_chlor_sf'
    'u_flntu_turb_do'
    'u_flntu_turb_sf'
    'u_use_current_correction'
    'x_alt_time'
    'x_dr_state'
    'x_hit_a_waypoint'
    'x_inflecting'
    'x_last_wpt_lat'
    'x_last_wpt_lon'
    'x_mission_num'
    % Sensors for pressure adjustment test:
    'm_appear_to_be_at_surface'
    % 'm_certainly_at_surface'   % included in list of technical sensors
    'u_pressure_autocal_min_time_between'
    'u_pressure_autocal_enabled'
    'u_pressure_autocal_deadband'
    'u_pressure_autocal_max_allowed'
    'u_pressure_autocal_performed'
    'x_pressure_manual_cal_now'
    % Sensors involved in water velocity calculation:
    'm_dr_x_ini_err'
    'm_dr_y_ini_err'
    'm_dr_x_actual_err'
    'm_dr_y_actual_err'
    'm_dr_fix_time'
    'm_dr_postfix_time'
    'm_dr_time'
    'm_dr_x_postfix_drift'
    'm_dr_y_postfix_drift'
    'm_dr_x_ta_postfix_drift'
    'm_dr_y_ta_postfix_drift'
    'm_dr_surf_x_lmc'
    'm_dr_surf_y_lmc'
    'm_gps_fix_x_lmc'
    'm_gps_fix_y_lmc'
    'm_gps_postfix_x_lmc'
    'm_gps_postfix_y_lmc'
    'm_gps_utc_day'
    'm_gps_utc_month'
    'm_gps_utc_year'
    'm_gps_utc_hour'
    'm_gps_utc_minute'
    'm_gps_utc_second'
    'x_prior_seg_water_vx'
    'x_prior_seg_water_vy'
    % GFMR0058 Alnitak 2017 uses different names for variables (c_ballast_pumped and m_ballast_pumped)
    'm_ballast_pumped'       
    'c_ballast_pumped'
    'x_gps_reasonable_radius'
    'm_gps_dist_from_dr'
    'm_gps_num_satellites'
    'm_system_clock_lags_gps'
    'x_system_clock_adjusted'
    'u_max_lag_before_syncing_time'
    'c_weight_drop'
    'u_tickle_on_gps'
    'm_tot_on_time'
    'x_hardware_cop_timeout'
    'm_veh_temp'
    'm_veh_overheat'
  };
  
end
