function data_proc = processGliderData(data_pre, varargin)
%PROCESSGLIDERDATA  Processes raw glider data applying conversions and derivations.
%
%  DATA_PROC = PROCESSGLIDERDATA(DATA_PRE, OPT1, VAL1, ...) processes a raw 
%  glider data struct DATA_PRE according to given options in option-value pairs
%  OPT1 and VAL1... DATA_PRE is a struct in the format returned by 
%  PREPROCESSGLIDERDATA, where each field is a time sequence from the sensor
%  with the same name. DATA_PROC is a struct with the same format, whth time 
%  sequences resulting from the following processes:
%    - Selection of reference sensors: 
%      Time, latitude and longitude sequences are selected.
%      Optionally, missing values are filled by interpolation.
%      This sequences are mandatory, processing aborts if missing.
%    - Selection of optional reference sensors:
%      Navigation depth and pitch sequences are selected, if any.
%      Optionally, missing values are filled by interpolation.
%    - Selection of water velocity sensors.
%      Mean segment water eastward and northward speed sequences are selected,
%      if any.
%    - Selection of commanded trajectory sensors:
%      Commanded waypoint latitude and longitude sequences are selected, if any.
%    - Selection of CTD sensor:
%      Conductivity, temperature and pressure sequences are selected, if any.
%      Optionally the CTD timestamp sequence is selected, too.
%    - Selection of chlorophyl sensor:
%      Fluor and turbidity sequences are selected, if any.
%    - Selection of oxygen sensors:
%      Oxygen concentration and saturation sequences are selected, if any.
%    - Selection of other sensors of interest:
%      Sequences from extra sensors configured in options are selected.
%    - Transect identification:
%      Transects are identified finding their boundaries at changes of waypoint
%      coordinates.
%    - Distance over ground computation:
%      The planar distance covered along the trajectory is computed cumulating
%      the distance between consecutive points with valid position coordinates.
%    - Pressure processing:
%      Pressure is optionally filtered using a filter proposed by Seabird.
%      Depth is optionally derived from pressure and longitude sequences.
%    - Cast identification:
%      Upcasts and downcasts are identified finding local extrema of the chosen 
%      depth or pressure sequence, and the glider vertical direction is deduced.
%    - Sensor lag correction:
%      Any already selected sequence may be corrected from sensor lag effects.
%      The sensor lag time constant may be provided as option or estimated from
%      identified consecutive casts with opposed directions.
%    - Thermal lag correction:
%      Any temperature and conductivity sequence pair may be corrected from
%      thermal lag effects. The thermal lag parameters may be provided as option
%      or estimated from identified consecutive casts with opposed directions.
%    - Salinity derivation:
%      In situ salinity may be derived from any set of conductivity, temperature
%      and pressure sequences already selected or produced.
%    - Density derivation:
%      In situ density may be derived from any set of conductivity, temperature 
%      and pressure sequences already selected or produced.
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
%    VALIDATEPROFILES
%    APPLYSEABIRDFILTER
%    SW_DPTH
%    SW_SALT
%    SW_DENS
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  %% Configure default values for optional sensor lag arguments. 
  default_sensor_lag_time_option = {'time'};
  default_sensor_lag_depth_option = {'depth'};
  default_sensor_lag_param_estimator = @median;
  
  
  %% Configure default values for optional thermal lag arguments. 
  % Before refactoring was default value for missing pitch was: deg2rad(26).
  default_thermal_lag_time_option = {'time_ctd' 'time'};
  default_thermal_lag_depth_option = {'depth_ctd' 'depth'};
  default_thermal_lag_pitch_option = {'pitch'};
  default_thermal_lag_pitch_missing_value = [];
  default_thermal_lag_param_estimator = @median;
  
  
  %% Handle optional arguments.
  % Set default values for non mandatory options.
  time_sensor_option = {'m_present_time' 'sci_m_present_time'};
  position_sensor_option = struct('latitude',  {'m_gps_lat' 'm_lat'}, ...
                                  'longitude', {'m_gps_lon' 'm_lon'});
  depth_sensor_option = {'m_depth'};
  pitch_sensor_option = {'m_pitch'};
  waypoint_sensor_option = struct('latitude',  {'c_wpt_lat'}, ...
                                  'longitude', {'c_wpt_lon'});
  water_velocity_sensor_option = ...
    struct('water_speed_eastward', {'m_final_water_vx'}, ...
           'water_speed_northward', {'m_final_water_vy'});
  ctd_sensor_option = ...
    struct('conductivity', {'sci_water_cond'        'm_water_cond'}, ...
           'temperature',  {'sci_water_temp'        'm_water_temp'}, ...
           'pressure',     {'sci_water_pressure'    'm_water_pressure'}, ...
           'time',         {'sci_ctd41cp_timestamp' []});
  flntu_sensor_option = struct('chlorophyll', {'sci_flntu_chlor_units'}, ...
                               'turbidity',   {'sci_flntu_turb_units'});
  oxygen_sensor_option = ...
    struct('oxygen_concentration', {'sci_oxy3835_oxygen'}, ...
           'oxygen_saturation', {'sci_oxy3835_saturation'});
  extra_sensor_option_list = {};
  time_filling = true;
  position_filling = true;
  pitch_filling = false;
  depth_filling = false;
  waypoint_filling = true;
  pressure_conversion = true;
  pressure_filtering = true;
  pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  depth_ctd_derivation = true;
  profiling_sequence_option = {'depth_ctd' 'depth_nav'};
  profiling_sequence_filling = true;
  valid_profile_min_range = 10;
  valid_profile_max_gap_ratio = 0.8;
  sensor_lag_option_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});
  thermal_lag_option_list = ...
    struct('conductivity_corrected', {'conductivity_corrected_thermal'}, ...
           'temperature_corrected',  {'temperature_corrected_thermal'}, ...         
           'conductivity_original', {'conductivity'}, ...
           'temperature_original', {'temperature'}, ...
           'parameters', {'auto'} );
  salinity_option_list = ...
    struct('salinity', {'salinity'}, 'conductivity', {'conductivity'}, ...
           'temperature', {'temperature'}, 'pressure', {'pressure'});
  density_option_list = ...
    struct('density', {'density'}, 'salinity', {'salinity'}, ...
           'temperature', {'temperature'}, 'pressure', {'pressure'});
  % Parse option-value pairs given as arguments.
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'time'
        time_sensor_option = val;
      case 'time_filling'
        time_filling = val;
      case 'position'
        position_sensor_option = val;
      case 'position_filling'
        position_filling = val;
      case 'depth'
        depth_sensor_option = val;
      case 'depth_filling'
        depth_filling = val;
      case 'pitch'
        pitch_sensor_option = val;
      case 'pitch_filling'
        pitch_filling = val;
      case 'waypoint'
        waypoint_sensor_option = val;
      case 'waypoint_filling'
        waypoint_filling = val;
      case 'ctd'
        ctd_sensor_option = val;
      case 'flntu'
        flntu_sensor_option = val;
      case 'oxygen'
        oxygen_sensor_option = val;
      case 'extra_sensors'
        extra_sensor_option_list = val;
      case 'pressure_bars_to_decibars'
        pressure_conversion = val;
      case 'pressure_filtering'
        pressure_filtering = val;
      case 'pressure_filter_constant'
        pressure_filter_constant = val;
      case 'depth_ctd'
        depth_ctd_derivation = val;
      case 'profiling'
        profiling_sequence_option = val;
      case 'profiling_sequence_filling'
        profiling_sequence_filling = val;
      case 'profile_min_range'
        valid_profile_min_range = val;
      case 'profile_max_gap'
        valid_profile_max_gap_ratio = val;
      case 'sensor_lag'
        sensor_lag_option_list = val;
      case 'thermal_lag'
        thermal_lag_option_list = val;
      case 'salinity'
        salinity_option_list = val;
      case 'density'
        density_option_list = val;
      otherwise
        error('glider_toolbox:processGliderData:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end

  
  %% Initialize output variable.
  data_proc = struct();
  
  
  %% Get list of available sensors.
  sensor_list = fieldnames(data_pre);
  
  
  %% Select time coordinate sensor.
  % Find time sensor in the list of available sensors.
  % For Slocum data please be aware of the efects of program dba_merge,
  % namely the copy of the sci_m_present_time value to the m_present_time for
  % sensor cycles coming from the science board.
  time_sensor_present = ismember(time_sensor_option, sensor_list);
  if ~any(time_sensor_present)
    error('glider_toolbox:processGliderData:MissingSensorTime', ...
          'No time sensor present in data set.');
  end
  % Take first time sensor found (preferred).
  time_sensor_index = find(time_sensor_present, 1, 'first');
  time_sensor = time_sensor_option{time_sensor_index};
  % Set time sequence, filling missing readings if needed.
  % Regular sampling is assumed on time gaps.
  data_proc.time = data_pre.(time_sensor);
  if time_filling
    data_proc.time = ...
      fillInvalidValues(data_proc.time, 'linear');
  end

  
  %% Select position coordinate sensors.
  % Find latitude and longitude sensors in the list of available sensors.
  latitude_sensor_present = ...
    ismember({position_sensor_option.latitude}, sensor_list);
  longitude_sensor_present = ...
    ismember({position_sensor_option.longitude}, sensor_list);
  position_sensor_present = latitude_sensor_present & longitude_sensor_present;
  if ~any(position_sensor_present)
    error('glider_toolbox:processGliderData:MissingSensorPosition', ...
          'No latitude and longitude sensors present in data set.');
  end
  % Take first latitude and longitude sensor set found (preferred).
  position_sensor_index = find(position_sensor_present, 1, 'first');
  latitude_sensor = position_sensor_option(position_sensor_index).latitude;
  longitude_sensor = position_sensor_option(position_sensor_index).longitude;
  % Set latitude and longitude sequences filling missing readings if needed.  
  data_proc.latitude = data_pre.(latitude_sensor);
  data_proc.longitude = data_pre.(longitude_sensor);
  if position_filling
     data_proc.latitude = ...
       fillInvalidValues(data_proc.time, data_proc.latitude, 'linear');
     data_proc.longitude = ...
       fillInvalidValues(data_proc.time, data_proc.longitude, 'linear');
  end
  
  
  %% Select depth sensor.
  % Find depth sensor in the list of available sensors, if any.
  depth_sensor_present = ismember(depth_sensor_option, sensor_list);
  if any(depth_sensor_present)
    % Take first depth sensor found (preferred).
    depth_sensor_index = find(depth_sensor_present, 1, 'first');
    depth_sensor = depth_sensor_option{depth_sensor_index};
    % Set depth sequence, filling missing readings if needed.
    data_proc.depth = data_pre.(depth_sensor);
    if depth_filling
      data_porc.depth = ...
        fillInvalidValues(data_proc.time, data_proc.depth, 'linear');
    end
  end
  
  
  %% Select pitch sensor.
  % Find pitch sensor in the list of available sensors, if any.
  pitch_sensor_present = ismember(pitch_sensor_option, sensor_list);
  if any(pitch_sensor_present)
    % Take first pitch sensor found (preferred).
    pitch_sensor_index = find(pitch_sensor_present, 1, 'first');
    pitch_sensor = pitch_sensor_option{pitch_sensor_index};
    % Set pitch sequence, filling missing readings if needed.
    data_proc.pitch = data_pre.(pitch_sensor);
    if pitch_filling
      data_proc.pitch = ...
        fillInvalidValues(data_proc.time, data_proc.pitch, 'linear');
    end
  end
  
  
  %% Select waypoint sensors.
  % Find waypoint latitude and longitude sensor set in the list of available
  % sensors, if any.
  wpt_lat_sensor_present = ...
    ismember({waypoint_sensor_option.latitude}, sensor_list);
  wpt_lon_sensor_present = ...
    ismember({waypoint_sensor_option.longitude}, sensor_list);
  waypoint_sensor_present = wpt_lat_sensor_present & wpt_lon_sensor_present;
  if any(waypoint_sensor_present)
    % Take first waypoint latitude and longitude sensor set found (preferred).
    waypoint_sensor_index = find(waypoint_sensor_present, 1, 'first');
    wpt_lat_sensor = waypoint_sensor_option(waypoint_sensor_index).latitude;
    wpt_lon_sensor = waypoint_sensor_option(waypoint_sensor_index).longitude;
    % Set waypoint latitude and longitude sequences, filling invalid values.
    % Waypoint coordinates are assumed constant until next waypoint reading.
    data_proc.waypoint_latitude = data_pre.(wpt_lat_sensor);
    data_proc.waypoint_longitude = data_pre.(wpt_lon_sensor);
    if waypoint_filling
      data_proc.waypoint_latitude = ...
        fillInvalidValues(data_proc.waypoint_latitude, 'previous');
      data_proc.waypoint_longitude = ...
        fillInvalidValues(data_proc.waypoint_longitude, 'previous');
    end
  end
  
  
  %% Select segment mean water velocity sensor.
  % Find full set of segment mean water velocity sensors in the list of 
  % available sensors, if any.
  water_speed_east_sensor_present = ...
    ismember({water_velocity_sensor_option.water_speed_eastward}, sensor_list);
  water_speed_north_sensor_present = ...
    ismember({water_velocity_sensor_option.water_speed_northward}, sensor_list);
  water_vel_sensor_present = ...
    water_speed_east_sensor_present & water_speed_north_sensor_present;
  if any(water_vel_sensor_present)
    % Take first water velocity sensor set found (preferred).
    water_vel_sensor_index = find(water_vel_sensor_present, 1, 'first');
    water_speed_east_sensor = ...
      water_velocity_sensor_option(water_vel_sensor_index).water_speed_eastward;
    water_speed_north_sensor = ...
      water_velocity_sensor_option(water_vel_sensor_index).water_speed_northward;
    % Set water eastward and northward speed sequences.
    data_proc.water_speed_eastward = data_pre.(water_speed_east_sensor);
    data_proc.water_speed_northward = data_pre.(water_speed_north_sensor);
  end
  
  
  %% Select CTD sensor.
  % Find CTD sensor sets in the list of available sensors, if any.
  cond_sensor_present = ismember({ctd_sensor_option.conductivity}, sensor_list);
  temp_sensor_present = ismember({ctd_sensor_option.temperature}, sensor_list);
  pres_sensor_present = ismember({ctd_sensor_option.pressure}, sensor_list);
  ctd_sensor_present = ...
    cond_sensor_present & temp_sensor_present & pres_sensor_present;
  if any(ctd_sensor_present)
    % Take first CTD sensor set found (preferred).
    ctd_sensor_index = find(ctd_sensor_present, 1, 'first');
    cond_sensor = ctd_sensor_option(ctd_sensor_index).conductivity;
    temp_sensor = ctd_sensor_option(ctd_sensor_index).temperature;
    pres_sensor = ctd_sensor_option(ctd_sensor_index).pressure;
    % Set CTD sequences.
    data_proc.conductivity = data_pre.(cond_sensor);
    data_proc.temperature = data_pre.(temp_sensor);
    data_proc.pressure = data_pre.(pres_sensor);
    % Look for CTD timestamp.
    if isfield(ctd_sensor_option, 'time') ...
       && ~isempty(ctd_sensor_option(ctd_sensor_index).time) ...
       && ismember(ctd_sensor_option(ctd_sensor_index).time, sensor_list)
      time_ctd_sensor = ctd_sensor_option(ctd_sensor_index).time;
      data_proc.time_ctd = data_pre(time_ctd_sensor);
    end
  end
  
  
  %% Select fluor (chlorophyl) and turbidity sensor.
  % Find fluor and turbidity sensors in the list of available sensors, if any.
  chlr_sensor_present = ismember({flntu_sensor_option.chlorophyll}, sensor_list);
  turb_sensor_present = ismember({flntu_sensor_option.turbidity}, sensor_list);
  flntu_sensor_present = chlr_sensor_present & turb_sensor_present;
  if any(flntu_sensor_present)
    % Take first fluor and turbidity sensor set found (preferred).
    flntu_sensor_index = find(flntu_sensor_present, 1, 'first');
    chlr_sensor = flntu_sensor_option(flntu_sensor_index).chlorophyll;
    turb_sensor = flntu_sensor_option(flntu_sensor_index).turbidity;
    % Set fluor and turbidity sequences.
    data_proc.chlorophyll = data_pre.(chlr_sensor);
    data_proc.turbidity = data_pre.(turb_sensor);
  end
  
  
  %% Select oxygen sensors.
  % Find full set of oxygen sensors in the list of available sensors, if any.
  oxy_con_sensor_present = ...
    ismember({oxygen_sensor_option.oxygen_concentration}, sensor_list);
  oxy_sat_sensor_present = ...
    ismember({oxygen_sensor_option.oxygen_saturation}, sensor_list);
  oxygen_sensor_present = oxy_con_sensor_present & oxy_sat_sensor_present;
  if any(oxygen_sensor_present)
    % Take first oxygen sensor set found (preferred).
    oxygen_sensor_index = find(oxygen_sensor_present, 1, 'first');
    oxy_con_sensor = ...
      oxygen_sensor_option(oxygen_sensor_index).oxygen_concentration;
    oxy_sat_sensor = ...
      oxygen_sensor_option(oxygen_sensor_index).oxygen_saturation;
    % Set oxygen concentration and saturation sequences.
    data_proc.oxygen_concentration = data_pre.(oxy_con_sensor);
    data_proc.oxygen_saturation = data_pre.(oxy_sat_sensor);
  end
  
  
  %% Select any other extra sensor.
  % Loop over desired extra sensor sets, and add them to processed data if they
  % are available.
  for extra_sensor_idx = 1:numel(extra_sensor_option_list)
    % Find full set of extra sensor in the list of available sensors, if any.
    extra_sensor_option = extra_sensor_option_list{extra_sensor_idx};
    extra_sensor_present = ...
      all(ismember(struct2cell(extra_sensor_option(:)), sensor_list), 1);
    if any(extra_sensor_present)
      % Take first extra sensor set found (preferred).
      extra_sensor_index = find(extra_sensor_present, 1, 'first');
      extra_sensor = extra_sensor_option(extra_sensor_index);
      extra_sensor_field_list = fieldnames(extra_sensor_option);
      % Set extra sensor sequences.
      for extra_sensor_field_idx = 1:numel(extra_sensor_field_list)
        extra_sensor_field = extra_sensor_field_list(extra_sensor_name_idx);
        extra_sensor_name = extra_sensor.(extra_sensor_field);
        data_proc.(extra_sensor_field) = data_pre.(extra_sensor_name);
      end
    end
  end
  

  %% Identify begin and end of transects, if waypoint coordinates available.
  if all(isfield(data_proc, {'waypoint_latitude' 'waypoint_longitude'}))
    data_proc.transect_index = ...
      findTransects(data_proc.waypoint_latitude, data_proc.waypoint_longitude);
  end
  
  
  %% Compute navigated distance over ground.
  data_proc.distance_over_ground = ...
    computePLanarDistance(data_proc.latitude, data_proc.longitude);
  

  %% Convert and filter pressure, if pressure available and needed.
  if isfield(data_proc, 'pressure')
    % Convert pressure from bars to decibars, if needed (by later processings).
    if pressure_conversion
      data_proc.pressure = 10 * data_proc.pressure;
    end
    % Apply pressure filter, if needed.
    if pressure_filtering
      if isfield(data_proc, 'time_ctd')
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time_ctd, data_proc.pressure, ...
                                     pressure_filter_constant);
      else
        data_proc.pressure = ...
          applySeabirdPressureFilter(data_proc.time, data_proc.pressure, ...
                                     pressure_filter_constant);
      end
    end
  end
  
  
  %% Derive depth from pressure, if pressure available and needed.
  if depth_ctd_derivation && all(isfield(data_proc, {'pressure' 'latitude'}))
    data_proc.depth_ctd = sw_dpth(data_proc.pressure, data_proc.latitude);
  end
  
  
  %% Identify start and end of profiles.
  % Find profiling sequence (e.g. navigation depth, CTD derived depth, ...)
  % present in the already processed data.
  profiling_sequence_present = isfield(data_proc, profiling_sequence_option);
  if any(profiling_sequence_present)
    % Take first profiling sequence found (preferred).
    profiling_sequence_index = find(profiling_sequence_present, 1, 'first');
    profiling_sequence = profiling_sequence_option{profiling_sequence_index};
    profile_stamp = data_proc.(profiling_sequence);
    % Fill profiling sequence invalid values, if needed.
    if (profiling_sequence_filling)
      profile_stamp = fillInvalidValues(profile_stamp, 'linear');
    end
    % Find profile directions and indices.
    [data_proc.profile_direction, data_proc.profile_index] = ...
      findProfiles(profile_stamp);
  end
  
  
  %% Perform sensor lag estimation and correction, if needed.
  for sensor_lag_option_idx = 1:numel(sensor_lag_option_list)
    % Get sensor lag arguments, setting options to default values if needed.
    sensor_lag_option = sensor_lag_option_list(sensor_lag_option_idx);
    sensor_lag_cor = sensor_lag_option.corrected;
    sensor_lag_raw = sensor_lag_option.original;
    sensor_lag_params = sensor_lag_option.parameters;
    sensor_lag_time_option = default_sensor_lag_time_option;
    sensor_lag_depth_option = default_sensor_lag_depth_option;
    sensor_lag_param_estimator = default_sensor_lag_param_estimator;
    if isfield(sensor_lag_option, 'time') && ~isempty(sensor_lag_option.time)
      sensor_lag_time_option = sensor_lag_option.time;
    end
    if isfield(sensor_lag_option, 'depth') && ~isempty(sensor_lag_option.depth)
      sensor_lag_depth_option = sensor_lag_option.depth;
    end
    if isfield(sensor_lag_option, 'estimator') ...
        && ~isempty(sensor_lag_option.estimator)
      sensor_lag_param_estimator = sensor_lag_option.estimator;
    end
    % Find input fields needed for sensor lag estimation or correction.
    sensor_lag_raw_avail = false;
    sensor_lag_time_avail = false;
    sensor_lag_depth_avail = false;
    if isfield(data_proc, sensor_lag_raw)
      sensor_lag_raw_avail = true;
    end
    sensor_lag_time_present = isfield(data_proc, sensor_lag_time_option);
    if any(sensor_lag_time_present)
      sensor_lag_time_index = find(sensor_lag_time_present, 1, 'first');
      sensor_lag_time = sensor_lag_time_option{sensor_lag_time_index};
      sensor_lag_time_avail = true;
    end
    sensor_lag_depth_present = isfield(data_proc, sensor_lag_depth_option);
    if any(sensor_lag_depth_present)
      sensor_lag_depth_index = find(sensor_lag_depth_present, 1, 'first');
      sensor_lag_depth = sensor_lag_depth_option{sensor_lag_depth_index};
      sensor_lag_depth_avail = true;
    end
    sensor_lag_input_avail = ...
      all([sensor_lag_raw_avail sensor_lag_time_avail sensor_lag_depth_avail]);
    % Perform sensor lag correction if needed input fields are there.
    if isfield(data_proc, 'profile_index') && sensor_lag_input_avail 
      % Estimate sensor lag time constant, if needed.
      if ischar(sensor_lag_params) && strcmpi(sensor_lag_params, 'auto')
        % Estimate sensor lag time constant for each pofile.
        num_profiles = fix(max(data_proc.profile_index));
        sensor_lag_param_estimates = nan(num_profiles-1, 1);
        for profile_idx = 1:(num_profiles-1)
          prof1_select = (data_proc.profile_index == profile_idx);
          prof1_dir = data_proc.profile_direction(prof1_select(1));
          prof1_raw = data_proc.(sensor_lag_raw)(prof1_select);
          prof1_depth = data_proc.(sensor_lag_depth)(prof1_select);
          prof1_time = data_proc.(sensor_lag_time)(prof1_select);
          prof1_valid = validateProfile(prof1_depth, prof1_raw, ...
                                        'range', valid_profile_min_range, ...
                                        'gap', valid_profile_max_gap_ratio);
          prof2_select = (data_proc.profile_index == profile_idx + 1);
          prof2_dir = data_proc.profile_direction(prof2_select(1));
          prof2_raw = data_proc.(sensor_lag_raw)(prof2_select);
          prof2_depth = data_proc.(sensor_lag_depth)(prof2_select);
          prof2_time = data_proc.(sensor_lag_time)(prof2_select);
          prof2_valid = validateProfile(prof2_depth, prof2_raw, ...
                                        'range', valid_profile_min_range, ...
                                        'gap', valid_profile_max_gap_ratio);
          prof_opposite_dir = (prof1_dir * prof2_dir < 0);
          if ~prof_opposite_dir
            fprintf('Omitting casts %d and %d for sensor lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'same direction');
          elseif ~prof1_valid
            fprintf('Omitting casts %d and %d for sensor lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'invalid first cast');
          elseif ~prof2_valid
            fprintf('Omitting casts %d and %d for sensor lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'invalid second cast');
          else
            sensor_lag_param_estimates(profile_idx) = ...
              findSensorLagParams(prof1_time, prof1_depth, prof1_raw, ...
                                  prof2_time, prof2_depth, prof2_raw);
          end
        end
        % Compute statistical estimate from individual profile estimates.
        % Use feval to allow estimator as either function handle or name string.
        sensor_lag_constant = ...
          feval(sensor_lag_param_estimator, sensor_lag_param_estimates);
      elseif isnumeric(sensor_lag_params) && isscalar(sensor_lag_params)
        % Sensor lag time constant given.
        sensor_lag_constant = sensor_lag_params;
      else
        % Invalid sensor lag parameters given.
        error('glider_toolbox:processGliderData:InvalidSensorLagParam', ...
              'Invalid sensor lag parameter for %s', sensor_lag_cor);
      end
      % Correct sensor lag, if possible.
      if isnan(sensor_lag_constant)
        fprintf('Omitting %s sensor lag correction: %s.\n', ...
                sensor_lag_cor, 'no valid sensor lag parameter available.');
      else
        data_proc.(sensor_lag_cor) = nan(size(data_proc.(sensor_lag_raw)));
        for profile_idx = 1:num_profiles
          prof_select = (data_proc.profile_index == profile_idx);
          prof_raw = data_proc.(sensor_lag_raw)(prof_select);
          prof_time = data_proc.(sensor_lag_time)(prof_select);
          prof_cor = correctSensorLag(prof_time, prof_raw, sensor_lag_constant);
          data_proc.(sensor_lag_cor)(prof_select) = prof_cor;
        end
      end
    end
  end

  
  %% Perform thermal lag estimation and correction, if needed.
  for thermal_lag_option_idx = 1:numel(thermal_lag_option_list)
    % Get thermal lag arguments, setting options to default values if needed.
    thermal_lag_option = thermal_lag_option_list(thermal_lag_option_idx);
    thermal_lag_cond_cor = thermal_lag_option.conductivity_corrected;
    thermal_lag_temp_cor = thermal_lag_option.temperature_corrected;
    thermal_lag_cond_raw = thermal_lag_option.conductivity_original;
    thermal_lag_temp_raw = thermal_lag_option.temperature_original;
    thermal_lag_params = thermal_lag_option.parameters;
    thermal_lag_time_option = default_thermal_lag_time_option;
    thermal_lag_depth_option = default_thermal_lag_depth_option;
    thermal_lag_pitch_option = default_thermal_lag_pitch_option;
    thermal_lag_pitch_missing_value = default_thermal_lag_pitch_missing_value;
    thermal_lag_param_estimator = default_thermal_lag_param_estimator;
    if isfield(thermal_lag_option, 'time') && ~isempty(thermal_lag_option.time)
      thermal_lag_time_option = thermal_lag_option.time;
    end
    if isfield(thermal_lag_option, 'depth') ...
        && ~isempty(thermal_lag_option.depth);
      thermal_lag_depth_option = thermal_lag_option.depth;
    end
    if isfield(thermal_lag_option, 'pitch') ...
        && ~isempty(thermal_lag_option.pitch)
      thermal_lag_pitch_option = thermal_lag_option.pitch;
    end
    if isfield(thermal_lag_option, 'pitch_missing_value') ...
        && ~isempty(thermal_lag_option.pitch_missing_value)
      thermal_lag_pitch_missing_value = thermal_lag_option.pitch_missing_value;
    end
    if isfield(thermal_lag_option, 'estimator');
      thermal_lag_param_estimator = thermal_lag_option.estimator;
    end
    % Find input fields needed for thermal lag estimation or correction.
    thermal_lag_cond_raw_avail = false;
    thermal_lag_temp_raw_avail = false;
    thermal_lag_time_avail = false;
    thermal_lag_depth_avail = false;
    thermal_lag_pitch_avail = false;
    thermal_lag_pitch_missing_value_avail = false;
    if isfield(data_proc, thermal_lag_cond_raw)
      thermal_lag_cond_raw_avail = true;
    end
    if isfield(data_proc, thermal_lag_temp_raw)
      thermal_lag_temp_raw_avail = true;
    end
    thermal_lag_time_present = isfield(data_proc, thermal_lag_time_option);
    if any(thermal_lag_time_present)
      thermal_lag_time_index = find(thermal_lag_time_present, 1, 'first');
      thermal_lag_time = thermal_lag_time_option{thermal_lag_time_index};
      thermal_lag_time_avail = true;
    end
    thermal_lag_depth_present = isfield(data_proc, thermal_lag_depth_option);
    if any(thermal_lag_depth_present)
      thermal_lag_depth_index = find(thermal_lag_depth_present, 1, 'first');
      thermal_lag_depth = thermal_lag_depth_option{thermal_lag_depth_index};
      thermal_lag_depth_avail = true;
    end
    thermal_lag_pitch_present = isfield(data_proc, thermal_lag_pitch_option);
    if any(thermal_lag_pitch_present)
      thermal_lag_pitch_index = find(thermal_lag_pitch_present, 1, 'first');
      thermal_lag_pitch = thermal_lag_pitch_option{thermal_lag_pitch_index};
      thermal_lag_pitch_avail = true;
    elseif ~isempty(thermal_lag_pitch_missing_value)
      thermal_lag_pitch = thermal_lag_pitch_missing_value;
      thermal_lag_pitch_missing_value_avail = true;
    end
    thermal_lag_input_avail = ...
      all([thermal_lag_cond_raw_avail thermal_lag_temp_raw_avail ...
           thermal_lag_time_avail thermal_lag_depth_avail ...
           (thermal_lag_pitch_avail | thermal_lag_pitch_missing_value_avail)]);
    % Perform thermal lag correction if needed input fields are there.
    if isfield(data_proc, 'profile_index') && thermal_lag_input_avail
      % Estimate thermal lag constant, if needed.
      if ischar(thermal_lag_params) && strcmpi(thermal_lag_params, 'auto')
        % Estimate sensor lag time constant for each pofile.
        num_profiles = fix(max(data_proc.profile_index));
        thermal_lag_param_estimates = nan(num_profiles-1, 4);
        for profile_idx = 1:(num_profiles-1)
          prof1_select = (data_proc.profile_index == profile_idx);
          prof1_dir = data_proc.profile_direction(prof1_select(1));
          prof1_cond_raw = data_proc.(thermal_lag_cond_raw)(prof1_select);
          prof1_temp_raw = data_proc.(thermal_lag_temp_raw)(prof1_select);
          prof1_depth = data_proc.(thermal_lag_depth)(prof1_select);
          prof1_time = data_proc.(thermal_lag_time)(prof1_select);
          if thermal_lag_pitch_avail
            prof1_pitch = data_proc.(thermal_lag_pitch)(prof1_select);
          else
            prof1_pitch = thermal_lag_pitch_missing_value;
          end
          prof1_valid = ...
            validateProfile(prof1_depth, [prof1_cond_raw prof1_temp_raw], ...
                            'range', valid_profile_min_range, ...
                            'gap', valid_profile_max_gap_ratio);
          prof2_select = (data_proc.profile_index == profile_idx + 1);
          prof2_dir = data_proc.profile_direction(prof2_select(1));
          prof2_cond_raw = data_proc.(thermal_lag_cond_raw)(prof2_select);
          prof2_temp_raw = data_proc.(thermal_lag_temp_raw)(prof2_select);
          prof2_depth = data_proc.(thermal_lag_depth)(prof2_select);
          prof2_time = data_proc.(thermal_lag_time)(prof2_select);
          if thermal_lag_pitch_avail
            prof2_pitch = data_proc.(thermal_lag_pitch)(prof2_select);
          else
            prof2_pitch = thermal_lag_pitch_missing_value;
          end
          prof2_valid = ...
            validateProfile(prof2_depth, [prof2_cond_raw prof2_temp_raw], ...
                            'range', valid_profile_min_range, ...
                            'gap', valid_profile_max_gap_ratio);
          prof_opposite_dir = (prof1_dir * prof2_dir < 0);
          if ~prof_opposite_dir
            fprintf('Omitting casts %d and %d for thermal lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'same direction');
          elseif ~prof1_valid
            fprintf('Omitting casts %d and %d for thermal lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'invalid first cast');
          elseif ~prof2_valid
            fprintf('Omitting casts %d and %d for thermal lag estimation: %s.\n', ...
                    profile_idx, profile_idx+1, 'invalid second cast');
          else
            thermal_lag_param_estimates(profile_idx) = ...
              findThermalLagParams(prof1_time, prof1_depth, ...
                                   prof1_cond_raw, prof1_temp_raw, ...
                                   prof2_time, prof2_depth, ...
                                   prof2_cond_raw, prof2_temp_raw, ...
                                   'pitch_down', prof1_pitch, ...
                                   'pitch_up', prof2_pitch);
          end
        end
        % Compute statistical estimate from individual profile estimates.
        % Use feval to allow estimator as either function handle or name string.
        thermal_lag_constants = ...
          feval(thermal_lag_param_estimator, thermal_lag_param_estimates);
      elseif isnumeric(thermal_lag_params) && (numel(thermal_lag_params) == 4)
        % Thermal lag parameters given.
        thermal_lag_constants = thermal_lag_params;
      else
        % Invalid thermal lag parameters given.
        error('glider_toolbox:processGliderData:InvalidThermalLagParam', ...
              'Invalid sensor lag parameter for %s and %s.', ...
              thermal_lag_cond_cor, thermal_lag_temp_cor);
      end
      % Correct thermal lag, if possible.
      if any(isnan(thermal_lag_constant))
        fprintf('Omitting %s and %s thermal lag correction: %s.\n', ...
                thermal_lag_cond_cor, thermal_lag_temp_cor, ...
                'no valid thermal lag parameters available.');
      else
        data_proc.(thermal_lag_cond_cor) = ...
          nan(size(data_proc.(thermal_lag_cond_raw)));
        data_proc.(thermal_lag_temp_cor) = ...
          nan(size(data_proc.(thermal_lag_temp_raw)));
        for profile_idx = 1:num_profiles
          prof_select = (data_proc.profile_index == profile_idx);
          prof_cond_raw = data_proc.(thermal_lag_cond_raw)(prof_select);
          prof_temp_raw = data_proc.(thermal_lag_temp_raw)(prof_select);
          prof_time = data_proc.(thermal_lag_time)(prof_select);
          if thermal_lag_pitch_avail
            prof_pitch = data_proc.(thermal_lag_pitch)(prof_select);
          else
            prof_pitch = thermal_lag_pitch_missing_value;
          end
          [prof_cond_cor, prof_temp_cor] = ...
            correctThermalLag(prof_time, prof_cond_raw, prof_temp_raw, ...
                              thermal_lag_constants, 'pitch', prof_pitch);
          data_proc.(thermal_lag_cond_cor)(prof_select) = prof_cond_cor;
          data_proc.(thermal_lag_temp_cor)(prof_select) = prof_temp_cor;
        end
      end
    end
  end
  
  
  %% Derive salinity from pressure, conductivity and temperature, if available.
  for salinity_option_idx = 1:numel(salinity_option_list)
    salinity_option = salinity_option_list(salinity_option_idx);
    salinity_salt = salinity_option.salinity;
    salinity_cond = salinity_option.conductivity;
    salinity_temp = salinity_option.temperature;
    salinity_pres = salinity_option.pressure;
    if all(isfield(data_proc, {salinity_cond salinity_temp salinity_pres}))
      % Compute salinity from temperature, pressure and conductivity ratio.
      % Input conductivity is given in S/m (Siemens per metre), 
      % but reference conductivity returned by sw_c3515 is in mS/cm.
      data_proc.(salinity_salt) = ...
        sw_salt(data_proc.(salinity_cond) * (10 / sw_c3515()), ...
                data_proc.(salinity_temp), data_proc.(salinity_pres));
    end
  end

  
  %% Derive density from pressure, salinity and temperature, if available.
  for density_option_idx = 1:numel(density_option_list)
    density_option = density_option_list(density_option_idx);
    density_dens = density_option.density;
    density_salt = density_option.salinity;
    density_temp = density_option.temperature;
    density_pres = density_option.pressure;
    if all(isfield(data_proc, {density_salt density_temp density_pres}))
      % Compute density from temperature, pressure and salinity.
      data_proc.(density_dens) = ...
        sw_dens(data_proc.(density_salt), ...
                data_proc.(density_temp), data_proc.(density_pres));
    end
  end
  
end
