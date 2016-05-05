function nc = generateOutputNetCDF(filename, data, meta, deployment, vars, dims, atts, varargin)
%GENERATEOUTPUTNETCDF  Generate NetCDF output for glider deployment data.
%
%  Syntax:
%    NC = GENERATEOUTPUTNETCDF(FILENAME, DATA, META, DEPLOYMENT, VARS, DIMS, ATTS)
%    NC = GENERATEOUTPUTNETCDF(FILENAME, DATA, META, DEPLOYMENT, VARS, DIMS, ATTS, OPTIONS)
%    NC = GENERATEOUTPUTNETCDF(FILENAME, DATA, META, DEPLOYMENT, VARS, DIMS, ATTS, OPT1, VAL1, ...)
%
%  Description:
%    NC = GENERATEOUTPUTNETCDF(FILENAME, DATA, META, DEPLOYMENT, VARS, DIMS, ATTS)
%    calls SAVENC to generate a NetCDF file named FILENAME from deployment data
%    in struct DATA, according to the template defined by variable metadata in
%    VARS, dimension definitions in struct DIMS and global attributes in struct
%    array ATTS, and returns the absolute name of the generated file in string
%    NC.
%
%    DATA and VARS should be structs with one field per variable with the
%    variable data and the variable metadata respectively, as needed by SAVENC.
%    To allow runtime defined variable metadata, META might be a struct with 
%    variable names as field names and runtime defined variable attributes as 
%    values. Each field should be a struct with the vattribute names as field
%    names and the attribute values as field values. If the value of a variable
%    attribute in a field of VARS is left undefined (empty) and its name matches
%    a field name of the corresponding variable field in META, the value is
%    overwritten.
%
%    DIMS should be a struct as needed by SAVENC. To allow runtime defined 
%    dimensions and predefined dimensions (useful for the case of string
%    variables), variables may specifye dimensions in VARS which are not defined 
%    in DIMS or with undefined length (empty LENGTH field value), and they are 
%    inferred from the size of the data values.
%
%    ATTS should be a struct array as needed by SAVENC, too. To allow runtime 
%    defined global attributes, attributes in ATTS whose name matches a field
%    name in struct DEPLOYMENT are overwritten with the field value.
%    In addition, if the following global attributes are present in struct ATTS, 
%    they are updated with values computed from data (see options below):
%      DATE_MODIFIED: modification time given by POSIXTIME ('yyyy-mm-ddTHH:MM:SS+00:00').
%      GEOSPATIAL_LAT_MAX: maximum latitude value inferred from data.
%      GEOSPATIAL_LAT_MIN: minimum latitude value inferred from data.
%      GEOSPATIAL_LAT_UNITS: latitude units given by variable attributes.
%      GEOSPATIAL_LON_MAX: maximum longitude value inferred from data.
%      GEOSPATIAL_LON_MIN: minimum longitude value inferred from data.
%      GEOSPATIAL_LON_UNITS: longitude units given by variable attributes.
%      GEOSPATIAL_VERTICAL_MAX: maximum vertical value inferred from data.
%      GEOSPATIAL_VERTICAL_MIN: minimum vertical value inferred from data.
%      GEOSPATIAL_VERTICAL_UNITS: vertical units given by variable attributes.
%      GEOSPATIAL_VERTICAL_POSITIVE: vertical positive direction given by variable attributes.
%      TIME_COVERAGE_END: maximum time value inferred from data.
%      TIME_COVERAGE_START: minimum time value inferred from data.
%      TIME_COVERAGE_UNITS: time units given by value variable attributes.
%
%    NC = GENERATEOUTPUTNETCDF(..., OPTIONS) and
%    NC = GENERATEOUTPUTNETCDF(..., OPT1, VAL1, ...) accept the following
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS 
%    with field names as option keys and field values as option values, 
%    to control the generation of coverage metadata:
%      MODIFIED: modification time stamp.
%        String with the timestamp for the 'date_modified' attribute.
%        Default value: 
%          datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00');
%      TIME: variable choices for time coverage information.
%        Char array or string cell array with the names of the variables from
%        which to extract the time coverage information, in order of preference.
%        Default value: 'time'
%      TIME_CONVERSION: conversion to POSIX time for time coverage.
%        String cell array of function names or cell array of function handles 
%        with the functions to convert time variables in option TIME to POSIX
%        time format (seconds since 1970-01-01 00:00:00 UTC). If a single value
%        is provided, the same conversion is used for all variable choices.
%        If empty, no conversion is applied.
%      TIME_FORMAT: format for time coverage timestamps.
%        String cell array of function names or cell array of function handles 
%        with the functions to convert each time variable choice in option TIME
%        to the desired timestamp format (instead of using the numeric values).
%        If a single value is provided, the same format is used for all choices.
%        If empty, no format is applied and the numeric values are used.
%        Default value: @(t)(datestr(posixtime2utc(t), 'yyyy-mm-ddTHH:MM:SS+00:00'))
%      POSITION: variable choice for position coverage information.
%        Two column string cell array with the names of the variables from which 
%        to extract the position coverage information (latitude and longitude).
%        Columns correspond to the x and y coordinates respectively.
%        Default value: {'longitude' 'latitude'}
%      POSITION_CONVERSION: conversion to decimal degrees for position coverage.
%        String cell array of function names or cell array of function handles 
%        with the functions to convert each choice of position variables in 
%        option POSITION to longitude and latitude in decimal degrees
%        (in that order). If a single value is provided, the same conversion 
%        is used for all variable choices. If empty, no conversion is applied.
%        Default value: [] (no conversion applied)
%      VERTICAL: variable choice for latitude coverage information.
%        Char array or string cell array with the names of the variables from
%        which to extract the vertical coverage information, in order of 
%        preference.
%        Default value: 'depth'
%      VERTICAL_CONVERSION: conversion to meters for vertical coverage.
%        String cell array of function names or cell array of function handles 
%        with the functions to convert each choice of vertical coordinate 
%        variable in option VERTICAL to meters. If a single value is provided,
%        the same conversion is used for all variable choices. If empty, 
%        no conversion is applied.
%        Default value: [] (no conversion applied)
%      VERTICAL_POSITIVE: vertical positive direction.
%        Char array or string cell array with the positive direction of each
%        choice of vertical coordinate variable in option VERTICAL ('up' or 
%        'down'). If a single string is provided, the same direction is assumed
%        for all vertical coordinate variables.
%        Default value: 'down'
%
%  Notes:
%    Usually input data is the output of LOADSLOCUMDATA or LOADSEAGLIDERDATA, 
%    PROCESSGLIDERDATA or GRIDGLIDERDATA.
%    
%    Be aware that only variables present in both structs DATA and VARS are 
%    added to the NetCDF file. Any field in DATA not present in VARS is omited.
%
%  Examples:
%    nc = generateOutputNetCDF(filename, data, deployment, vars, dims, atts)
%    nc = ...
%      generateOutputNetCDF( ...
%       filename, data, deployment, vars, dims, atts, ...
%       'time', {'m_present_time' 'sci_m_present_time'}, ...
%       'vertical', {'m_depth' 'sci_water_pressure' 'm_pressure'}, ...
%       'vertical_positive', 'down', ...
%       'vertical_conversion', {false, @(z)(z*10), @(z)(z*10)}, ...
%       'position', {'m_gps_lon' 'm_gps_lat'; 'm_lon' 'm_lat'}, ...
%       'position_conversion', ...
%          @(x,y)(subsref({nmea2deg(x) nmea2deg(y)}, substruct('{}', {':'}))))
%
%  See also:
%    SAVENC
%    POSIXTIME2UTC
%    POSIXTIME
%    NMEA2DEG
%    LOADSLOCUMDATA
%    LOADSEAGLIDERDATA
%    PREPROCESSGLIDERDATA
%    PROCESSGLIDERDATA
%    GRIDGLIDERDATA
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

  error(nargchk(6, 26, nargin, 'struct'));
  
  %% Set options and default values.
  options.modified = ...
    datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00');
  options.time = 'time';
  options.time_conversion = [];
  options.time_format = ...
    @(t)(datestr(posixtime2utc(t), 'yyyy-mm-ddTHH:MM:SS+00:00'));
  options.position = {'longitude' 'latitude'};
  options.position_conversion = [];
  options.vertical = 'depth';
  options.vertical_conversion = [];
  options.vertical_positive = 'down';
 
  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:generateOutputNetCDF:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:generateOutputNetCDF:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  

  %% Get dynamic global attribute values.
  dyn_atts = struct();
  % Modification date:
  dyn_atts.date_modified = options.modified;
  % Time coverage:
  time_field_list = cellstr(options.time);
  time_field_present = ...
    isfield(data, time_field_list) & isfield(vars, time_field_list);
  if any(time_field_present)
    time_field_index = find(time_field_present, 1);
    time_field = time_field_list{time_field_index};
    time_units = [];
    if iscell(options.time_conversion)
      time_func = options.time_conversion{time_field_index};
    else
      time_func = options.time_conversion;
    end
    if isempty(time_func)
      time_data = data.(time_field);
      if isfield(vars.(time_field), 'attributes')
        time_atts = vars.(time_field).attributes;
        time_units_select = strcmp('units', {time_atts.name});
        if any(time_units_select)
          time_units = time_atts(time_units_select).value;
        end
      end
    else
      if ischar(time_func)
        time_func = str2func(time_func);
      end
      time_data = time_func(data.(time_field));
    end
    if numel(options.time_format) > 1
      time_format_func = options.time_format{time_field_index};
    else
      time_format_func = options.time_format;
    end
    if isempty(time_format_func)
      dyn_atts.time_coverage_start = min(time_data);
      dyn_atts.time_coverage_end = max(time_data);
      if time_units
        dyn_atts.time_coverage_units = time_units;
      end
    else
      dyn_atts.time_coverage_start = time_format_func(min(time_data));
      dyn_atts.time_coverage_end = time_format_func(max(time_data));
    end
  end
  % Geospatial coverage:
  position_field_list  = cellstr(options.position);
  position_field_present = all(isfield(data, position_field_list) ...
                             & isfield(vars, position_field_list), 2);
  if any(position_field_present)
    position_field_index = find(position_field_present, 1);
    [position_x_field, position_y_field] = ...
      position_field_list{position_field_index, :};
    if iscell(options.position_conversion)
      position_func = options.position_conversion{position_field_index};
    else
      position_func = options.position_conversion;
    end
    if isempty(position_func)
      longitude_data = data.(position_x_field);
      latitude_data = data.(position_y_field);
      longitude_units = [];
      latitude_units = [];
      if isfield(vars.(position_x_field), 'attributes')
        longitude_atts = vars.(position_x_field).attributes;
        longitude_units_select = strcmp('units', {longitude_atts.name});
        if any(longitude_units_select)
          longitude_units = longitude_atts(longitude_units_select).value;
        end
      end
      if isfield(vars.(position_y_field), 'attributes')
        latitude_atts = vars.(position_y_field).attributes;
        latitude_units_select = strcmp('units', {latitude_atts.name});
        if any(latitude_units_select)
          latitude_units = latitude_atts(latitude_units_select).value;
        end
      end
    else
      if ischar(position_func)
        position_func = str2func(position_func);
      end
      [longitude_data, latitude_data] = ...
        position_func(data.(position_x_field), data.(position_y_field));
      longitude_units = 'degree_east';
      latitude_units = 'degree_north';
    end
    dyn_atts.geospatial_lon_min = min(longitude_data);
    dyn_atts.geospatial_lon_max = max(longitude_data);
    dyn_atts.geospatial_lat_min = min(latitude_data);
    dyn_atts.geospatial_lat_max = max(latitude_data);
    if longitude_units
      dyn_atts.geospatial_lon_units = longitude_units;
    end
    if latitude_units
      dyn_atts.geospatial_lat_units = latitude_units;
    end
  end
  % Vertical coverage:
  vertical_field_list  = cellstr(options.vertical);
  vertical_field_present = ...
    isfield(data, vertical_field_list) & isfield(vars, vertical_field_list);
  if any(vertical_field_present)
    vertical_field_index = find(vertical_field_present, 1);
    vertical_field = vertical_field_list{vertical_field_index};
    if iscell(options.vertical_conversion)
      vertical_func = options.vertical_conversion{vertical_field_index};
    else
      vertical_func = options.vertical_conversion;
    end
    if isempty(vertical_func)
      vertical_data = data.(vertical_field);
      vertical_units = [];
      vertical_positive = [];
      if isfield(vars.(vertical_field), 'attributes')
        vertical_atts = vars.(vertical_field).attributes;
        vertical_units_select = strcmp('units', {vertical_atts.name});
        vertical_positive_select = strcmp('positive', {vertical_atts.name});
        if any(vertical_units_select)
          vertical_units = vertical_atts(vertical_units_select).value;
        end
        if any(vertical_positive_select)
          vertical_positive = vertical_atts(vertical_positive_select).value;
        end
      end
    else
      if ischar(vertical_func)
        vertical_func = str2func(vertical_func);
      end
      vertical_data = vertical_func(data.(vertical_field));
      vertical_units = 'meters';
      vertical_positive_list = cellstr(options.vertical_positive);
      if numel(vertical_positive_list) > 1
        vertical_positive = vertical_positive_list{position_field_index};
      else
        vertical_positive = vertical_positive_list{1};
      end
    end
    dyn_atts.geospatial_vertical_min = min(vertical_data);
    dyn_atts.geospatial_vertical_max = max(vertical_data);
    if vertical_units
      dyn_atts.geospatial_vertical_units = vertical_units;
    end
    if vertical_positive
      dyn_atts.geospatial_vertical_positive = vertical_positive;
    end
  end
  

  %% Aggregate global metadata (global attributes and dimension definitions).
  global_meta = struct();
  % Set global attributes.
  global_meta.attributes = atts;
  % Overwrite default attributes with deployment fields or dynamic values.
  for att_idx = 1:numel(global_meta.attributes)
    if isfield(deployment, global_meta.attributes(att_idx).name)
      global_meta.attributes(att_idx).value = ...
        deployment.(global_meta.attributes(att_idx).name);
    elseif isfield(dyn_atts, global_meta.attributes(att_idx).name)
      global_meta.attributes(att_idx).value = ...
        dyn_atts.(global_meta.attributes(att_idx).name);
    end
  end
  % Set dimension lengths.
  global_meta.dimensions = dims;
  % Overwrite lengths of dimensions not defined by input arguments.
  var_name_list = fieldnames(vars);
  for var_idx = 1:numel(var_name_list);
    var_name = var_name_list{var_idx};
    if isfield(data, var_name)
      dim_name_list = vars.(var_name).dimensions;
      dim_size_list = size(data.(var_name));
      for dim_idx = 1:numel(dim_name_list)
        dim_name = dim_name_list{dim_idx};
        dim_size = dim_size_list(dim_idx);
        dim_comp = strcmp(dim_name, {global_meta.dimensions.name});
        if ~any(dim_comp)
          global_meta.dimensions(end+1) = ...
            struct('name', {dim_name}, 'length', {dim_size});
        elseif isempty(global_meta.dimensions(dim_comp).length)
          global_meta.dimensions(dim_comp).length = dim_size;
        end
      end
    end
  end
  
  
  %% Aggregate variable metadata and overwrite runtime defined metadata.
  variable_meta = struct();
  var_name_list = fieldnames(vars);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    if isfield(data, var_name)
      variable_meta.(var_name) = vars.(var_name);
      % Loop in reverse order to allow for deletion of indexed attributes.
      for att_idx = numel(variable_meta.(var_name).attributes):-1:1
        att_name = variable_meta.(var_name).attributes(att_idx).name;
        att_value = variable_meta.(var_name).attributes(att_idx).value;
        if isempty(att_value)
          if isfield(meta, var_name) && isfield(meta.(var_name), att_name)
            if iscellstr(meta.(var_name).(att_name))
              variable_meta.(var_name).attributes(att_idx).value = ...
                strtrim(sprintf('%s ', meta.(var_name).(att_name){:}));
            elseif islogical(meta.(var_name).(att_name))
              variable_meta.(var_name).attributes(att_idx).value = ...
                uint8(meta.(var_name).(att_name));
            else
              variable_meta.(var_name).attributes(att_idx).value = ...
                meta.(var_name).(att_name);
            end
          else
            variable_meta.(var_name).attributes(att_idx) = [];
          end
        end
      end
    end
  end
  
  
  %% Aggregate required variable data and apply required conversions.
  variable_data = struct();
  data_field_list = fieldnames(data);
  for data_field_idx = 1:numel(data_field_list)
    data_field = data_field_list{data_field_idx};
    if isfield(vars, data_field)
      % Convert text data from string cell array to C style strings.
      if iscellstr(data.(data_field))
        variable_data.(data_field) = strc(data.(data_field));
      else
        variable_data.(data_field) = data.(data_field);
      end
    end
  end
  
  
  %% Create base directory of target file if needed.
  % This seems to be the best way to check if a relative path points to
  % an existing directory (EXIST checks for existance in the whole load path).
  [file_dir, ~, ~] = fileparts(filename);
  [status, attrout] = fileattrib(file_dir);
  if ~status
    [success, message] = mkdir(file_dir);
    if ~success
      error('glider_toolbox:generateOutputNetCDF:NetCDFDirectoryError', ...
            'Could not create directory %s: %s.', file_dir, message);
    end
  elseif ~attrout.directory
    error('glider_toolbox:generateOutputNetCDF:NetCDFDirectoryError', ...
          'Not a directory: %s.', attrout.Name);
  end
  
  
  %% Generate the file.
  savenc(variable_data, variable_meta, global_meta, filename);
  
  
  %% Return the absolute name of the generated file.
  [status, attrout, ~] = fileattrib(filename);
  if status==0
    % We should never get here (if NetCDF creation succeed, file must exist).
    error('glider_toolbox:generateOutputNetCDF:NetCDFFileError', ...
          'NetCDF generation succeed but problems with output file %s: %s.', ...
          filename, attrout);
  end
  nc = attrout.Name;

end
