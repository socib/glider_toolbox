function ncl0_info = configDTOutputNetCDFL0Seaglider()
%CONFIGDTOUTPUTNETCDFL0SEAGLIDER  Configure NetCDF output for raw Seaglider glider deployment data in delayed time.
%
%  Syntax:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SEAGLIDER()
%
%  Description:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SEAGLIDER() should return a struct
%    describing the structure of the NetCDF file for raw Seaglider glider
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
%    LOADSEAGLIDERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl0_info = configDTOutputNetCDFL0Seaglider()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
%    LOADSEAGLIDERDATA
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

  var_attr_list.AD7714Ch0Gain = {
    'long_name'     'pressure sensor gain'
    'units'         '1'
    'comment'       'Gain assigned to the pressure sensor channel on the AD7714 analog-to-digital converter.'
    '_FillValue'    default_fill_value };

  var_attr_list.AH0_10V = {
    'long_name'     'low voltage battery pack capacity'
    'units'         'A h'
    'comment'       'Capacity of the 10V (low voltage) battery pack (AmpHr).'
    '_FillValue'    default_fill_value };

  var_attr_list.AH0_24V = {
    'long_name'     'high voltage battery pack capacity'
    'units'         'A h'
    'comment'       'Capacity of the 24V (high voltage) battery pack (AmpHr).'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_BOTTOM_PING_dpth = {
    'long_name'     'glider depth at altimeter ping'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth of the glider when performing bottom ping.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_BOTTOM_PING_rnge = {
    'long_name'     'altimeter detected bottom range'
    'units'         'm'
    'comment'       'Altimeter-detected distance to bottom during bottom ping.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_BOTTOM_PING_RANGE = {
    'long_name'     'altimeter bottom range to ping'
    'standard_name' 'distance'
    'units'         'm'
    'comment'       'Range from the presumed apogee depth to ping for the bottom.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_BOTTOM_TURN_MARGIN = {
    'long_name'     'altimeter bottom turn marging'
    'standard_name' 'distance'
    'units'         'm'
    'comment'       'Distance from the altimeter detected range at which to initiate the apogee maneuver.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_FREQUENCY = {
    'long_name'     'altimeter ping frequency'
    'standard_name' 'frequency'
    'units'         'kHz'
    'comment'       'Frequency to use for altimeter pings.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_PING_DELTA = {
    'long_name'     'altimeter ping depth interval'
    'units'         'm'
    'comment'       'Depth interval to repeat ping after a failed altimeter return or confirmation ping return.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_PING_DEPTH = {
    'long_name'     'altimeter depth to ping'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth of the first altimeter ping.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_PULSE = {
    'long_name'     'altimeter pulse width'
    'units'         'ms'
    'comment'       'Pulse width of altimeter pings.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_SENSITIVITY = {
    'long_name'     'altimeter envelope detector sensitivity'
    'units'         'V'
    'comment'       'Sensitivity of the envelope detector on the altimeter.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_TOP_MIN_OBSTACLE = {
    'long_name'     'altimeter subsurface minimum obstacle depth'
    'units'         'm'
    'comment'       'Minimum obstacle depth to honor in initiating a subsurface finish.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_TOP_PING_RANGE = {
    'long_name'     'altimeter surface range to ping'
    'units'         'm'
    'comment'       'Range from the surface at which to ping the altimeter.'
    '_FillValue'    default_fill_value };

  var_attr_list.ALTIM_TOP_TURN_MARGIN = {
    'long_name'     'altimeter top turn marging'
    'units'         'm'
    'comment'       'Distance from the altimeter detected range at which to initiate the apogee maneuver.'
    '_FillValue'    default_fill_value };

  var_attr_list.APOGEE_PITCH = {
    'long_name'     'apogee phase pitch'
    'units'         'degree'
    'comment'       'Intermediate pitch (position of the pitch mass) that Seaglider pitches to between the dive and climb phases to prevent stalling.'
    '_FillValue'    default_fill_value };

  var_attr_list.CALLS = {
    'long_name'     'number of calls'
    'units'         '1'
    'comment'       'Total calls in an attempt to connect on previous dive surfacing.'
    '_FillValue'    default_fill_value };

  var_attr_list.CALL_NDIVES = {
    'long_name'     'call dive step'
    'units'         '1'
    'comment'       'Number of profiles (dive/climb cycles) to perform before attempting communications.'
    '_FillValue'    default_fill_value };

  var_attr_list.CALL_TRIES = {
    'long_name'     'call maximum attempts'
    'units'         '1'
    'comment'       'Maximum number of phone calls to attempt during a surfacing between dives.'
    '_FillValue'    default_fill_value };

  var_attr_list.CALL_WAIT = {
    'long_name'     'call wait time'
    'units'         's'
    'comment'       'wait time between call attempts during a communication session.'
    '_FillValue'    default_fill_value };

  var_attr_list.CAPMAXSIZE = {
    'long_name'     'capture file maximum size'
    'units'         'bytes'
    'comment'       'Maximum size of the capture file to upload (prior to compression).'
    '_FillValue'    default_fill_value };

  var_attr_list.CAPUPLOAD = {
    'long_name'     'capture file upload flag'
    'units'         '1'
    'comment'       'Whether upload capture file (0 = do not upload cap file, 1 = upload cap file).'
    '_FillValue'    default_fill_value };

  var_attr_list.CAP_FILE_SIZE_field01 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 01 of CAP_FILE_SIZE log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.CAP_FILE_SIZE_field02 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 02 of CAP_FILE_SIZE log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.CF8_MAXERRORS = {
    'long_name'     'compact flash maximum errors'
    'units'         '1'
    'comment'       'Maximum number of compact fash errors allowed.'
    '_FillValue'    default_fill_value };

  var_attr_list.CFSIZE_bytes_free = {
    'long_name'     'compact flash free space'
    'units'         'bytes'
    'comment'       'Available free space on the compact flash card.'
    '_FillValue'    default_fill_value };

  var_attr_list.CFSIZE_bytes_total = {
    'long_name'     'compact flash capacity'
    'units'         'bytes'
    'comment'       'Total capacity of the compact flash card.'
    '_FillValue'    default_fill_value };

  var_attr_list.COMM_SEQ = {
    'long_name'     'file transfer sequence'
    'units'         '1'
    'comment'       'Specification of the sequence of file transfer to use.'
    '_FillValue'    default_fill_value };

  var_attr_list.COMPASS2_DEVICE = {
    'long_name'     'second compass device configuration flag'
    'units'         '1'
    'comment'       'Configuration flags specifying the specific model and port for the second compass and transponder/altimeter devices.'
    '_FillValue'    default_fill_value };

  var_attr_list.COMPASS_DEVICE = {
    'long_name'     'first compass device configuration flag'
    'units'         '1'
    'comment'       'Configuration flags specifying the specific model and port for the second compass and transponder/altimeter devices.'
    '_FillValue'    default_fill_value };

  var_attr_list.COMPASS_USE = {
    'long_name'     'compass use control'
    'units'         '1'
    'comment'       'Parameter used in development to assess compass problems (0 = trust compass inputs, use and report fully calibrated values).'
    '_FillValue'    default_fill_value };

  var_attr_list.COURSE_BIAS = {
    'long_name'     'heading bias compensation'
    'units'         'degree'
    'comment'       'A heading bias to compensate for an observed tendency of Seaglider to veer to one side.'
    '_FillValue'    default_fill_value };

  var_attr_list.CURRENT_cur_dir = {
    'long_name'     'depth averaged current direction'
    'standard_name' 'direction_of_sea_water_velocity'
    'units'         'degree'
    'comment'       'Direction of depth averaged current calculated in some navigation modes.'
    '_FillValue'    default_fill_value };

  var_attr_list.CURRENT_cur_spd = {
    'long_name'     'depth averaged current speed'
    'standard_name' 'sea_water_speed'
    'units'         'm s-1'
    'comment'       'Speed of depth averaged current calculated in some navigation modes.'
    '_FillValue'    default_fill_value };

  var_attr_list.CURRENT_cur_val = {
    'long_name'     'depth averaged current validity'
    'units'         '1'
    'comment'       'Validity check of depth averaged current calculated in some navigation modes (1 = valid, 0 = invalid).'
    '_FillValue'    default_fill_value };

  var_attr_list.C_PITCH = {
    'long_name'     'pitch center position'
    'units'         'counts'
    'comment'       'Flat position for pitch.'
    '_FillValue'    default_fill_value };

  var_attr_list.C_ROLL_CLIMB = {
    'long_name'     'climb roll center position'
    'units'         'counts'
    'comment'       'Straight flight position for roll during climb phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.C_ROLL_DIVE = {
    'long_name'     'dive roll center position'
    'units'         'counts'
    'comment'       'Straight flight position for roll during dive phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.C_VBD = {
    'long_name'     'VBD center position'
    'units'         'counts'
    'comment'       'Neutrally buoyant position for VBD.'
    '_FillValue'    default_fill_value };

  var_attr_list.DATA_FILE_SIZE_bytes = {
    'long_name'     'data file size'
    'units'         'bytes'
    'comment'       'Total size of the data file.'
    '_FillValue'    default_fill_value };

  var_attr_list.DATA_FILE_SIZE_samples = {
    'long_name'     'number of data samples'
    'units'         '1'
    'comment'       'Number of data samples taken during the dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEEPGLIDER = {
    'long_name'     'Deepglider type indicator'
    'units'         ''
    'comment'       'Indicates whether the glider is a Deepglider instead of a standard Seaglider (0 = standard Seaglider).'
    '_FillValue'    default_fill_value };

  var_attr_list.DEEPGLIDERMB = {
    'long_name'     'Deepglider motherboard indicator'
    'units'         '1'
    'comment'       'Indicates whether the main board is intended for use in Deepglider (0 = standard Seaglider main board).'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE1 = {
    'long_name'     'device slot 1 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE2 = {
    'long_name'     'device slot 2 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE3 = {
    'long_name'     'device slot 3 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE4 = {
    'long_name'     'device slot 4 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE5 = {
    'long_name'     'device slot 5 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE6 = {
    'long_name'     'device slot 6 configuration flag'
    'units'         '1'
    'comment'       'Configuration flag specifying device type and port for each of the six possible attached science sensors. Empty device slots are indicated with a parameter value of -1.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Analog_circuits = {
    'long_name'     'analog circuits maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by analog circuits (including pressure sensor).'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Compass = {
    'long_name'     'compass maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by compass device.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Compass2 = {
    'long_name'     'second compass maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by compass2 device.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_GPS = {
    'long_name'     'gps fix maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by GPS device for fix acquisition.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_GPS_charging = {
    'long_name'     'gps charging circuit maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by auxiliary GPS charging circuit.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_GUMSTIX_24V = {
    'long_name'     'gumstix maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by Gumstix device.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Iridium_during_connect = {
    'long_name'     'iridium connection maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by phone while connecting to basestation.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Iridium_during_init = {
    'long_name'     'iridium initialization maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by phone related to turn it on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Iridium_during_xfer = {
    'long_name'     'iridium transfer maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by phone during a file transfer.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_LPSleep = {
    'long_name'     'low power sleep maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 under low power sleep.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Pitch_motor = {
    'long_name'     'pitch motor maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by pitch motor.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_RAFOS = {
    'long_name'     'RAFOS receiver maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by RAFOS receiver.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Roll_motor = {
    'long_name'     'roll motor maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by roll motor.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_TT8 = {
    'long_name'     'TT8 2 MHz maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 at 2MHz.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_TT8_Active = {
    'long_name'     'TT8 active maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 in active mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_TT8_CF8 = {
    'long_name'     'TT8 flash access maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 while accessing compact flash memory.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_TT8_Kalman = {
    'long_name'     'TT8 Kalman filter maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 while running the Kalman filter.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_TT8_Sampling = {
    'long_name'     'TT8 sampling maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by TT8 while sampling sensors.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Transponder = {
    'long_name'     'transponder maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by transponder device.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_Transponder_ping = {
    'long_name'     'transponder ping maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by transponder during an active ping.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_VBD_pump_during_apogee = {
    'long_name'     'VBD apogee pump maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by VBD pump in active mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_VBD_pump_during_surface = {
    'long_name'     'VBD surface pump maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by VBD pump outside of dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_MAMPS_VBD_valve = {
    'long_name'     'VBD valve maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by VBD valve.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Analog_circuits = {
    'long_name'     'analog circuits power time'
    'units'         's'
    'comment'       'Time analog circuits powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Compass = {
    'long_name'     'compass power time'
    'units'         's'
    'comment'       'Time compass device powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Compass2 = {
    'long_name'     'second compass power time'
    'units'         's'
    'comment'       'Time compass2 powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_GPS = {
    'long_name'     'gps fix power time'
    'units'         's'
    'comment'       'Time GPS device powered on for fix acquisition.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_GPS_charging = {
    'long_name'     'gps charging circuit power time'
    'units'         's'
    'comment'       'Time auxiliary GPS charging circuit powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_GUMSTIX_24V = {
    'long_name'     'gumstix power time'
    'units'         's'
    'comment'       'Time Gumstix device powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Iridium_during_connect = {
    'long_name'     'iridium connection powe time'
    'units'         's'
    'comment'       'Time phone powered on while connecting to basestation.'
   '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Iridium_during_init = {
    'long_name'     'iridium initialization powe time'
    'units'         's'
    'comment'       'Time phone powered on to turn it on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Iridium_during_xfer = {
    'long_name'     'iridium transfer powe time'
    'units'         's'
    'comment'       'Time phone powered on during a file transfer.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_LPSleep = {
    'long_name'     'low power sleep powe time'
    'units'         's'
    'comment'       'Time TT8 powered on under low power sleep.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Pitch_motor = {
    'long_name'     'pitch motor powe time'
    'units'         's'
    'comment'       'Time pitch motor powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_RAFOS = {
    'long_name'     'RAFOS receiver powe time'
    'units'         's'
    'comment'       'Time RAFOS receiver powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Roll_motor = {
    'long_name'     'roll motor power time'
    'units'         's'
    'comment'       'Time roll motor powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_TT8 = {
    'long_name'     'TT8 2 MHz power time'
    'units'         's'
    'comment'       'Time TT8 at 2MHz powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_TT8_Active = {
    'long_name'     'TT8 active power time'
    'units'         's'
    'comment'       'Time TT8  powered on in active mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_TT8_CF8 = {
    'long_name'     'TT8 flash access power time'
    'units'         's'
    'comment'       'Time TT8 powered on while accessing compact flash memory.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_TT8_Kalman = {
    'long_name'     'TT8 Kalman filter power time'
    'units'         's'
    'comment'       'Time TT8 powered on while running the Kalman filter.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_TT8_Sampling = {
    'long_name'     'TT8 sampling power time'
    'units'         's'
    'comment'       'Time TT8 powered on while sampling sensors.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Transponder = {
    'long_name'     'transponder power time'
    'units'         's'
    'comment'       'Time transponder device powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_Transponder_ping = {
    'long_name'     'transponder ping power time'
    'units'         's'
    'comment'       'Time transponder powered on during an active ping.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_VBD_pump_during_apogee = {
    'long_name'     'VBD apogee pump power time'
    'units'         's'
    'comment'       'Time VBD pump powered on in active mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_VBD_pump_during_surface = {
    'long_name'     'VBD surface pump power time'
    'units'         's'
    'comment'       'Time VBD pump powered on outside of dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.DEVICE_SECS_VBD_valve = {
    'long_name'     'VBD valve power time'
    'units'         's'
    'comment'       'Time VBD valve powered on.'
    '_FillValue'    default_fill_value };

  var_attr_list.DIVE = {
    'long_name'     'dive number'
    'units'         '1'
    'comment'       'Dive number in current mission.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_ABORT = {
    'long_name'     'allowed maximum depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Maximum depth for Seaglider operations.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_BOOST = {
    'long_name'     'boost depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth above which only boost pump runs.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_CALL = {
    'long_name'     'call depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'GPS acquisition and Iridium phone call starting depth.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_FINISH = {
    'long_name'     'finish depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth to finish the dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_FLARE = {
    'long_name'     'flare depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth to flare to the computed pitch angle following the initial dive from the surface.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_GRID = {
    'long_name'     'bathymetry apogee depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Bathymetry map depth where apogee state begins.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_NO_BLEED = {
    'long_name'     'no bleed depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth below which no oil bleeds from the bladder.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_OFFGRID = {
    'long_name'     'off-grid depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Bathymetry map depth value used outside the map area.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_PITCH = {
    'long_name'     'pitch depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth to reach before surface pitch mneuver.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_SAFE = {
    'long_name'     'safe depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Target depth for escape route flight and VBD depth safety limit.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_SURF = {
    'long_name'     'surface depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth to surface approach.'
    '_FillValue'    default_fill_value };

  var_attr_list.D_TGT = {
    'long_name'     'target depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth to reach to start apogee phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_bufoverrun = {
    'long_name'     'buffer overrun errors'
    'units'         '1'
    'comment'       'Number of times the log file output is longer than the internal buffer length.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fclos_errs = {
    'long_name'     'close file errors'
    'units'         '1'
    'comment'       'Number of CF8 errors while closing files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fclos_rets = {
    'long_name'     'close file retries'
    'units'         '1'
    'comment'       'Number of CF8 retries while closing files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fopen_errs = {
    'long_name'     'open file errors'
    'units'         '1'
    'comment'       'Number of CF8 errors while opening files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fopen_rets = {
    'long_name'     'open file retries'
    'units'         '1'
    'comment'       'Number of CF8 retries while opening files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fwrit_errs = {
    'long_name'     'write file errors'
    'units'         '1'
    'comment'       'Number of CF8 errors while writing files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_fwrit_rets = {
    'long_name'     'write file retries'
    'units'         '1'
    'comment'       'Number of CF8 retries while writing files.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_gps_mis = {
    'long_name'     'gps missing errors'
    'units'         '1'
    'comment'       'Number of times GPS did not provide data records within the 2 second timeout.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_gps_pps = {
    'long_name'     'gps pulse per second errors'
    'units'         '1'
    'comment'       'Number of GPS pulse per second (PPS) errors.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_interrupts = {
    'long_name'     'interrupt errors'
    'units'         '1'
    'comment'       'Number of spurious interrupts resultin from division by zero, memory dereference problems, or interrupt contention.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_ptch_errs = {
    'long_name'     'pitch errors'
    'units'         '1'
    'comment'       'Number of pitch errors.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_ptch_rets = {
    'long_name'     'pitch retries'
    'units'         '1'
    'comment'       'Number of pitch retries.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_roll_errs = {
    'long_name'     'roll errors'
    'units'         '1'
    'comment'       'Number of roll errors.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_roll_rets = {
    'long_name'     'roll retries'
    'units'         '1'
    'comment'       'Number of roll retries.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_vbd_errs = {
    'long_name'     'VBD errors'
    'units'         '1'
    'comment'       'Number of VBD errors.'
    '_FillValue'    default_fill_value };

  var_attr_list.ERRORS_vbd_rets = {
    'long_name'     'VBD retries'
    'units'         '1'
    'comment'       'Number of VBD retries.'
    '_FillValue'    default_fill_value };

  var_attr_list.ESCAPE_HEADING = {
    'long_name'     'escape heading'
    'units'         'degree'
    'comment'       'Base heading to steer in an escape recovery situation when either no position fix is available or no escape target in targets file.'
    '_FillValue'    default_fill_value };

  var_attr_list.ESCAPE_HEADING_DELTA = {
    'long_name'     'eascape heading increment'
    'units'         'degree'
    'comment'       'Escape heading increment according to bottom depth change.'
    '_FillValue'    default_fill_value };

  var_attr_list.FERRY_MAX = {
    'long_name'     'maximum rhumb line correction'
    'units'         'degree'
    'comment'       'Maximum correction to apply to the rhumb line to the next waypoint when NAV_MODE = 2.'
    '_FillValue'    default_fill_value };

  var_attr_list.FG_AHR_10V = {
    'long_name'     'low voltage battery pack consumption'
    'units'         'A h'
    'comment'       'Cumulative power consumed from the low voltage battery pack (10 V) as tracked by the supervisor fuel gauge.'
    '_FillValue'    default_fill_value };

  var_attr_list.FG_AHR_10Vo = {
    'long_name'     'low voltage battery pack dive end consumption'
    'units'         'A h'
    'comment'       'Cumulative power consumed from the low voltage battery pack (24 V) as tracked by the supervisor fuel gauge and recorded at the end of the dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.FG_AHR_24V = {
    'long_name'     'high voltage battery pack consumption'
    'units'         'A h'
    'comment'       'Cumulative power consumed from the high voltage battery pack (24 V) as tracked by the supervisor fuel gauge.'
    '_FillValue'    default_fill_value };

  var_attr_list.FG_AHR_24Vo = {
    'long_name'     'high voltage battery pack dive end consumption'
    'units'         'A h'
    'comment'       'Cumulative power consumed from the high voltage battery pack (24 V) as tracked by the supervisor fuel gauge and recorded at the end of the dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.FILEMGR = {
    'long_name'     'file management agressivity'
    'units'         '1'
    'comment'       'Onboard file system management agressivity (0 = none, 1 = only store compressed files, 2 = delete splits on failed phone call).'
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH_dens = {
    'long_name'     'finish density'
    'standard_name' 'sea_water_density'
    'units'         'kg l-1'
    'comment'       'Density of water at the first sample taken after reaching D_SURF (or D_FINISH, if enabled).'
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH_dpth = {
    'long_name'     'finish depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Depth of glider at the first sample taken after reaching D_SURF (or D_FINISH, if enabled).'
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH1_field01 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH1_field02 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH1_field03 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.FINISH2 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.FIX_MISSING_TIMEOUT = {
    'long_name'     'missing navigation fix timeout'
    'units'         'days'
    'comment'       'Maximum time allowed without any valid navigation fix (GPS, RAFOS, Iridium geolocation) before entering into recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.GLIDE_SLOPE = {
    'long_name'     'maximum glide slope'
    'units'         'degree'
    'comment'       'Absolute value of the maximum glide slope allowed.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPS_DEVICE = {
    'long_name'     'GPS device model'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_ddmmyy = {
    'long_name'     'GPS date stamp'
    'comment'       'Day of month (dd), month of year (mm), 2-digit year (yy) UTC'
    '_FillValue'    0 };

  var_attr_list.GPSFIX_fixlat = {
    'long_name'     'gps latitude'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    'comment'       'Latitude coordinate of GPS fix.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_fixlon = {
    'long_name'     'gps longitude'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    'comment'       'Longitude coordinate of GPS fix.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_hhmmss = {
    'long_name'     'gps time stamp'
    'comment'       'Hour (hh), minute (mm), second (ss) UTC'
    '_FillValue'    0 };

  var_attr_list.GPSFIX_hordop = {
    'long_name'     'horizontal dilution of precision'
    'units'         ''
    'comment'       'Measure of the strength of the figure used to compute the GPS fix.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_magvar = {
    'long_name'     'gps magnetic variation'
    'units'         'degree'
    'comment'       'Magnetic variation, positive east.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_ttafix = {
    'long_name'     'gps time to acquire fix'
    'units'         ''
    'comment'       'Total time to acquire fix.'
    '_FillValue'    default_fill_value };

  var_attr_list.GPSFIX_ttffix = {
    'long_name'     'gps time to first fix'
    'units'         's'
    'comment'       'Time to first fix,'
    '_FillValue'    default_fill_value };

  var_attr_list.HD_A = {
    'long_name'     'lift coefficient'
    'units'         ''
    'comment'       'Hydrodynamic parameter representing the lift coefficient determined empirically and used in onboard performance prediction and guidance calculations.'
    '_FillValue'    default_fill_value };

  var_attr_list.HD_B = {
    'long_name'     'drag coefficient'
    'units'         ''
    'comment'       'Hydrodynamic parameter representing the drag coefficient determined empirically and used in onboard performance prediction and guidance calculations.'
    '_FillValue'    default_fill_value };

  var_attr_list.HD_C = {
    'long_name'     'induced drag coefficient'
    'units'         ''
    'comment'       'Hydrodynamic parameter representing the induced drag coefficient determined empirically and used in on-board performance prediction and guidance calculations.'
    '_FillValue'    default_fill_value };

  var_attr_list.HEADING = {
    'long_name'     'navigation heading'
    'units'         'degree'
    'comment'       'Syntetic waypoint heading (NAV_MODE 0,1 or 2) or heading offset from depth-averaged current (NAV_MODE 3).'
    '_FillValue'    default_fill_value };

  var_attr_list.HEAD_ERRBAND = {
    'long_name'     'heading deadband'
    'units'         'degree'
    'comment'       'Heading minimum error to recquire a correction in guidance and control mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.HEAPDBG = {
    'long_name'     'heap debug control'
    'units'         '1'
    'comment'       'Control of the extended heap debugging function.'
    '_FillValue'    default_fill_value };

  var_attr_list.HUMID = {
    'long_name'     'internal humidity'
    'units'         '%'
    'comment'       'Relative humidity inside the pressure hull.'
    '_FillValue'    default_fill_value };

  var_attr_list.ICE_FREEZE_MARGIN = {
    'long_name'     'freezing point temperature margin'
    'units'         'Celsius'
    'comment'       'Temperature margin used in the freezing point calculation.'
    '_FillValue'    default_fill_value };

  var_attr_list.ID = {
    'long_name'     'identification number'
    'units'         '1'
    'comment'       'Seglider identification (serial) number.'
    '_FillValue'    default_fill_value };

  var_attr_list.INTERNAL_PRESSURE = {
    'long_name'     'internal pressure'
    'units'         'psia'
    'comment'       'Pressure inside the pressure hull'
    '_FillValue'    default_fill_value };

  var_attr_list.INT_PRESSURE_SLOPE = {
    'long_name'     'internal pressure calibration slope'
    'units'         'psia counts-1'
    'comment'       'Slope calibration of the internal pressure sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.INT_PRESSURE_YINT = {
    'long_name'     'internal pressure calibration intercept'
    'units'         'psia'
    'comment'       'Y-intercept calibration of the internal pressure sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.IRIDIUM_FIX_field01 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 01 of IRIDIUM_FIX log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.IRIDIUM_FIX_field02 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 02 of IRIDIUM_FIX log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.IRIDIUM_FIX_field03 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 03 of IRIDIUM_FIX log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.IRIDIUM_FIX_field04 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 04 of IRIDIUM_FIX log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_CONTROL_spd_east = {
    'long_name'     'desired eastward speed'
    'units'         'm s-1'
    'comment'       'Eastward component of horizontal speed from which heading is derived.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_CONTROL_spd_nrth = {
    'long_name'     'desired northward speed'
    'units'         'm s-1'
    'comment'       'Northward component of horizontal speed from which heading is derived.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_USE = {
    'long_name'     'navigation Kalman filter control'
    'units'         '1'
    'comment'       'Control parameter for the run state of the Kalman filter navigation program (0 = reset Kalman filter, 1 = run Kalman filter, 2 = do not run the Kalman filter).'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_X_cur_diur_east = {
    'long_name'     'Kalman filter diurnal current easting'
    'units'         'm'
    'comment'       'East position relative to initial position at time tk due to diurnal current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_X_cur_mean_east = {
    'long_name'     'Kalman filter mean current easting'
    'units'         'm'
    'comment'       'East position relative to initial position at time tk due to mean current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_X_cur_semi_east = {
    'long_name'     'Kalman filter semidiurnal current easting'
    'units'         'm'
    'comment'       'East position relative to initial position at time tk due to semidiurnal current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_X_delta_x = {
    'long_name'     'Kalman filter x displacement'
    'units'         'm'
    'comment'       'X displacement from present position to predicted position due to mean, diurnal and semidiurnal components of the model.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_X_gld_wspd_east = {
    'long_name'     'Kalman filter glider speed easting'
    'units'         'm'
    'comment'       'East position relative to initial position at time tk due to glider speed through water.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_Y_cur_diur_nrth = {
    'long_name'     'Kalman filter diurnal current northing'
    'units'         'm'
    'comment'       'North position relative to initial position at time tk due to diurnal current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_Y_cur_mean_nrth = {
    'long_name'     'Kalman filter mean current northing'
    'units'         'm'
    'comment'       'North position relative to initial position at time tk due to mean current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_Y_cur_semi_nrth = {
    'long_name'     'Kalman filter semidiurnal current northing'
    'units'         'm'
    'comment'       'North position relative to initial position at time tk due to semidiurnal current.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_Y_delta_y = {
    'long_name'     'Kalman filter y displacement'
    'units'         'm'
    'comment'       'Y displacement from present position to predicted position due to mean, diurnal and semidiurnal components of the model.'
    '_FillValue'    default_fill_value };

  var_attr_list.KALMAN_Y_gld_wspd_nrth = {
    'long_name'     'Kalman filter glider speed northing'
    'units'         'm'
    'comment'       'North position relative to initial position at time tk due to glider speed through water.'
    '_FillValue'    default_fill_value };

  var_attr_list.KERMIT = {
    'long_name'     'kermit control'
    'units'         ''
    'comment'       'Control of the use of kermit (vs xmodem) for file transfers. Not used.'
    '_FillValue'    default_fill_value };

  var_attr_list.LOGGERDEVICE1 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.LOGGERDEVICE2 = {
    'long_name'     ''
    'units'         ''
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.LOGGERS = {
    'long_name'     'logger bitmask'
    'units'         ''
    'comment'       'bit mask for the autonomous logging devices configured with the Autonomous Logger Interface (ALI).'
    '_FillValue'    default_fill_value };

  var_attr_list.MASS = {
    'long_name'     'glider mass'
    'standard_name' 'mass'
    'units'         'g'
    'comment'       'Mass used in onboard buoyancy and current estimation calculation.'
    '_FillValue'    default_fill_value };

  var_attr_list.MAX_BUOY = {
    'long_name'     'maximum negative thrust'
    'units'         'cm3'
    'comment'       'Absolute value of the maximum negative thrust (in cc) that Seaglider is allowed to develop during the dive phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.MEM = {
    'long_name'     'free RAM memory'
    'units'         'bytes'
    'comment'       'Amount of free RAM reported by the glider.'
    '_FillValue'    default_fill_value };

  var_attr_list.MHEAD_RNG_PITCHd_Wd_mag_head = {
    'long_name'     'desired magnetic heading'
    'units'         'degree'
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.MHEAD_RNG_PITCHd_Wd_ptch_ang = {
    'long_name'     'desired pitch angle'
    'units'         'degree'
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.MHEAD_RNG_PITCHd_Wd_tgt_rnge = {
    'long_name'     'targer range'
    'units'         'm'
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.MHEAD_RNG_PITCHd_Wd_vert_vel = {
    'long_name'     'desired vertical velocity'
    'units'         'm s-1'
    'comment'       ''
    '_FillValue'    default_fill_value };

  var_attr_list.MINV_10V = {
    'long_name'     'low voltage battery pack minimum voltage allowed'
    'units'         'V'
    'comment'       'minimum allowable observed voltage on the low voltage battery pack before going into recovery.'
    '_FillValue'    default_fill_value };

  var_attr_list.MINV_24V = {
    'long_name'     'high voltage battery pack minimum voltage allowed'
    'units'         'V'
    'comment'       'minimum allowable observed voltage on the low voltage battery pack before going into recovery.'
    '_FillValue'    default_fill_value };

  var_attr_list.MISSION = {
    'long_name'     'mission number'
    'units'         '1'
    'comment'       'Current mission number.'
    '_FillValue'    default_fill_value };

  var_attr_list.MOTHERBOARD = {
    'long_name'     'motherboard revision'
    'units'         '1'
    'comment'       'Revision of the carried motherboard.'
    '_FillValue'    default_fill_value };

  var_attr_list.NAV_MODE = {
    'long_name'     'navigation mode'
    'units'         '1'
    'comment'       'Heading selection method (0 = constant HEADING, 1 = KALMAN_USE, 2 = ferry angle correction wrt depth-averaged current, 3 = HEADING relative to depth-averaged current).'
    '_FillValue'    default_fill_value };

  var_attr_list.N_FILEKB = {
    'long_name'     'data upload file size'
    'units'         'kbytes'
    'comment'       'Size and type of file used for data uploading (disable gzip compression if negative).'
    '_FillValue'    default_fill_value };

  var_attr_list.N_GPS = {
    'long_name'     'gps maximum time'
    'units'         's'
    'comment'       'Time to wait after the first GPS fix is received for a GPS fix with HDOP less than 2.0.'
    '_FillValue'    default_fill_value };

  var_attr_list.N_NOCOMM = {
    'long_name'     'allowed no-communication dives'
    'units'         '1'
    'comment'       'Number of dives allowed without a complete and successful data communication session before setting the surface buoyancy parameter to the allowed maximum.'
    '_FillValue'    default_fill_value };

  var_attr_list.N_NOSURFACE = {
    'long_name'     'non-surfacing dive control'
    'units'         '1'
    'comment'       'Control of surfacing and non-surfacing dives. If positive dives multiple of N_NOSURFACE will complete at subsurface instead of surface. A negative value reverses this logic.'
    '_FillValue'    default_fill_value };

  var_attr_list.PHONE_DEVICE = {
    'long_name'     'phone device model'
    'units'         '1'
    'comment'       'Model of the attached phone device.'
    '_FillValue'    default_fill_value };

  var_attr_list.PHONE_SUPPLY = {
    'long_name'     'phone power supply'
    'units'         ''
    'comment'       'Iridium modem power usage attribution (1 = 10V battery, 2 = 24V battery).'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_ADJ_DBAND = {
    'long_name'     'pitch control deadband'
    'units'         'degree'
    'comment'       'Allowed deadband for active pitch control during dive and climb.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_ADJ_GAIN = {
    'long_name'     'pitch control gain'
    'units'         'cm degree-1'
    'comment'       'Adjustment factor for active pitch control during dive and climb.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_AD_RATE = {
    'long_name'     'pitch rate retry threshold'
    'units'         'count s-1'
    'comment'       'Pitch rate threshold for retries when pitching.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_CNV = {
    'long_name'     'pitch position conversion factor'
    'units'         'cm counts-1'
    'comment'       'Pitch position conversion factor set by manufacturer or assembler.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_DBAND = {
    'long_name'     'pitch deadband'
    'units'         'cm'
    'comment'       'Pitch position deadband (cm) within which no further pitch motion is commanded.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_GAIN = {
    'long_name'     'pitch gain'
    'units'         'degree cm-1'
    'comment'       'Amount of vehicle pitch change corresponding to a 1 cm movement of the pitch mass.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_MAX = {
    'long_name'     'pitch maximum position'
    'units'         'counts'
    'comment'       'Pitch position software limit aft.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_MAXERRORS = {
    'long_name'     'maximum pitch errors'
    'units'         '1'
    'comment'       'Number of pitch motor errors allowed before going into recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_MIN = {
    'long_name'     'pitch minimum position'
    'units'         'counts'
    'comment'       'Pitch position software limit forward.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_TIMEOUT = {
    'long_name'     'pitch timeout'
    'units'         's'
    'comment'       'Time allowed the mass shifter to achieve the desired pitch position.'
    '_FillValue'    default_fill_value };

  var_attr_list.PITCH_VBD_SHIFT = {
    'long_name'     'pitch VBD compensation'
    'units'         'cm cm-3'
    'comment'       'Pitch compensation (cm/cm3) required to balance the mass of the hydraulic oil moving forward and aft with the change in buoyancy as a result of VBD changes.'
    '_FillValue'    default_fill_value };

  var_attr_list.PRESSURE_SLOPE = {
    'long_name'     'pressure slope'
    'units'         ''
    'comment'       'Slope of linear fit between psig and pressure sensor output (after digitization to A/D counts through AD7714).'
    '_FillValue'    default_fill_value };

  var_attr_list.PRESSURE_YINT = {
    'long_name'     'pressure interecept'
    'units'         ''
    'comment'       'Y-intercept of linear fit between psig and pressure sensor output (after digitization to A/D counts through AD7714).'
    '_FillValue'    default_fill_value };

  var_attr_list.P_OVSHOOT = {
    'long_name'     'pitch overshoot'
    'units'         'cm'
    'comment'       'Distance by which the pitch mass is allowed to overshoot its target after the pitch motor is turned off.'
    '_FillValue'    default_fill_value };

  var_attr_list.RAFOS_CORR_THRESH = {
    'long_name'     'RAFOS correlation threshold'
    'units'         '1'
    'comment'       'Correlation threshold to use when selecting RAFOS hits for navigation solutions.'
    '_FillValue'    default_fill_value };

  var_attr_list.RAFOS_DEVICE = {
    'long_name'     'RAFOS device flag'
    'units'         '1'
    'comment'       'Model of the attached RAFOS device (-1 = RAFOS device not installed).'
    '_FillValue'    default_fill_value };

  var_attr_list.RAFOS_HIT_WINDOW = {
    'long_name'     'RAFOS hit window size'
    'units'         '1'
    'comment'       'Size of search window in seconds to use when clustering hits for navigation solutions.'
    '_FillValue'    default_fill_value };

  var_attr_list.RAFOS_PEAK_OFFSET = {
    'long_name'     'RAFOS arrival time offset'
    'units'         's'
    'comment'       'Offset of actual arrival time from the receiver reported arrival index due to receiver firmware artefacts.'
    '_FillValue'    default_fill_value };

  var_attr_list.RELAUNCH = {
    'long_name'     'post-error relaunch flag'
    'units'         '1'
    'comment'       'Behaviour in the event of a crash to TOM8 or any watchdog timer reset (0 = resume diving, 1 = enter recovery)'
    '_FillValue'    default_fill_value };

  var_attr_list.RHO = {
    'long_name'     'water density preset'
    'standard_name' 'sea_water_density'
    'units'         'kg l-1'
    'comment'       'Water density value used for converting buoyancy force in grams to sea water displacement in cm3 and on-board performance prediction computations.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_ADJ_DBAND = {
    'long_name'     'roll control deadband'
    'units'         'degree s-1'
    'comment'       'Allowed deadband for roll control.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_ADJ_GAIN = {
    'long_name'     'roll control gain'
    'units'         'degree degree-1 s-1'
    'comment'       'Adjustment factor for roll control.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_AD_RATE = {
    'long_name'     'roll rate retry threshold.'
    'units'         'counts s-1'
    'comment'       'Roll rate threshold for retries when rolling.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_CNV = {
    'long_name'     'roll position conversion factor'
    'units'         'degree counts-1'
    'comment'       'Roll position conversion factor determined by the particulars of the roll gear train, motor and potentiometer.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_DEG = {
    'long_name'     'turn roll angle'
    'units'         'degree'
    'comment'       'Angle to roll the internal roll mass during a turn.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_MAX = {
    'long_name'     'roll maximum position'
    'units'         'counts'
    'comment'       'Roll position software limit to starboard.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_MAXERRORS = {
    'long_name'     'maximum roll errors'
    'units'         '1'
    'comment'       'Number of roll motor errors allowed before going into recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_MIN = {
    'long_name'     'roll minimum position'
    'units'         'counts'
    'comment'       'Roll position software limit to port.'
    '_FillValue'    default_fill_value };

  var_attr_list.ROLL_TIMEOUT = {
    'long_name'     'roll timeout'
    'units'         's'
    'comment'       'Time allowed to achieve the desired roll position.'
    '_FillValue'    default_fill_value };

  var_attr_list.R_PORT_OVSHOOT = {
    'long_name'     'roll port overshoot'
    'units'         'counts'
    'comment'       'Roll mass overshoot to port after motor is turned off.'
    '_FillValue'    default_fill_value };

  var_attr_list.R_STBD_OVSHOOT = {
    'long_name'     'roll starboard port overshoot'
    'units'         'counts'
    'comment'       'Roll mass overshoot to port after motor is turned off.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_C_G = {
    'long_name'     'conductivity calibration coefficient g'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_C_H = {
    'long_name'     'conductivity calibration coefficient h'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_C_I = {
    'long_name'     'conductivity calibration coefficient i'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_C_J = {
    'long_name'     'conductivity calibration coefficient j'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_T_G = {
    'long_name'     'temperature calibration coefficient g'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute temperature, salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_T_H = {
    'long_name'     'temperature calibration coefficient h'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute temperature, salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_T_I = {
    'long_name'     'temperature calibration coefficient i'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute temperature, salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SEABIRD_T_J = {
    'long_name'     'temperature calibration coefficient j'
    'units'         ''
    'comment'       'Seabird Electronics-provided calibration coefficients for conductivity sensor used to compute temperature, salinity and density for self-trimming applications and subsurface finish maneuvers.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_AA4330 = {
    'long_name'     'anderaa 4330 maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by Aanderaa 4330 sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_SBE_CT = {
    'long_name'     'seabird ct maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by Seabird conductivity and temperature sail.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_WL_BBFL2VMT = {
    'long_name'     'bbfl2 triplet maximum current'
    'units'         'mA'
    'comment'       'Maximum current drawn by WETLabs BBFL2 fluorometer and backscatter sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_field04 = {
    'long_name'     ''
    'units'         'mA'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_field05 = {
    'long_name'     ''
    'units'         'mA'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_field06 = {
    'long_name'     ''
    'units'         'mA'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_field07 = {
    'long_name'     ''
    'units'         'mA'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_MAMPS_field08 = {
    'long_name'     ''
    'units'         'mA'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_AA4330 = {
    'long_name'     'anderaa 4330 power time'
    'units'         's'
    'comment'       'Time Aanderaa 4330 sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_SBE_CT = {
    'long_name'     'seabird ct power time'
    'units'         's'
    'comment'       'Time Seabird conductivity and temperature sail.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_WL_BBFL2VMT = {
    'long_name'     'bbfl2 power time'
    'units'         's'
    'comment'       'Time WETLabs BBFL2 fluoreometer and backscatter sensor.'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_field04 = {
    'long_name'     ''
    'units'         's'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_field05 = {
    'long_name'     ''
    'units'         's'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_field06 = {
    'long_name'     ''
    'units'         's'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_field07 = {
    'long_name'     ''
    'units'         's'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SENSOR_SECS_field08 = {
    'long_name'     ''
    'units'         's'
    'comment'       'Unknown sensor or nil (no sensor present in this slot).'
    '_FillValue'    default_fill_value };

  var_attr_list.SIM_PITCH = {
    'long_name'     'simulated pitch angle'
    'units'         'degree'
    'comment'       'Simulated pitch angle value during the dive phase of a simulated run.'
    '_FillValue'    default_fill_value };

  var_attr_list.SIM_W = {
    'long_name'     'simulated vertical velocity'
    'units'         'm s-1'
    'comment'       'Simulated vertical velocity during the dive phase of a simulated run.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_ANGLEo = {
    'long_name'     'surface angle'
    'units'         'degree'
    'comment'       'Glider-measured angle at surface at end of previous dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CC = {
    'long_name'     'VBD minimum buoyancy position'
    'units'         'cm3'
    'comment'       'Specified minimum-buoyancy position of the VBD to attain at surface.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_DEPTHo = {
    'long_name'     'surface depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'comment'       'Glider-measured depth at surface at end of previous dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field01 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 01 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field02 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 02 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field03 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 03 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field04 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 04 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field05 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 05 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field06 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 06 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field07 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 07 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field08 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 08 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field09 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 09 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field10 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 10 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field11 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 11 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field12 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 12 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_GC_field13 = {
    'long_name'     ''
    'units'         ''
    'comment'       'Unknown field 13 SM_GC log parameter.'
    '_FillValue'    default_fill_value };

  var_attr_list.SPEED_FACTOR = {
    'long_name'     'speed compensation factor'
    'units'         '1'
    'comment'       'factor to compensate the inability to dive at the desired horizontal velocity.'
    '_FillValue'    default_fill_value };

  var_attr_list.SPEED_LIMITS_max_spd = {
    'long_name'     'maximum horizontal speed'
    'units'         'm s-1'
    'comment'       'Maximum attainable horizontal speed on dive based on the minimum dive angle and the allowable buoyancy force.'
    '_FillValue'    default_fill_value };

  var_attr_list.SPEED_LIMITS_min_spd = {
    'long_name'     'minimum horizontal speed'
    'units'         'm s-1'
    'comment'       'Minimum attainable horizontal speed on dive based on the maximum dive angle and the allowable buoyancy force.'
    '_FillValue'    default_fill_value };

  var_attr_list.STROBE = {
    'long_name'     'strobe led control'
    'units'         '1'
    'comment'       'Control of the blinking of the strobe led (0 = no blinking, 1 = on recovery, 2 = on surface).'
    '_FillValue'    default_fill_value };

  var_attr_list.SURFACE_URGENCY = {
    'long_name'     'extra surfacing allowed dives'
    'units'         '1'
    'comment'       'Dives to accumulate before trying extra surfacings. For ice capable gliders only.'
    '_FillValue'    default_fill_value };

  var_attr_list.SURFACE_URGENCY_FORCE = {
    'long_name'     'forced extra surfacing dive modulo'
    'units'         '1'
    'comment'       'Dive number modulo for forced extra surfacing attempts. For under ice only.'
    '_FillValue'    default_fill_value };

  var_attr_list.SURFACE_URGENCY_TRY = {
    'long_name'     'extra surfacing dive modulo'
    'units'         '1'
    'comment'       'Dive number modulo for extra surfacing attempts. For under ice only.'
    '_FillValue'    default_fill_value };

  var_attr_list.TCM_PITCH_OFFSET = {
    'long_name'     'pitch-compass offset'
    'units'         'degree'
    'comment'       'Static offset in pitch axis between the compass output and the actual glider body asmeasured in the lab.'
    '_FillValue'    default_fill_value };

  var_attr_list.TCM_ROLL_OFFSET = {
    'long_name'     'roll-compass offset'
    'units'         ''
    'comment'       'Static offset in pitch axis between the compass output and the actual glider body asmeasured in the lab.'
    '_FillValue'    default_fill_value };

  var_attr_list.TCM_TEMP = {
    'long_name'     'compass temperature'
    'units'         'Celsius'
    'comment'       'Last temperature reading taken from compass.'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_AUTO_DEFAULT = {
    'long_name'     'default target update control'
    'units'         '1'
    'comment'       'Control of automatic update of default target (1 = automatically update default target in NVRAM, 0 = do not update default target in NVRAM).'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_DEFAULT_LAT = {
    'long_name'     'default target latitude'
    'units'         'nmea_degree'
    'comment'       'Latitude coordinate of default target location used when the targets file cannot be read.'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_DEFAULT_LON = {
    'long_name'     'default target longitude'
    'units'         'nmea_degree'
    'comment'       'Longitude coordinate of default target location used when the targets file cannot be read.'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_LATLONG_tgt_lat = {
    'long_name'     'target latitude'
    'units'         'nmea_degree'
    'comment'       'Latitude coordinate of target position for current dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_LATLONG_tgt_lon = {
    'long_name'     'target longitude'
    'units'         'nmea_degree'
    'comment'       'Longitude coordinate of target position of current dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.TGT_NAME = {
    'long_name'     'target name'
    'units'         ''
    'comment'       'Name of active target of this dive.'
    '_FillValue'    0 };

  var_attr_list.TGT_RADIUS = {
    'long_name'     'target radius'
    'units'         'm'
    'comment'       'Radius of active target of this dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.TT8_MAMPS = {
    'long_name'     'tt8 end dive power'
    'units'         'A'
    'comment'       'Power draw on the low voltage battery pack (10 V) at the end of the dive (it can be used to determine if devices are being left on).'
    '_FillValue'    default_fill_value };

  var_attr_list.T_ABORT = {
    'long_name'     'dive timeout'
    'units'         'minutes'
    'comment'       'Time allowed for a dive before entering the recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_BOOST = {
    'long_name'     'boost pump time'
    'units'         's'
    'comment'       'Boost pump run time before turning it off when deeper than boost depth.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_DIVE = {
    'long_name'     'dive time'
    'units'         'minutes'
    'comment'       'Time to make one dive-climb cycle (not including pump during apogee phase)used to calculate the desired vertical velocity.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_GPS = {
    'long_name'     'GPS timeout'
    'units'         'minutes'
    'comment'       'Maximum allowed time to obtain a GPS position.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_GPS_ALMANAC = {
    'long_name'     'GPS almanac timeout'
    'units'         'minutes'
    'comment'       'Maximum allowed time to acquire the GPS almanac.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_GPS_CHARGE = {
    'long_name'     'Garmin GPS25 trickle-charging time'
    'units'         'secs'
    'comment'       'Time to wait before trickle-charging the GPS receiver (for Garmin GPS25 engines only). GPS units now installed run on a button battery so there is no need to charge the system.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_LOITER = {
    'long_name'     'loiter time'
    'units'         's'
    'comment'       'Time to loiter after going neutral at apogee, before pitching up and becoming positively buoyant for climb.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_MISSION = {
    'long_name'     'mission timeout'
    'units'         'minutes'
    'comment'       'Maximum mission time allowed.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_NO_W = {
    'long_name'     'no vertical speed time'
    'units'         's'
    'comment'       'Wait time with no significantly non-zero vertical velocity (less than 1 cm/s, as measured by dP/dt) before proceeding to the next phase of a dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_RSLEEP = {
    'long_name'     'recovery sleep time interval'
    'units'         'minutes'
    'comment'       'Sleep time interval during the recovery phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_TURN = {
    'long_name'     'turn timeout'
    'units'         's'
    'comment'       'maximum time allowed to complete a turn during the active GC mode.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_TURN_SAMPINT = {
    'long_name'     'turn sampling interval'
    'units'         's'
    'comment'       'Sample interval during active and passive GC while turning.'
    '_FillValue'    default_fill_value };

  var_attr_list.T_WATCHDOG = {
    'long_name'     'watchdog timer'
    'units'         'minutes'
    'comment'       'Value to which the watchdog timer is set. This is an information only parameter so the glider software knows the watchdog timer value.'
    '_FillValue'    default_fill_value };

  var_attr_list.UNCOM_BLEED = {
    'long_name'     'VBD uncommanded bleed trigger'
    'units'         'counts'
    'comment'       'Uncommanded change of VBD bleed that triggers the safety actions (stop motors, close skinner valve) and entering into recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.UPLOAD_DIVES_MAX = {
    'long_name'     'maximum dive upload'
    'units'         ''
    'comment'       'maximum number of dives to upload at one surfacing (-1 = upload all available dives that have not been previously uploaded)'
    '_FillValue'    default_fill_value };

  var_attr_list.USE_BATHY = {
    'long_name'     'bathymetry map use control'
    'units'         '1'
    'comment'       'Control of use of onboard bathymap to determine the appropiate apogee depth (-4 = use on-board bathymap appropiate for current position, 0 = do not use bathymetry, positive = use matching bathymap).'
    '_FillValue'    default_fill_value };

  var_attr_list.USE_ICE = {
    'long_name'     'ice map use control'
    'units'         '1'
    'comment'       'Control of use of onboard icemap for surfacing decisions (-4 = use on-board bathymap appropiate for current position, 0 = do not use bathymetry, positive = use matching bathymap).'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_BLEED_AD_RATE = {
    'long_name'     'bleed rate retry threshold'
    'units'         'counts s-1'
    'comment'       'Bleed rate threshold for retries when bleeding.'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_CNV = {
    'long_name'     'VBD position conversion factor'
    'units'         'cm3 counts-1'
    'comment'       'VBD position conversion factor determined by the geometry of the internal hydraulic fluid reservoir and the potentiometers (the sign is negative, meaning that the higher A/D counts reflect more oil in the internal reservoir, hence a less inflated external bladder, hence a lower displacement, and thus a lower buoyancy).'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_DBAND = {
    'long_name'     'VBD position deadband'
    'units'         'cm3'
    'comment'       'Allowed deadband for VBD control.'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_MAX = {
    'long_name'     'VBD maximum position'
    'units'         'counts'
    'comment'       'VBD position software limit when the internal reservoir is almost full (external bladder fully bled, minimum buoyancy).'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_MAXERRORS = {
    'long_name'     'maximum VBD errors'
    'units'         '1'
    'comment'       'Number of VBD errors allowed before entering into recovery state.'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_MIN = {
    'long_name'     'VBD minimum position'
    'units'         'counts'
    'comment'       'VBD position software limit when the internal reservoir is almost empty (external bladder fully pumped, maximum buoyancy).'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_PUMP_AD_RATE_APOGEE = {
    'long_name'     'apogee pump rate'
    'units'         'counts s-1'
    'comment'       'Pump rate threshold for retries when pumping at apogee.'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_PUMP_AD_RATE_SURFACE = {
    'long_name'     'apogee pump rate'
    'units'         'counts s-1'
    'comment'       'Pump rate threshold for retries when pumping at surface.'
    '_FillValue'    default_fill_value };

  var_attr_list.VBD_TIMEOUT = {
    'long_name'     'VBD timeout'
    'units'         's'
    'comment'       'Time allowed to achieve the commanded change in VBD position.'
    '_FillValue'    default_fill_value };

  var_attr_list.XMS_NAKs = {
    'long_name'     'no acknowledged transfers'
    'units'         '1'
    'comment'       'Number of transfers ended with a NAK (No Acknowledgements) on previous surfacing.'
    '_FillValue'    default_fill_value };

  var_attr_list.XMS_TOUTs = {
    'long_name'     'no timeout transfers'
    'units'         '1'
    'comment'       'Total number of transfers ended without a timeout on previous surfacing.'
    '_FillValue'    default_fill_value };

  var_attr_list.XPDR_DEVICE = {
    'long_name'     'transponder model flag'
    'units'         '1'
    'comment'       'Configuration value specifying the model of the attached device.'
    '_FillValue'    default_fill_value };

  var_attr_list.XPDR_INHIBIT = {
    'long_name'     'transponder inhibit time'
    'units'         'ds'
    'comment'       'Time after a transponder reply during which the transponder does not reply to subsequent interrogation.'
    '_FillValue'    default_fill_value };

  var_attr_list.XPDR_PINGS = {
    'long_name'     'transponder pings'
    'units'         '1'
    'comment'       'Count of the number of times the glider transducer responded to an external stimulus at its frequency setting during a dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.XPDR_VALID = {
    'long_name'     'transponder validation sensitivity'
    'units'         '0.5 ms'
    'comment'       'Total time over a 10 ms window following initial triggering that the detector circuit must remain triggered.'
    '_FillValue'    default_fill_value };

  var_attr_list.x10V_AH_ampsh_tot = {
    'long_name'     'low voltage battery pack total consumption'
    'units'         'A h'
    'comment'       'Total power consumed on the low voltage battery pack (10 V) since last reset of battery meters (usually when new batteries are installed).'
    '_FillValue'    default_fill_value };

  var_attr_list.x10V_AH_volts_min = {
    'long_name'     'low voltage battery pack minimum voltage'
    'units'         'V'
    'comment'       'Minimum voltage measured on the low voltage battery pack (10 V) during active phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.x24V_AH_ampsh_tot = {
    'long_name'     'high voltage battery pack total consumption'
    'units'         'A h'
    'comment'       'Total power consumed on the high voltage battery pack (24 V) since last reset of battery meters (usually when new batteries are installed).'
    '_FillValue'    default_fill_value };

  var_attr_list.x24V_AH_volts_min = {
    'long_name'     'high voltage battery pack minimum voltage'
    'units'         'V'
    'comment'       'Minimum voltage measured on the high voltage battery pack (10 V) during active phase.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_data_pts = {
    'long_name'     'data points'
    'units'         '1'
    'comment'       'Number of data records collected thus far in the dive.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_end_secs = {
    'long_name'     'gc end elapsed time'
    'units'         's'
    'comment'       'Elapsed time from the start of the dive to the end of the GC.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_ob_vertv = {
    'long_name'     'observed vertical velocity'
    'units'         'cm s-1'
    'comment'       'Observed vertical velocity.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_phase = {
    'long_name'     'gc phase'
    'units'         '1'
    'comment'       'Guidance and control phase (1: pitch change, 2: VBD change, 3: roll, 4: turning (passive), 5: roll back to center, 6: passive mode waiting).'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_ad = {
    'long_name'     'gc pitch position'
    'units'         'counts'
    'comment'       'Position of the pitch motor at the end of the motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_ctl = {
    'long_name'     'gc pitch control'
    'units'         'cm'
    'comment'       'Position of the pitch mass relative to pitch center (positive aft).'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_errors = {
    'long_name'     'gc pitch errors'
    'units'         '1'
    'comment'       'Number of pitch motor errors (timeouts) during this motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_i = {
    'long_name'     'gc pitch motor current'
    'units'         'A'
    'comment'       'Average current used by pitch motor.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_retries = {
    'long_name'     'gc pitch motor retries'
    'units'         '1'
    'comment'       'Number of retries during this pitch motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_pitch_secs = {
    'long_name'     'gc pitch motor time'
    'units'         's'
    'comment'       'Time the pitch motor was on.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_roll_ad = {
    'long_name'     'gc roll position'
    'units'         'counts'
    'comment'       'Position of the roll motor at the end of the motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_roll_errors = {
    'long_name'     'gc roll errors'
    'units'         '1'
    'comment'       'Number of roll motor errors (timeouts) during this motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_roll_i = {
    'long_name'     'gc roll motor current'
    'units'         'A'
    'comment'       'Average current used by roll motor.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_roll_retries = {
    'long_name'     'gc roll motor retries'
    'units'         '1'
    'comment'       'Number of retries during this roll motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_roll_secs = {
    'long_name'     'gc roll motor time'
    'units'         's'
    'comment'       'Time the roll motor was on.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_ad = {
    'long_name'     'gc VBD position'
    'units'         'counts'
    'comment'       'Position of the VBD at the end of the motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_ctl = {
    'long_name'     'gc VBD control'
    'units'         'cm3'
    'comment'       'Position of the VBD mass relative to VBD center (positive buoyant).'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_errors = {
    'long_name'     'gc VBD errors'
    'units'         '1'
    'comment'       'Number of VBD errors (timeouts) during this motor move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_i = {
    'long_name'     'gc VBD current'
    'units'         'A'
    'comment'       'Average current used by VBD.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_retries = {
    'long_name'     'gc VBD retries'
    'units'         '1'
    'comment'       'Number of retries during this VBD move.'
    '_FillValue'    default_fill_value };

  var_attr_list.GC_vbd_secs = {
    'long_name'     'gc VBD time'
    'units'         's'
    'comment'       'Time the VBD was on.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_amps = {
    'long_name'     'sm VBD current'
    'units'         'A'
    'comment'       'Average current for the VBD during the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_ccss = {
    'long_name'     'sm VBD final position'
    'units'         'cm3'
    'comment'       'Final position of the VBD after the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_cnts = {
    'long_name'     'sm VBD final position'
    'units'         'counts'
    'comment'       'Final position of the VBD after the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_errs = {
    'long_name'     'sm VBD errors'
    'units'         '1'
    'comment'       'Number of errors during the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_rets = {
    'long_name'     'sm VBD retries'
    'units'         '1'
    'comment'       'Number of retries during the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.SM_CCo_pmp_secs = {
    'long_name'     'sm VBD time'
    'units'         's'
    'comment'       'Time for the surface maneuver pump.'
    '_FillValue'    default_fill_value };

  var_attr_list.STATE_result = {
    'long_name'     'gc result state'
    'units'         ''
    'comment'       'State result at end of phase.'
    '_FillValue'    0 };

  var_attr_list.STATE_status = {
    'long_name'     'gc state action'
    'units'         ''
    'comment'       'Current state action.'
    '_FillValue'    0 };

  var_attr_list.depth = {
    'long_name'     'measured depth'
    'standard_name' 'depth'
    'units'         'cm'
    'positive'      'down'
    'comment'       'This is the depth derived from the pressure measurements and using a constant conversion factor (0.685 psi m-1).'
    '_FillValue'    default_fill_value };

  var_attr_list.elaps_t = {
    'long_name'     'mission elapsed time'
    'standard_name' 'time'
    'units'         'seconds since start of first dive'
    'comment'       'Time since the start of the first dive (time_coverage_start).'
    '_FillValue'    default_fill_value };

  var_attr_list.elaps_t_0000 = {
    'long_name'     'time since start of day'
    'units'         's'
    'comment'       'Time since 0000UTC of the current day.'
    '_FillValue'    default_fill_value };

  var_attr_list.head = {
    'long_name'     'Vehicle heading'
    'standard_name' 'heading'
    'units'         'degree'
    'comment'       'Vehicle heading (magnetic degree).'
    '_FillValue'    default_fill_value };

  var_attr_list.pitchAng = {
    'long_name'     'vehicle pitch'
    'standard_name' 'pitch'
    'units'         'degree'
    'comment'       'Vehicle pitch angle (positive nose up).'
    '_FillValue'    default_fill_value };

  var_attr_list.pitchCtl = {
    'long_name'     'pitch mass position'
    'units'         'cm'
    'comment'       'Pitch mass position relative to pitch center (positive nose up).'
    '_FillValue'    default_fill_value };

  var_attr_list.rec = {
    'long_name'     'sample record'
    'units'         '1'
    'comment'       'Sample record number.'
    '_FillValue'    default_fill_value };

  var_attr_list.rollAng = {
    'long_name'     'vehicle roll'
    'standard_name' 'roll'
    'units'         'degree'
    'comment'       'Vehicle roll angle (positive starboard wing down, rolled to starboard).'
    '_FillValue'    default_fill_value };

  var_attr_list.rollCtl = {
    'long_name'     'roll mass position'
    'units'         'degree'
    'comment'       'Roll mass position relative to roll dive or climb center (positive starboard wing down).'
    '_FillValue'    default_fill_value };

  var_attr_list.vbdCC = {
    'long_name'     'VBD position'
    'units'         'cm3'
    'comment'       'VBD value relative to VBD center (positive buoyant).'
    '_FillValue'    default_fill_value };

  var_attr_list.sbect_condFreq = {
    'long_name'     'conductivity frequency'
    'units'         'Hz'
    'comment'       'Conductivity frequency from Seabird CT sail.'
    '_FillValue'    default_fill_value };

  var_attr_list.sbect_tempFreq = {
    'long_name'     'temperature frequency'
    'units'         'Hz'
    'comment'       'Temperature frequency from Seabird CT sail.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa1_AirSat = {
    'long_name'     'air saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '%'
    'comment'       'Air saturation from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa1_CalPhase = {
    'long_name'     'optode calibrated phase'
    'units'         'degree'
    'comment'       'Calibrated phase from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa1_O2 = {
    'long_name'     'oxygen molar concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    'comment'       'Oxygen molarity from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa1_TCPhase = {
    'long_name'     'optode temperature compensated phase'
    'units'         'Celsius'
    'comment'       'Temperature-compensated phase from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa1_Temp = {
    'long_name'     'optode temperature'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    'comment'       'Temperature from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa4330_O2 = {
    'long_name'     'oxygen molar concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    'comment'       'Oxygen molarity from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa4330_AirSat = {
    'long_name'     'air saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '%'
    'comment'       'Air saturation from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa4330_Temp = {
    'long_name'     'optode temperature'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    'comment'       'Temperature from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa4330_CalPhase = {
    'long_name'     'optode calibrated phase'
    'units'         'degree'
    'comment'       'Calibrated phase from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.aa4330_TCPhase  = {
    'long_name'     'optode temperature compensated phase'
    'units'         'Celsius'
    'comment'       'Temperature-compensated phase from Aanderaa oxygen optode.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_Chlref1 = {
    'long_name'     'chlorophyll reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck chlorophyll output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_Chlsig1 = {
    'long_name'     'chlorophyll signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck chlorophyll output signal.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_Cdomref1 = {
    'long_name'     'CDOM reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck CDOM output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_Cdomsig1 = {
    'long_name'     'CDOM signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck CDOM output signal.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_ref1 = {
    'long_name'     'backscatter reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_sig1 = {
    'long_name'     'backscatter signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output signal.'
    '_FillValue'    default_fill_value };

  var_attr_list.wl1_temp1 = {
    'long_name'     'bbfl2 triplet temperature'
    'units'         'Celsius'
    'comment'       'WETLabs ECO triplet puck temperature.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_Chlref = {
    'long_name'     'chlorophyll reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck chlorophyll signal output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_Chlsig = {
    'long_name'     'chlorophyll signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck chlorophyll signal output backscatter.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_Cdomref = {
    'long_name'     'CDOM reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck CDOM signal output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_Cdomsig = {
    'long_name'     'CDOM signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck CDOM signal output backscatter.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_wl600ref = {
    'long_name'     'backscatter reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_wl600sig = {
    'long_name'     'backscatter signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output signal.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_wl650ref = {
    'long_name'     'backscatter reference'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output reference.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_wl650sig = {
    'long_name'     'backscatter signal'
    'units'         'counts'
    'comment'       'WETLabs ECO triplet puck backscatter output signal.'
    '_FillValue'    default_fill_value };

  var_attr_list.wlbbfl2vmt_L2VMTtemp = {
    'long_name'     'bbfl2 triplet temperature'
    'units'         'Celsius'
    'comment'       'WETLabs ECO triplet puck temperature.'
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
  dimension_time = struct('name', {'time'}, 'length', {0});
  dimension_dive = struct('name', {'dive'}, 'length', {[]});
  dimension_gpsfix = struct('name', {'gpsfix'}, 'length', {[]});
  dimension_string7 = struct('name', {'string7'}, 'length', {7});
  dimension_string32 = struct('name', {'string32'}, 'length', {32});


  %% Return global and variable metadata in the correct format.
  ncl0_info = struct();
  % Set the dimension names.
  ncl0_info.dimensions = ...
    [dimension_time dimension_dive dimension_gpsfix ...
     dimension_string7 dimension_string32]';
  % Set the global attributes.
  ncl0_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  % Set the variable metadata.
  ncl0_info.variables = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    if regexp(var_name, '^GPSFIX_(ddmmyy|hhmmss)', 'once')
      var_dims = {dimension_gpsfix.name dimension_string7.name};
    elseif regexp(var_name, '^GPSFIX_', 'once')
      var_dims = {dimension_gpsfix.name};
    elseif regexp(var_name, '^STATE_', 'once')
      var_dims = {dimension_time.name dimension_string32.name};
    elseif any(regexp(var_name, '^(GC|SM_CCo)_', 'once')) ...
        || any(regexp(var_name, '^(sbect)_', 'once')) ...
        || any(regexp(var_name, '^(wl1|wlbbfl2vmt)_', 'once')) ...
        || any(regexp(var_name, '^(aa1|aa4330)_', 'once')) ...
        || any(strcmp(var_name, ...
                      {'rec' 'elaps_t' 'elaps_t_0000' 'vbdCC' 'depth' 'head' ...
                       'pitchAng' 'pitchCtl' 'rollAng' 'rollCtl'}))
      var_dims = {dimension_time.name};
    elseif regexp(var_name, '^TGT_NAME', 'once')
      var_dims = {dimension_dive.name dimension_string32.name};
    else
      var_dims = {dimension_dive.name};
    end
    ncl0_info.variables.(var_name).dimensions = var_dims;
    ncl0_info.variables.(var_name).attributes = ...
      cell2struct(var_atts, {'name' 'value'}, 2);
  end

end
