function slocum_options = configDTFileOptionsSlocum()
%CONFIGDTFILEOPTIONSSLOCUM  Configure conversion and loading options for Slocum files in delayed time.
%
%  SLOCUM_OPTIONS = CONFIGDTFILEOPTIONSSLOCUM() should return a struct with the
%  parameters that control which are the deployment files, whether they need to
%  be converted, and which files and data should be used in delayed time mode.
%  The returned struct should have the following fields:
%    FORMAT_CONVERSION: boolean specifying whether data is in binary files that
%      should be converted to human readable format.
%    BIN_NAME_PATTERN: string with the name pattern of binary data files as
%      needed by script MAIN_GLIDER_DATA_PROCESSING_DT. A binary file should 
%      match this pattern to be converted, and the conversion to ascii format 
%      renames it according to this pattern and the replacement string in next 
%      field.
%    DBA_NAME_REPLACEMENT: string with the name pattern replacement to use when
%      converting binary files to ascii.
%    DBA_NAME_PATTERN_NAV: string with the name pattern of navigation ascii 
%      files to be loaded for processing by function LOADSLOCUMDATA. An ascii 
%      file should match this pattern to be loaded as a navigation file.
%    DBA_NAME_PATTERN_SCI: string with the name pattern of science ascii files
%      to be loaded for processing by LOADSLOCUMDATA. An ascii file should match
%      this pattern to be loaded as a science file by function LOADSLOCUMDATA.
%    DBA_TIME_SENSOR_NAV: string with the name of the timestamp sensor to use in
%      navigation files when combining data from different ascii files.
%    DBA_TIME_SENSOR_SCI: string with the name of the timestamp sensor to use in
%      science files when combining data from different ascii files.
%    DBA_SENSORS: string cell array with the name of the sensors to be included
%      in the processing. Restricting the list of sensors to load may reduce the
%      memory footprint.
%
%  Notes:
%
%  Examples:
%    slocum_options = configDTFileOptionsSlocum()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    LOADSLOCUMDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  % Enable binary file conversion to text format.
  % Disable it when reprocessing deployments with no new binary data.
  slocum_options.format_conversion = false;
  
  % All binary files, renamed or not:
  % slocum_options.bin_name_pattern = '^(.*)\.([smdtne]bd)$';
  % Already renamed binary files of all sizes.
  slocum_options.bin_name_pattern = '^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$';
  
  % xbd to dba name replacement.
  slocum_options.dba_name_replacement = '$1-$2.dba';
  
  % Select navigation files to use. Restrict the character set if needed.
  slocum_options.dba_name_pattern_nav = '^.*-[d]bd.dba$';
  
  % Select science files to use. Restrict the character set if needed.
  slocum_options.dba_name_pattern_sci = '^.*-[e]bd.dba$';
  
  % Select time sensor column in navigation files.
  slocum_options.dba_time_sensor_nav = 'm_present_time';
  
  % Select time sensor column in science files.
  slocum_options.dba_time_sensor_sci = 'sci_m_present_time';
  
  % Sensors to load.
  slocum_options.dba_sensors = {
    'm_present_time'
    'm_lat'
    'm_lon'
    'm_gps_lat'
    'm_gps_lon'
    'm_gps_status'
    'c_wpt_lat'
    'c_wpt_lon'
    'm_pitch'
    'm_depth'
    'm_final_water_vx'
    'm_final_water_vy'
    'x_dr_state'
    'u_flntu_chlor_do'
    'u_flntu_turb_do'
    'u_flntu_chlor_sf'
    'u_flntu_turb_sf'
    'sci_m_present_time'
    'sci_ctd41cp_timestamp'
    'sci_water_pressure'
    'sci_water_cond'
    'sci_water_temp'
    'sci_flntu_chlor_ref'
    'sci_flntu_chlor_sig'
    'sci_flntu_chlor_units'
    'sci_flntu_temp'
    'sci_flntu_turb_ref'
    'sci_flntu_turb_sig'
    'sci_flntu_turb_units'
    'sci_flntu_timestamp'
    'sci_oxy3835_oxygen'
    'sci_oxy3835_saturation'
    'sci_oxy3835_temp'
    'sci_oxy3835_timestamp'
  };
  
end
