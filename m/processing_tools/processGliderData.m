function data_proc = processGliderData(data_pre, varargin)
%PROCESSGLIDERDATA  Glider data processing applying conversions and derivations.
%
%  Syntax:
%    DATA_PROC = PROCESSGLIDERDATA(DATA_PRE)
%    DATA_PROC = PROCESSGLIDERDATA(DATA_PRE, OPTIONS)
%    DATA_PROC = PROCESSGLIDERDATA(DATA_PRE, OPT1, VAL1, ...)
%
%  DATA_PROC = PROCESSGLIDERDATA(DATA_PRE, ...) processes glider preprocessed 
%  deployment data according to given options, performing the following actions:
%    - Selection of reference sensors: 
%      Time, latitude and longitude sequences are selected.
%      Optionally, bad position values are masked as missing,
%      and missing values are filled by interpolation.
%      These sequences are mandatory, processing aborts if missing.
%    - Selection of optional reference sensors:
%      Navigation depth, pitch, roll and heading sequences are selected, if any.
%      Optionally, missing values are filled by interpolation.
%    - Selection of water velocity sensors.
%      Mean segment water eastward and northward velocity sequences are 
%      selected, if any.
%    - Selection of commanded trajectory sensors:
%      Commanded waypoint latitude and longitude sequences are selected, if any.
%    - Selection of CTD sensor:
%      Conductivity, temperature and pressure sequences are selected, if any.
%      Optionally the CTD timestamp sequence is selected, too.
%    - Selection of chlorophyl sensor:
%      Fluorescense and turbidity sequences are selected, if any.
%      Optionally the FLNTU timestamp sequence is selected, too.
%    - Selection of oxygen sensors:
%      Oxygen concentration and saturation sequences are selected, if any.
%      Optionally the oxygen sensor timestamp and temperature sequences are 
%      selected, too.
%    - Selection of other sensors of interest:
%      Sequences from extra sensors configured in options are selected.
%    - Identification of transects:
%      Transects are identified finding their boundaries at changes of waypoint
%      coordinates.
%    - Computation of distance over ground:
%      The planar distance covered along the trajectory is computed cumulating
%      the distance between consecutive points with valid position coordinates.
%    - Pressure processing:
%      Pressure is optionally filtered using a filter proposed by Seabird.
%      Depth is optionally derived from pressure and longitude sequences.
%    - Identification of casts:
%      Upcasts and downcasts are identified finding local extrema of the chosen 
%      depth or pressure sequence, and the glider vertical direction is deduced.
%    - CTD flow speed derivation:
%      Flow speed through the CTD cell may be derived from selected depth,
%      time and pitch sequences. A nominal pitch value may be given if the pitch
%      sequence is not available.
%    - Sensor lag correction:
%      Any already selected sequence may be corrected from sensor lag effects.
%      The sensor lag time constant may be provided as option or estimated from
%      identified consecutive casts with opposite directions.
%    - Thermal lag correction:
%      Any temperature and conductivity sequence pair may be corrected from
%      thermal lag effects. The thermal lag parameters may be provided as option
%      or estimated from identified consecutive casts with opposite directions.
%    - Salinity derivation:
%      In situ salinity may be derived from any set of conductivity, temperature
%      and pressure sequences already selected or produced.
%    - Density derivation:
%      In situ density may be derived from any set of conductivity, temperature 
%      and pressure sequences already selected or produced.
%
%  DATA_PRE should be a struct in the format returned by PREPROCESSGLIDERDATA,
%  where each field is a time sequence from the sensor with the same name.
%
%  DATA_PROC is a struct in the same format as DATA_PRE, with time sequences 
%  resulting from the processing actions described above, performed according
%  to the options described below.
%
%  Options may be given in key-value pairs OPT1, VAL1... or in a struct OPTIONS
%  with field names as option keys and field values as option values.
%  Recognized options are:
%    TIME_SENSOR_LIST: time sensor choices.
%      String cell array with the name of time sensors, in order of preference.
%      Default value: {'m_present_time' 'sci_m_present_time'}
%    POSITION_SENSOR_LIST: latitude and longitude sensor choices.
%      Struct array selecting latitude and longitude sensor sets in order
%      of preference, with optional mask of valid position readings.
%      It should have the following fields:
%        LATITUDE: latitude sensor name.
%        LONGITUDE: longitude sensor name.
%      It may have the following optional fields (empty or missing):
%        POSITION_STATUS: position status sensor name.
%        POSITION_STATUS_GOOD: position status good values.
%        POSITION_STATUS_BAD:  position status bad values.
%      Default value: struct('latitude',  {'m_gps_lat' 'm_lat'}, ...
%                            'longitude', {'m_gps_lon' 'm_lon'}, ...
%                            'position_status',      {'m_gps_status' []}, ...
%                            'position_status_good', { 0 []}, ...
%                            'position_status_bad',  {[] []})
%    DEPTH_SENSOR_LIST: depth sensor choices.
%      String cell array with the name of depth sensors, in order of preference.
%      Default value: {'m_depth'}
%    ATTITUDE_SENSOR_LIST: roll and pitch sensor choices.
%      Struct array selecting roll and pitch sensor sets, in order of 
%      preference. It should have the following fields:
%        ROLL: roll sensor name.
%        PITCH: pitch sensor name.
%      Default value: struct('roll', {'m_roll'}, 'pitch', {'m_pitch'})
%    HEADING_SENSOR_LIST: heading sensor choices.
%      String cell array with the name of heading sensors, in order of 
%      preference.
%      Default value: {'m_heading'}
%    WAYPOINT_SENSOR_LIST: waypoint latitude and longitude sensor choices.
%      Struct array selecting waypoint latitude and longitude sensor sets in
%      order of preference. It should have the following fields:
%        LATITUDE: waypoint latitude sensor name.
%        LONGITUDE: waypoint longitude sensor name.
%      Default value: struct('latitude',  {'c_wpt_lat'}, ...
%                            'longitude', {'c_wpt_lon'})
%    WATER_VELOCITY_SENSOR_LIST: water velocity sensor choices.
%      Struct array selecting water velocity coordinate sensor sets in order of
%      preference. It should have the following fields:
%        VELOCITY_EASTWARD: water velocity eastward component sensor name.
%        VELOCITY_NORTHWARD: water velocity northward component sensor name.
%      Default value: struct('velocity_eastward', {'m_final_water_vx'}, ...
%                            'velocity_northward', {'m_final_water_vy'})
%    CTD_SENSOR_LIST: CTD sensor set choices.
%      Struct array selecting the CTD sensor sets, in order of preference.
%      It should have the following fields:
%        CONDUCTIVITY: conductivity sensor name.
%        TEMPERATURE: temperature sensor name.
%        PRESSURE: pressure sensor name.
%      It may have the following optional fields (empty or missing):
%        TIME: CTD time sensor name.
%      Default value: struct('conductivity', {'sci_water_cond'        'm_water_cond'}, ...
%                            'temperature',  {'sci_water_temp'        'm_water_temp'}, ...
%                            'pressure',     {'sci_water_pressure'    'm_water_pressure'}, ...
%                            'time',         {'sci_ctd41cp_timestamp' []})
%    FLNTU_SENSOR_LIST: fluorescence and turbidity sensor set choices.
%      Struct array selecting the fluorescence and turbidity sensor sets in 
%      order of preference. It should have the following fields:
%        CHLOROPHYLL: chlorophyl sensor name.
%        TURBIDITY: turbidity sensor name.
%      It may have the following optional fields (empty or missing):
%        TIME:  FLNTU timestamp sensor name.
%      Default value: struct('chlorophyll', {'sci_flntu_chlor_units'}, ...
%                            'turbidity',   {'sci_flntu_turb_units'}, ...
%                            'time',        {'sci_flntu_timestamp'})
%    OXYGEN_SENSOR_LIST: oxygen sensor set choices.
%      Struct array selecting the oxygen sensor sets, in order of preference.
%      It should have the following fields:
%        OXYGEN_CONCENTRATION: concentration of oxygen sensor name.
%        OXYGEN_SATURATION: saturation of oxygen sensor name.
%      It may have the following optional fields (empty or missing):
%        TEMPERATURE: oxygen temperature sensor name.
%        TIME: oxygen timestamp sensor name.
%      Default value: struct('oxygen_concentration', {'sci_oxy3835_oxygen'}, ...
%                            'oxygen_saturation',    {'sci_oxy3835_saturation'}, ...
%                            'temperature',          {'sci_oxy3835_temp'}, ...
%                            'time',                 {'sci_oxy3835_timestamp'})
%    EXTRA_SENSOR_LIST: other sensor set choices.
%      Struct selecting other sensor sets of interest. Each field in the struct
%      represents a sensor set of interest. The field name is the sensor set 
%      name (e.g. battery_info) and the field value should be a struct array 
%      with the sensor set choices in order of preference, where field names are
%      the final sensor names (fields in struct DATA_PROC, e.g. 
%      battery_nominal_capacity and battery_total_consumption) and field values 
%      are the original sensor name choices (fields in struct DATA_PRE, e.g. 
%      f_coulomb_battery_capacity m_coulomb_amphr_total).
%      Default value: {}
%    TIME_FILLING: time interpolation switch.
%      Boolean setting whether time missing values should be filled by 
%      interpolation.
%      Default value: false
%    POSITION_FILLING: position interpolation switch.
%      Boolean setting whether latitude and longitude missing values should be 
%      filled by interpolation.
%      Default value: false
%    DEPTH_FILLING: depth interpolation switch.
%      Boolean setting whether depth missing values should be filled by
%      interpolation.
%      Default value: false
%    ATTITUDE_FILLING: attitude interpolation switch.
%      Boolean setting whether roll and pitch missing values should be filled by
%      interpolation.
%      Default value: false
%    HEADING_FILLING: heading interpolation switch.
%      Boolean setting whether heading missing values should be filled by
%      interpolation.
%      Default value: false
%    WAYPOINT_FILLING: waypoint interpolation switch.
%      Boolean setting whether waypoint latitude and longitude missing values 
%      should be filled with the previous valid value.
%      Default value: true
%    PRESSURE_CONVERSION: pressure unit conversion switch.
%      Boolean setting whether pressure should be converted from bars to
%      decibars.
%      Default value: true
%    PRESSURE_FILTERING: Seabird pressure filtering switch.
%      Boolean setting whether pressure should be filtered with low pass filter 
%      described in the Seabird Data Processing Manual.
%      Default value: true
%    PRESSURE_FILTER_CONSTANT: Seabird pressure filter parameter.
%      Non negative number, the time constant for the Seabird low-pass filter.
%      Default value: 4 (recommended by Seabird Data Processing Manual)
%    DEPTH_CTD_DERIVATION: depth from CTD pressure derivation.
%      Boolean setting whether a depth sequence should be derived from CTD
%      pressure readings.
%      Default value: true
%    PROFILING_SEQUENCE: depth or pressure sequence choices for cast identification.
%      String cell array with the names of the pressure or depth sequence to be
%      used for cast identification, in order of preference.
%      Default value: {'depth_ctd' 'depth'}
%    PROFILING_SEQUENCE_FILLING: profiling sequence interpolation switch.
%      Boolean setting whether the missing values in the profiling sequence
%      should be filled by interpolation before cast identification.
%      Default value: true
%    PROFILE_MIN_RANGE: minimum depth range allowed for a valid profile.
%      Non negative real number setting the minimum depth range threshold for
%      cast validation. If the difference between the maximum and the minimum 
%      depth reached in a cast is less than the given threshold, the cast will
%      be invalid. Set it to zero to prevent discarting any cast.
%      Default value: 10
%    PROFILE_MAX_GAP_RATIO: maximum gap depth ratio allowed for a valid profile.
%      Real number (in [0..1]) setting the maximum gap ratio threshold for cast
%      cast validation. A gap is a sequence of consecutive readings in which the
%      value of at least one of the sensors taken into account is invalid.
%      The gap ratio is the ratio of the depth range covered during the gap to
%      the total depth covered of the cast. If the ratio of the largest gap
%      to the total depth range is greater than the given threshold, the cast
%      will be invalid. Set it to 1 to prevent discarting any cast.
%      Default value: 0.8
%    FLOW_CTD_LIST: CTD flow speed derivation input set choices.
%      Struct array selecting input sequences for CTD flow speed derivation, in
%      order of preference. It should have the following fields:
%        TIME: time sequence name.
%        DEPTH: depth sequence name.
%        PITCH: pitch sequence name.
%      Each struct in the struct specifies a choice of inputs for CTD flow speed 
%      derivation. Pitch sequence is optional. If missing or empty, the nominal 
%      pitch value may be used (see below). Derivation will be performed only if
%      if the casts are properly identified, and using the first input choice 
%      whose time and depth sequences are available, and either the pitch 
%      sequence is available or the pitch nominal value is set. If no input
%      choice is available, CTD flow speed is not derived.
%      Default value: struct('time', {}, 'depth', {}, 'pitch', {}) (no derivation)
%    FLOW_CTD_PITCH_VALUE: nominal pitch value for CTD flow speed derivation.
%      Number with the nominal pitch value (radians) to use for CTD flow speed
%      derivation when no pitch sequence is available.
%      Default value: [] (no default pitch value)
%    FLOW_CTD_MIN_PITCH: low pitch threshold for CTD flow speed derivation.
%      Number with the minimum absolute pitch value below which flow speed is 
%      considered invalid during CTD flow speed derivation.
%      Default value: 0 (all values are valid).
%    FLOW_CTD_MIN_VELOCITY: low velocity threshold for CTD flow speed derivation.
%      Number with the minimum absolute vertical velocity value below which 
%      flow speed is considered invalid during CTD flow speed derivation.
%      Default value: 0 (all values are valid).
%    SENSOR_LAG_LIST: sensor lag correction settings.
%      Struct array specifying which sequences should be produced by correcting 
%      the sensor lag in the corresponding original sensor sequences.
%      It should have the following fields:
%        CORRECTED: string with the name for the corrected sequence (field in 
%          struct DATA_PROC).
%        ORIGINAL: string with the name of the original sequence (field in 
%          struct DATA_PROC).
%        PARAMETERS: non negative number as predefined time constant, or string 
%          'auto' for automatic estimation from casts.
%      It may have the following optional fields (empty or missing):
%        TIME: string cell array with the names of the time sequence to use 
%          for estimation or correction, in order of preference.
%          Default value: {'time'}
%        DEPTH: string cell array with the names of the depth sequence to use 
%          for estimation or correction, in order of preference.
%          Default value: {'depth'}
%        FLOW: string cell array with the names of the flow sequence to use
%          for estimation or correction, in order of preference. This is only
%          used if flow speed is not constant.
%          Default value: {'flow_ctd'}
%        CONSTANT_FLOW: boolean setting whether parameters are static or dynamic
%          (varying with the flow speed).
%          Default value: false
%        ESTIMATOR: function handle or string with the name of the estimator to
%          use to combine the parameter estimates computed for each cast pair.
%          Default value: @nanmedian
%        MINOPTS: struct to pass custom minimization options for estimation,
%          in the format accepted by function FINDSENSORLAGPARAMS.
%          Default value: struct()
%      Each struct in the struct array specifies a sensor lag correction.
%      It will be performed only if the casts are properly identified,
%      all the input sequences are available, and the correction parameter is
%      available too (either given as option or estimated from pair of casts).
%      Default value: struct('corrected', {}, 'original', {}, 'parameters', {})
%    THERMAL_LAG_LIST: thermal lag correction settings.
%      Struct array specifying which temperature and conductivity sequences
%      should be produced by correcting the thermal lag in the corresponding 
%      original sensor sequences.
%      It should have the following fields:
%        CONDUCTIVITY_CORRECTED: string with the name for the corrected
%          conductivity sequence (field in DATA_PROC).
%        TEMPERATURE_CORRECTED: string with the name for the corrected
%          temperature sequence (field in DATA_PROC).
%        CONDUCTIVITY_ORIGINAL: string with the name of the original
%          conductivity sequence (field in DATA_PROC).
%        TEMPERATURE_ORIGINAL: string with the name of the original temperature
%          sequence (field in DATA_PROC).
%        PRESSURE_ORIGINAL: string with the name of the original pressure
%          sequence (field in DATA_PROC).
%        PARAMETERS: numeric vector with predefined thermal lag parameters or
%          string 'auto' for automatic estimation from casts. Parameter vector's
%          should be a 2 element array  when flow speed is constant (error and 
%          error time), and a 4 element array otherwise (error offset, error 
%          slope, error time offset and error time slope).
%      It may have the following optional fields (empty or missing):
%        TIME: string cell array with the names of the time sequence to use 
%          for estimation or correction, in order of preference.
%          Default value: {'time_ctd' 'time'}
%        DEPTH: string cell array with the names of the depth sequence to use 
%          for estimation or correction, in order of preference. Depth is only
%          used to ignore invalid profiles.
%          Default value: {'depth_ctd' 'depth'}
%        FLOW: string cell array with the names of the flow sequence to use
%          for estimation or correction, in order of preference. This is only
%          used if flow speed is not constant.
%          Default value: {'flow_ctd'}
%        CONSTANT_FLOW: boolean setting whether parameters are static or dynamic
%          (varying with the flow speed).
%          Default value: false
%        ESTIMATOR: function handle or string with the name of the estimator to
%          use to combine the parameter estimates computed for each cast pair.
%          Default value: @nanmedian
%        MINOPTS: struct to pass custom minimization options for estimation,
%          in the format accepted by function FINDTHERMALLAGPARAMS.
%          Default value: struct()
%      Each struct in the struct array specifies a thermal lag correction.
%      It will be performed only if casts are properly identified, all the 
%      input sequences are available, and the correction parameters are
%      available too (either given as option or estimated from pair of casts).
%      Default value: struct('conductivity_corrected', {'conductivity_corrected_thermal'}, ...
%                            'temperature_corrected',  {'temperature_corrected_thermal'}, ...         
%                            'conductivity_original', {'conductivity'}, ...
%                            'temperature_original', {'temperature'}, ...
%                            'pressure_original', {'pressure'}, ...
%                            'parameters', {'auto'} )
%    SALINITY_LIST: salinity derivation settings.
%      Struct cell array specifying which salinity sequences should be produced
%      by derivation from corresponding conductivity, temperature and pressure
%      sequences.
%      It should have the following fields:
%        SALINITY: string with the name for the salinity sequence (field in 
%          DATA_PROC).
%        CONDUCTIVITY: string with the name of the original conductivity 
%          sequence (field in DATA_PROC).
%        TEMPERATURE: string with the name of the original temperature 
%          sequence (field in DATA_PROC).
%        PRESSURE: string with the name of the original pressure sequence (field
%          in DATA_PRE).
%      Each struct in the struct array specifies a salinity derivation.
%      It will be performed only if all the original sequences are available.
%      Default value: struct('salinity',     {'salinity     salinity_corrected_thermal'}, ...
%                            'conductivity', {'conductivity conductivity'}, ...
%                            'temperature',  {'temperature  temperature_corrected_thermal'},
%                            'pressure',     {'pressure' '  pressure});
%    DENSITY_LIST: density derivation settings.
%      Struct cell array specifying which salinity sequences should be produced
%      by derivation from corresponding salinity, temperature and pressure
%      sequences.
%      It should have the following fields:
%        DENSITY: string with the name for the density sequence (field in 
%          DATA_PROC).
%        SALINITY: string with the name of the original salinity sequence 
%          (field in DATA_PROC).
%        TEMPERATURE: string with the name of the original temperature 
%          sequence (field in DATA_PROC).
%        PRESSURE: string with the name of the original pressure sequence (field
%          in DATA_PROC).
%      Each struct in the struct array specifies a density derivation.
%      It will be performed only if all the original sequences are available.
%      Default value: struct('density',     {'density'     'density_corrected_thermal'}, ...
%                            'salinity',    {'salinity'    'salinity_corrected_thermal'}, ...
%                            'temperature', {'temperature' 'temperature'}, ...
%                            'pressure',    {'pressure'    'pressure'})
%  
%  Notes:
%    This function is based on the previous work by Tomeu Garau. He is the true
%    glider man.
%
%  See also:
%    PREPROCESSGLIDERDATA
%    FILLINVALIDVALUES
%    FINDTRANSECTS
%    COMPUTECUMULATIVEDISTANCE
%    FINDPROFILES
%    VALIDATEPROFILE
%    APPLYSEABIRDPRESSUREFILTER
%    FINDSENSORLAGPARAMS
%    CORRECTSENSORLAG
%    FINDTHERMALLAGPARAMS
%    CORRECTTHERMALLAG
%    SW_DPTH
%    SW_SALT
%    SW_DENS
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
  
  error(nargchk(1, 55, nargin, 'struct'));
  
  
  %% Configure default values for optional sensor lag settings. 
  default_sensor_lag_time_list = {'time'};
  default_sensor_lag_depth_list = {'depth'};
  default_sensor_lag_flow_list = {'flow_ctd'};
  default_sensor_lag_flow_const = false;
  default_sensor_lag_estimator = @nanmedian;
  default_sensor_lag_minopts = struct();
  
  
  %% Configure default values for optional thermal lag settings. 
  default_thermal_lag_time_list = {'time_ctd' 'time'};
  default_thermal_lag_depth_list = {'depth_ctd' 'depth'};
  default_thermal_lag_flow_list = {'flow_ctd'};
  default_thermal_lag_flow_const = false;
  default_thermal_lag_estimator = @nanmedian;
  default_thermal_lag_minopts = struct();
  
  
  %% Set processing options and default values.
  options = struct();
  options.time_sensor_list = {'m_present_time' 'sci_m_present_time'};
  options.position_sensor_list = ...
    struct('latitude',        {'m_gps_lat'    'm_lat'}, ...
           'longitude',       {'m_gps_lon'    'm_lon'}, ...
           'position_status',      {'m_gps_status' []}, ...
           'position_status_good', {0              []}, ...
           'position_status_bad',  {[]             []});
  options.depth_sensor_list = {'m_depth'};
  options.attitude_sensor_list = struct('roll',  {'m_roll'}, ...
                                        'pitch', {'m_pitch'});
  options.heading_sensor_list = {'m_heading'};
  options.waypoint_sensor_list = struct('latitude',  {'c_wpt_lat'}, ...
                                        'longitude', {'c_wpt_lon'});
  options.water_velocity_sensor_list = ...
    struct('velocity_eastward', {'m_final_water_vx'}, ...
           'velocity_northward', {'m_final_water_vy'});
  options.ctd_sensor_list = ...
    struct('conductivity', {'sci_water_cond'        'm_water_cond'}, ...
           'temperature',  {'sci_water_temp'        'm_water_temp'}, ...
           'pressure',     {'sci_water_pressure'    'm_water_pressure'}, ...
           'time',         {'sci_ctd41cp_timestamp' []});
  options.flntu_sensor_list = ...
    struct('chlorophyll', {'sci_flntu_chlor_units'}, ...
           'turbidity',   {'sci_flntu_turb_units'}, ...
           'time',        {'sci_flntu_timestamp'});
  options.oxygen_sensor_list = ...
    struct('oxygen_concentration', {'sci_oxy3835_oxygen'}, ...
           'oxygen_saturation',    {'sci_oxy3835_saturation'}, ...
           'temperature',          {'sci_oxy3835_temp'}, ...
           'time',                 {'sci_oxy3835_timestamp'});
  options.extra_sensor_list = struct();
  
  options.time_filling = false;
  options.position_filling = false;
  options.depth_filling = false;
  options.attitude_filling = false;
  options.heading_filling = false;
  options.waypoint_filling = false;
  
  options.pressure_conversion = true;
  options.pressure_filtering = true;
  options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  options.depth_ctd_derivation = true;
  
  options.profiling_sequence_list = {'depth_ctd' 'depth'};
  options.profiling_sequence_filling = true;
  options.profile_min_range = 10;
  options.profile_max_gap_ratio = 0.8;
  
  options.flow_ctd_list = struct('time', {}, 'depth', {}, 'pitch', {});
  options.flow_ctd_pitch_value = []; % Before refactoring it was DEG2RAD(26).
  options.flow_ctd_min_pitch = 0;
  options.flow_ctd_min_velocity = 0;
  
  options.sensor_lag_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});
  
  options.thermal_lag_list = ...
    struct('conductivity_corrected', {}, 'temperature_corrected',  {}, ...         
           'conductivity_original',  {}, 'temperature_original', {}, ...
           'pressure_original', {}, 'parameters',  {} );
