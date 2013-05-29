function data_pre = preprocessGliderData(data_raw, varargin)
%PREPROCESSGLIDERDATA  Preprocess glider deployment data.
%
%  Syntax:
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW)
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, OPTIONS)
%    [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, OPT1, VAL1, ...)
%
%  [DATA_PRE, META_PRE] = PREPROCESSGLIDERDATA(DATA_RAW, ...) preprocesses
%  glider deployment data according to given options, performing the following 
%  actions:
%    - Convert NMEA latitude/longitude format to decimal degrees.
%
%  DATA_RAW should be a struct in the format returned by DBACAT or DBAMERGE,
%  where each field is a time sequence from the sensor with the same name.
%
%  Options may be given either as key-value pairs OPT1, VAL1 ... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    NMEA_CONVERSION_SENSOR_LIST: string cell array with the latitude or 
%      longitude sensor sequences to be converted from NMEA to decimal degrees.
%      Default value is empty list, any conversion applied.
%
%  DATA_PRE is a copy of DATA_RAW with the following conversions applied:
%    - Each serie in NMEA_CONVERSION_SENSOR_LIST option is converted from NMEA 
%      degrees to decimal degrees using the function NMEA2DEG.
%
%  Examples:
%    data_pre = preprocessGliderData(data_raw, options)
%
%  See also:
%    NMEA2DEG
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 3, nargin, 'struct'));
  
  %% Set preprocessing options.
  % Set default options values.
  options = struct();
  options.nmea_conversion_sensor_list = {};  
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
    error('glider_toolbox:processGliderData:InvalidOption', ...
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


  %% Initialize output data.
  data_pre = data_raw;


  %% NMEA to decimal degree conversion.
  for sensor_idx = 1:numel(options.nmea_conversion_sensor_list)
    sensor_name = options.nmea_conversion_sensor_list{sensor_idx};
    if isfield(data_pre, sensor_name)
      data_pre.(sensor_name) = nmea2deg(data_pre.(sensor_name));
    end
  end

end
