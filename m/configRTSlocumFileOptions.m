function slocum_opts = configRTSlocumFileOptions()
%CONFIGRTSLOCUMFILEOPTIONS  Configure downloading, converting and loading options for Slocum files in real time.
%
%  SLOCUM_OPTS = CONFIGRTSLOCUMFILEOPTIONS() should return a struct with the
%  parameters that control the files to retrieve, how they will be converted,
%  and which files and data should be used in real time mode. The returned 
%  struct should have the following fields:
%    LOG_NAME_PATTERN: string with the name pattern of surface log files as
%      needed by function GETDOCKSERVERFILES. A remote log file should match 
%      this should match to be downloaded.
%    BIN_NAME_PATTERN: string with the name pattern of binary data files as
%      needed by function GETDOCKSERVERFILES. A remote binary file should match
%      this pattern to be downloaded, and the conversion to ascii format renames
%      it according to this pattern and the replacement string in next field.
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
%    slocum_opts = configRTSlocumFileOptions()
%
%  See also:
%    GETDOCKSERVERFILES
%    LOADSLOCUMDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  % Surface log files of any kind.
  slocum_opts.log_name_pattern = '^\w+_(modem|network)_\d{8}T\d{6}\.log$';

  % All binary files, renamed or not:
  % slocum_opts.bin_name_pattern = '^(.*)\.([smdtne]bd)$';
  % Already renamed binary files of all sizes.
  slocum_opts.bin_name_pattern = '^(\w+-\d{4}-\d{1,3}-\d+-\d+)\.([smdtne]bd)$';
  
  % xbd to dba name replacement.
  slocum_opts.dba_name_replacement = '$1_$2.dba';
  
  % Select navigation files to use. Restrict the character set if needed.
  slocum_opts.dba_name_pattern_nav = '.*_[smd]bd.dba';
  
  % Select science files to use. Restrict the character set if needed.
  slocum_opts.dba_name_pattern_sci = '.*_[tne]bd.dba';
  
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
