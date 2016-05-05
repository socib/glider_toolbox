function slocum_options = configRTFileOptionsSlocum()
%CONFIGRTFILEOPTIONSSLOCUM  Configure download, conversion and loading options for Slocum files in real time.
%
%  Syntax:
%    SLOCUM_OPTIONS = CONFIGRTFILEOPTIONSSLOCUM()
%
%  Description:
%    SLOCUM_OPTIONS = CONFIGRTFILEOPTIONSSLOCUM() should return a struct
%    with the parameters that control the files to retrieve, how they will 
%    be converted, and which files and data should be used in real time mode.
%    The returned struct should have the following fields:
%      LOG_NAME_PATTERN: string with the name pattern of surface log files as
%        needed by function GETDOCKSERVERFILES.
%        The name of a log file should match this pattern to be downloaded.
%      XBD_NAME_PATTERN: string with the name pattern of binary data files as
%        needed by function GETDOCKSERVERFILES and LOADSLOCUMDATA.
%        The name of a binary file should match this pattern to be downloaded,
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
%    slocum_options = configRTFileOptionsSlocum()
%
%  See also:
%    GETDOCKSERVERFILES
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
  
  % Surface log files of any kind:
  slocum_options.log_name_pattern = '^\w+_(modem|network|freewave)_\d{8}T\d{6}\.log$';

  % All binary files, renamed or not:
  % slocum_options.xbd_name_pattern = '^(.*)\.([smdtne]bd)$';
  % Already renamed binary files of all sizes:
  slocum_options.xbd_name_pattern = '^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$';
  
  % xbd to dba name replacement:
  slocum_options.dba_name_replace = '$1-$2.dba';
  
  % Navigation files to use (restrict the character set if needed):
  slocum_options.dba_name_pattern_nav = '^.*-[smd]bd\.dba$';
  
  % Science files to use: (restrict the character set if needed):
  slocum_options.dba_name_pattern_sci = '^.*-[tne]bd\.dba$';
  
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
  };
  
end
