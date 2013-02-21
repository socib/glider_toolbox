function ncl2 = generateOutputNetCDFL2(filename, data, meta, dims, atts, deployment)
%GENERATEOUTPUTNETCDFL2  Generate NetCDF output for processed glider deployment data.
%
%  NCL2 = GENERATEOUTPUTNETCDFL1(FILENAME, DATA, META, DIMS, ATTS, DEPLOYMENT)
%  calls WRITENETCDFDATA to generate a NetCDF file named FILENAME from processed 
%  deployment data in struct DATA, variable metadata in struct META, dimension
%  names in struct DIMS and global attributes in struct array ATTS, and returns
%  the absolute name of the generated file in string NCL1.
%  DATA and META should be structs with one field per variable with the variable
%  data and the variable metadata respectively, as needed by WRITENETCDFDATA.
%  For gridded data, the DIMS argument should be a struct with the following
%  fields defining dimension names:
%    PROFILE: name of the profile index dimension (number of profiles).
%    DEPTH: name of the depth dimension (number of depth levels).
%  ATTS should be a struct array as needed by WRITENETCDFDATA, too. To allow 
%  runtime defined attributes, attributes in ATTS whose name match a field name 
%  in struct DEPLOYMENT are overwritten with the field value.
%  In addition, if the following global attributes are present in struct ATTS, 
%  they are updated with values computed from deployment data:
%    DATE_MODIFIED: modification time given by POSIXTIME ('yyyy-mm-ddTHH:MM:SSZ').
%    GEOSPATIAL_LAT_MAX: maximum latitude value inferred from data (LATITUDE).
%    GEOSPATIAL_LAT_MIN: minimum latitude value inferred from data (LATITUDE).
%    GEOSPATIAL_LAT_RESOLUTION: mean latitude step inferred from data (LATITUDE).
%    GEOSPATIAL_LAT_UNITS: latitude units inferred from metadata (LATITUDE).
%    GEOSPATIAL_LON_MAX: maximum longitude value inferred from data (LONGITUDE).
%    GEOSPATIAL_LON_MIN: minimum longitude value inferred from data (LONGITUDE).
%    GEOSPATIAL_LON_RESOLUTION: mean longitude step inferred from data (LONGITUDE).
%    GEOSPATIAL_LON_UNITS: longitude units inferred from metadata (LONGITUDE).
%    TIME_COVERAGE_END: maximum time value inferred from value (TIME_NAV).
%    TIME_COVERAGE_RESOLUTION:  mean time step inferred from data (TIME_NAV).
%    TIME_COVERAGE_START: minimum time value inferred from data (TIME_NAV).
%
%  Notes:
%    Usually input data is the output of GRIDGLIDERDATA.
%    Be aware that only variables present in struct META are added to the NetCDF
%    file. If there is any field in DATA not present in META, it is omited.
%
%  Examples:
%    ncl2 = generateOutputNetCDFL0(filename, data, meta, dims, atts, deployment)
%
%  See also:
%    GRIDGLIDERDATA
%    WRITENETCDFDATA
%    POSIXTIME2UTC
%    POSIXTIME
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(6, 6, nargin, 'struct'));

  %% Set dynamic global attributes.
  dyn_atts = struct();
  dyn_atts.date_modified = ...
    datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00');
  if isfield(data, 'time')
    dyn_atts.time_coverage_start = ...
      datestr(posixtime2utc(min(data.time)), 'yyyy-mm-ddTHH:MM:SS+00');
    dyn_atts.time_coverage_end = ...
      datestr(posixtime2utc(max(data.time)), 'yyyy-mm-ddTHH:MM:SS+00');
    dyn_atts.time_coverage_resolution = ...
      sprintf('P%.2fS', min(abs(diff(data.time))));
  end
  if isfield(data, 'latitude') && isfield(meta, 'latitude')
    dyn_atts.geospatial_lat_min = min(data.latitude);
    dyn_atts.geospatial_lat_max = max(data.latitude);
    dyn_atts.geospatial_lat_resolution = min(abs(diff(data.latitude)));
    [lat_has_units, lat_units_idx] = ...
      ismember('units', {meta.latitude.attributes.name});
    if lat_has_units
      dyn_atts.geospatial_lat_units = ...
        meta.latitude.attributes(lat_units_idx).value;
    end
  end
  if isfield(data, 'longitude') && isfield(meta, 'longitude')
    dyn_atts.geospatial_lon_min = min(data.longitude);
    dyn_atts.geospatial_lon_max = max(data.longitude);
    dyn_atts.geospatial_lon_resolution = min(abs(diff(data.longitude)));
    [lon_has_units, lon_units_idx] = ...
      ismember('units', {meta.longitude.attributes.name});
    if lon_has_units
      dyn_atts.geospatial_lon_units = ...
        meta.longitude.attributes(lon_units_idx).value;
    end
  end


  %% Overwrite default attributes with deployment fields or dynamic values.
  global_atts = atts;
  for atts_idx = 1:numel(atts)
    if isfield(deployment, atts(atts_idx).name)
      global_atts(atts_idx).value = deployment.(atts(atts_idx).name);
    elseif isfield(dyn_atts, atts(atts_idx).name)
      global_atts(atts_idx).value = dyn_atts.(atts(atts_idx).name);
    end
  end
  
  
  %% Select only data properly described by metadata.
  data_selected = struct();
  data_field_name_list = fieldnames(data);
  for data_field_name_idx = 1:numel(data_field_name_list)
    data_field_name = data_field_name_list{data_field_name_idx};
    if isfield(meta, data_field_name);
      data_selected.(data_field_name) = data.(data_field_name);
    end
  end  
    
  
  %% Set dimension lengths.
  dim_info = struct(dims.profile, {numel(data.time)}, ...
                    dims.depth, {numel(data.depth)});
  
  
  %% Create base directory of target file if needed.
  [file_dir, ~, ~] = fileparts(filename);
  if ~exist(file_dir, 'dir')
    [success, message] = mkdir(file_dir);
    if ~success
      error('glider_toolbox:netcdf_tools:NetCDFDirectoryError', ...
            'Could not create output directory %s: %s.', file_dir, message);
    end
  end
  
  
  %% Generate the file.
  writeNetCDFData(filename, data_selected, meta, dim_info, global_atts);
  
  
  %% Return the absolute name of the generated file.
  [status, att_output, ~] = fileattrib(filename);
  if status==0
    % We should never get here (if NetCDF creation succeed, file must exist).
    error('glider_toolbox:netcdf_tools:NetCDFFileError', ...
          'NetCDF generation succeed but problems with output file %s: %s.', ...
          filename, att_output);
  end
  ncl2 = att_output.Name;

end
