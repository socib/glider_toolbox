function data_pre = preprocessGliderData(data_raw, options)
%PREPROCESSGLIDERDATA  Preprocess glider deployment data.
%
%  [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, OPTIONS) preprocesses
%  glider deployment data in struct DATA_RAW according to option struct OPTIONS,
%  returning the preprocessed data in struct DATA_PRE. It performs the following
%  actions:
%    - Convert NMEA latitude/longitude format to decimal degrees.
%
%  DATA_RAW should be a struct with vector fields containing time series of
%  sensor data and named after the corresponding sensor.
%
%  OPTIONS should be a struct with the following preprocessing option fields:
%    NMEA_COORD_SENSORS: string cell array with the list of latitude/longitude 
%      to be converted from NMEA degrees to decimal degrees.
%
%  DATA_PRE is a copy of DATA_RAW with the following conversions applied:
%    - Each serie in NMEA_COORD_SENSORS option is converted from NMEA degrees to
%      decimal degrees using the function NMEA2DEG.
%
%  All fields in struct OPTIONS are optional. If any field is missing the
%  conversion is not applied.
%
%  Examples:
%    data_pre = preprocessGliderData(data_raw, options)
%
%  See also:
%    NMEA2DEG
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 2, nargin));
  
  % Initialize output data.
  data_pre = data_raw;
  
  % NMEA to decimal degree conversion.
  nmea_sensors = {};
  if isfield(options, 'nmea_coord_sensors')
    nmea_sensors = options.nmea_coord_sensors;
  end
  for sensor_idx = 1:numel(nmea_sensors)
    sensor_name = nmea_sensors{sensor_idx};
    if isfield(data_pre, sensor_name)
      data_pre.(sensor_name) = nmea2deg(data_pre.(sensor_name));
    end
  end

end
