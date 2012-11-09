function slocum_opts = configDTSlocumFileOptions()
%CONFIGDTSLOCUMFILEOPTIONS  Configure converting and loading options for Slocum files in delayed time.
%
%  SLOCUM_OPTS = CONFIGDTSLOCUMFILEOPTIONS() should return a struct with the
%  parameters that control which are the deployment files, whether they need to
%  be converted, and which files and data should be used in delayed time mode.
%  The returned struct should have the following fields:
%    FORMAT_CONVERSION: boolean specifying whether data is in binary files that
%      should be converted to human readable format.
%    BIN_NAME_PATTERN: string with the name pattern of binary data files as
%      needed by function CONVERTSLOCUMFILES. A remote binary file should match
%      this pattern to be converted.
%    DBA_NAME_REPLACEMENT: string with the name pattern replacement to use when
%      converting binary files to ascii.
%    DBA_NAME_PATTERN_NAV: string with the name pattern of navigation ascii 
%      files to be loaded for processing.
%    DBA_NAME_PATTERN_SCI: string with the name pattern of science ascii files
%      to be loaded for processing.
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
%    slocum_opts = configDTSlocumFileOptions()
%
%  See also:
%    CONVERTSLOCUMFILES
%    LOADSLOCUMDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  % Enable binary file conversion to text format.
  % Disable it when reprocessing deployments with no new binary data.
  slocum_opts.format_conversion = true;
  
  % All binary files, renamed or not:
  % slocum_opts.bin_name_pattern = '^(.*)\.([smdtne]bd)$';
  % Already renamed binary files of all sizes.
  slocum_opts.bin_name_pattern = '^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$';
  
  % xbd to dba name replacement.
  slocum_opts.dba_name_replacement = '$1_$2.dba';
  
  % Select navigation files to use. Restrict the character set if needed.
  slocum_opts.dba_name_pattern_nav = '^.*_[d]bd.dba$';
  
  % Select science files to use. Restrict the character set if needed.
  slocum_opts.dba_name_pattern_sci = '^.*_[e]bd.dba$';
  
  % Select time sensor column in navigation files.
  slocum_opts.dba_time_sensor_nav = 'm_present_time';
  
  % Select time sensor column in science files.
  slocum_opts.dba_time_sensor_sci = 'sci_m_present_time';
  
  % Sensors to load.
  slocum_opts.dba_sensors = {
    'm_present_time'
    'm_gps_lat'
    'm_gps_lon'
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
    'sci_ctd41cp_timestamp'
    'sci_m_present_time'
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
    'sci_oxy3835_oxygen'
    'sci_oxy3835_saturation'
    'sci_oxy3835_temp'
  };
  
end
