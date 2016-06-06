function [data_proc, meta_proc] = processGliderData(data_pre, meta_pre, varargin)
%PROCESSGLIDERDATA  Glider data processing applying conversions and derivations.
%
%  Syntax:
%    [DATA_PROC, META_PROC] = PROCESSGLIDERDATA(DATA_PRE, META_PRE)
%    [DATA_PROC, META_PROC] = PROCESSGLIDERDATA(DATA_PRE, META_PRE, OPTIONS)
%    [DATA_PROC, META_PROC] = PROCESSGLIDERDATA(DATA_PRE, META_PRE, OPT1, VAL1, ...)
%
%  Description:
%    DATA_PROC = PROCESSGLIDERDATA(DATA_PRE, META_PRE, ...) processes 
%    preprocessed data from a glider deploymnet according to given options, 
%    performing the following actions:
%      - Interpolation of reference sensors: 
%        Missing values of time, latitude and longitude sequences are filled 
%        by interpolation if required.
%      - Interpolation of optional reference sensors:
%        Missing values of navigation depth, pitch, roll and heading sequences, 
%        if present, are filled by interpolation if required.
%      - Identification of transects:
%        Transects are identified finding their boundaries at changes of 
%        waypoint coordinates, if they are available.
%      - Computation of distance over ground:
%        The planar distance covered along the trajectory is computed cumulating
%        the distance between consecutive positions with valid coordinates.
%      - Pressure processing:
%        Pressure is optionally filtered using a filter proposed by Seabird.
%        Depth is optionally derived from pressure and longitude sequences.
%      - Identification of casts:
%        Upcasts and downcasts are identified finding local extrema of the
%        chosen depth or pressure sequence, and the glider vertical direction
%        is deduced.
%      - CTD flow speed derivation:
%        Flow speed through the CTD cell may be derived from selected depth,
%        time and pitch sequences. A nominal pitch value may be given if the
%        pitch sequence is not available.
%      - Sensor lag correction:
%        Any already selected sequence may be corrected from sensor lag effects.
%        The sensor lag time constant may be provided as option or estimated
%        from identified consecutive casts with opposite directions.
%      - Thermal lag correction:
%        Any temperature and conductivity sequence pair may be corrected from
%        thermal lag effects. The thermal lag parameters may be provided as
%        option or estimated from identified consecutive casts with opposite
%        directions.
%      - Salinity derivation:
%        In situ salinity may be derived from any set of conductivity,
%        temperature and pressure sequences already selected or produced.
%      - Density derivation:
%        In situ density may be derived from any set of conductivity,
%        temperature and pressure sequences already selected or produced.
%
%    DATA_PRE should be a struct in the format returned by PREPROCESSGLIDERDATA,
%    where each field is a sequence of measurements of the variable with the 
%    same name.
%
%    DATA_PROC is a struct in the same format as DATA_PRE, with time sequences 
%    resulting from the processing actions described above, performed according
%    to the options described below.
%
%    META_PROC is also a struct with one field per variable, adding processing 
%    metadata to any existing metadata in META_PRE.
%
%    Options may be given in key-value pairs OPT1, VAL1... or in a struct
%    OPTIONS with field names as option keys and field values as option values.
%    Recognized options are:
%      TIME_FILLING: time interpolation switch.
%        Boolean setting whether time missing values should be filled by 
%        interpolation.
%        Default value: false
%      POSITION_FILLING: position interpolation switch.
%        Boolean setting whether latitude and longitude missing values should be 
%        filled by interpolation.
%        Default value: false
%      DEPTH_FILLING: depth interpolation switch.
%        Boolean setting whether depth missing values should be filled by
%        interpolation.
%        Default value: false
%      ATTITUDE_FILLING: attitude interpolation switch.
%        Boolean setting whether roll and pitch missing values should be
%        filled by interpolation.
%        Default value: false
%      HEADING_FILLING: heading interpolation switch.
%        Boolean setting whether heading missing values should be filled by
%        interpolation.
%        Default value: false
%      WAYPOINT_FILLING: waypoint interpolation switch.
%        Boolean setting whether waypoint latitude and longitude missing values 
%        should be filled with the previous valid value.
%        Default value: true
%      PRESSURE_FILTERING: Seabird pressure filtering switch.
%        Boolean setting whether pressure should be filtered with low pass
%        filter described in the Seabird Data Processing Manual.
%        Default value: true
%      PRESSURE_FILTER_CONSTANT: Seabird pressure filter parameter.
%        Non-negative number, the time constant for the Seabird low-pass filter.
%        Default value: 4 (recommended by Seabird Data Processing Manual)
%      DEPTH_CTD_DERIVATION: depth from CTD pressure derivation.
%        Boolean setting whether a depth sequence should be derived from CTD
%        pressure readings.
%        Default value: true
%      PROFILING_LIST: cast identification settings.
%        Struct array selecting input sequences and parameters for cast
%        boundary identification, in order of preference. It should have 
%        the following fields:
%          DEPTH: depth or pressure sequence name.
%        It may have the following optional fields (empty or missing):
%          TIME: time sequence name or empty.
%            Default value: []
%          STALL: scalar with the maximum vertical displacement when stalled.
%            Default value: 3
%          SHAKE: scalar with the maximum duration of a vertical shake.
%            Default value: 20
%          INVERSION: scalar with the maximum depth inversion allowed during a
%            cast.
%            Default value: 3
%          INTERRUPT: scalar with the maximum duration of stalled and/or shake 
%            intervals during a cast.
%            Default value: 180
%          LENGTH: scalar with the minimum depth range a cast must span.
%            Default value: 10
%          PERIOD: scalar with the minimum duration range a cast must last.
%            Default value: 0
%        Each struct in the array specifies a choice of inputs for cast 
%        boundary identification. The time sequence is optional and is
%        relevant only if the SHAKE, INTERRUPT or PERIOD options are used.
%        Identification will be performed with the first input choice whose 
%        input sequences are available. If no input choice is available,
%        profiles are not identified.
%        Default value: struct('depth', {'depth' 'depth_ctd' 'depth_ctd'}, ...
%                              'time',  {'time'  'time_ctd'  'time'});
%      PROFILE_MIN_RANGE: minimum depth range allowed for a valid profile.
%        Non-negative real number setting the minimum depth range threshold for
%        cast validation. If the difference between the maximum and the minimum 
%        depth of a valid reading in a cast is less than the given threshold,
%        the cast will be discarded. Set it to 0 to prevent discarding any cast.
%        Default value: 10
%      PROFILE_MAX_GAP_RATIO: maximum gap ratio allowed for a valid profile.
%        Real number (in [0..1]) setting the maximum gap ratio threshold for
%        cast validation. A gap is a sequence of consecutive readings taken
%        during a depth inversion or in which the value of at least one of the
%        involved sensors is invalid. The gap ratio is the ratio of the depth 
%        range covered during the gap over the total depth covered of the cast.
%        If the ratio of the largest gap over the total depth range is greater
%        than the given threshold, the cast will be discarded.
%        Set it to 1 to prevent discarding any cast.
%        Default value: 0.8
%      FLOW_CTD_LIST: CTD flow speed derivation input set choices.
%        Struct array selecting input sequences for CTD flow speed derivation,
%        in order of preference. It should have the following fields:
%          TIME: time sequence name.
%          DEPTH: depth sequence name.
%          PITCH: pitch sequence name.
%        Each struct in the array specifies a choice of inputs for CTD flow 
%        speed derivation. Pitch sequence is optional. If missing or empty, 
%        the nominal pitch value may be used (see FLOW_CTD_PITCH VALUE below).
%        Derivation will be performed only if the casts are properly identified,
%        and using the first input choice whose time and depth sequences are 
%        available, and either the pitch sequence is available or the pitch 
%        nominal value is set. If no input choice is available, CTD flow speed
%        is not derived.
%        Default value: struct('time', {}, 'depth', {}, 'pitch', {})
%      FLOW_CTD_PITCH_VALUE: nominal pitch value for CTD flow speed derivation.
%        Number with the nominal pitch value (radians) to use for CTD flow
%        speed derivation when no pitch sequence is available.
%        Default value: [] (no default pitch value)
%      FLOW_CTD_MIN_PITCH: low pitch threshold for CTD flow derivation.
%        Number with the minimum absolute pitch value below which flow speed is 
%        considered invalid during CTD flow speed derivation.
%        Default value: 0 (all values are valid).
%      FLOW_CTD_MIN_VELOCITY: low velocity threshold for CTD flow derivation.
%        Number with the minimum absolute vertical velocity value below which 
%        flow speed is considered invalid during CTD flow speed derivation.
%        Default value: 0 (all values are valid).
%      SENSOR_LAG_LIST: sensor lag correction settings.
%        Struct array specifying the sequences to produce by correcting
%        the sensor lag in the corresponding original sensor sequences.
%        It should have the following fields:
%          CORRECTED: string with the name for the corrected sequence (field in 
%            struct DATA_PROC).
%          ORIGINAL: string with the name of the original sequence (field in 
%            struct DATA_PROC).
%          PARAMETERS: non-negative number as predefined time constant,
%            or string 'auto' for automatic estimation from casts.
%        It may have the following optional fields (empty or missing):
%          TIME: string cell array with the names of the time sequence to use 
%            for estimation or correction, in order of preference.
%            Default value: {'time'}
%          DEPTH: string cell array with the names of the depth sequence to use 
%            for estimation or correction, in order of preference.
%            Default value: {'depth'}
%          FLOW: string cell array with the names of the flow sequence to use
%            for estimation or correction, in order of preference. This is only
%            used if flow speed is not constant.
%            Default value: {'flow_ctd'}
%          CONSTANT_FLOW: boolean setting whether parameters are static or
%            dynamic (varying with the flow speed).
%            Default value: false
%          ESTIMATOR: function handle or string with the name of the estimator
%            to combine the parameter estimates computed for each cast pair.
%            Default value: @nanmedian
%          MINOPTS: struct to pass custom minimization options for estimation,
%            in the format accepted by function FINDSENSORLAGPARAMS.
%            Default value: struct()
%        Each struct in the struct array specifies a sensor lag correction.
%        It will be performed only if the casts are properly identified,
%        all the input sequences are available, and the correction parameter is
%        available too (either given as option or estimated from pair of casts).
%        Default value: struct('corrected',  {}, ...
%                              'original',   {}, ...
%                              'parameters', {})
%      THERMAL_LAG_LIST: thermal lag correction settings.
%        Struct array specifying the temperature and conductivity sequences
%        to produce by correcting the thermal lag in the corresponding 
%        original sensor sequences.
%        It should have the following fields:
%          CONDUCTIVITY_CORRECTED: string with the name for the corrected
%            conductivity sequence (field in DATA_PROC).
%          TEMPERATURE_CORRECTED: string with the name for the corrected
%            temperature sequence (field in DATA_PROC).
%          CONDUCTIVITY_ORIGINAL: string with the name of the original
%            conductivity sequence (field in DATA_PROC).
%          TEMPERATURE_ORIGINAL: string with the name of the original 
%            temperature sequence (field in DATA_PROC).
%          PRESSURE_ORIGINAL: string with the name of the original 
%            pressure sequence (field in DATA_PROC).
%          PARAMETERS: numeric vector with predefined thermal lag parameters or
%            string 'auto' for automatic estimation from casts. If a vector, it
%            should be a 2 element array when flow speed is constant (error and 
%            error time), and a 4 element array otherwise (error offset, error 
%            slope, error time offset and error time slope).
%        It may have the following optional fields (empty or missing):
%          TIME: string cell array with the names of the time sequence to use 
%            for estimation or correction, in order of preference.
%            Default value: {'time_ctd' 'time'}
%          DEPTH: string cell array with the names of the depth sequence to use 
%            for estimation or correction, in order of preference.
%            Depth is only used to ignore invalid profiles.
%            Default value: {'depth_ctd' 'depth'}
%          FLOW: string cell array with the names of the flow sequence to use
%            for estimation or correction, in order of preference.
%            This is only used if flow speed is not constant.
%            Default value: {'flow_ctd'}
%          CONSTANT_FLOW: boolean setting whether parameters are static or 
%            dynamic (varying with the flow speed).
%            Default value: false
%          ESTIMATOR: function handle or string with the name of the estimator
%             to combine the parameter estimates computed for each cast pair.
%            Default value: @nanmedian
%          MINOPTS: struct to pass custom minimization options for estimation,
%            in the format accepted by function FINDTHERMALLAGPARAMS.
%            Default value: struct()
%        Each struct in the struct array specifies a thermal lag correction.
%        It will be performed only if casts are properly identified, all the 
%        input sequences are available, and the correction parameters are
%        available too (either given as option or estimated from pair of casts).
%        Default value: struct('conductivity_corrected', {'conductivity_corrected_thermal'}, ...
%                              'temperature_corrected',  {'temperature_corrected_thermal'}, ...         
%                              'conductivity_original', {'conductivity'}, ...
%                              'temperature_original', {'temperature'}, ...
%                              'pressure_original', {'pressure'}, ...
%                              'parameters', {'auto'} )
%      SALINITY_LIST: salinity derivation settings.
%        Struct cell array specifying which salinity sequences to produce
%        by derivation from corresponding conductivity, temperature 
%        and pressure sequences. It should have the following fields:
%          SALINITY: string with the name for the salinity sequence
%            (field in DATA_PROC).
%          CONDUCTIVITY: string with the name of the original conductivity 
%            sequence (field in DATA_PROC).
%          TEMPERATURE: string with the name of the original temperature 
%            sequence (field in DATA_PROC).
%          PRESSURE: string with the name of the original pressure sequence
%            (field in DATA_PRE).
%        Each struct in the struct array specifies a salinity derivation.
%        It will be performed only if all the original sequences are available.
%        Default value: struct('salinity',     {'salinity     salinity_corrected_thermal'}, ...
%                              'conductivity', {'conductivity conductivity'}, ...
%                              'temperature',  {'temperature  temperature_corrected_thermal'},
%                              'pressure',     {'pressure' '  pressure});
%      DENSITY_LIST: density derivation settings.
%        Struct cell array specifying which salinity sequences to produce
%        by derivation from corresponding salinity, temperature
%        and pressure sequences. It should have the following fields:
%          DENSITY: string with the name for the density sequence (field in 
%            DATA_PROC).
%          SALINITY: string with the name of the original salinity sequence 
%            (field in DATA_PROC).
%          TEMPERATURE: string with the name of the original temperature 
%            sequence (field in DATA_PROC).
%          PRESSURE: string with the name of the original pressure sequence (field
%            in DATA_PROC).
%        Each struct in the struct array specifies a density derivation.
%        It will be performed only if all the or'time'iginal sequences are available.
%        Default value: struct('density',     {'density'     'density_corrected_thermal'}, ...
%                              'salinity',    {'salinity'    'salinity_corrected_thermal'}, ...
%                              'temperature', {'temperature' 'temperature'}, ...
%                              'pressure',    {'pressure'    'pressure'})
%
%    The following options are deprecated and should not be used:
%      PROFILING_SEQUENCE_LIST: sequence choices for cast identification.
%        String cell array with the names of the pressure or depth sequence to
%        use for cast identification, in order of preference.
%        Deprecated in v1.1.0:
%          Superseeded by PROFILING_LIST.
%      PROFILE_JOIN_SAME_DIR: join consecutive profiles with the same direction.
%        Boolean setting whether consecutive valid profiles with the same 
%        vertical direction should be joined into one.
%        Deprecated in v1.1.0:
%          Superseeded by PROFILING_LIST.
%      PROFILING_SEQUENCE_FILLING: profiling sequence interpolation switch.
%        Boolean setting whether the missing values in the profiling sequence
%        should be filled by interpolation before cast identification.
%        Deprecated in v1.1.0:
%          Not needed anymore since profile identification is consistent and 
%          robust against missing values.
%
%  Notes:
%    This function is based on the previous work by Tomeu Garau. He is the true
%    glider man.
%
%  Examples:
%    [data_proc, meta_proc] = processGliderData(data_pre, meta_pre, options)
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
  
  error(nargchk(2, 56, nargin, 'struct'));
  
  %% Configure default values for optional profile identification settings.
  default_profiling_time = [];
  default_profiling_stall = 3;
  default_profiling_shake = 20;
  default_profiling_inversion = 3;
  default_profiling_interrupt = 180;
  default_profiling_length = 10;
  default_profiling_period =  0;
  
  
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
  options.time_filling = false;
  options.position_filling = false;
  options.depth_filling = false;
  options.attitude_filling = false;
  options.heading_filling = false;
  options.waypoint_filling = false;
  
  options.pressure_filtering = true;
  options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  options.depth_ctd_derivation = true;
  
  options.profiling_list = ...
    struct('depth', {'depth' 'depth_ctd' 'depth_ctd'}, ...
           'time',  {'time'  'time_ctd'  'time'});
    
  options.profiling_sequence_list = [];    % Deprecated in v1.1.0.
  options.profiling_sequence_filling = []; % Deprecated in v1.1.0.
  options.profile_join_same_dir = [];      % Deprecated in v1.1.0.
  
  options.profile_min_range = 10;
  options.profile_max_gap_ratio = 0.8;
  
  options.flow_ctd_list = struct('time', {}, 'depth', {}, 'pitch', {});
  options.flow_ctd_pitch_value = []; % Before refactoring it was DEG2RAD(26).
  options.flow_ctd_min_pitch = 0;
  options.flow_ctd_min_velocity = 0;
  
  options.sensor_lag_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});
  
  options.thermal_lag_list = ...
    struct('conductivity_corrected', {'conductivity_corrected_thermal'}, ...
           'temperature_corrected',  {'temperature_corrected_thermal'}, ...         
           'conductivity_original',  {'conductivity'}, ...
           'temperature_original',   {'temperature'}, ...
           'pressure_original',      {'pressure'}, ...
           'parameters',             {'auto'} );
  
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
  
  
  %% Handle deprecated options.
  % Handle deprecated options for profile identification.
  if ~isempty(options.profiling_sequence_list) ...
      || ~isempty(options.profiling_sequence_filling) ...
      || ~isempty(options.profile_join_same_dir)
    warning('glider_toolbox:findProfiles:DeprecatedOption', ...
            'Deprecated option: %s, %s and %s. See option: %s.', ...
            'profiling_sequence_list', 'profiling_sequence_filling', ...
            'profile_join_same_dir', 'profiling_list');
    options.profiling_list = ...
      struct('depth', options.profiling_sequence_list, ...
             'stall', options.profile_min_range, ...
             'interrupt', options.join * inf, ...
             'inversion', options.join * inf);
  end
  
  
  %% Initialize output variables.
  data_proc = data_pre;
  meta_proc = meta_pre;
  
  
  %% Fill missing time readings, if needed.
  % Regular sampling is assumed on time gaps.
  if options.time_filling && isfield(data_proc, 'time')
    fprintf('Filling missing time readings...\n');
    data_proc.time = ...
      fillInvalidValues(data_proc.time, 'linear');
    meta_proc.time.filling = 'linear';
  end
  
  
  %% Fill missing position readings, if needed.
  % Use linear interpolation of valid coordinate readings.
  if options.position_filling ...
      && all(isfield(data_proc, {'latitude' 'longitude'})) ...
      && any(isfield(data_proc, {'time' 'time_position'}))
    fprintf('Filling missing position readings...\n');
    if isfield(data_proc, 'time_position')
      data_proc.latitude = ...
        fillInvalidValues(data_proc.time_position, data_proc.latitude, ...
                          data_proc.time, nan(size(data_proc.time)), 'linear');
      data_proc.longitude = ...
        fillInvalidValues(data_proc.time_position, data_proc.longitude, ...
                          data_proc.time, nan(size(data_proc.time)), 'linear');
      meta_proc.latitude.sources = ...
        vertcat(cellstr(meta_proc.longitude.sources), ...
                cellstr(meta_proc.time.sources));
      meta_proc.longitude.sources = ...
        vertcat(cellstr(meta_proc.longitude.sources), ...
                cellstr(meta_proc.time.sources));
    else
      data_proc.latitude = ...
        fillInvalidValues(data_proc.time, data_proc.latitude, 'linear');
      data_proc.longitude = ...
        fillInvalidValues(data_proc.time, data_proc.longitude, 'linear');
    end
    meta_proc.latitude.filling = 'linear';
    meta_proc.longitude.filling = 'linear';
  end
  
  
  %% Fill missing depth readings, if needed.
  % Use linear interpolation of valid depth readings.
  if options.depth_filling && all(isfield(data_proc, {'time' 'depth'}))
    fprintf('Filling missing depth readings...\n');
    data_proc.depth = ...
      fillInvalidValues(data_proc.time, data_proc.depth, 'linear');
    meta_proc.depth.filling = 'linear';
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
    meta_proc.roll.filling = 'linear';
    meta_proc.pitch.filling = 'linear';
  end
  
  
  %% Fill missing heading readings, if needed.
  % Use linear interpolation of valid coordinate readings.
  if options.heading_filling && all(isfield(data_proc, {'time' 'heading'}))
    fprintf('Filling missing heading readings...\n');
    data_proc.heading = ...
      fillInvalidValues(data_proc.time, data_proc.heading, 'linear');
    meta_proc.heading.filling = 'linear';
  end
  
  
  %% Fill missing waypoint coordinate readings, if needed.
  % Waypoint coordinates are assumed constant until next valid waypoint 
  % coordinate reading.
  if options.waypoint_filling ...
      && all(isfield(data_proc, {'waypoint_latitude' 'waypoint_longitude'}))
    fprintf('Filling missing commanded waypoint readings...\n');
    data_proc.waypoint_latitude = ...
      fillInvalidValues(data_proc.waypoint_latitude, 'prev');
    data_proc.waypoint_longitude = ...
      fillInvalidValues(data_proc.waypoint_longitude, 'prev');
    meta_proc.waypoint_latitude.filling = 'prev';
    meta_proc.waypoint_longitude.filling = 'prev';
  end
  
  
  %% Identify transect boundaries, if waypoint coordinates available.
  if all(isfield(data_proc, {'waypoint_latitude' 'waypoint_longitude'}))
    fprintf('Computing transect index by transect boundary identification...\n');
    data_proc.transect_index = ...
      findTransects(data_proc.waypoint_latitude, data_proc.waypoint_longitude);
    meta_proc.transect_index.sources = ...
      {'waypoint_latitude' 'waypoint_longitude'}';
    meta_proc.transect_index.method = 'findTransects';
  end
  
  
  %% Compute navigated distance over ground.
  if all(isfield(data_proc, {'latitude' 'longitude'}))
    fprintf('Computing covered horizontal distance...\n');
    data_proc.distance_over_ground = ...
      computeCumulativeDistance(data_proc.latitude, data_proc.longitude);
    meta_proc.distance_over_ground.sources = {'latitude' 'longitude'}';
    meta_proc.distance_over_ground.method = 'computeCumulativeDistance';
  end
  
  
  %% Convert and filter pressure, if pressure available and needed.
  if isfield(data_proc, 'pressure')
    % Apply pressure filter, if needed.
    if options.pressure_filtering
      if isfield(data_proc, 'time_ctd')
        fprintf('Filtering pressure sequence using CTD time stamp...\n');
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time_ctd, data_proc.pressure, ...
                                     options.pressure_filter_constant);
        meta_proc.pressure.sources = ...
          vertcat(cellstr(meta_proc.pressure.sources), ...
                  cellstr(meta_proc.time_ctd.sources));
      elseif isfield(data_proc, 'time')
        fprintf('Filtering pressure sequence using global time stamp...\n');
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time, data_proc.pressure, ...
                                     options.pressure_filter_constant);
        meta_proc.pressure.sources = ...
          vertcat(cellstr(meta_proc.pressure.sources), ...
                  cellstr(meta_proc.time.sources));
      end
      meta_proc.pressure.filter_method = 'applySeabirdPressureFilter';
      meta_proc.pressure.filter_parameters = options.pressure_filter_constant;
    end
  end
  
  
  %% Derive depth from pressure, if pressure available and needed.
  if options.depth_ctd_derivation ...
      && all(isfield(data_proc, {'pressure' 'latitude'}))
    fprintf('Deriving CTD depth from pressure and latitude readings...\n');
    data_proc.depth_ctd = sw_dpth(data_proc.pressure, data_proc.latitude);
    meta_proc.depth_ctd.sources = {'pressure' 'latitude'}';
    meta_proc.depth_ctd.method = 'sw_depth';
  end
  
  
  %% Identify start and end of profiles.
  % Find preferred vertical coordinate sequence
  % (e.g. navigation depth, CTD-derived depth, pressure...)
  % with optional duration sequence (navigation time, CTD timestamp, ...)
  % and identification parameters.
  profiling_avail = false;
  for profiling_option_idx = 1:numel(options.profiling_list)
    profiling_option = options.profiling_list(profiling_option_idx);
    profiling_depth = profiling_option.depth;
    profiling_time = default_profiling_time;
    profiling_stall = default_profiling_stall;
    profiling_shake = default_profiling_shake;
    profiling_inversion = default_profiling_inversion;
    profiling_interrupt = default_profiling_interrupt;
    profiling_length = default_profiling_length;
    profiling_period = default_profiling_period;
    if isfield(profiling_option, 'time') && ~isempty(profiling_option.time)
      profiling_time = profiling_option.time;
    end
    if isfield(profiling_option, 'stall') && ~isempty(profiling_option.stall)
      profiling_stall = profiling_option.stall;
    end
    if isfield(profiling_option, 'shake') && ~isempty(profiling_option.shake)
      profiling_shake = profiling_option.shake;
    end
    if isfield(profiling_option, 'inversion') ...
        && ~isempty(profiling_option.inversion)
      profiling_inversion = profiling_option.inversion;
    end
    if isfield(profiling_option, 'interrupt') ...
        && ~isempty(profiling_option.interrupt)
      profiling_interrupt = profiling_option.interrupt;
    end
    if isfield(profiling_option, 'length') && ~isempty(profiling_option.length)
      profiling_length = profiling_option.legnth;
    end
    if isfield(profiling_option, 'preiod') && ~isempty(profiling_option.period)
      profiling_period = profiling_option.period;
    end
    profiling_depth_avail = false;
    profiling_time_avail = false;
    if isfield(data_proc, profiling_depth) ...
        && ~all(isnan(data_proc.(profiling_depth)))
      profiling_depth_avail = true;
    end
    if isfield(data_proc, profiling_time) ...
        && any(data_proc.(profiling_time) > 0)
      profiling_time_avail = true;
    end
    if profiling_depth_avail
      if isempty(profiling_time)
        profiling_vars = {data_proc.(profiling_depth)};
        profiling_avail = true;
        break
      elseif profiling_time_avail
        profiling_vars = ...
          {data_proc.(profiling_time) data_proc.(profiling_depth)};
        profiling_avail = true;
        break
      end
    end
  end
  % Compute profile boundaries and direction if profiling sequence available.
  if profiling_avail
    fprintf('Computing vertical direction and profile index with settings:\n');
    fprintf('  vertical   sequence: %s\n', profiling_depth);
    if profiling_time_avail
      fprintf('  horizontal sequence: %s\n', profiling_time);
    end
    fprintf('  maximum profile stall     : %f\n', profiling_stall);
    fprintf('  maximum profile shake     : %f\n', profiling_shake);
    fprintf('  maximum profile inversion : %f\n', profiling_inversion);
    fprintf('  maximum profile interrupt : %f\n', profiling_interrupt);
    fprintf('  minimum profile length    : %f\n', profiling_length);
    fprintf('  minimum profile period    : %f\n', profiling_period);
    % Find profile directions and indices.
    [data_proc.profile_index, data_proc.profile_direction] = findProfiles( ...
        profiling_vars{:}, ...
        'stall', profiling_stall, 'shake', profiling_shake, ...
        'inversion', profiling_inversion, 'interrupt', profiling_interrupt, ...
        'length', profiling_length, 'period', profiling_period);
    meta_proc.profile_index.method = 'findProfiles';
    if profiling_time_avail
      meta_proc.profile_index.sources = {profiling_time profiling_depth};
    else
      meta_proc.profile_index.sources = {profiling_depth};
    end
    meta_proc.profile_index.shake = profiling_shake;
    meta_proc.profile_index.stall = profiling_stall;
    meta_proc.profile_index.inversion = profiling_inversion;
    meta_proc.profile_index.interrupt = profiling_interrupt;
    meta_proc.profile_index.length = profiling_length;
    meta_proc.profile_index.period = profiling_period;
    meta_proc.profile_direction.method = meta_proc.profile_index.method;
    meta_proc.profile_direction.sources = meta_proc.profile_index.sources;
    meta_proc.profile_direction.shake = meta_proc.profile_index.shake;
    meta_proc.profile_direction.stall = meta_proc.profile_index.stall;
    meta_proc.profile_direction.inversion = meta_proc.profile_index.inversion;
    meta_proc.profile_direction.interrupt = meta_proc.profile_index.interrupt;
    meta_proc.profile_direction.length = meta_proc.profile_index.length;
    meta_proc.profile_direction.period = meta_proc.profile_index.period;
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
    if flow_ctd_pitch_avail
      meta_proc.flow_ctd.sources = ...
        {flow_ctd_time flow_ctd_depth flow_ctd_pitch 'profile_index'}';
    else
      meta_proc.flow_ctd.sources = ...
        {flow_ctd_time flow_ctd_depth 'profile_index'};
      meta_proc.flow_ctd.pitch_value = options.flow_ctd_pitch_value;
    end
    meta_proc.flow_ctd.method = 'computeCTDFlowSpeed';
    meta_proc.flow_ctd.min_pitch = options.flow_ctd_min_pitch;
    meta_proc.flow_ctd.min_vel = options.flow_ctd_min_velocity;
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
          [prof1_valid, ~, prof1_vars{:}] = ...
            validateProfile(prof1_depth(:), prof1_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          [prof2_valid, ~, prof2_vars{:}] = ...
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
          [prof_valid, ~, prof_vars{:}] = ...
            validateProfile(prof_depth(:), prof_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          if prof_valid
            prof_cor = correctSensorLag(prof_vars{:}, sensor_lag_constants);
            data_proc.(sensor_lag_cor)(prof_select) = prof_cor;
          end
        end
        if sensor_lag_flow_const
          meta_proc.(sensor_lag_cor).sources = ...
            {sensor_lag_raw sensor_lag_time sensor_lag_depth 'profile_index'}';
        else
          meta_proc.(sensor_lag_cor).sources = ...
            {sensor_lag_raw sensor_lag_time sensor_lag_depth sensor_lag_flow 'profile_index'}';
        end
        meta_proc.(sensor_lag_cor).method = 'correctSensorLag';
        meta_proc.(sensor_lag_cor).parameters = sensor_lag_constants;
        if sensor_lag_params_avail
          meta_proc.(sensor_lag_cor).parameter_method = 'preset';
        else
          meta_proc.(sensor_lag_cor).parameter_method = 'findSensorLagParams';
          meta_proc.(sensor_lag_cor).parameter_estimator = func2str(sensor_lag_estimator);
          meta_proc.(sensor_lag_cor).parameter_estimates = sensor_lag_estimates;
          meta_proc.(sensor_lag_cor).parameter_exitflags = sensor_lag_exitflags;
        end
        meta_proc.(sensor_lag_cor).profile_min_range = options.profile_min_range;
        meta_proc.(sensor_lag_cor).profile_gap_ratio = options.profile_max_gap_ratio;
      end
    end
  end
  
  
  %% Perform thermal lag estimation and correction, if needed.
  % Conductivity, temperature, pressure, and time sequences must be present in 
  % already processed data. CTD flow speed sequence is also required for 
  % non-constant flow (unpumped) CTDs.
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
        break
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
          [prof1_valid, ~, prof1_vars{:}] = ...
            validateProfile(prof1_depth(:), prof1_vars{:}, ...
                            'range', options.profile_min_range, ...
                            'gap', options.profile_max_gap_ratio);
          [prof2_valid, ~, prof2_vars{:}] = ...
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
          [prof_valid, ~, prof_vars{:}] = ...
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
        if thermal_lag_flow_const
          meta_proc.(thermal_lag_cond_cor).sources = ...
            {thermal_lag_cond_raw thermal_lag_temp_raw thermal_lag_pres_raw ...
             thermal_lag_time thermal_lag_depth 'profile_index'}';
        else
          meta_proc.(thermal_lag_cond_cor).sources = ...
            {thermal_lag_cond_raw thermal_lag_temp_raw thermal_lag_pres_raw ...
             thermal_lag_flow thermal_lag_time thermal_lag_depth 'profile_index'}';
        end
        meta_proc.(thermal_lag_cond_cor).method = 'correctThermalLag';
        meta_proc.(thermal_lag_cond_cor).parameters = thermal_lag_constants;
        if thermal_lag_params_avail
          meta_proc.(thermal_lag_cond_cor).parameter_method = 'preset';
        else
          meta_proc.(thermal_lag_cond_cor).parameter_method = 'findThermalLagParams';
          meta_proc.(thermal_lag_cond_cor).parameter_estimates = thermal_lag_estimates;
          meta_proc.(thermal_lag_cond_cor).parameter_exitflags = thermal_lag_exitflags;
          meta_proc.(thermal_lag_cond_cor).parameter_estimator = func2str(thermal_lag_estimator);
        end
        meta_proc.(thermal_lag_cond_cor).profile_min_range = options.profile_min_range;
        meta_proc.(thermal_lag_cond_cor).profile_gap_ratio = options.profile_max_gap_ratio;
        meta_proc.(thermal_lag_temp_cor) = meta_proc.(thermal_lag_cond_cor);
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
      meta_proc.(salinity_salt).sources = ...
        {salinity_cond salinity_temp salinity_pres}';
      meta_proc.(salinity_salt).method = 'sw_salt';
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
      meta_proc.(density_dens).sources = ...
        {density_salt density_temp density_pres}';
      meta_proc.(density_dens).method = 'sw_dens';
    end
  end
  
end
