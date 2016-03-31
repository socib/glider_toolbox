function [data_pre, meta_pre] = preprocessGliderData(data_raw, meta_raw, varargin)
%PREPROCESSGLIDERDATA  Preprocess glider deployment data.
%
%  Syntax:
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, META_RAW)
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, META_RAW, OPTIONS)
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, META_RAW, OPT1, VAL1, ...)
%
%  Description:
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, META_RAW, ...)
%    preprocesses glider deployment data according to given options,
%    performing the following actions:
%      - Selection of time sensors: 
%        A time sequence is selected.
%        Optionally, a unit conversion may be applied, if needed.
%        This sequence is mandatory, processing aborts if missing.
%      - Selection of horizontal position sensors:
%        Latitude and longitude sequences are selected.
%        A position flag is also selected, if any, and bad values are masked
%        as missing. Optionally, a unit conversion may be applied, if needed.
%        Latitude and longitude are mandatory, processing aborts if missing.
%      - Selection of optional reference sensors:
%        Navigation depth, pitch, roll, and heading sequences are selected,
%        if any. Unit conversions may be applied, if needed.
%      - Selection of water velocity sensors or estimates.
%        Mean segment water eastward and northward velocity sequences are 
%        selected, if any. Unit conversions may be applied, if needed.
%      - Selection of commanded trajectory sensors:
%        Commanded waypoint longitude and latitude sequences are selected,
%        if any. Unit conversions may be applied, if needed.
%      - Selection of CTD sensor:
%        Conductivity, temperature and pressure sequences are selected, if any.
%        Optionally the CTD timestamp sequence is selected, too.
%        Unit conversion may be applied to pressure readings, if needed; and 
%        factory calibrations may be applied to temperature and conductivity.
%      - Selection of fluorescence and/or scattering sensor:
%        Chlorophyll, turbidity, CDOM and/or scattering sequences are selected, 
%        if any. Optionally the sensor timestamp sequence is selected, too.
%        Manufacturer calibrations may be applied, if needed.
%      - Selection of oxygen sensors:
%        Oxygen concentration and saturation sequences are selected, if any.
%        Optionally oxygen sensor timestamp and temperature sequences are 
%        selected. Unit conversion and manufacturer calibrations may be applied.
%      - Selection of other sensors of interest:
%        Sequences from extra sensors configured in options are selected.
%        Unit conversions and manufacturer calibrations may be applied,
%        if needed.
%
%      DATA_RAW should be a struct in the format returned by LOADSLOCUMDATA or
%      LOADSEAGLIDERDATA, where each field is a vector sequence from the sensor 
%      or variable with the same name. META_RAW should be the struct with the
%      metadata required for the preprocessing. Currently it is only used for
%      the following actions:
%        - Seaglider log parameter alignment (see option SG_DIVE_PARAMS below).
%
%    Preprocessed data is returned in struct DATA_PRE, where each field is a
%    sequence of readings selected and preprocessed according to given options
%    (see below). META_PRE is a struct with the same fields keeping track of
%    the source of each selected sequence and how it has been modified.
%
%    Options may be given in key-value pairs OPT1, VAL1... or in a struct
%    OPTIONS with field names as option keys and field values as option values.
%    Recognized options are:
%      SG_DIVE_PARAMS: Seaglider dive parameters to align with column data.
%        String cell array with the names of the Seaglider log parameters that
%        need to align with the rest of the data collected during the dive as
%        required by function ALIGNSGDIVEPARAMS.
%        Default value: {}
%      TIME_LIST: time sensor choices.
%        Struct array with the time sensor choices, in order of preference.
%        It should have the following fields:
%          TIME: time sequence name.
%        It may have the following optional fields (empty or missing):
%          CONVERSION: time unit conversion.
%            Handle or name of the time unit conversion.
%            If present and not empty, the selected sequence is converted 
%            through that function.
%        Default value: struct('time', {'m_present_time' 'sci_m_present_time'})
%      POSITION_LIST: longitude and latitude sensor choices.
%        Struct array selecting longitude and latitude sensor sets in order
%        of preference, with optional mask of valid position readings.
%        It should have the following fields:
%          LONGITUDE: longitude sequence name.
%          LATITUDE: latitude sequence name.
%        It may have the following optional fields (empty or missing):
%          STATUS: position status sequence name.
%          STATUS_GOOD: position status good values or filter.
%          STATUS_BAD:  position status bad values or filter.
%          CONVERSION: position coordinate conversion.
%            Handle or name of the position coordinate conversion function.
%            If present and not empty, the selected longitude and latitude 
%            sequences are converted through this function.
%          TIME: time component of position reading timestamp.
%          DATE: date component of position reading timestamp.
%          TIME_CONVERSION: position timestamp conversion.
%            Handle or name of the position timestamp conversion function.
%            If present and not empty, the selected position time stamp and
%            position date stamp sequences are converted through this function
%            to a sequence of absolute timepstamps.
%        Default value: struct('longitude', {'m_gps_lon' 'm_lon'}, ...
%                              'latitude', {'m_gps_lat' 'm_lat'}, ...
%                              'position_status', {'m_gps_status' []}, ...
%                              'position_status_good', {0 []}, ...
%                              'position_status_bad', {[] []}, ...
%                              'conversion', {@nmea2deg @nmea2deg})
%      DEPTH_LIST: depth sensor choices.
%        Struct array with the depth sensor choices, in order of preference.
%        It should have the following fields:
%          DEPTH: depth sequence name.
%        It may have the following optional fields (empty or missing):
%          CONVERSION: depth unit conversion.
%            Handle or name of the depth coordinate conversion function.
%            If present and not empty, the selected depth sequence is converted 
%            through this function. 
%        Default value: struct('depth', {'m_depth'});
%      ATTITUDE_LIST: roll and pitch sensor choices.
%        Struct array with the roll and pitch sensor choices sequences, 
%        in order of preference. It should have the following fields:
%          ROLL: roll sensor name.
%          PITCH: pitch sensor name.
%        It may have the following optional fields (empty or missing):
%          CONVERSION: roll and pitch unit conversion.
%            Handle or name of the attitude conversion function.
%            If present and not empty, each selected roll and pitch sequence
%            is converted through this function.
%        Default value: struct('roll', {'m_roll'}, 'pitch', {'m_pitch'})
%      HEADING_LIST: heading sensor choices.
%        Struct array with the heading sensor choices, in order of preference.
%        It should have the following fields:
%          HEADING: heading sequence name.
%        It may have the following optional fields (empty or missing):
%          CONVERSION: heading unit conversion.
%            Handle or name of the heading unit conversion.
%            If present and not empty, the selected sequence is converted through
%            that function.
%        Default value: struct('heading', {'m_heading'})
%      WAYPOINT_LIST: waypoint longitude and latitude choices.
%        Struct array selecting waypoint longitude and latitude sequences,
%        in order of preference. It should have the following fields:
%          LONGITUDE: waypoint longitude sequence name.
%          LATITUDE: waypoint latitude sequence name.
%        It may have the following optional fields (empty or missing):
%          CONVERSION: position coordinate conversion.
%            Handle or name of the position coordinate conversion function.
%            If present and not empty, the selected waypoint longitude and 
%            latitude sequences are converted through this function. 
%        Default value: struct('longitude', {'c_wpt_lon'}, ...
%                              'latitude',  {'c_wpt_lat'}, ...
%                              'conversion', {@nmea2deg})
%      WATER_VELOCITY_LIST: water velocity choices.
%        Struct array selecting estimates water velocity components,
%        in order of preference. It should have the following fields:
%          VELOCITY_EASTWARD: water velocity eastward component sensor name.
%          VELOCITY_NORTHWARD: water velocity northward component sensor name.
%          CONVERSION: water velocity conversion.
%            Handle or name of the water velocity conversion function.
%            If present and not empty, the selected water velocity component 
%            sequences are converted through this function. 
%        Default value: struct('velocity_eastward', {'m_final_water_vx'}, ...
%                              'velocity_northward', {'m_final_water_vy'})
%      CTD_LIST: CTD sensor choices.
%        Struct array selecting the CTD sensors, in order of preference.
%        It should have the following fields:
%          CONDUCTIVITY: conductivity sequence name.
%          TEMPERATURE: temperature sequence name.
%          PRESSURE: pressure sequence name.
%        It may have the following optional fields (empty or missing):
%          TIME: CTD timestamp sequence name.
%          PRESSURE_CONVERSION: pressure unit conversion.
%            Handle or name of the pressure unit conversion function.
%            If present and not empty, the selected pressure sequence is 
%            converted through this function.
%          CALIBRATION: conductivity and temperature factory calibration.
%            Handle or name of the temperature and conductivity factory
%            calibration function. If present and not empty, the raw 
%            conductivity and temperature sequences, and the pressure sequence
%            are passed to this function to get the calibrated temperature
%            and conductivity.
%        Default value:
%          struct('conductivity', {'sci_water_cond'        'm_water_cond'}, ...
%                 'temperature',  {'sci_water_temp'        'm_water_temp'}, ...
%                 'pressure',     {'sci_water_pressure'    'm_water_pressure'}, ...
%                 'time',         {'sci_ctd41cp_timestamp' []}
%                 'pressure_conversion', {@bar2dbar        @bar2dbar})
%      OXYGEN_LIST: oxygen sensor set choices.
%        Struct array selecting the oxygen sensor sets, in order of preference.
%        It should have the following fields:
%          OXYGEN_CONCENTRATION: concentration of oxygen sequence name.
%          OXYGEN_SATURATION: saturation of oxygen sequence name.
%        It may have the following optional fields (empty or missing):
%          TEMPERATURE: oxygen temperature sequence name.
%          TIME: oxygen timestamp sequence name.
%        Default value: struct('oxygen_concentration', {'sci_oxy3835_oxygen'}, ...
%                              'oxygen_saturation',    {'sci_oxy3835_saturation'}, ...
%                              'temperature',          {'sci_oxy3835_temp'}, ...
%                              'time',                 {'sci_oxy3835_timestamp'})
%      OPTICS_LIST: fluorescence and scattering sensor set choices.
%        Struct array selecting the fluorescence and scattering sensor sets,
%        in  order of preference. It may have the following optional fields 
%        (empty or missing):
%          CHLOROPHYLL: chlorophyl sequence name.
%          TURBIDITY: turbidity sequence name.
%          CDOM: CDOM sequence name.
%          SCATTER_650: 650 nm wavelength scattering sequence name.
%          TIME: optic sensor timestamp sequence name.
%          CALIBRATION: fluorescence and scattering factory calibration.
%            Handle or name of the optic sensor factory calibration function.
%            If present and not empty, the selected raw sequences are passed to
%            this function to get the calibrated optic measurements.
%        Default value: struct('chlorophyll', {'sci_flntu_chlor_units'}, ...
%                              'turbidity',   {'sci_flntu_turb_units'}, ...
%                              'cdom',        {[]}, ...
%                              'scatter_650', {[]}, ...
%                              'time',        {'sci_flntu_timestamp'})
%      EXTRA_SENSOR_LIST: other sensor set choices.
%        Struct selecting other sensor sets of interest, where each field 
%        represents a sensor of interest. The field name is an arbitrary sensor 
%        name (e.g. battery_info), and the field value should be a struct array 
%        with the sensor choices in order of preference, where field names are
%        the final sequence names (fields in struct DATA_PRE, e.g. 
%        battery_nominal_capacity and battery_total_consumption) and field 
%        values are the original sequence name choices (fields in struct 
%        DATA_RAW, e.g. f_coulomb_battery_capacity and m_coulomb_amphr_total).
%        Default value: struct()
%      CALIBRATION_PARAMETER_LIST: calibration parameters for each variable.
%        Struct with the calibration parameters of each uncalibrated variable.
%        For each raw variable with calibration parameters there should be a 
%        field with the same name and whose value is a struct with the parameter
%        names as field names and its parameter values as field values.
%        Default value: struct()
%
%  Examples:
%    data_pre = preprocessGliderData(data_raw, meta_raw, options)
%
%  See also:
%    ALIGNSGPARAMS
%    FILLSGMISSINGGPSDATE
%    NMEA2DEG
%    BAR2DBAR
%    SGDEPTH2PRES
%    CALIBRATESBECT
%    CALIBRATEWLECBBFL2
%    
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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

  error(nargchk(2, 24, nargin, 'struct'));
  
  
  %% Set preprocessing options.
  % Set default options values.
  options = struct();
  options.sg_dive_params = {};
  options.time_list = ...
    struct('time', {'m_present_time' 'sci_m_present_time'});
  options.position_list = ...
    struct('longitude',            {'m_gps_lon'    'm_lon'}, ...
           'latitude',             {'m_gps_lat'    'm_lat'}, ...
           'position_status',      {'m_gps_status' []}, ...
           'position_good',        {0              []}, ...
           'position_bad',         {[]             []}, ...
           'time',                 {[]             []}, ...
           'date',                 {[]             []}, ...
           'conversion',           {@nmea2deg      @nmea2deg});
  options.depth_list = ...
    struct('depth', {'m_depth'});
  options.attitude_list = ...
    struct('roll',  {'m_roll'}, ...
           'pitch', {'m_pitch'});
  options.heading_list = ...
    struct('heading', {'m_heading'});
  options.waypoint_list = ...
    struct('longitude',  {'c_wpt_lon'}, ...
           'latitude',   {'c_wpt_lat'}, ...
           'conversion', {@nmea2deg});
  options.water_velocity_list = ...
    struct('velocity_eastward',  {'m_final_water_vx'}, ...
           'velocity_northward', {'m_final_water_vy'});
  options.ctd_list = ...
    struct('conductivity',        {'sci_water_cond'        'm_water_cond'}, ...
           'temperature',         {'sci_water_temp'        'm_water_temp'}, ...
           'pressure',            {'sci_water_pressure'    'm_water_pressure'}, ...
           'oxygen',              {'GPCTD_DOF'    'SBD_DOF'}, ...
           'time',                {'sci_ctd41cp_timestamp' []}, ...
           'pressure_conversion', {@bar2dbar               @bar2dbar});
  options.oxygen_list = ...
    struct('oxygen_concentration', {'sci_oxy3835_oxygen'}, ...
           'oxygen_saturation',    {'sci_oxy3835_saturation'}, ...
           'temperature',          {'sci_oxy3835_temp'}, ...
           'time',                 {'sci_oxy3835_timestamp'});
  options.optics_list = ...
    struct('chlorophyll', {'sci_flntu_chlor_units'}, ...
           'turbidity',   {'sci_flntu_turb_units'}, ...
           'cdom',        {[]}, ...
           'scatter_650', {[]}, ...
           'time',        {'sci_flntu_timestamp'});
  options.extra_sensor_list = ...
    struct();
  options.calibration_parameter_list = ...
    struct();
  
  
  %% Get options from extra arguments.
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument.
    option_key_list = fieldnames(varargin{1});
    option_val_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = varargin(1:2:end);
    option_val_list = varargin(2:2:end);
  else
    error('glider_toolbox:preprocessGliderData:InvalidOption', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:preprocessGliderData:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end


  %% Initialize output data.
  meta_pre = struct();
  data_pre = struct();
  
  
  %% Get list of available variables and their calibrations.
  field_list = fieldnames(data_raw);
  calibration_parameters = struct();
  if isfield(options, 'calibration_parameter_list')
    calibration_parameters = options.calibration_parameter_list;
  end
  
  
  %% Realign Seaglider log parameters to the start of the dive data, if needed.
  if ~isempty(options.sg_dive_params)
    data_raw = alignSGDiveParams(data_raw, meta_raw, options.sg_dive_params);
  end
  
  
  %% Select time coordinate sensor.
  % Find preferred valid time sensor available in list of sensor fields.
  % For Slocum data please be aware of the efects of program dba_merge,
  % namely the copy of the sci_m_present_time value to the m_present_time for
  % sensor cycles coming from the science board.
  % Convert char array to string cell array if needed (safe if cell array).
  time_choice_list = options.time_list;
  for time_choice_idx = 1:numel(time_choice_list)
    time_choice = time_choice_list(time_choice_idx);
    time_field = time_choice.time;
    time_conversion_func = [];
    if isfield(time_choice_list, 'conversion')
      time_conversion_func = time_choice.conversion;
    end
    if ismember(time_field, field_list) && any(data_raw.(time_field) > 0)
      data_pre.time = data_raw.(time_field);
      meta_pre.time.sources = time_field;
      fprintf('Selected time sensor %d:\n', time_choice_idx); ...
      fprintf('  time: %s\n', time_field);
      if ~isempty(time_conversion_func)
        if ischar(time_conversion_func)
          time_conversion_func = str2func(time_conversion_func);
        end
        data_pre.time = time_conversion_func(data_pre.time);
        meta_pre.time.conversion = func2str(time_conversion_func);
        fprintf('  conversion: %s\n', func2str(time_conversion_func));
      end
      break;
    end
  end
  if ~isfield(data_pre, 'time')
    error('glider_toolbox:preprocessGliderData:MissingSensorTime', ...
          'No time sensor present in data set.');
  end
  
  
  %% Select position coordinate sensors.
  % Find preferred valid longitude and latitude sensor available in list of 
  % sensor fields. Also find optional date and time components of position 
  % timestamp. Optionally set flagged readings as invalid (NaN), 
  % if position status field and good or bad value criteria are available.
  position_choice_list = options.position_list;
  for position_choice_idx = 1:numel(position_choice_list)
    position_choice = position_choice_list(position_choice_idx);
    lon_field = position_choice.longitude;
    lat_field = position_choice.latitude;
    position_date_field = [];
    position_time_field = [];
    position_status_field = [];
    position_conversion_func = [];
    position_time_conversion_func = [];
    position_good = [];
    position_bad = [];
    if isfield(position_choice_list, 'position_status')
      position_status_field = position_choice.position_status;
    end
    if isfield(position_choice_list, 'position_good')
      position_good = position_choice.position_good;
    end
    if isfield(position_choice_list, 'position_bad')
      position_bad = position_choice.position_bad;
    end
    if isfield(position_choice_list, 'conversion')
      position_conversion_func = position_choice.conversion;
    end
    if isfield(position_choice_list, 'time')
      position_time_field = position_choice.time;
    end
    if isfield(position_choice_list, 'date')
      position_date_field = position_choice.date;
    end
    if isfield(position_choice_list, 'time_conversion')
      position_time_conversion_func = position_choice.time_conversion;
    end
    if all(ismember({lat_field lon_field}, field_list)) ...
        && ~all(isnan(data_raw.(lon_field))) ...
        && ~all(isnan(data_raw.(lat_field)))
      data_pre.longitude = data_raw.(lon_field);
      data_pre.latitude = data_raw.(lat_field);
      meta_pre.longitude.sources = lon_field;
      meta_pre.latitude.sources = lat_field;
      fprintf('Selected position sensor %d:\n', position_choice_idx);
      fprintf('  longitude: %s\n', lon_field);
      fprintf('  latitude : %s\n', lat_field);
      if ~isempty(position_status_field) ...
          && ismember(position_status_field, field_list) ...
          && ~all(isnan(data_raw.(position_status_field)))
        data_pre.position_status = data_raw.(position_status_field);
        meta_pre.position_status.sources = position_status_field;
        fprintf('  position status: %s\n', position_status_field);
        position_invalid = false(size(data_pre.position_status));
        if ~isempty(position_good)
          if ischar(position_good) 
            position_invalid = ~feval(position_good, ...
                                      data_pre.longitude, data_pre.latitude, ...
                                      data_pre.position_status);
            meta_pre.position_status.position_good = position_good;
            fprintf('  position good  : %s\n', position_good);
          elseif isa(position_good, 'function_handle')
            position_invalid = ~feval(position_good, ...
                                      data_pre.longitude, data_pre.latitude, ...
                                      data_pre.position_status);
            meta_pre.position_status.position_good = func2str(position_good);
            fprintf('  position good  : %s\n', func2str(position_good));
          else
            position_invalid = ...
              ~ismember(data_pre.position_status, position_good);
            meta_pre.position_status.position_good = position_good;
            fprintf('  position good  : %s\n', num2str(position_good));
          end
        end
        if ~isempty(position_bad)
          if ischar(position_bad) 
            position_invalid = position_invalid ...
                             | feval(position_bad, ...
                                     data_pre.longitude, data_pre.latitude, ...
                                     data_pre.position_status);
            meta_pre.position_status.position_bad = position_bad;
            fprintf('  position bad   : %s\n', position_bad);
          elseif isa(position_bad, 'function_handle')
            position_invalid = position_invalid ...
                             | feval(position_bad, ...
                                     data_pre.longitude, data_pre.latitude, ...
                                     data_pre.position_status);
            meta_pre.position_status.position_bad = func2str(position_bad);
            fprintf('  position bad   : %s\n', func2str(position_bad));
          else
            position_invalid = position_invalid ...
                             | ismember(data_pre.position_status, position_bad);
            meta_pre.position_status.position_bad = position_bad;
            fprintf('  position bad   : %s\n', num2str(position_bad));
          end
        end
        data_pre.latitude(position_invalid) = nan;
        data_pre.longitude(position_invalid) = nan;
      end
      if ~isempty(position_conversion_func)
        if ischar(position_conversion_func)
          position_conversion_func = str2func(position_conversion_func);
        end
        [data_pre.longitude, data_pre.latitude] = ...
          position_conversion_func(data_pre.longitude, data_pre.latitude);
        meta_pre.longitude.sources = {lon_field lat_field}';
        meta_pre.longitude.conversion = func2str(position_conversion_func);
        meta_pre.latitude.sources = {lon_field lat_field}';
        meta_pre.latitude.conversion = func2str(position_conversion_func);
        fprintf('  conversion : %s\n', func2str(position_conversion_func));
      end
      if ~isempty(position_time_field) ...
          && ismember(position_time_field, field_list)
        data_pre.position_time = data_raw.(position_time_field);
        meta_pre.position_time.sources = position_time_field;
        fprintf('  position time  : %s\n', position_time_field);
      end
      if ~isempty(position_date_field) ...
          && ismember(position_date_field, field_list)
        data_pre.position_date = data_raw.(position_date_field);
        meta_pre.position_date.sources = position_date_field;
        fprintf('  position date  : %s\n', position_date_field);
      end
      if ~isempty(position_time_conversion_func)
        if ischar(position_time_conversion_func)
          position_time_conversion_func = ...
            str2func(position_time_conversion_func);
        end
        data_pre.time_position = ...
          position_time_conversion_func(data_pre.position_time, ...
                                        data_pre.position_date);
        meta_pre.time_position.sources = ...
          {position_time_field position_date_field}';
        meta_pre.time_position.conversion = ...
          func2str(position_time_conversion_func);
        fprintf('  time conversion : %s\n', ...
                func2str(position_time_conversion_func));
      end
      break;
    end
  end
  if ~all(isfield(data_pre, {'longitude' 'latitude'}))
    error('glider_toolbox:preprocessGliderData:MissingSensorPosition', ...
          'No longitude and latitude sensor present in data set.');
  end
  
  
  %% Select depth sensor.
  % Find preferred valid depth sensor available in list of sensor fields, if any.
  % Convert char array to string cell array if needed (safe if cell array).
  depth_choice_list = options.depth_list;
  for depth_choice_idx = 1:numel(depth_choice_list)
    depth_choice = depth_choice_list(depth_choice_idx);
    depth_field = depth_choice.depth;
    depth_conversion_func = [];
    if isfield(depth_choice_list, 'conversion')
      depth_conversion_func = depth_choice.conversion;
    end
    if ismember(depth_field, field_list) ...
        && ~all(isnan(data_raw.(depth_field)))
      data_pre.depth = data_raw.(depth_field);
      meta_pre.depth.sources = depth_field;
      fprintf('Selected depth sensor %d:\n', depth_choice_idx);
      fprintf('  depth: %s\n', depth_field);
      if ~isempty(depth_conversion_func)
        if ischar(depth_conversion_func)
          depth_conversion_func = str2func(depth_conversion_func);
        end
        data_pre.depth = depth_conversion_func(data_pre.depth);
        meta_pre.depth.conversion = func2str(depth_conversion_func);
        fprintf('  conversion : %s\n', func2str(depth_conversion_func));
      end
      break;
    end
  end
  
  
  %% Select attitude sensors.
  % Find preferred valid roll and pitch sensor available in list of sensor
  % fields, if any.
  attitude_choice_list = options.attitude_list;
  for attitude_choice_idx = 1:numel(attitude_choice_list)
    attitude_choice = attitude_choice_list(attitude_choice_idx);
    roll_field = attitude_choice_list(attitude_choice_idx).roll;
    pitch_field = attitude_choice_list(attitude_choice_idx).pitch;
    attitude_conversion = [];
    if isfield(attitude_choice_list, 'conversion')
      attitude_conversion = attitude_choice.conversion;
    end
    if all(ismember({roll_field pitch_field}, field_list)) ...
        && ~all(isnan(data_raw.(roll_field))) ...
        && ~all(isnan(data_raw.(pitch_field))) 
      data_pre.roll = data_raw.(roll_field);
      data_pre.pitch = data_raw.(pitch_field);
      meta_pre.roll.sources = roll_field;
      meta_pre.pitch.sources = pitch_field;
      fprintf('Selected attitude sensors %d:\n', attitude_choice_idx);
      fprintf('  roll : %s\n', roll_field);
      fprintf('  pitch: %s\n', pitch_field);
      if ~isempty(attitude_conversion)
        if ischar(attitude_conversion)
          attitude_conversion = str2func(attitude_conversion);
        end
        data_pre.roll = attitude_conversion(data_pre.roll);
        data_pre.pitch = attitude_conversion(data_pre.pitch);
        meta_pre.roll.conversion = func2str(attitude_conversion);
        meta_pre.pitch.conversion = func2str(attitude_conversion);
        fprintf('  conversion : %s\n', func2str(attitude_conversion));
      end
      break;
    end
  end
  
  
  %% Select heading sensor.
  % Find preferred valid heading sensor available in list of sensor fields.
  % Convert char array to string cell array if needed (safe if cell array).
  heading_choice_list = options.heading_list;
  for heading_choice_idx = 1:numel(heading_choice_list)
    heading_choice = heading_choice_list(heading_choice_idx);
    heading_field = heading_choice.heading;
    heading_conversion_func = [];
    if isfield(heading_choice_list, 'conversion')
      heading_conversion_func = heading_choice.conversion;
    end
    if ismember(heading_field, field_list) ...
        && ~all(isnan(data_raw.(heading_field)))
      data_pre.heading = data_raw.(heading_field);
      fprintf('Selected heading sensor %d:\n', heading_choice_idx);
      fprintf('  heading: %s\n', heading_field);
      if ~isempty(heading_conversion_func)
        if ischar(heading_conversion_func)
          heading_conversion_func = str2func(heading_conversion_func);
        end
        data_pre.heading = heading_conversion_func(data_pre.heading);
        meta_pre.heading.conversion = func2str(heading_conversion_func);
        fprintf('  conversion : %s\n', func2str(heading_conversion_func));
      end
      break;
    end
  end
  
  
  %% Select waypoint coordinate sensors.
  % Find preferred valid waypoint longitude and latitude sensor available in 
  % list sensor fields, if any.
  waypoint_choice_list = options.waypoint_list;
  for waypoint_choice_idx = 1:numel(waypoint_choice_list)
    waypoint_choice = waypoint_choice_list(waypoint_choice_idx);
    wpt_lon_field = waypoint_choice.longitude;
    wpt_lat_field = waypoint_choice.latitude;
    wpt_conversion_func = [];
    if isfield(waypoint_choice_list, 'conversion')
      wpt_conversion_func = waypoint_choice.conversion;
    end
    if all(ismember({wpt_lat_field wpt_lon_field}, field_list)) ...
        && ~all(isnan(data_raw.(wpt_lon_field))) ...
        && ~all(isnan(data_raw.(wpt_lat_field)))
      data_pre.waypoint_longitude = data_raw.(wpt_lon_field);
      data_pre.waypoint_latitude = data_raw.(wpt_lat_field);
      meta_pre.waypoint_longitude.sources = wpt_lon_field;
      meta_pre.waypoint_latitude.sources = wpt_lat_field;
      fprintf('Selected waypoint position sensors %d:\n', waypoint_choice_idx);
      fprintf('  waypoint longitude: %s\n', wpt_lon_field);
      fprintf('  waypoint latitude : %s\n', wpt_lat_field);
      if ~isempty(wpt_conversion_func)
        if ischar(wpt_conversion_func)
          wpt_conversion_func = str2func(wpt_conversion_func);
        end
        [data_pre.waypoint_longitude, data_pre.waypoint_latitude] = ...
          wpt_conversion_func(data_pre.waypoint_longitude, ...
                              data_pre.waypoint_latitude);
        meta_pre.waypoint_longitude.sources = {wpt_lon_field wpt_lat_field}';
        meta_pre.waypoint_longitude.conversion = func2str(wpt_conversion_func);
        meta_pre.waypoint_latitude.sources = {wpt_lon_field wpt_lat_field}';
        meta_pre.waypoint_latitude.conversion = func2str(wpt_conversion_func);
        fprintf('  conversion : %s\n', func2str(wpt_conversion_func));
      end
      break;
    end
  end
  
  
  %% Select averaged water velocity sensor.
  % Find preferred valid averaged water velocity sensor available in list of 
  % sensor fields, if any.
  water_velocity_choice_list = options.water_velocity_list;
  for water_velocity_choice_idx = 1:numel(water_velocity_choice_list)
    water_velocity_choice = ...
      water_velocity_choice_list(water_velocity_choice_idx);
    wat_vel_east_field = water_velocity_choice.velocity_eastward;
    wat_vel_north_field = water_velocity_choice.velocity_northward;
    wat_vel_conversion_func = [];
    if isfield(water_velocity_choice_list, 'conversion')
      wat_vel_conversion_func = water_velocity_choice.conversion;
    end
    if all(ismember({wat_vel_north_field wat_vel_east_field}, field_list)) ...
        && ~all(isnan(data_raw.(wat_vel_east_field))) ...
        && ~all(isnan(data_raw.(wat_vel_north_field)))
      data_pre.water_velocity_eastward = data_raw.(wat_vel_east_field);
      data_pre.water_velocity_northward = data_raw.(wat_vel_north_field);
      fprintf('Selected water velocity sensors %d:\n', water_velocity_choice_idx);
      fprintf('  water velocity eastward : %s\n', wat_vel_east_field);
      fprintf('  water velocity northward: %s\n', wat_vel_north_field);
      if ~isempty(wat_vel_conversion_func)
        if ischar(wat_vel_conversion_func)
          wat_vel_conversion_func = str2func(wat_vel_conversion_func);
        end
        [data_pre.water_velocity_northward, data_pre.water_velocity_eastward] = ...
          wat_vel_conversion_func(data_pre.water_velocity_eastward, ...
                                  data_pre.water_velocity_northward);
        meta_pre.water_velocity_eastward.sources = ...
          {wat_vel_north_field wat_vel_east_field}';
        meta_pre.water_velocity_eastward.conversion = ...
          func2str(wat_vel_conversion_func);
        meta_pre.water_velocity_northward.sources = ...
          {wat_vel_east_field wat_vel_north_field}';
        meta_pre.water_velocity_northward.conversion = ...
          func2str(wat_vel_conversion_func);
        fprintf('  conversion : %s\n', func2str(wat_vel_conversion_func));
      end
      break;
    end
  end
  
  
  %% Select CTD sensor.
  % Find preferred valid CTD sensor available in list of sensor fields, if any.
  ctd_choice_list = options.ctd_list;
  for ctd_choice_idx = 1:numel(ctd_choice_list)
    ctd_choice = ctd_choice_list(ctd_choice_idx);
    cond_field = ctd_choice.conductivity;
    temp_field = ctd_choice.temperature;
    pres_field = ctd_choice.pressure;
    time_ctd_field = [];
    pressure_conversion_func = [];
    condtemp_calibration_func = [];
    if isfield(ctd_choice_list, 'time')
      time_ctd_field = ctd_choice.time;
    end
    if isfield(ctd_choice_list, 'oxygen')
      oxygen_ctd_field = ctd_choice.oxygen;
    end    
    if isfield(ctd_choice_list, 'pressure_conversion')
      pressure_conversion_func = ctd_choice.pressure_conversion;
    end
    if isfield(ctd_choice_list, 'calibration')
      condtemp_calibration_func = ctd_choice.calibration;
    end
    if all(ismember({cond_field temp_field pres_field}, field_list)) ...
        && any(data_raw.(cond_field) > 0) ...
        && any(data_raw.(temp_field) > 0) ...
        && any(data_raw.(pres_field) > 0)
      data_pre.conductivity = data_raw.(cond_field);
      data_pre.temperature = data_raw.(temp_field);
      data_pre.pressure = data_raw.(pres_field);
      meta_pre.conductivity.sources = cond_field;
      meta_pre.temperature.sources = temp_field;
      meta_pre.pressure.sources = pres_field;
      fprintf('Selected CTD sensor %d:\n', ctd_choice_idx);
      fprintf('  conductivity: %s\n', cond_field);
      fprintf('  temperature : %s\n', temp_field);
      fprintf('  pressure    : %s\n', pres_field);
      if ~isempty(time_ctd_field) ...
          && ismember(time_ctd_field, field_list) ...
          && any(data_raw.(time_ctd_field) > 0)
        data_pre.time_ctd = data_raw.(time_ctd_field);
        meta_pre.time_ctd.sources = time_ctd_field;
        fprintf('  time CTD    : %s\n', time_ctd_field);
      end
      % SeaExplorer glider has GPCTD_DOF
      if ~isempty(oxygen_ctd_field)
          data_pre.oxygen_frequency = data_raw.(oxygen_ctd_field);
          meta_pre.oxygen_frequency.sources = oxygen_ctd_field;
          fprintf('  oxygen frequency (gpctd)    : %s\n', oxygen_ctd_field);
      end
      if ~isempty(pressure_conversion_func)
        if ischar(pressure_conversion_func)
          pressure_conversion_func = str2func(pressure_conversion_func);
        end
        data_pre.pressure = pressure_conversion_func(data_pre.pressure);
        meta_pre.pressure.conversion = func2str(pressure_conversion_func);
        fprintf('  pressure conversion : %s\n', func2str(pressure_conversion_func));
      end
      if ~isempty(condtemp_calibration_func)
        if ischar(condtemp_calibration_func)
          condtemp_calibration_func = str2func(condtemp_calibration_func);
        end
        temp_calib_params = calibration_parameters.(temp_field);
        cond_calib_params = calibration_parameters.(cond_field);
        [data_pre.temperature, data_pre.conductivity] = ...
          condtemp_calibration_func( ...
            data_pre.temperature, data_pre.conductivity, data_pre.pressure, ...
            temp_calib_params, cond_calib_params);
        if isstruct(temp_calib_params)
          temp_calib_param_names = fieldnames(temp_calib_params);
          temp_calib_param_values = cell2mat(struct2cell(temp_calib_params));
        else
          temp_calib_param_names = {};
          temp_calib_param_values = temp_calib_params;
        end
        if isstruct(cond_calib_params)
          cond_calib_param_names = fieldnames(cond_calib_params);
          cond_calib_param_values = cell2mat(struct2cell(cond_calib_params));
        else
          cond_calib_param_names = {};
          cond_calib_param_values = cond_calib_params;
        end
        meta_pre.temperature.sources = {cond_field temp_field pres_field}';
        meta_pre.temperature.calibration = func2str(condtemp_calibration_func);
        meta_pre.temperature.calibration_parameters = temp_calib_param_values;
        meta_pre.conductivity.sources = {cond_field temp_field pres_field}';
        meta_pre.conductivity.calibration = func2str(condtemp_calibration_func);
        meta_pre.conductivity.calibration_parameters = cond_calib_param_values;
        if isempty(temp_calib_param_names)
          temp_calib_param_names = ...
            arrayfun(@num2str, 1:numel(temp_calib_param_values), ...
                     'UniformOutput', false);
        else
          meta_pre.temperature.calibration_parameter_names = ...
            temp_calib_param_names;
        end
        if isempty(cond_calib_param_names)
          temp_calib_param_names = ...
            arrayfun(@num2str, 1:numel(cond_calib_param_values), ...
                     'UniformOutput', false);
        else
          meta_pre.conductivity.calibration_parameter_names = ...
            cond_calib_param_names;
        end
        fprintf('  calibration : %s\n', func2str(condtemp_calibration_func));
        for temp_calib_param_idx = 1:numel(temp_calib_param_names)
          fprintf('  temperature  calibration parameter %-8s: %f\n', ...
                  temp_calib_param_names{temp_calib_param_idx}, ...
                  temp_calib_param_values(temp_calib_param_idx));
        end
        for cond_calib_param_idx = 1:numel(cond_calib_param_names)
          fprintf('  conductivity calibration parameter %-8s: %f\n', ...
                  cond_calib_param_names{cond_calib_param_idx}, ...
                  cond_calib_param_values(cond_calib_param_idx));
        end
      end
      break;
    end
  end
  
  
  %% Select oxygen sensors.
  % Find preferred valid oxygen sensor availbale in list of sensor fields, 
  % if any.
  oxygen_choice_list = options.oxygen_list;
  for oxygen_choice_idx = 1:numel(oxygen_choice_list)
    oxygen_choice = oxygen_choice_list(oxygen_choice_idx);
    oxy_con_field = oxygen_choice.oxygen_concentration;
    oxy_sat_field = oxygen_choice.oxygen_saturation;
    time_oxygen_field = [];
    temperature_oxygen_field = [];
    if isfield(oxygen_choice_list, 'time')
      time_oxygen_field = oxygen_choice.time;
    end
    if isfield(oxygen_choice_list, 'temperature')
      temperature_oxygen_field = oxygen_choice.temperature;
    end
    if all(ismember({oxy_con_field oxy_sat_field}, field_list)) ...
        && any(data_raw.(oxy_con_field) > 0) ...
        && any(data_raw.(oxy_sat_field) > 0)
      data_pre.oxygen_concentration = data_raw.(oxy_con_field);
      data_pre.oxygen_saturation = data_raw.(oxy_sat_field);
      meta_pre.oxygen_concentration.sources = oxy_con_field;
      meta_pre.oxygen_saturation.sources = oxy_sat_field;
      fprintf('Selected oxygen sensor %d:\n', oxygen_choice_idx);
      fprintf('  oxygen concentration: %s\n', oxy_con_field);
      fprintf('  oxygen saturation   : %s\n', oxy_sat_field);
      if ~isempty(time_oxygen_field) ...
          && ismember(time_oxygen_field, field_list) ...
          && any(data_raw.(time_oxygen_field) > 0)
        data_pre.time_oxygen = data_raw.(time_oxygen_field);
        meta_pre.time_oxygen.sources = time_oxygen_field;
        fprintf('  time oxygen         : %s\n', time_oxygen_field);
      end
      if ~isempty(temperature_oxygen_field) ...
          && ismember(temperature_oxygen_field, field_list) ...
          && any(data_raw.(temperature_oxygen_field) > 0)
        data_pre.temperature_oxygen = data_raw.(temperature_oxygen_field);
        meta_pre.temperature_oxygen.sources = temperature_oxygen_field;
        fprintf('  temperature oxygen  : %s\n', temperature_oxygen_field);
      end
      break;
    end
  end
  
  
  %% Select fluorescence and scatter sensor (chlorophyll, turbidity, cdom...).
  % Find preferred valid fluorescence and turbidity sensor available in list of 
  % sensor fields, if any.
  optics_choice_list = options.optics_list;
  optics_variables = {'chlorophyll' 'turbidity' 'cdom' 'scatter_650' ...
                      'backscatter_700'};
  for optics_choice_idx = 1:numel(optics_choice_list)
    optics_choice = optics_choice_list(optics_choice_idx);
    optics_variables_select = ...
      cellfun(@(v)(isfield(optics_choice_list, v) && ~isempty(optics_choice.(v))), ...
              optics_variables);
    optics_var_list = optics_variables(optics_variables_select);
    optics_field_list = cellfun(@(v)(optics_choice.(v)), ...
                                optics_var_list, 'UniformOutput', false);
    time_optics_field = [];
    optics_calibration_func = [];
    if isfield(optics_choice_list, 'time')
      time_optics_field = optics_choice.time;
    end
    if isfield(optics_choice_list, 'calibration')
      optics_calibration_func = optics_choice.calibration;
    end
    optics_available = ...
      all(ismember(optics_field_list, field_list)) && ...
      all(cellfun(@(f)(any(data_raw.(f)) > 0), optics_field_list));
    if optics_available
      fprintf('Selected fluorescence and scatter sensor %d:\n', optics_choice_idx);
      for optics_var_idx = 1:numel(optics_var_list);
        optics_var = optics_var_list{optics_var_idx};
        optics_field = optics_field_list{optics_var_idx};
        data_pre.(optics_var) = data_raw.(optics_field);
        meta_pre.(optics_var).sources = optics_field;
        fprintf('  %-12s: %s\n', optics_var, optics_field);
      end
      if ~isempty(time_optics_field) ...
          && ismember(time_optics_field, field_list) ...
          && any(data_raw.(time_optics_field) > 0)
        data_pre.time_optics = data_raw.(time_optics_field);
        meta_pre.time_optics.sources = time_optics_field;
        fprintf('  time_optics  : %s\n', time_optics_field);
      end
      if ~isempty(optics_calibration_func)
        if ischar(optics_calibration_func)
          optics_calibration_func = str2func(optics_calibration_func);
        end
        optics_calib_data = ...
          cellfun(@(v)(data_pre.(v)), optics_var_list, 'UniformOutput', false);
        optics_calib_params = ...
          cellfun(@(f)(calibration_parameters.(f)), optics_field_list, ...
                  'UniformOutput', false);
        [optics_calib_data{:}] = ...
          optics_calibration_func(optics_calib_data{:}, optics_calib_params{:});
        fprintf('  calibration : %s\n', func2str(optics_calibration_func));
        for optics_var_idx = 1:numel(optics_var_list);
          optics_var = optics_var_list{optics_var_idx};
          optics_var_calib_data = optics_calib_data{optics_var_idx};
          optics_var_calib_params = optics_calib_params{optics_var_idx};
          data_pre.(optics_var) = optics_var_calib_data;
          if isstruct(optics_var_calib_params)
            optics_var_calib_param_names = fieldnames(optics_var_calib_params);
            optics_var_calib_param_values = ...
              cell2mat(struct2cell(optics_var_calib_params));
          else
            optics_var_calib_param_names = {};
            optics_var_calib_param_values = optics_var_calib_params;
          end
          meta_pre.(optics_var).calibration = func2str(optics_calibration_func);
          meta_pre.(optics_var).calibration_parameters = ...
            optics_var_calib_param_values;
          if isempty(optics_var_calib_param_names)
            optics_var_calib_param_names = ...
              arrayfun(@num2str, 1:numel(optics_var_calib_param_values), ...
                       'UniformOutput', false);
          else
            meta_pre.(optics_var).calibration_parameter_names = ...
              optics_var_calib_param_names;
          end
          for optics_var_calib_param_idx = 1:numel(optics_var_calib_param_names)
            fprintf('  %-12s calibration parameter %-8s: %f\n', optics_var, ...
                    optics_var_calib_param_names{optics_var_calib_param_idx}, ...
                    optics_var_calib_param_values(optics_var_calib_param_idx));
          end
        end
      end
      break;
    end
  end
  
  
  %% Select any other extra sensor.
  % Add the preferred valid extra sensor available in list of sensor fields,
  % for each extra sensor option given.
  extra_sensor_name_list = fieldnames(options.extra_sensor_list);
  for extra_sensor_name_idx = 1:numel(extra_sensor_name_list)
    extra_sensor_name = extra_sensor_name_list{extra_sensor_name_idx};
    extra_sensor_choice_list = options.extra_sensor_list.(extra_sensor_name);
    extra_sensor_variables = setdiff(fieldnames(extra_sensor_choice_list), ...
                                     {'calibration' 'conversion'});
    for extra_sensor_choice_idx = 1:numel(extra_sensor_choice_list)
      extra_sensor_choice = extra_sensor_choice_list(extra_sensor_choice_idx);
      extra_sensor_fields = ...
        cellfun(@(v)(extra_sensor_choice.(v)), extra_sensor_variables, ...
                'UniformOutput', false);
      extra_sensor_variable_select = ~cellfun(@isempty, extra_sensor_fields);
      extra_sensor_var_list = ...
        extra_sensor_variables(extra_sensor_variable_select);
      extra_sensor_field_list = ...
        extra_sensor_fields(extra_sensor_variable_select);
      extra_sensor_conversion_func = [];
      extra_sensor_calibration_func = [];
      if isfield(extra_sensor_choice_list, 'conversion')
        extra_sensor_conversion_func = extra_sensor_choice.conversion;
      end
      if isfield(extra_sensor_choice_list, 'calibration')
        extra_sensor_calibration_func = extra_sensor_choice.calibration;
      end
      extra_sensor_available = ...
        all(ismember(extra_sensor_field_list, field_list)) && ...
        all(cellfun(@(f)(~all(isnan(data_raw.(f)))), extra_sensor_field_list));
      if extra_sensor_available
        fprintf('Selected %s sensor %d:\n', ...
                extra_sensor_name, extra_sensor_choice_idx);
        extra_sensor_data = cell(size(extra_sensor_var_list));
        for extra_sensor_var_idx = 1:numel(extra_sensor_var_list)
          extra_sensor_var = ... 
            extra_sensor_var_list{extra_sensor_var_idx};
          extra_sensor_field = ...
            extra_sensor_field_list{extra_sensor_var_idx};
          extra_sensor_data{extra_sensor_var_idx} = ...
            data_raw.(extra_sensor_field);
          meta_pre.(extra_sensor_var).sources = extra_sensor_field;
          fprintf('  %-12s: %s\n', extra_sensor_var, extra_sensor_field);
        end
        if ~isempty(extra_sensor_conversion_func)
          if ischar(extra_sensor_conversion_func)
            extra_sensor_conversion_func = ...
              str2func(extra_sensor_conversion_func);
          end
          [extra_sensor_data{:}] = ...
            extra_sensor_conversion_func(extra_sensor_data{:});
          fprintf('  conversion : %s\n', func2str(extra_sensor_conversion_func));
          for extra_sensor_var_idx = 1:numel(extra_sensor_var_list);
            extra_sensor_var = ...
              extra_sensor_var_list{extra_sensor_var_idx};
            meta_pre.(extra_sensor_var).sources = extra_sensor_field_list;
            meta_pre.(extra_sensor_var).conversion = ...
              func2str(extra_sensor_conversion_func);
          end
        end
        if ~isempty(extra_sensor_calibration_func)
          if ischar(extra_sensor_calibration_func)
            extra_sensor_calibration_func = ...
              str2func(extra_sensor_calibration_func);
          end
          extra_sensor_calib_params = ...
            cellfun(@(f)(calibration_parameters.(f)), extra_sensor_field_list, ...
                    'UniformOutput', false);
          [extra_sensor_data{:}] = ...
            extra_sensor_calibration_func(extra_sensor_data{:}, ...
                                          extra_sensor_calib_params{:});
          fprintf('  calibration : %s\n', func2str(extra_sensor_calibration_func));
          for extra_sensor_var_idx = 1:numel(extra_sensor_var_list);
            extra_sensor_var = ...
              extra_sensor_var_list{extra_sensor_var_idx};
            extra_sensor_var_calib_params = ...
              extra_sensor_calib_params{extra_sensor_var_idx};
            if isstruct(extra_sensor_calib_params)
              extra_sensor_var_calib_param_names = ...
                fieldnames(extra_sensor_var_calib_params);
              extra_sensor_var_calib_param_values = ...
                cell2mat(struct2cell(extra_sensor_var_calib_params));
            else
              extra_sensor_var_calib_param_names = {};
              extra_sensor_var_calib_param_values = ...
                extra_sensor_var_calib_params;
            end
            meta_pre.(extra_sensor_var).sources = extra_sensor_field_list;
            meta_pre.(extra_sensor_var).calibration = ...
              func2str(extra_sensor_calibration_func);
            meta_pre.(extra_sensor_var).calibration_parameters = ...
              extra_sensor_var_calib_param_values;
            if isempty(extra_sensor_var_calib_param_names)
              extra_sensor_var_calib_param_names = ...
                arrayfun(@num2str, 1:numel(extra_sensor_var_calib_param_values), ...
                         'UniformOutput', false);
            else
              meta_pre.(extra_sensor_var).calibration_parameter_names = ...
                extra_sensor_var_calib_param_names;
            end
            for optics_var_calib_param_idx = 1:numel(extra_sensor_var_calib_param_names)
              fprintf('  %-12s calibration parameter %-8s: %f\n', ...
                      extra_sensor_var, ...
                      extra_sensor_var_calib_param_names{extra_sensor_var_calib_param_idx}, ...
                      extra_sensor_var_calib_param_values(extra_sensor_var_calib_param_idx));
            end
          end
        end
        for extra_sensor_var_idx = 1:numel(extra_sensor_var_list)
          extra_sensor_var = ... 
            extra_sensor_var_list{extra_sensor_var_idx};
          data_pre.(extra_sensor_var) = ...
            extra_sensor_data{extra_sensor_var_idx};
        end
        break
      end
    end
  end

end