%   options.thermal_lag_list = ...
%     struct('conductivity_corrected', {'conductivity_corrected_thermal'}, ...
%            'temperature_corrected',  {'temperature_corrected_thermal'}, ...         
%            'conductivity_original',  {'conductivity'}, ...
%            'temperature_original',   {'temperature'}, ...
%            'pressure_original',      {'pressure'}, ...
%            'parameters',             {'auto'} );
  
  options.salinity_list = ...
    struct('salinity',     {'salinity'     'salinity_corrected_thermal'}, ...
           'conductivity', {'conductivity' 'conductivity'}, ...
           'temperature',  {'temperature'  'temperature_corrected_thermal'}, ...
           'pressure',     {'pressure'     'pressure'});
  
  options.density_list = ...
    struct('density',     {'density'     'density_corrected_thermal'}, ...
           'salinity',    {'salinity'    'salinity_corrected_thermal'}, ...
           'temperature', {'temperature' 'temperature'}, ...
           'pressure',    {'pressure'    'pressure'});
  
  
  %% Get options from extra arguments.
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    option_key_list = fieldnames(varargin{1});
    option_val_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = varargin(1:2:end);
    option_val_list = varargin(2:2:end);
  else
    error('glider_toolbox:processGliderData:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:processGliderData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Initialize output variable.
  data_proc = struct();
  
  
  %% Get list of available sensors.
  sensor_list = fieldnames(data_pre);
  
  
  %% Select time coordinate sensor.
  % Find preferred valid time sensor in list of available sensors.
  % For Slocum data please be aware of the efects of program dba_merge,
  % namely the copy of the sci_m_present_time value to the m_present_time for
  % sensor cycles coming from the science board.
  % Convert char array to string cell array if needed (safe if cell array).
  time_sensor_list = cellstr(options.time_sensor_list);
  for time_sensor_idx = 1:numel(time_sensor_list)
    time_sensor = time_sensor_list{time_sensor_idx};
    if ismember(time_sensor, sensor_list) && any(data_pre.(time_sensor) > 0)
      data_proc.time = data_pre.(time_sensor);
      fprintf('Selected time sensor:\n'); ...
      fprintf('  time: %s\n', time_sensor);
      break;
    end
  end
  if ~isfield(data_proc, 'time')
    error('glider_toolbox:processGliderData:MissingSensorTime', ...
          'No time sensor present in data set.');
  end
  
  
  %% Select position coordinate sensors.
  % Find preferred set of valid latitude and longitude sensors in list of 
  % available sensors. Optionally set flagged readings as invalid (NaN),
  % if position status sensor, and good or bad values are available.
  position_sensor_list = options.position_sensor_list;
  for position_sensor_idx = 1:numel(position_sensor_list)
    lat_sensor = position_sensor_list(position_sensor_idx).latitude;
    lon_sensor = position_sensor_list(position_sensor_idx).longitude;
    position_status_sensor = [];
    position_status_good = [];
    position_status_bad = [];
    if isfield(position_sensor_list, 'position_status')
      position_status_sensor = ...
        position_sensor_list(position_sensor_idx).position_status;
    end
    if isfield(position_sensor_list, 'position_status_good')
      position_status_good = ...
        position_sensor_list(position_sensor_idx).position_status_good;
    end
    if isfield(position_sensor_list, 'position_status_bad')
      position_status_bad = ...
        position_sensor_list(position_sensor_idx).position_status_bad;
    end
    if all(ismember({lat_sensor lon_sensor}, sensor_list)) ...
        && ~all(isnan(data_pre.(lat_sensor))) ...
        && ~all(isnan(data_pre.(lon_sensor))) 
      data_proc.latitude = data_pre.(lat_sensor);
      data_proc.longitude = data_pre.(lon_sensor);
      fprintf('Selected position sensors:\n');
      fprintf('  latitude : %s\n', lat_sensor);
      fprintf('  longitude: %s\n', lon_sensor);
      if ~isempty(position_status_sensor) ...
          && ismember(position_status_sensor, sensor_list) ...
          && ~all(isnan(data_pre.(position_status_sensor)))
        position_status_flag = data_pre.(position_status_sensor);
        position_status = true(size(position_status_flag));
        if ~isempty(position_status_good)
            position_status = position_status ...
                            & ismember(position_status_flag, position_status_good);
        end
        if ~isempty(position_status_bad)
            position_status = position_status ...
                            & ~ismember(position_status_flag, position_status_bad);
        end
        data_proc.position_status = position_status;
        data_proc.latitude(~position_status) = nan;
        data_proc.longitude(~position_status) = nan;
        fprintf('  position status     : %s\n', position_status_sensor);
        fprintf('  position status good: %s\n', num2str(position_status_good));
        fprintf('  position status bad : %s\n', num2str(position_status_bad));
      end
      break;
    end
  end
  if ~all(isfield(data_proc, {'latitude' 'longitude'}))
    error('glider_toolbox:processGliderData:MissingSensorPosition', ...
          'No latitude and longitude sensors present in data set.');
  end
  
  
  %% Select depth sensor.
  % Find preferred valid depth sensor in list of available sensors, if any.
  % Convert char array to string cell array if needed (safe if cell array).
  depth_sensor_list = cellstr(options.depth_sensor_list);
  for depth_sensor_idx = 1:numel(depth_sensor_list)
    depth_sensor = depth_sensor_list{depth_sensor_idx};
    if ismember(depth_sensor, sensor_list) ...
        && ~all(isnan(data_pre.(depth_sensor)))
      data_proc.depth = data_pre.(depth_sensor);
      fprintf('Selected depth sensor:\n');
      fprintf('  depth: %s\n', depth_sensor);
      break;
    end
  end
  
  
  %% Select attitude sensors.
  % Find preferred set of valid roll and pitch sensors in list of available 
  % sensors.
  attitude_sensor_list = options.attitude_sensor_list;
  for attitude_sensor_idx = 1:numel(attitude_sensor_list)
    roll_sensor = attitude_sensor_list(attitude_sensor_idx).roll;
    pitch_sensor = attitude_sensor_list(attitude_sensor_idx).pitch;
    if all(ismember({roll_sensor pitch_sensor}, sensor_list)) ...
        && ~all(isnan(data_pre.(roll_sensor))) ...
        && ~all(isnan(data_pre.(pitch_sensor))) 
      data_proc.roll = data_pre.(roll_sensor);
      data_proc.pitch = data_pre.(pitch_sensor);
      fprintf('Selected attitude sensors:\n');
      fprintf('  roll : %s\n', roll_sensor);
      fprintf('  pitch: %s\n', pitch_sensor);
      break;
    end
  end
  
  
  %% Select heading sensor.
  % Find preferred valid heading sensor in list of available sensors, if any.
  % Convert char array to string cell array if needed (safe if cell array).
  heading_sensor_list = cellstr(options.heading_sensor_list);
  for heading_sensor_idx = 1:numel(heading_sensor_list)
    heading_sensor = heading_sensor_list{heading_sensor_idx};
    if ismember(heading_sensor, sensor_list) ...
        && ~all(isnan(data_pre.(heading_sensor)))
      data_proc.heading = data_pre.(heading_sensor);
      fprintf('Selected heading sensor:\n');
      fprintf('  heading: %s\n', heading_sensor);
      break;
    end
  end
  
  
  %% Select waypoint coordinate sensors.
  % Find preferred set of valid waypoint latitude and longitude sensors in list 
  % of available sensors, if any.
  waypoint_sensor_list = options.waypoint_sensor_list;
  for waypoint_sensor_idx = 1:numel(waypoint_sensor_list)
    wpt_lat_sensor = waypoint_sensor_list(waypoint_sensor_idx).latitude;
    wpt_lon_sensor = waypoint_sensor_list(waypoint_sensor_idx).longitude;
    if all(ismember({wpt_lat_sensor wpt_lon_sensor}, sensor_list)) ...
        && ~all(isnan(data_pre.(wpt_lat_sensor))) ...
        && ~all(isnan(data_pre.(wpt_lon_sensor)))
      data_proc.waypoint_latitude = data_pre.(wpt_lat_sensor);
      data_proc.waypoint_longitude = data_pre.(wpt_lon_sensor);
      fprintf('Selected waypoint position sensors:\n');
      fprintf('  waypoint_latitude : %s\n', wpt_lat_sensor);
      fprintf('  waypoint_longitude: %s\n', wpt_lon_sensor);
      break;
    end
  end
  
  
  %% Select segment mean water velocity component sensor.
  % Find preferred set of valid segment mean water velocity sensors in list of 
  % available sensors, if any.
  water_velocity_sensor_list = options.water_velocity_sensor_list;
  for water_velocity_sensor_idx = 1:numel(water_velocity_sensor_list)
    wat_vel_north_sensor = ...
      water_velocity_sensor_list(water_velocity_sensor_idx).velocity_northward;
    wat_vel_east_sensor = ...
      water_velocity_sensor_list(water_velocity_sensor_idx).velocity_eastward;
    if all(ismember({wat_vel_north_sensor wat_vel_east_sensor}, sensor_list)) ...
        && ~all(isnan(data_pre.(wat_vel_north_sensor))) ...
        && ~all(isnan(data_pre.(wat_vel_east_sensor)))
      data_proc.water_velocity_northward = data_pre.(wat_vel_north_sensor);
      data_proc.water_velocity_eastward = data_pre.(wat_vel_east_sensor);
      fprintf('Selected water velocity sensors:\n');
      fprintf('  water_velocity_northward: %s\n', wat_vel_north_sensor);
      fprintf('  water_velocity_eastward : %s\n', wat_vel_east_sensor);
      break;
    end
  end
  
  
  %% Select CTD sensor.
  % Find preferred valid CTD sensor set in list of available sensors, if any.
  ctd_sensor_list = options.ctd_sensor_list;
  for ctd_sensor_idx = 1:numel(ctd_sensor_list)
    cond_sensor = ctd_sensor_list(ctd_sensor_idx).conductivity;
    temp_sensor = ctd_sensor_list(ctd_sensor_idx).temperature;
    pres_sensor = ctd_sensor_list(ctd_sensor_idx).pressure;
    time_ctd_sensor = [];
    if isfield(ctd_sensor_list, 'time')
      time_ctd_sensor = ctd_sensor_list(ctd_sensor_idx).time;
    end
    if all(ismember({cond_sensor temp_sensor pres_sensor}, sensor_list)) ...
        && any(data_pre.(cond_sensor) > 0) ...
        && any(data_pre.(temp_sensor) > 0) ...
        && any(data_pre.(pres_sensor) > 0)
      data_proc.conductivity = data_pre.(cond_sensor);
      data_proc.temperature = data_pre.(temp_sensor);
      data_proc.pressure = data_pre.(pres_sensor);
      fprintf('Selected CTD sensors:\n');
      fprintf('  conductivity: %s\n', cond_sensor);
      fprintf('  temperature : %s\n', temp_sensor);
      fprintf('  pressure    : %s\n', pres_sensor);
      if ~isempty(time_ctd_sensor) ...
          && ismember(time_ctd_sensor, sensor_list) ...
          && any(data_pre.(time_ctd_sensor) > 0)
        data_proc.time_ctd = data_pre.(time_ctd_sensor);
        fprintf('  time_ctd    : %s\n', time_ctd_sensor);
      end
      break;
    end
  end
  
  
  %% Select fluorescence (chlorophyll) and turbidity sensor.
  % Find preferred set of valid fluorescence and turbidity sensors in list of 
  % available sensors, if any.
  flntu_sensor_list = options.flntu_sensor_list;
  for flntu_sensor_idx = 1:numel(flntu_sensor_list)
    chlr_sensor = flntu_sensor_list(flntu_sensor_idx).chlorophyll;
    turb_sensor = flntu_sensor_list(flntu_sensor_idx).turbidity;
    time_flntu_sensor = [];
    if isfield(flntu_sensor_list, 'time')
      time_flntu_sensor = flntu_sensor_list(flntu_sensor_idx).time;
    end
    if all(ismember({chlr_sensor turb_sensor}, sensor_list)) ...
        && any(data_pre.(chlr_sensor) > 0) ...
        && any(data_pre.(turb_sensor) > 0)
      data_proc.chlorophyll = data_pre.(chlr_sensor);
      data_proc.turbidity = data_pre.(turb_sensor);
      fprintf('Selected chlorophyll and turbitidy sensors:\n');
      fprintf('  chlorophyll: %s\n', chlr_sensor);
      fprintf('  turbidity  : %s\n', turb_sensor);
      if ~isempty(time_flntu_sensor) ...
          && ismember(time_flntu_sensor, sensor_list) ...
          && any(data_pre.(time_flntu_sensor) > 0)
        data_proc.time_flntu = data_pre.(time_flntu_sensor);
        fprintf('  time_flntu : %s\n', time_flntu_sensor);
      end
      break;
    end
  end
  
  
  %% Select oxygen sensors.
  % Find preferred set of valid oxygen sensors in list of available sensors, 
  % if any.
  oxygen_sensor_list = options.oxygen_sensor_list;
  for oxygen_sensor_idx = 1:numel(oxygen_sensor_list)
    oxy_con_sensor = oxygen_sensor_list(oxygen_sensor_idx).oxygen_concentration;
    oxy_sat_sensor = oxygen_sensor_list(oxygen_sensor_idx).oxygen_saturation;
    time_oxygen_sensor = [];
    temperature_oxygen_sensor = [];
    if isfield(oxygen_sensor_list, 'time')
      time_oxygen_sensor = oxygen_sensor_list(oxygen_sensor_idx).time;
    end
    if isfield(oxygen_sensor_list, 'temperature')
      temperature_oxygen_sensor = ...
        oxygen_sensor_list(oxygen_sensor_idx).temperature;
    end
    if all(ismember({oxy_con_sensor oxy_sat_sensor}, sensor_list)) ...
        && any(data_pre.(oxy_con_sensor) > 0) ...
        && any(data_pre.(oxy_sat_sensor) > 0)
      data_proc.oxygen_concentration = data_pre.(oxy_con_sensor);
      data_proc.oxygen_saturation = data_pre.(oxy_sat_sensor);
      fprintf('Selected oxygen sensors:\n');
      fprintf('  oxygen_concentration: %s\n', oxy_con_sensor);
      fprintf('  oxygen_saturation   : %s\n', oxy_sat_sensor);
      if ~isempty(time_oxygen_sensor) ...
          && ismember(time_oxygen_sensor, sensor_list) ...
          && any(data_pre.(time_oxygen_sensor) > 0)
        data_proc.time_oxygen = data_pre.(time_oxygen_sensor);
        fprintf('  time_oxygen         : %s\n', time_oxygen_sensor);
      end
      if ~isempty(temperature_oxygen_sensor) ...
          && ismember(temperature_oxygen_sensor, sensor_list) ...
          && any(data_pre.(temperature_oxygen_sensor) > 0)
        data_proc.temperature_oxygen = data_pre.(temperature_oxygen_sensor);
        fprintf('  temperature_oxygen  : %s\n', temperature_oxygen_sensor);
      end
      break;
    end
  end
  
  
  %% Select any other extra sensor.
  % Add the preferred set of valid extra sensors available in list of sensors,
  % for each extra sensor option given.
  extra_sensor_option_name_list = fieldnames(options.extra_sensor_list);
  for extra_sensor_option_name_idx = 1:numel(extra_sensor_option_name_list)
    extra_sensor_option_name = ...
      extra_sensor_option_name_list{extra_sensor_option_name_idx};
    extra_sensor_option_value_list = ...
      options.extra_sensor_list.(extra_sensor_option_name);
    extra_sensor_option_field_list = ...
      fieldnames(extra_sensor_option_value_list);
    % Find preferred set of valid extra sensors in list of available sensors, 
    % if any.
    for extra_sensor_value_idx = 1:numel(extra_sensor_option_value_list)
      extra_sensor_struct = ...
        extra_sensor_option_value_list(extra_sensor_value_idx);
      if all(structfun(@(s) isempty(s) || (ismember(s, sensor_list) && any(data_pre.(s) > 0)), ...
                       extra_sensor_struct))
        fprintf('Selected %s sensors:\n', extra_sensor_option_name);
        for extra_sensor_field_idx = 1:numel(extra_sensor_option_field_list)
          extra_sensor_field = ...
            extra_sensor_option_field_list{extra_sensor_field_idx};
          extra_sensor_name = extra_sensor_struct.(extra_sensor_field);
          if ~isempty(extra_sensor_name)
            data_proc.(extra_sensor_field) = data_pre.(extra_sensor_name);
            fprintf('  %-24s: %s\n', extra_sensor_field, extra_sensor_name);
          end
        end
        break
      end
    end
  end
    
  
  %% Fill missing time readings, if needed.
  % Regular sampling is assumed on time gaps.
  if options.time_filling && isfield(data_proc, 'time')
    fprintf('Filling missing time readings...\n');
    data_proc.time = ...
      fillInvalidValues(data_proc.time, 'linear');
  end
  
  
  %% Fill missing position readings, if needed.
  % Use linear interpolation of valid coordinate readings.
  if options.position_filling ...
      && all(isfield(data_proc, {'time' 'latitude' 'longitude'}))
    fprintf('Filling missing position readings...\n');
    data_proc.latitude = ...
      fillInvalidValues(data_proc.time, data_proc.latitude, 'linear');
    data_proc.longitude = ...
      fillInvalidValues(data_proc.time, data_proc.longitude, 'linear');
  end
  
  
  %% Fill missing depth readings, if needed.
  % Use linear interpolation of valid depth readings.
  if options.depth_filling && all(isfield(data_proc, {'time' 'depth'}))
    fprintf('Filling missing depth readings...\n');
    data_proc.depth = ...
      fillInvalidValues(data_proc.time, data_proc.depth, 'linear');
  end
  
  
  %% Fill missing attitude readings, if needed.
  % Use linear interpolation of valid roll and pitch readings.
  if options.attitude_filling && ...
      all(isfield(data_proc, {'time' 'roll' 'pitch'}))
    fprintf('Filling missing attitude readings...\n');
    data_proc.roll = ...
      fillInvalidValues(data_proc.time, data_proc.roll, 'linear');
    data_proc.pitch = ...
      fillInvalidValues(data_proc.time, data_proc.pitch, 'linear');
  end
  
  
  %% Fill missing heading readings, if needed.
  % Use linear interpolation of valid coordinate readings.
  if options.heading_filling && all(isfield(data_proc, {'time' 'heading'}))
    fprintf('Filling missing heading readings...\n');
    data_proc.heading = ...
      fillInvalidValues(data_proc.time, data_proc.heading, 'linear');
  end
  
  
  %% Fill missing waypoint coordinate readings, if needed.
  % Waypoint coordinates are assumed constant until next valid waypoint 
  % coordinate reading.
  if options.waypoint_filling ...
      && all(isfield(data_proc, {'waypoint_latitude' 'waypoint_longitude'}))
    fprintf('Filling missing commanded waypoint readings...\n');
    data_proc.waypoint_latitude = ...
      fillInvalidValues(data_proc.waypoint_latitude, 'previous');
    data_proc.waypoint_longitude = ...
      fillInvalidValues(data_proc.waypoint_longitude, 'previous');
  end
  
  
  %% Identify transect bounadaries, if waypoint coordinates available.
  if all(isfield(data_proc, {'waypoint_latitude' 'waypoint_longitude'}))
    fprintf('Computing transect index by transect boundary identification...\n');
    data_proc.transect_index = ...
      findTransects(data_proc.waypoint_latitude, data_proc.waypoint_longitude);
  end
  
  
  %% Compute navigated distance over ground.
  if all(isfield(data_proc, {'latitude' 'longitude'}))
    fprintf('Computing covered horizontal distance...\n');
    data_proc.distance_over_ground = ...
      computeCumulativeDistance(data_proc.latitude, data_proc.longitude);
  end
  
  
  %% Convert and filter pressure, if pressure available and needed.
  if isfield(data_proc, 'pressure')
    % Convert pressure from bars to decibars, if needed (by later processings).
    if options.pressure_conversion
      fprintf('Performing pressure unit conversion (bars to decibars)...\n');
      data_proc.pressure = 10 * data_proc.pressure;
    end
    % Apply pressure filter, if needed.
    if options.pressure_filtering
      if isfield(data_proc, 'time_ctd')
        fprintf('Filtering pressure sequence using CTD time stamp...\n');
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time_ctd, data_proc.pressure, ...
                                     options.pressure_filter_constant);
      elseif isfield(data_proc, 'time')
        fprintf('Filtering pressure sequence using global time stamp...\n');
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time, data_proc.pressure, ...
                                     options.pressure_filter_constant);
      end
    end
  end
  
  
  %% Derive depth from pressure, if pressure available and needed.
  if options.depth_ctd_derivation ...
      && all(isfield(data_proc, {'pressure' 'latitude'}))
    fprintf('Deriving CTD depth from pressure and latitude readings...\n');
    data_proc.depth_ctd = sw_dpth(data_proc.pressure, data_proc.latitude);
  end
  
  
  %% Identify start and end of profiles.
  % Find preferred profiling sequence (e.g. navigation depth, CTD derived depth,
  % pressure ...) present in the already processed data.
  profiling_sequence_list = cellstr(options.profiling_sequence_list);
  profiling_sequence_avail = false;
  for profiling_sequence_idx = 1:numel(profiling_sequence_list)
    profiling_sequence = profiling_sequence_list{profiling_sequence_idx};
    if isfield(data_proc, profiling_sequence) ...
        && ~all(isnan(data_proc.(profiling_sequence)))
      profile_stamp = data_proc.(profiling_sequence);
      profiling_sequence_avail = true;
      break;
    end
  end
  % Compute profile boundaries and direction if profiling sequence available.
  if profiling_sequence_avail
    fprintf('Computing vertical direction and profile index with settings:\n');
    fprintf('  profiling sequence        : %s\n', profiling_sequence);
    fprintf('  profiling sequence filling: %d\n', options.profiling_sequence_filling);
    fprintf('  minimum depth range       : %f\n', options.profile_min_range);
    % Fill profiling sequence invalid values, if needed.
    if (options.profiling_sequence_filling && isfield(data_proc, 'time'))
      profile_stamp = ...
        fillInvalidValues(data_proc.time, profile_stamp, 'linear');
    end
    % Find profile directions and indices.
    [data_proc.profile_index, data_proc.profile_direction] = ...
      findProfiles(profile_stamp, 'range', options.profile_min_range);
  end
  
  
  %% Derive flow speed through CTD cell, if needed and data available.
  % Time and depth sequences must be present in already processed data.
  % Pitch may be also a sequence in processed data (preferred) 
  % or a default pitch value when pitch sequence is not available.
  flow_ctd_avail = false;
  flow_ctd_pitch_value_avail = ~isempty(options.flow_ctd_pitch_value);
  for flow_ctd_option_idx = 1:numel(options.flow_ctd_list)
    flow_ctd_option = options.flow_ctd_list(flow_ctd_option_idx);
    flow_ctd_time_avail = false;
    flow_ctd_depth_avail = false;
    flow_ctd_pitch_avail = false;
    if isfield(data_proc, flow_ctd_option.time) ...
        && any(data_proc.(flow_ctd_option.time) > 0)
      flow_ctd_time = flow_ctd_option.time;
      flow_ctd_time_avail = true;
    end
    if isfield(data_proc, flow_ctd_option.depth) ...
        && ~all(isnan(data_proc.(flow_ctd_option.depth)))
      flow_ctd_depth = flow_ctd_option.depth;
      flow_ctd_depth_avail = true;
    end
    if isfield(flow_ctd_option, 'pitch') ...
        && isfield(data_proc, flow_ctd_option.pitch) ...
        && ~all(isnan(data_proc.(flow_ctd_option.pitch)))
      flow_ctd_pitch = flow_ctd_option.pitch;
      flow_ctd_pitch_avail = true;
    end
    if flow_ctd_time_avail && flow_ctd_depth_avail ...
        && (flow_ctd_pitch_avail || flow_ctd_pitch_value_avail)
      flow_ctd_avail = true;
      break
    end
  end
  flow_ctd_prof_avail = isfield(data_proc, 'profile_index');
  if flow_ctd_prof_avail && flow_ctd_avail
    fprintf('Deriving CTD flow speed with settings:\n');
    fprintf('  depth sequence: %s\n', flow_ctd_depth);
    fprintf('  time  sequence: %s\n', flow_ctd_time);
    if flow_ctd_pitch_avail
      fprintf('  pitch sequence: %s\n', flow_ctd_pitch);
    else
      fprintf('  pitch value   : %f\n', options.flow_ctd_pitch_value);
    end
    fprintf('  pitch minimum threshold            : %f\n', options.flow_ctd_min_pitch);
    fprintf('  vertical velocity minimum threshold: %f\n', options.flow_ctd_min_velocity);
    data_proc.flow_ctd = nan(size(data_proc.time));
    num_profiles = fix(max(data_proc.profile_index));
    for profile_idx = 1:num_profiles
      prof_select = (data_proc.profile_index == profile_idx);
      prof_time = data_proc.(flow_ctd_time)(prof_select);
      prof_depth = data_proc.(flow_ctd_depth)(prof_select);
      if flow_ctd_pitch_avail
        prof_pitch = data_proc.(flow_ctd_pitch)(prof_select);
        prof_vars = {prof_time(:) prof_pitch(:)};
      else
        prof_pitch = options.flow_ctd_pitch_value;
        prof_vars = {prof_time(:)};
      end
      [prof_valid, ~] = validateProfile(prof_depth(:), prof_vars{:}, ...
                                        'range', options.profile_min_range, ...
                                        'gap', options.profile_max_gap_ratio);
      if prof_valid
        data_proc.flow_ctd(prof_select) = ...
          computeCTDFlowSpeed(prof_time, prof_depth, prof_pitch, ...
                              'minpitch', options.flow_ctd_min_pitch, ...
                              'minvel', options.flow_ctd_min_velocity);
      end
    end
  end
 
  
  %% Perform sensor lag estimation and correction, if needed.
  % Sensor, time and depth sequences must be present in already processed data.
  for sensor_lag_option_idx = 1:numel(options.sensor_lag_list)
    % Get sensor lag arguments, setting options to default values if needed.
    % Name of corrected sequence must be specified in option.
    % Name of original sequence must be specified too.
    % Name of time and depth sequences may be specified as list of choices,
    % defaulted if missing.
    % Time constant may be given in option, or estimated from cast pairs.
    sensor_lag_option = options.sensor_lag_list(sensor_lag_option_idx);
    sensor_lag_cor = sensor_lag_option.corrected;
    sensor_lag_raw = sensor_lag_option.original;
    sensor_lag_params = sensor_lag_option.parameters;
    sensor_lag_time_list = default_sensor_lag_time_list;
    sensor_lag_depth_list = default_sensor_lag_depth_list;
    sensor_lag_flow_list = default_sensor_lag_flow_list;
    sensor_lag_flow_const = default_sensor_lag_flow_const;
    sensor_lag_estimator = default_sensor_lag_estimator;
    sensor_lag_minopts = default_sensor_lag_minopts;
    if isfield(sensor_lag_option, 'time') && ~isempty(sensor_lag_option.time)
      sensor_lag_time_list = sensor_lag_option.time;
    end
    if isfield(sensor_lag_option, 'depth') && ~isempty(sensor_lag_option.depth)
      sensor_lag_depth_list = sensor_lag_option.depth;
    end
    if isfield(sensor_lag_option, 'flow') ...
        && ~isempty(sensor_lag_option.flow)
      sensor_lag_flow_list = cellstr(sensor_lag_option.flow);
    end
    if isfield(sensor_lag_option, 'constant_flow') ...
        && ~isempty(sensor_lag_option.constant_flow)
      sensor_lag_flow_const = sensor_lag_option.constant_flow;
    end
    if isfield(sensor_lag_option, 'estimator') ...
        && ~isempty(sensor_lag_option.estimator)
      % Convert estimator function name string to function handle, if needed.
      if ischar(sensor_lag_option.estimator) 
        sensor_lag_estimator = str2func(sensor_lag_option.estimator);
      else
        sensor_lag_estimator = sensor_lag_option.estimator;
      end
    end
    if isfield(sensor_lag_option, 'minopts') ...
        && ~isempty(sensor_lag_option.minopts)
      sensor_lag_minopts = sensor_lag_option.minopts;
    end
    % Check if parameters are given or need to be estimated.
    sensor_lag_num_params = 2;
    if sensor_lag_flow_const
      sensor_lag_num_params = 1;
    end
    if isnumeric(sensor_lag_params) && ...
        (numel(sensor_lag_params) == sensor_lag_num_params)
      % Sensor lag parameters preset.
      sensor_lag_params_avail = true;
    elseif strcmpi(sensor_lag_params, 'auto')
      % Sensor lag parameter estimation requested.
      sensor_lag_params_avail = false;
    else
      % Invalid sensor lag parameter specification.
      error('glider_toolbox:processGliderData:InvalidSensorLagParam', ...
            'Invalid sensor lag settings %d: bad parameter specification.', ...
            sensor_lag_option_idx);
    end
    % Find input fields needed for sensor lag estimation or correction.
    sensor_lag_prof_avail = isfield(data_proc, 'profile_index');
    sensor_lag_raw_avail = false;
    sensor_lag_time_avail = false;
    sensor_lag_depth_avail = false;
    sensor_lag_flow_avail = false;
    if isfield(data_proc, sensor_lag_raw) ...
        && ~all(isnan(data_proc.(sensor_lag_raw)))
      sensor_lag_raw_avail = true;
    end
    for sensor_lag_time_idx = 1:numel(sensor_lag_time_list)
      sensor_lag_time = sensor_lag_time_list{sensor_lag_time_idx};
      if isfield(data_proc, sensor_lag_time) ...
          && any(data_proc.(sensor_lag_time) > 0)
        sensor_lag_time_avail = true;
        break
      end
    end
    for sensor_lag_depth_idx = 1:numel(sensor_lag_depth_list)
      sensor_lag_depth = sensor_lag_depth_list{sensor_lag_depth_idx};
      if isfield(data_proc, sensor_lag_depth)
        sensor_lag_depth_avail = true;
        break
      end
    end
    for sensor_lag_flow_idx = 1:numel(sensor_lag_flow_list)
      sensor_lag_flow = sensor_lag_flow_list{sensor_lag_flow_idx};
      if isfield(data_proc, sensor_lag_flow) ...
          && ~all(isnan(data_proc.(sensor_lag_flow)))
        sensor_lag_flow_avail = true;
        break
      end
    end
    % Perform sensor lag correction if needed input fields are there.
    if sensor_lag_prof_avail && sensor_lag_raw_avail ...
        && sensor_lag_time_avail && sensor_lag_depth_avail ...
        && (sensor_lag_flow_const || sensor_lag_flow_avail)
      num_profiles = fix(max(data_proc.profile_index));
      % Estimate sensor lag time constant, if needed.
      if sensor_lag_params_avail
        % Sensor lag time constant given (do not perform estimation).
        sensor_lag_constants = sensor_lag_params;
      else
        fprintf('Performing sensor lag parameter estimation %d with settings:\n', sensor_lag_option_idx);
        fprintf('  sensor sequence    : %s\n', sensor_lag_raw);
        fprintf('  time sequence      : %s\n', sensor_lag_time);
        fprintf('  depth sequence     : %s\n', sensor_lag_depth);
        if ~sensor_lag_flow_const
          fprintf('  flow speed sequence: %s\n', sensor_lag_flow);
        end
        fprintf('  estimator          : %s\n', func2str(sensor_lag_estimator));
        % Estimate sensor lag time constant for each pofile.
        sensor_lag_estimates = nan(num_profiles-1, sensor_lag_num_params);
        sensor_lag_exitflags = nan(num_profiles-1, 1);
        sensor_lag_residuals = nan(num_profiles-1, 1);
        for profile_idx = 1:(num_profiles-1)
          prof1_select = (data_proc.profile_index == profile_idx);
          [~, ~, prof1_dir] = ...
            find(data_proc.profile_direction(prof1_select), 1);
          prof1_raw = data_proc.(sensor_lag_raw)(prof1_select);
          prof1_time = data_proc.(sensor_lag_time)(prof1_select);
          prof1_depth = data_proc.(sensor_lag_depth)(prof1_select);
          prof2_select = (data_proc.profile_index == profile_idx + 1);
          [~, ~, prof2_dir] = ...
            find(data_proc.profile_direction(prof2_select), 1);
          prof2_raw = data_proc.(sensor_lag_raw)(prof2_select);
          prof2_time = data_proc.(sensor_lag_time)(prof2_select);
          prof2_depth = data_proc.(sensor_lag_depth)(prof2_select);
          if sensor_lag_flow_const
            prof1_vars = {prof1_time(:) prof1_depth(:) prof1_raw(:)};
            prof2_vars = {prof2_time(:) prof2_depth(:) prof2_raw(:)};
          else
            prof1_flow = data_proc.(sensor_lag_flow)(prof1_select);
            prof1_vars = ...
              {prof1_time(:) prof1_depth(:) prof1_raw(:) prof1_flow(:)};
            prof2_flow = data_proc.(sensor_lag_flow)(prof2_select);
            prof2_vars = ...
              {prof2_time(:) prof2_depth(:) prof2_raw(:) prof2_flow(:)};
          end
          [prof1_valid, ~] = ...
            validateProfile(prof1_depth(:), prof1_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          [prof2_valid, ~] = ...
            validateProfile(prof2_depth(:), prof2_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          prof_opposite_dir = (prof1_dir * prof2_dir < 0);
          if prof1_valid && prof2_valid && prof_opposite_dir
            try
              [sensor_lag_estimates(profile_idx, :), ...
               sensor_lag_exitflags(profile_idx), ...
               sensor_lag_residuals(profile_idx)] = ...
                findSensorLagParams(prof1_vars{:}, prof2_vars{:}, sensor_lag_minopts);
              if sensor_lag_exitflags(profile_idx) <= 0
                 warning('glider_toolbox:processGliderData:SensorLagMinimizationError', ...
                         'Minimization did not converge for casts %d and %d, residual area: %f.', ...
                         profile_idx, profile_idx+1, sensor_lag_residuals(profile_idx));
              end
            catch exception
              fprintf('Sensor lag estimation failed for casts: %d and %d.\n', ...
                      profile_idx, profile_idx+1);
              disp(getReport(exception, 'extended'));
            end
          end
        end
        % Compute statistical estimate from individual profile estimates.
        sensor_lag_constants = sensor_lag_estimator(sensor_lag_estimates);
      end
      % Correct sensor lag, if possible.
      if any(isnan(sensor_lag_constants))
        fprintf('Omiting sensor lag correction %d (%s): %s.\n', ...
                sensor_lag_option_idx, sensor_lag_cor, ...
                'no valid parameters available');
      else
        fprintf('Performing sensor lag correction %d with settings:\n', sensor_lag_option_idx);
        fprintf('  output sensor sequence: %s\n', sensor_lag_cor);
        fprintf('  input sensor sequence : %s\n', sensor_lag_raw);
        fprintf('  input time sequence   : %s\n', sensor_lag_time);
        fprintf('  input depth sequence  : %s\n', sensor_lag_depth);
        if sensor_lag_flow_const
          fprintf('  parameters            : %f\n', sensor_lag_constants);
        else
          fprintf('  input flow sequence   : %s\n', sensor_lag_flow);
          fprintf('  parameters            : %f %f\n', sensor_lag_constants);
        end
        data_proc.(sensor_lag_cor) = nan(size(data_proc.(sensor_lag_raw)));
        for profile_idx = 1:num_profiles
          prof_select = (data_proc.profile_index == profile_idx);
          prof_raw = data_proc.(sensor_lag_raw)(prof_select);
          prof_time = data_proc.(sensor_lag_time)(prof_select);
          prof_depth = data_proc.(sensor_lag_depth)(prof_select);
          if sensor_lag_flow_const
            prof_vars = {prof_time(:) prof_raw(:)};
          else
            prof_flow = data_proc.(sensor_lag_flow)(prof_select);
            prof_vars = {prof_time(:) prof_raw(:) prof_flow(:)};
          end
          [prof_valid, ~] = ...
            validateProfile(prof_depth(:), prof_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          if prof_valid
            prof_cor = correctSensorLag(prof_vars{:}, sensor_lag_constants);
            data_proc.(sensor_lag_cor)(prof_select) = prof_cor;
          end
        end
      end
    end
  end
  
  
  %% Perform thermal lag estimation and correction, if needed.
  % Conductivity, temperature, pressure, and time sequences must be present in 
  % already processed data. CTD flow speed sequence is also required for non 
  % constant flow (unpumped) CTDs.
  for thermal_lag_option_idx = 1:numel(options.thermal_lag_list)
    % Get thermal lag arguments, setting options to default values if needed.
    % Name of corrected conductivity and temperature sequences must be specified in option.
    % Name of original conductivity and temperature sequences must be specified too.
    % Name of flow speed sequence only needed when non-constant flow.
    % Name of time, and flow sequences may be specified as list of choices, defaulted if missing.
    % Parameters may be given in option, or estimated from cast pairs.
    thermal_lag_option = options.thermal_lag_list(thermal_lag_option_idx);
    thermal_lag_cond_cor = thermal_lag_option.conductivity_corrected;
    thermal_lag_temp_cor = thermal_lag_option.temperature_corrected;
    thermal_lag_cond_raw = thermal_lag_option.conductivity_original;
    thermal_lag_temp_raw = thermal_lag_option.temperature_original;
    thermal_lag_pres_raw = thermal_lag_option.pressure_original;
    thermal_lag_params = thermal_lag_option.parameters;
    thermal_lag_time_list = default_thermal_lag_time_list;
    thermal_lag_depth_list = default_thermal_lag_depth_list;
    thermal_lag_flow_list = default_thermal_lag_flow_list;
    thermal_lag_flow_const = default_thermal_lag_flow_const;
    thermal_lag_estimator = default_thermal_lag_estimator;
    thermal_lag_minopts = default_thermal_lag_minopts;
    if isfield(thermal_lag_option, 'time') ...
        && ~isempty(thermal_lag_option.time)
      thermal_lag_time_list = cellstr(thermal_lag_option.time);
    end
    if isfield(thermal_lag_option, 'depth') ...
        && ~isempty(thermal_lag_option.depth)
      thermal_lag_depth_list = cellstr(thermal_lag_option.depth);
    end
    if isfield(thermal_lag_option, 'flow') ...
        && ~isempty(thermal_lag_option.flow)
      thermal_lag_flow_list = cellstr(thermal_lag_option.flow);
    end
    if isfield(thermal_lag_option, 'constant_flow') ...
        && ~isempty(thermal_lag_option.constant_flow)
      thermal_lag_flow_const = thermal_lag_option.constant_flow;
    end
    if isfield(thermal_lag_option, 'estimator');
      % Convert estimator function name string to function handle, if needed.
      if ischar(thermal_lag_option.estimator) 
        thermal_lag_estimator = str2func(thermal_lag_option.estimator);
      else
        thermal_lag_estimator = thermal_lag_option.estimator;
      end
    end
    if isfield(thermal_lag_option, 'minopts');
      thermal_lag_minopts = thermal_lag_option.minopts;
    end
    % Check if parameters are given or need to be estimated.
    thermal_lag_num_params = 4;
    if thermal_lag_flow_const
      thermal_lag_num_params = 2;
    end
    if isnumeric(thermal_lag_params) ...
        && (numel(thermal_lag_params) == thermal_lag_num_params)
      % Thermal lag parameters preset.
      thermal_lag_params_avail = true;
    elseif strcmpi(thermal_lag_params, 'auto')
      % Thermal lag parameter estimation requested.
      thermal_lag_params_avail = false;
    else
      % Invalid thermal lag parameters given.
      error('glider_toolbox:processGliderData:InvalidThermalLagParam', ...
            'Invalid thermal lag settings %d: bad parameter specification.', ...
            thermal_lag_option_idx);
    end
    % Find input fields needed for thermal lag estimation or correction.
    thermal_lag_prof_avail = isfield(data_proc, 'profile_index');
    thermal_lag_cond_raw_avail = false;
    thermal_lag_temp_raw_avail = false;
    thermal_lag_pres_avail = false;
    thermal_lag_time_avail = false;
    thermal_lag_depth_avail = false;
    thermal_lag_flow_avail = false;
    if isfield(data_proc, thermal_lag_cond_raw) ...
        && ~all(isnan(data_proc.(thermal_lag_cond_raw))) 
      thermal_lag_cond_raw_avail = true;
    end
    if isfield(data_proc, thermal_lag_temp_raw) ...
        && ~all(isnan(data_proc.(thermal_lag_temp_raw)))
      thermal_lag_temp_raw_avail = true;
    end
    if isfield(data_proc, thermal_lag_pres_raw) ...
        && ~all(isnan(data_proc.(thermal_lag_pres_raw)))
      thermal_lag_pres_avail = true;
    end
    for thermal_lag_time_idx = 1:numel(thermal_lag_time_list)
      thermal_lag_time = thermal_lag_time_list{thermal_lag_time_idx};
      if isfield(data_proc, thermal_lag_time) ...
          && any(data_proc.(thermal_lag_time) > 0)
        thermal_lag_time_avail = true;
        break;
      end
    end
    for thermal_lag_depth_idx = 1:numel(thermal_lag_depth_list)
      thermal_lag_depth = thermal_lag_depth_list{thermal_lag_depth_idx};
      if isfield(data_proc, thermal_lag_depth) ...
          && ~all(isnan(data_proc.(thermal_lag_depth)))
        thermal_lag_depth_avail = true;
        break
      end
    end
    for thermal_lag_flow_idx = 1:numel(thermal_lag_flow_list)
      thermal_lag_flow = thermal_lag_flow_list{thermal_lag_flow_idx};
      if isfield(data_proc, thermal_lag_flow) ...
          && ~all(isnan(data_proc.(thermal_lag_flow)))
        thermal_lag_flow_avail = true;
        break
      end
    end
    % Perform thermal lag correction if input fields are there.
    if thermal_lag_prof_avail && thermal_lag_cond_raw_avail ...
        && thermal_lag_temp_raw_avail && thermal_lag_pres_avail ...
        && thermal_lag_time_avail && thermal_lag_depth_avail ...
        && (thermal_lag_flow_const || thermal_lag_flow_avail)
      num_profiles = fix(max(data_proc.profile_index));
      % Estimate thermal lag constant, if needed.
      if thermal_lag_params_avail
        % Thermal lag parameters given.
        thermal_lag_constants = thermal_lag_params;
      else
        fprintf('Performing thermal lag parameter estimation %d with settings:\n', thermal_lag_option_idx);
        fprintf('  conductivity sequence: %s\n', thermal_lag_cond_raw);
        fprintf('  temperature sequence : %s\n', thermal_lag_temp_raw);
        fprintf('  pressure sequence    : %s\n', thermal_lag_pres_raw);
        fprintf('  time sequence        : %s\n', thermal_lag_time);
        fprintf('  depth sequence       : %s\n', thermal_lag_depth);
        if ~thermal_lag_flow_const
          fprintf('  flow speed sequence  : %s\n', thermal_lag_flow);
        end
        fprintf('  estimator            : %s\n', func2str(thermal_lag_estimator));
        % Estimate thermal lag time constant for each pofile.
        thermal_lag_estimates = nan(num_profiles-1, thermal_lag_num_params);
        thermal_lag_residuals = nan(num_profiles-1, 1);
        thermal_lag_exitflags = nan(num_profiles-1, 1);
        for profile_idx = 1:(num_profiles-1)
          prof1_select = (data_proc.profile_index == profile_idx);
          [~, ~, prof1_dir] = ...
            find(data_proc.profile_direction(prof1_select), 1);
          prof1_cond = data_proc.(thermal_lag_cond_raw)(prof1_select);
          prof1_temp = data_proc.(thermal_lag_temp_raw)(prof1_select);
          prof1_pres = data_proc.(thermal_lag_pres_raw)(prof1_select);
          prof1_time = data_proc.(thermal_lag_time)(prof1_select);
          prof1_depth = data_proc.(thermal_lag_depth)(prof1_select);
          prof2_select = (data_proc.profile_index == profile_idx + 1);
          [~, ~, prof2_dir] = ...
            find(data_proc.profile_direction(prof2_select), 1);
          prof2_cond = data_proc.(thermal_lag_cond_raw)(prof2_select);
          prof2_temp = data_proc.(thermal_lag_temp_raw)(prof2_select);
          prof2_pres = data_proc.(thermal_lag_pres_raw)(prof2_select);
          prof2_time = data_proc.(thermal_lag_time)(prof2_select);
          prof2_depth = data_proc.(thermal_lag_depth)(prof2_select);
          if thermal_lag_flow_const
            prof1_vars = ...
              {prof1_time(:) prof1_cond(:) prof1_temp(:) prof1_pres(:)};
            prof2_vars = ...
              {prof2_time(:) prof2_cond(:) prof2_temp(:) prof2_pres(:)};
          else
            prof1_flow = data_proc.(thermal_lag_flow)(prof1_select);
            prof1_vars = ...
              {prof1_time(:) prof1_cond(:) prof1_temp(:) prof1_pres(:) prof1_flow(:)};
            prof2_flow = data_proc.(thermal_lag_flow)(prof2_select);
            prof2_vars = ...
              {prof2_time(:) prof2_cond(:) prof2_temp(:) prof2_pres(:) prof2_flow(:)};
          end
          [prof1_valid, ~] = ...
            validateProfile(prof1_depth(:), prof1_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          [prof2_valid, ~] = ...
            validateProfile(prof2_depth(:), prof2_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          prof_opposite_dir = (prof1_dir * prof2_dir < 0);
          if prof1_valid && prof2_valid && prof_opposite_dir
            try
              [thermal_lag_estimates(profile_idx, :), ...
               thermal_lag_exitflags(profile_idx), ...
               thermal_lag_residuals(profile_idx)] = ...
                findThermalLagParams(prof1_vars{:}, prof2_vars{:}, thermal_lag_minopts);
              if thermal_lag_exitflags(profile_idx) <= 0
                 warning('glider_toolbox:processGliderData:ThermalLagMinimizationError', ...
                         'Minimization did not converge for casts %d and %d, residual area: %f.', ...
                         profile_idx, profile_idx+1, thermal_lag_residuals(profile_idx));
              end
            catch exception
              fprintf('Thermal lag estimation failed for casts: %d and %d.\n', ...
                      profile_idx, profile_idx+1);
              disp(getReport(exception, 'extended'));
            end
          end
        end
        % Compute statistical estimate from individual profile estimates.
        % Use feval to allow estimator as either function handle or name string.
        thermal_lag_constants = thermal_lag_estimator(thermal_lag_estimates);
      end
      % Correct thermal lag, if possible.
      if any(isnan(thermal_lag_constants))
        fprintf('Omiting thermal lag correction %d (%s and %s): %s.\n', ...
                thermal_lag_option_idx, thermal_lag_cond_cor, ...
                thermal_lag_temp_cor, 'no valid parameters available');
      else
        fprintf('Performing thermal lag correction %d with settings:\n', thermal_lag_option_idx);
        fprintf('  output temperature sequence : %s\n', thermal_lag_temp_cor);
        fprintf('  output conductivity sequence: %s\n', thermal_lag_cond_cor);
        fprintf('  input conductivity sequence : %s\n', thermal_lag_cond_raw);
        fprintf('  input temperature sequence  : %s\n', thermal_lag_temp_raw);        
        fprintf('  input pressure sequence     : %s\n', thermal_lag_pres_raw);
        fprintf('  input time sequence         : %s\n', thermal_lag_time);
        fprintf('  input depth sequence        : %s\n', thermal_lag_depth);
        if thermal_lag_flow_const
          fprintf('  parameters                  : %f %f\n', thermal_lag_constants);
        else
          fprintf('  input flow sequence         : %s\n', thermal_lag_flow);
          fprintf('  parameters                  : %f %f %f %f\n', thermal_lag_constants);
        end
        data_proc.(thermal_lag_cond_cor) = ...
          nan(size(data_proc.(thermal_lag_cond_raw)));
        data_proc.(thermal_lag_temp_cor) = ...
          nan(size(data_proc.(thermal_lag_temp_raw)));
        for profile_idx = 1:num_profiles
          prof_select = (data_proc.profile_index == profile_idx);
          prof_cond_raw = data_proc.(thermal_lag_cond_raw)(prof_select);
          prof_temp_raw = data_proc.(thermal_lag_temp_raw)(prof_select);
          prof_time = data_proc.(thermal_lag_time)(prof_select);
          prof_depth = data_proc.(thermal_lag_depth)(prof_select);
          if thermal_lag_flow_const
            prof_vars = {prof_time(:) prof_cond_raw(:) prof_temp_raw(:)};
          else
            prof_flow = data_proc.(thermal_lag_flow)(prof_select);
            prof_vars = ...
              {prof_time(:) prof_cond_raw(:) prof_temp_raw(:) prof_flow(:)};
          end
          [prof_valid, ~] = ...
            validateProfile(prof_depth(:), prof_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          if prof_valid
            [prof_temp_cor, prof_cond_cor] = ...
              correctThermalLag(prof_vars{:}, thermal_lag_constants);
            data_proc.(thermal_lag_temp_cor)(prof_select) = prof_temp_cor;
            data_proc.(thermal_lag_cond_cor)(prof_select) = prof_cond_cor;
          end
        end
      end
    end
  end
  
  
  %% Derive salinity from pressure, conductivity and temperature, if available.
  for salinity_option_idx = 1:numel(options.salinity_list)
    salinity_option = options.salinity_list(salinity_option_idx);
    salinity_salt = salinity_option.salinity;
    salinity_cond = salinity_option.conductivity;
    salinity_temp = salinity_option.temperature;
    salinity_pres = salinity_option.pressure;
    if all(isfield(data_proc, {salinity_cond salinity_temp salinity_pres}))
      % Compute salinity from temperature, pressure and conductivity ratio.
      % Input conductivity is given in S/m (Siemens per metre), 
      % but reference conductivity returned by sw_c3515 is in mS/cm.
      fprintf('Deriving salinity %d with settings:\n', salinity_option_idx);
      fprintf('  output salinity sequence   : %s\n', salinity_salt);
      fprintf('  input conductivity sequence: %s\n', salinity_cond);
      fprintf('  input temperature sequence : %s\n', salinity_temp);
      fprintf('  input pressure sequence    : %s\n', salinity_pres);
      data_proc.(salinity_salt) = ...
        sw_salt(data_proc.(salinity_cond) * (10 / sw_c3515()), ...
                data_proc.(salinity_temp), data_proc.(salinity_pres));
    end
  end
  
  
  %% Derive density from pressure, salinity and temperature, if available.
  for density_option_idx = 1:numel(options.density_list)
    density_option = options.density_list(density_option_idx);
    density_dens = density_option.density;
    density_salt = density_option.salinity;
    density_temp = density_option.temperature;
    density_pres = density_option.pressure;
    if all(isfield(data_proc, {density_salt density_temp density_pres}))
      % Compute density from temperature, pressure and salinity.
      fprintf('Deriving density %d with settings:\n', density_option_idx);
      fprintf('  output density sequence   : %s\n', density_dens);
      fprintf('  input salinity sequence   : %s\n', density_salt);
      fprintf('  input temperature sequence: %s\n', density_temp);
      fprintf('  input pressure sequence   : %s\n', density_pres);
      data_proc.(density_dens) = ...
        sw_dens(data_proc.(density_salt), ...
                data_proc.(density_temp), data_proc.(density_pres));
    end
  end
  
end
