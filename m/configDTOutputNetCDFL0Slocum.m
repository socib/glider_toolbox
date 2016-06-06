function ncl0_info = configDTOutputNetCDFL0Slocum()
%CONFIGDTOUTPUTNETCDFL0  Configure NetCDF output for raw Slocum glider deployment data in delayed time.
%
%  Syntax:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SLOCUM()
%
%  Description:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SLOCUM() should return a struct
%    describing the structure of the NetCDF file for raw Slocum glider
%    deployment data in delayed time (see the note about the file generation).
%    The returned struct should have the following fields:
%      DIMENSIONS: struct array with fields 'NAME' and 'LENGTH' defining the
%        dimensions for variables in the file.
%        A variable may have dimensions not listed here or with their length
%        left undefined (empty field value), and they are inferred from the
%        data during the generation of the file. However, it is useful to preset
%        the length of a dimension for record or string size dimensions.
%      ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining global
%        attributes of the file.
%        Global attributes might be overwritten by deployment fields
%        with the same name.
%      VARIABLES: struct defining variable metadata. Field names are variable
%        names and field values are structs as needed by function SAVENC.
%        It should have the following fields:
%          DIMENSIONS: string cell array with the names of the dimensions
%            of the variable.
%          ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining
%            the attributes of the variable.
%        More variables than the ones present in one specific deployment may be
%        described here. Only metadata corresponding variables in the deployment
%        data will be used.
%
%  Notes:
%    The NetCDF file will be created by the function GENERATEOUTPUTNETCDF with
%    the structure provided here and the metadata and data returned by
%    LOADSLOCUMDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl0_info = configDTOutputNetCDFL0Slocum()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
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

  error(nargchk(0, 0, nargin, 'struct'));

  %% Define variable information.
  % To define the variable attributes easily and readably, add the corresponding
  % variable field to the struct defined below, with its attributes defined in
  % a cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.

  default_fill_value = realmax('double');

  % Navigation time.
  var_attr_list.m_present_time = {
    'long_name'     'epoch time (navigation board)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % Navigation data.
  var_attr_list.m_lat = {
    'long_name'     'latitude (dead reckoned)'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.m_lon = {
    'long_name'     'longitude (dead reckoned)'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_lat = {
    'long_name'     'GPS latitude'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_lon = {
    'long_name'     'GPS longitude'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_status = {
    'long_name'     'GPS status'
    'units'         '1'
    'comment'       '0 = good fix, >0 = no fix'
    '_FillValue'    default_fill_value };

  var_attr_list.c_wpt_lat = {
    'long_name'     'next waypoint latitude'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.c_wpt_lon = {
    'long_name'     'next waypoint longitude'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.m_depth = {
    'long_name'     'glider measured depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    '_FillValue'    default_fill_value };

  var_attr_list.m_pressure = {
    'long_name'     'glider measured pressure'
    'standard_name' 'pressure'
    'units'         'bar'
    '_FillValue'    default_fill_value };

  var_attr_list.m_roll = {
    'long_name'     'glider roll'
    'units'         'rad'
    'comment'       'greater than 0 is port wing up'
    '_FillValue'    default_fill_value };

  var_attr_list.m_pitch = {
    'long_name'     'glider pitch'
    'units'         'rad'
    '_FillValue'    default_fill_value };

  var_attr_list.m_heading = {
    'long_name'     'glider heading'
    'units'         'rad'
    '_FillValue'    default_fill_value };

  var_attr_list.c_heading = {
    'long_name'     'glider commanded heading'
    'units'         'rad'
    '_FillValue'    default_fill_value };

  var_attr_list.m_speed = {
    'long_name'     'glider speed through water'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_fin = {
    'long_name'     'glider rudder'
    'units'         'rad'
    '_FillValue'    default_fill_value };

  var_attr_list.x_inflecting = {
    'long_name'     'glider inflecting marker'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_num_half_yos_in_segment = {
    'long_name'     'glider half yos number in segment'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_tot_num_inflections = {
    'long_name'     'total number of inflections'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_battery = {
    'long_name'     'battery voltage'
    'units'         'V'
    '_FillValue'    default_fill_value };

  var_attr_list.m_vacuum = {
    'long_name'     'vacuum'
    'units'         'inHg'
    '_FillValue'    default_fill_value };

  var_attr_list.m_leakdetect_voltage = {
    'long_name'     'leak detector'
    'units'         'V'
    'comment'       '2.5V means no leak; voltage drops if leak detected'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_call_num = {
    'long_name'     'number of iridium calls'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_connected = {
    'long_name'     'iridium connected'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_dialed_num = {
    'long_name'     'number of iridium dials'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.x_dr_state = {
    'long_name'     'dead reckoning state'
    'units'         '1'
    'comment'       '0 = mission_start, 1 = underwater, 2 = awaiting_fix, 3 = awaiting_postfix, 4 = awaiting_dive'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_fix_time = {
    'long_name'     'surface-to-fix elapsed time'
    'units'         's'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_postfix_time = {
    'long_name'     'fix-to-postfix elapsed time'
    'units'         's'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_surf_x_lmc = {
    'long_name'     'dead reckoned x surface location in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_surf_y_lmc = {
    'long_name'     'dead reckoned y surface location in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_time = {
    'long_name'     'dead reckoning time'
    'units'         's'
    'comment'       'time elapsed underwater subject to currents'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_x_actual_err = {
    'long_name'     'estimated actual dead reckoning x error in local mission coordinates'
    'units'         's'
    'comment'       'initial dead reckoning error minus estimated surface drift'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_x_ini_err = {
    'long_name'     'initial dead reckoning x error in local mission coordinates'
    'units'         'm'
    'comment'       'distance between dead reckoned surface location and initial GPS fix'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_x_postfix_drift = {
    'long_name'     'fix-to-postfix x drift in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_x_ta_postfix_drift = {
    'long_name'     'time-adjsuted fix-to-postfix x drift in local mission coordinates'
    'units'         's'
    'comment'       'used to account for surface drift in averaged sea water velocity computation'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_y_actual_err = {
    'long_name'     'estimated actual dead reckoning y error in local mission coordinates'
    'units'         's'
    'comment'       'initial dead reckoning error minus estimated surface drift'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_y_ini_err = {
    'long_name'     'initial dead reckoning y error in local mission coordinates'
    'units'         'm'
    'comment'       'distance between dead reckoned surface location and initial GPS fix'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_y_postfix_drift = {
    'long_name'     'fix-to-postfix y drift in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_y_ta_postfix_drift = {
    'long_name'     'time-adjsuted fix-to-postfix y drift in local mission coordinates'
    'units'         's'
    'comment'       'used to account for surface drift in averaged sea water velocity computation'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_fix_x_lmc = {
    'long_name'     'x GPS fix in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_fix_y_lmc = {
    'long_name'     'y GPS fix in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_postfix_x_lmc = {
    'long_name'     'x GPS postfix in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_postfix_y_lmc = {
    'long_name'     'y GPS postfix in local mission coordinates'
    'units'         'm'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_day = {
    'long_name'     'day component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_hour = {
    'long_name'     'hour component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_minute = {
    'long_name'     'minute component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_month = {
    'long_name'     'month component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_second = {
    'long_name'     'second component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_utc_year = {
    'long_name'     'year component of GPS timestamp'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_vx = {
    'long_name'     'eastward water current'
    'standard_name' 'eastward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_vy = {
    'long_name'     'northward water current'
    'standard_name' 'northward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_initial_water_vx = {
    'long_name'     'initial eastward water current'
    'standard_name' 'eastward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_initial_water_vy = {
    'long_name'     'initial northward water current'
    'standard_name' 'northward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_final_water_vx = {
    'long_name'     'final eastward water current'
    'standard_name' 'eastward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_final_water_vy = {
    'long_name'     'final northward water current'
    'standard_name' 'northward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_delta_vx = {
    'long_name'     'delta eastward water current'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_delta_vy = {
    'long_name'     'delta northward water current'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.x_prior_seg_water_vx = {
    'long_name'     'prior segment eastward water current'
    'standard_name' 'eastward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.x_prior_seg_water_vy = {
    'long_name'     'prior segment northward water current'
    'standard_name' 'northward_sea_water_velocity'
    'units'         'm s-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_depth = {
    'long_name'     'bathymetry'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    '_FillValue'    default_fill_value };

  % Navigation CTD.
  var_attr_list.m_water_temp = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_cond = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_pressure = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'bar'
    '_FillValue'    default_fill_value };

  % Science time.
  var_attr_list.sci_m_present_time = {
    'long_name'     'epoch time (science bay)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % Science CTD.
  var_attr_list.sci_water_temp = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_water_cond = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_water_pressure = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'bar'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ctd41cp_timestamp = {
    'long_name'     'epoch time (CTD sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % BB3SLO sensor.
  var_attr_list.sci_bb3slo_b470_ref = {
    'long_name'     'blue backscattering refersence'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b470_sig = {
    'long_name'     'blue backscattering signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b470_scaled = {
    'long_name'     'blue backscattering'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b532_ref = {
    'long_name'     'green backscattering reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b532_sig = {
    'long_name'     'green backscattering signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b532_scaled = {
    'long_name'     'green backscattering'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b660_ref = {
    'long_name'     'red backscattering reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b660_sig = {
    'long_name'     'red backscattering signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b660_scaled = {
    'long_name'     'red backscattering'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_temp = {
    'long_name'     'temperature (BB3SLO sensor)'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_timestamp = {
    'long_name'     'epoch time (BB3SLO sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b470_do = {
    'long_name'     'blue backscattering dark water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b532_do = {
    'long_name'     'green backscattering dark water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b660_do = {
    'long_name'     'red backscattering dark water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b470_sf = {
    'long_name'     'blue backscattering scale factor'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b532_sf = {
    'long_name'     'green backscattering scale factor'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bb3slo_b660_sf = {
    'long_name'     'red backscattering scale factor'
    'units'         '1'
    '_FillValue'    default_fill_value };

  % BBFL2S sensor.
  var_attr_list.sci_bbfl2s_bb_ref = {
    'long_name'     'backscattering reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_bb_sig = {
    'long_name'     'backscattering signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_bb_scaled = {
    'long_name'     'backscattering'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_cdom_ref = {
    'long_name'     'CDOM reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_cdom_sig = {
    'long_name'     'CDOM signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_cdom_scaled = {
    'long_name'     'CDOM'
    'units'         'ppb'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_chlor_ref = {
    'long_name'     'chlorophyll reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_chlor_sig = {
    'long_name'     'chlorophyll signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_chlor_scaled = {
    'long_name'     'chlorophyll'
    'standard_name' 'concentration_of_chlorophyll_in_sea_water'
    'units'         'mg m-3'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_temp = {
    'long_name'     'temperature (BBFL2S sensor)'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_timestamp = {
    'long_name'     'epoch time (BBFL2S sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_bb_cwo = {
    'long_name'     'backscattering clean water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_cdom_cwo = {
    'long_name'     'CDOM clean water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_chlor_cwo = {
    'long_name'     'chlorophyll clean water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_bb_sf = {
    'long_name'     'backscattering scale factor'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_cdom_sf = {
    'long_name'     'cdom scale factor'
    'units'         'ppb'
    '_FillValue'    default_fill_value };

  var_attr_list.u_bbfl2s_chlor_sf = {
    'long_name'     'chlorophyll scale factor'
    'units'         '1'
    '_FillValue'    default_fill_value };

  % OCR504I sensor.
  var_attr_list.sci_ocr504I_irrad1 = {
    'long_name'     'irradiance at 412nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad2 = {
    'long_name'     'irradiance at 442nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad3 = {
    'long_name'     'irradiance at 491nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad4 = {
    'long_name'     'irradiance at 664nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    '_FillValue'    default_fill_value };

  % FLNTU sensor.
  var_attr_list.sci_flntu_chlor_ref = {
    'long_name'     'chlorophyll reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_chlor_sig = {
    'long_name'     'chlorophyll signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_chlor_units = {
    'long_name'     'chlorophyll'
    'standard_name' 'concentration_of_chlorophyll_in_sea_water'
    'units'         'mg m-3'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_ref = {
    'long_name'     'turbidity reference'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_sig = {
    'long_name'     'turbidity signal'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_units = {
    'long_name'     'turbidity'
    'standard_name' 'turbidity'
    'units'         'NTU'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_temp = {
    'long_name'     'temperature (FLNTU sensor)'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_timestamp = {
    'long_name'     'epoch time (FLNTU sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_chlor_do = {
    'long_name'     'chlorophyll dark water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_turb_do = {
    'long_name'     'turbidity dark water offset'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_chlor_sf = {
    'long_name'     'chlorophyll scale factor'
    'units'         'mg m-3'
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_turb_sf = {
    'long_name'     'turbidity scale factor'
    'units'         'NTU'
    '_FillValue'    default_fill_value };

  % OXY3835 sensor (Aanderaa Oxygen Optode 3835).
  var_attr_list.sci_oxy3835_oxygen = {
    'long_name'     'oxygen concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy3835_saturation = {
    'long_name'     'oxygen saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy3835_temp = {
    'long_name'     'temperature (OXY3835 sensor)'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy3835_timestamp = {
    'long_name'     'epoch time (OXY3835 sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % OXY4 sensor (Aanderaa Oxygen Optode 4330F or 4831).
  var_attr_list.sci_oxy4_oxygen = {
    'long_name'     'oxygen concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy4_saturation = {
    'long_name'     'oxygen saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy4_temp = {
    'long_name'     'temperature (OXY4 sensor)'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy4_timestamp = {
    'long_name'     'epoch time (OXY4 sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % Other sensors of technical interest:
  var_attr_list.c_air_pump = {
    'long_name'     'air pump bladder'
    'units'         '1'
    'comment'       '<0 turns it off regardless, 0 turns it off unless thermal or deep electric engine needs it, >0 turns it on'
    '_FillValue'    default_fill_value };

  var_attr_list.c_alt_time = {
    'long_name'     'altimeter intersample time'
    'units'         's'
    'comment'       '<0 is off, =0 as fast as possible, >0 that many seconds betweens measurements'
    '_FillValue'    default_fill_value };

  var_attr_list.c_battpos = {
    'long_name'     'battery position'
    'units'         'in'
    'comment'       '>0 vehicle dives (nose down)'
    '_FillValue'    default_fill_value };

  var_attr_list.c_climb_target_depth = {
    'long_name'     'climb target depth'
    'units'         'm'
    'comment'       'value of b_arg for climb target depth'
    '_FillValue'    default_fill_value };

  var_attr_list.c_de_oil_vol = {
    'long_name'     'commanded oil'
    'units'         'cc'
    'comment'       '>0, goes up'
    '_FillValue'    default_fill_value };

  var_attr_list.c_dive_target_depth = {
    'long_name'     'dive target depth'
    'units'         'm'
    'comment'       'value of b_arg for dive target depth'
    '_FillValue'    default_fill_value };

  var_attr_list.c_fin = {
    'long_name'     'commanded fin position'
    'units'         'rad'
    'comment'       '>0 vehicle turns right'
    '_FillValue'    default_fill_value };

  var_attr_list.c_flntu_on = {
    'long_name'     'optical Sensor flntu toggle'
    'units'         's'
    'comment'       'commanded seconds between measurements: <0 stopped, 0 as fast as possible, >0 that many secons'
    '_FillValue'    default_fill_value };

  var_attr_list.c_iridium_current_num = {
    'long_name'     'current Iridium phone number'
    'units'         '1'
    'comment'       '0 = primary 1 = secondary'
    '_FillValue'    default_fill_value };

  var_attr_list.c_iridium_on = {
    'long_name'     'Iridium phone toggle'
    'units'         '1'
    'comment'       '<=0 turns it off, 1 turns it on, becomes 2nd console when connected, 2 turns it on, no 2nd console, 3 turns it on in "send data" mode, 4 turns it on in "echo data" mode'
    '_FillValue'    default_fill_value };

  var_attr_list.c_iridium_phone_num = {
    'long_name'     'primary Iridium phone number'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.c_iridium_phone_num_alt = {
    'long_name'     'alternative Iridium phone number'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.c_oxy3835_on = {
    'long_name'     'optical OXY3835 sensor toggle'
    'units'         's'
    'comment'       'commanded seconds between measurements: <0 stopped, 0 as fast as possible, >0 that many seconds'
    '_FillValue'    default_fill_value };

  var_attr_list.c_oxy4_on = {
    'long_name'     'optical OXY4 sensor toggle'
    'units'         's'
    'comment'       'commanded seconds between measurements: <0 stopped, 0 as fast as possible, >0 that many seconds'
    '_FillValue'    default_fill_value };

  var_attr_list.c_pitch = {
    'long_name'     'commanded pitch'
    'units'         'rad'
    'comment'       '<0 to dive'
    '_FillValue'    default_fill_value };

  var_attr_list.c_profile_on = {
    'long_name'     'intersample time cycles'
    'units'         's'
    'comment'       '<0 is off, =0 as fast as possible, >0 that many seconds between measurements'
    '_FillValue'    default_fill_value };

  var_attr_list.c_science_on = {
    'long_name'     'science board toggle'
    'units'         '1'
    'comment'       'nonzero turns on science uart'
    '_FillValue'    default_fill_value };

  var_attr_list.c_thermal_valve = {
    'long_name'     'commanded oil pump valve'
    'units'         '1'
    'comment'       '1=valve up, 2=valve charge, 3=valve down'
    '_FillValue'    default_fill_value };

  var_attr_list.c_weight_drop = {
    'long_name'     'weight drop toggle (Jettison)'
    'units'         '1'
    'comment'       '!=0 drop the weight'
    '_FillValue'    default_fill_value };

  var_attr_list.f_fin_safety_max = {
    'long_name'     'digifin range'
    'units'         'rad'
    'comment'       '>0.47 damage to glider'
    '_FillValue'    default_fill_value };

  var_attr_list.m_air_fill = {
    'long_name'     'measured air fill status'
    'units'         '1'
    'comment'       '1=air pump solenoid in fill position'
    '_FillValue'    default_fill_value };

  var_attr_list.m_altimeter_status = {
    'long_name'     'measured altimeter status'
    'units'         '1'
    'comment'       '0 good reading, otherwise rejected'
    '_FillValue'    default_fill_value };

  var_attr_list.m_altimeter_voltage = {
    'long_name'     'measured altimeter voltage'
    'units'         'V'
    'comment'       'voltage read from the A/D'
    '_FillValue'    default_fill_value };

  var_attr_list.m_altitude = {
    'long_name'     'measured altitude'
    'units'         'm'
    'comment'       'height above the bottom'
    '_FillValue'    default_fill_value };

  var_attr_list.m_appear_to_be_at_surface = {
    'long_name'     'glider at surface guess'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_argos_is_xmitting = {
    'long_name'     'measured Argos transmission status'
    'units'         '1'
    'comment'       '>0 = PTT is radiating'
    '_FillValue'    default_fill_value };

  var_attr_list.m_argos_on = {
    'long_name'     'measured Argos toggle status'
    'units'         '1'
    'comment'       '>0 means Argos is actually turned on'
    '_FillValue'    default_fill_value };

  var_attr_list.m_argos_sent_data = {
    'long_name'     'measured Argos sent data status'
    'units'         '1'
    'comment'       '> 0 means data was sent to PTT'
    '_FillValue'    default_fill_value };

  var_attr_list.m_avg_downward_inflection_time = {
    'long_name'     'downward inflection time'
    'units'         's'
    'comment'       'exponential average of inflections (start with reasonable guess)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_avg_speed = {
    'long_name'     'measured horizontal average speed'
    'units'         'm s-1'
    'comment'       'average vehicle horizontal speed through water, used only when computing commanded heading to waypoint'
    '_FillValue'    default_fill_value };

  var_attr_list.m_avg_upward_inflection_time = {
    'long_name'     'upward inflection time'
    'units'         's'
    'comment'       'exponential average of inflections (start with reasonable guess)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_battery_inst = {
    'long_name'     'measured battery instantaneous voltage'
    'units'         'V'
    '_FillValue'    default_fill_value };

  var_attr_list.m_battpos = {
    'long_name'     'measured battery position'
    'units'         'in'
    'comment'       '>0 vehicle dives (nose down)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_certainly_at_surface = {
    'long_name'     'glider at surface certain guess'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_cop_tickle = {
    'long_name'     'COP tickle watchdog'
    'units'         '1'
    'comment'       '1=COP tickled'
    '_FillValue'    default_fill_value };

  var_attr_list.m_coulomb_amphr = {
    'long_name'     'measured integrated current'
    'units'         'A h-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_coulomb_amphr_total = {
    'long_name'     'persistant measured integrated current'
    'units'         'A h-1'
    '_FillValue'    default_fill_value };

  var_attr_list.m_coulomb_current = {
    'long_name'     'measured instantaneous current'
    'units'         'A'
    '_FillValue'    default_fill_value };

  var_attr_list.m_cycle_number = {
    'long_name'     'cycle number'
    'units'         '1'
    'comment'       'cycle number since mission started'
    '_FillValue'    default_fill_value };

  var_attr_list.m_de_oil_vol = {
    'long_name'     'measured oil pump volume'
    'units'         'cm3'
    'comment'       'calibrated from m_de_oil_vol_pot_voltage'
    '_FillValue'    default_fill_value };

  var_attr_list.m_device_error = {
    'long_name'     'glider error number'
    'units'         '1'
    'comment'       'device number of offending device whenever it generates error'
    '_FillValue'    default_fill_value };

  var_attr_list.m_device_oddity = {
    'long_name'     'glider oddity number'
    'units'         '1'
    'comment'       'number of offending device whenever it generates oddity'
    '_FillValue'    default_fill_value };

  var_attr_list.m_device_warning = {
    'long_name'     'glider warning number'
    'units'         '1'
    'comment'       'device number of offending device whenever it generates warning'
    '_FillValue'    default_fill_value };

  var_attr_list.m_disk_free = {
    'long_name'     'navigation disk free space'
    'units'         'MiB'
    'comment'       'disk space currently free on navigation disk'
    '_FillValue'    default_fill_value };

  var_attr_list.m_disk_usage = {
    'long_name'     'navigation disk used space'
    'units'         'MiB'
    'comment'       'disk space currently used on navigation disk'
    '_FillValue'    default_fill_value };

  var_attr_list.m_dist_to_wpt = {
    'long_name'     'distance to next waypoint'
    'units'         'm'
    'comment'       'distance to (c_wpt_x_lmc, c_wpt_y_lmc)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_free_heap = {
    'long_name'     'free heap space'
    'units'         'B'
    'comment'       'amount of heap space currently free'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_dist_from_dr = {
    'long_name'     'distance from calculated position (dead reckoning distance)'
    'units'         'm'
    'comment'       'distance to fix from dead reckoned position'
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_on = {
    'long_name'     'measured GPS toggle status'
    'units'         '1'
    'comment'       '>0 GPS actually enabled'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_attempt_num = {
    'long_name'     'Iridium phone call number'
    'units'         '1'
    'comment'       'number of retries for the current Iridium phone number (should be initialized to 1)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_on = {
    'long_name'     'Iridium toggle status'
    'units'         '1'
    'comment'       '0=off, 1=on'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_signal_strength = {
    'long_name'     'Iridium quality signal'
    'units'         '1'
    'comment'       'Iridium received signal strength indication (RSSI)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_status = {
    'long_name'     'Iridium status'
    'units'         '1'
    'comment'       '0 = MODEM_NO_CARRIER, 1 = MODEM_OK, 2 = MODEM_CONNECT, 3 = MODEM_ERROR , 4 = MODEM_NO_ANSWER , 5 = MODEM_BUSY , 6 = MODEM_NO_DIALTONE , 7 = LOGGING_IN , 8 = LOGGED_ON , 10 = MODEM_AWAITING_OK , 11 = MODEM_AWAITING_CONNECTION , 12 = MODEM_TIMEOUT , 99 = MODEM_UNKNOWN , 100 = NO_CHARS_TIMEOUT'
    '_FillValue'    default_fill_value };

  var_attr_list.m_is_battpos_moving = {
    'long_name'     'measured battery in motion status'
    'units'         '1'
    'comment'       '1 = motor is moving'
    '_FillValue'    default_fill_value };

  var_attr_list.m_is_de_pump_moving = {
    'long_name'     'measured oil pump in motion status'
    'units'         '1'
    'comment'       '1 = motor is moving'
    '_FillValue'    default_fill_value };

  var_attr_list.m_leak = {
    'long_name'     'leak detection'
    'units'         '1'
    'comment'       'whether m_leakdetect_voltage_aft < f_leakdetect_threshold'
    '_FillValue'    default_fill_value };

  var_attr_list.m_mission_avg_speed_climbing = {
    'long_name'     'average climbing speed'
    'units'         'm s-1'
    'comment'       'running average of computed m_speed since start of mission'
    '_FillValue'    default_fill_value };

  var_attr_list.m_mission_avg_speed_diving = {
    'long_name'     'average diving speed'
    'units'         'm s-1'
    'comment'       'running average of computed m_speed since start of mission'
    '_FillValue'    default_fill_value };

  var_attr_list.m_mission_start_time = {
    'long_name'     'mission start epoch time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  var_attr_list.m_present_secs_into_mission = {
    'long_name'     'seconds in mission'
    'units'         's'
    'comment'       'time elapsed since mission started'
    '_FillValue'    default_fill_value };

  var_attr_list.m_science_clothesline_lag = {
    'long_name'     'science time lag'
    'units'         's'
    'comment'       'How far behind science is M_PRESENT_TIME - SCI_M_PRESENT_TIME'
    '_FillValue'    default_fill_value };

  var_attr_list.m_science_on = {
    'long_name'     'science board toggle status'
    'units'         '1'
    'comment'       'actual power state of science uart'
    '_FillValue'    default_fill_value };

  var_attr_list.m_science_sent_some_data = {
    'long_name'     'science board sent data status'
    'units'         '1'
    'comment'       'incremented when the glider pulls a character out of the clothesline buffer where chars received from science processor are stored.'
    '_FillValue'    default_fill_value };

  var_attr_list.m_spare_heap = {
    'long_name'     'measured spare heap space'
    'units'         'B'
    'comment'       'projected amount of heap space if every big consumer is activated'
    '_FillValue'    default_fill_value };

  var_attr_list.m_stable_comms = {
    'long_name'     'stable communications status'
    'units'         '1'
    'comment'       '1 = communications are stable (had m_console_cd for reqd number of secs in a row)'
    '_FillValue'    default_fill_value };

  var_attr_list.m_thermal_valve = {
    'long_name'     'measured oil pump valve status'
    'units'         '1'
    'comment'       '-3=moving to down, -2=moving to charge, -1=moving to up, 0=unknown, 1=valve up, 2=valve charge, 3=valve down'
    '_FillValue'    default_fill_value };

  var_attr_list.m_tot_horz_dist = {
    'long_name'     'total horizontal distance'
    'units'         'km'
    'comment'       'distance coverted underwater'
    '_FillValue'    default_fill_value };

  var_attr_list.m_vacuum_air_pump_on = {
    'long_name'     'air pump toggle initial pressure'
    'units'         'inHg'
    'comment'       'initial value of m_vacuum when air pump is turned on AND depth < u_max_depth_for_air_pump_est'
    '_FillValue'    default_fill_value };

  var_attr_list.m_why_started = {
    'long_name'     'glider start event'
    'units'         '1'
    'comment'       '128 = External (the reset button), 64 = Power-On, 32 = Software Watchdog, 16 = Dbl Bus Fault, 4 = Loss of Clock, 2 = RESET instruction, 1 = Test Submodule, 255 = Uninitialized'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_m_disk_free = {
    'long_name'     'science disk free space'
    'units'         'MiB'
    'comment'       'disk space currently free on science disk'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_m_disk_usage = {
    'long_name'     'science disk used space'
    'units'         'MiB'
    'comment'       'disk space currently used on science disk'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_m_free_heap = {
    'long_name'     'science free heap space'
    'units'         'bytes'
    'comment'       'amount of heap space currently free'
    '_FillValue'    default_fill_value };

  var_attr_list.sci_m_spare_heap = {
    'long_name'     'science measured spare heap space'
    'units'         'B'
    'comment'       'projected amount of heap space if every big consumer is activated'
    '_FillValue'    default_fill_value };

  var_attr_list.u_alt_min_depth = {
    'long_name'     'altimeter depth trigger'
    'units'         'm'
    'comment'       'minimum depth glider must be to use altitude'
    '_FillValue'    default_fill_value };

  var_attr_list.u_max_altimeter = {
    'long_name'     'altimeter maximum range'
    'units'         'm'
    'comment'       'altimeter reading must be between u_min_altimeter and u_max_altimeter'
    '_FillValue'    default_fill_value };

  var_attr_list.u_min_altimeter = {
    'long_name'     'altimeter minimum range'
    'units'         'm'
    'comment'       'altimeter reading must be between u_min_altimeter and u_max_altimeter'
    '_FillValue'    default_fill_value };

  var_attr_list.u_pressure_autocal_min_time_between = {
    'long_name'     'minimum time between automatic pressure calibrations'
    'units'         's'
    '_FillValue'    default_fill_value };

  var_attr_list.u_pressure_autocal_enabled = {
    'long_name'     'automatic pressure calibration switch'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.u_pressure_autocal_deadband = {
    'long_name'     'automatic pressure calibration threshold'
    'units'         'bar'
    '_FillValue'    default_fill_value };

  var_attr_list.u_pressure_autocal_max_allowed = {
    'long_name'     'automatic pressure calibration oddity threshold'
    'units'         'bar'
    '_FillValue'    default_fill_value };

  var_attr_list.u_pressure_autocal_performed = {
    'long_name'     'automatic pressure calibration flag'
    'units'         '1'
    'comment'       '1 = auto calibration done, 2 = manual calibration done, -1 = excessive pressure drift (calibration not done)'
    '_FillValue'    default_fill_value };

  var_attr_list.u_stable_comms_reqd_secs = {
    'long_name'     'stable communications required threshold'
    'units'         's'
    'comment'       'continuous seconds of carrier detect required to have stable communications'
    '_FillValue'    default_fill_value };

  var_attr_list.u_use_current_correction = {
    'long_name'     'use current correction toggle'
    'units'         '1'
    'comment'       '0 = calculate but do not use m_water_vx/y, 1 = use m_water_vx/y to navigate and aim'
    '_FillValue'    default_fill_value };

  var_attr_list.x_alt_time = {
    'long_name'     'altimeter intersample time'
    'units'         's'
    'comment'       'calculated c_alt_time value <0 altimeter off, =0 as fast as possible, >0 that many seconds between measurements'
    '_FillValue'    default_fill_value };

  var_attr_list.x_cycle_time = {
    'long_name'     'calculated cycle time'
    'units'         's'
    'comment'       'either u_cycle_time or u_low_power_cycle_time'
    '_FillValue'    default_fill_value };

  var_attr_list.x_hardware_cop_timeout = {
    'long_name'     'hardware cop timeout'
    'units'         'h'
    'comment'       'state of jumper: -1 = can not tell, >=RevE will be 2 or 16'
    '_FillValue'    default_fill_value };

  var_attr_list.x_hit_a_waypoint = {
    'long_name'     'waypoint hit event'
    'units'         '1'
    'comment'       'set by behavior when reach a waypoint'
    '_FillValue'    default_fill_value };

  var_attr_list.x_last_wpt_lat = {
    'long_name'     'latitude coordinate of last achieved waypoint'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.x_last_wpt_lon = {
    'long_name'     'longitude coordinate of last achieved waypoint'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.x_low_power_status = {
    'long_name'     'low power status'
    'units'         '1'
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.x_mission_num = {
    'long_name'     'last mission number'
    'units'         '1'
    'comment'       'YYDDxx the current or last mission number, old style before switch to DBD scheme kept for Argos'
    '_FillValue'    default_fill_value };

  var_attr_list.x_pressure_manual_cal_now = {
    'long_name'     'manual pressure calibration trigger'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.x_surface_active = {
    'long_name'     'active surface behavior status'
    'units'         '1'
    'comment'       'id of active surface behavior (>0 = active)'
    '_FillValue'    default_fill_value };


  %% Define global attributes (they may be overwritten with deployment values).
  % To define the global attributes easily and readably, add them to this
  % cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.
  global_atts = ...
  {
    'abstract'                     '' % deployment_description
    'acknowledgement'              '' % deployment_acknowledgement
    'author'                       '' % deployment_author
    'author_email'                 '' % deployment_author_email
    'cdm_data_type'                'Trajectory'
    'citation'                     '' % deployment_citation
    'comment'                      'Data provided as it comes from the glider.'
    'Conventions'                  'CF-1.6'
    'creator'                      '' % deployment_author
    'creator_email'                '' % deployment_author_email
    'creator_url'                  '' % deployment_author_url
    'data_center'                  '' % deployment_data_center
    'data_center_email'            '' % deployment_data_center_email
    'data_mode'                    'delayed time'
    'date_modified'                'undefined'
    'featureType'                  'trajectory'
    'geospatial_lat_max'           'undefined'
    'geospatial_lat_min'           'undefined'
    'geospatial_lat_units'         'undefined'
    'geospatial_lon_max'           'undefined'
    'geospatial_lon_min'           'undefined'
    'geospatial_lon_units'         'undefined'
    'history'                      sprintf('Product generated by the glider toolbox version %s (https://github.com/socib/glider_toolbox).', configGliderToolboxVersion())
    'institution'                  '' % institution_name
    'institution_references'       '' % institution_references
    'instrument'                   '' % instrument_name
    'instrument_manufacturer'      '' % instrument_manufacturer
    'instrument_model'             '' % instrument_model
    'license'                      'Approved for public release. Distribution Unlimited.' % deployment_distribution_statement
    'netcdf_version'               '4.0.1'
    'positioning_system'           'GPS and dead reckoning'
    'principal_investigator'       '' % deployment_principal_investigator
    'principal_investigator_email' '' % deployment_principal_investigator_email
    'processing_level'             'L0 raw data not calibrated'
    'project'                      '' % deployment_project
    'publisher'                    '' % deployment_publisher_name
    'publisher_email'              '' % deployment_publisher_email
    'publisher_url'                '' % deployment_publisher_url
    'source'                       'glider'
    'source_files'                 'undefined' % source_files field set by processing script after loading data.
    'standard_name_vocabulary'     'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/16/cf-standard-name-table.html'
    'summary'                      '' % deployment_description
    'time_coverage_end'            'undefined'
    'time_coverage_start'          'undefined'
    'title'                        'Glider deployment delayed time raw data'
    'transmission_system'          'IRIDIUM'
  };


  %% Define preset dimensions.
  time_dimension = struct('name', {'time'}, 'length', {0});


  %% Return global and variable metadata in the correct format.
  ncl0_info = struct();
  % Set the dimensions.
  ncl0_info.dimensions = time_dimension;
  % Set the global attributes.
  ncl0_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  % Set the variable metadata.
  ncl0_info.variables = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    ncl0_info.variables.(var_name).dimensions = {time_dimension.name};
    ncl0_info.variables.(var_name).attributes = ...
      cell2struct(var_atts, {'name' 'value'}, 2);
  end

end
