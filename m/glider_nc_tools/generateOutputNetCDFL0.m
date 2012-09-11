function ncl0 = generateOutputNetCDFL0(filename, data, meta, dims, atts, deployment)
%GENERATEOUTPUTNETCDFL0  Generate NetCDF output for raw glider deployment data.
%
%  NCL0 = GENERATEOUTPUTNETCDFL0(FILENAME, DATA, META, DIMS, ATTS, DEPLOYMENT)
%  calls WRITENETCDFDATA to generate a NetCDF file named FILENAME from raw 
%  deployment data in struct DATA, variable metadata in struct META, dimension
%  names in struct DIMS and global attributes in struct array ATTS.
%  For raw data, the DIMS argument should be a struct with the following fields 
%  defining the following dimension names:
%    TIME: name of the time dimension (record dimension).
%  To allow runtime defined attributes, attributes in ATTS whose name match 
%  a field name in struct DEPLOYMENT are overwritten with the field value.
%  In addition, if the following global attributes are present in struct ATTS, 
%  they are updated with values computed from deployment data:
%    DATE_MODIFIED: modification time given by UTC_TIME ('yyyy-mm-ddTHH:MM:SSZ').
%    GEOSPATIAL_LAT_MAX: maximum latitude value inferred from data (m_gps_lat).
%    GEOSPATIAL_LAT_MIN: minimum latitude value inferred from data (m_gps_lat).
%    GEOSPATIAL_LAT_RESOLUTION: mean latitude step inferred from data (m_gps_lat).
%    GEOSPATIAL_LAT_UNITS: latitude units inferred from metadata (m_gps_lat).
%    GEOSPATIAL_LON_MAX: maximum longitude value inferred from data (m_gps_lon).
%    GEOSPATIAL_LON_MIN: minimum longitude value inferred from data (m_gps_lon).
%    GEOSPATIAL_LON_RESOLUTION: mean longitude step inferred from data (m_gps_lon).
%    GEOSPATIAL_LON_UNITS: longitude units inferred from metadata (m_gps_lon).
%    TIME_COVERAGE_END: maximum time value inferred from value (m_present_time).
%    TIME_COVERAGE_RESOLUTION:  mean time step inferred from data (m_present_time).
%    TIME_COVERAGE_START: minimum time value inferred from data (m_present_time).
%
%  Notes:
%    Be aware that only variables present in struct META are added to the NetCDF
%    file. If there is any field in DATA not present in META, it is ommited.
%
%  Examples:
%    ncl0 = generateOutputNetCDFL0(filename, data, meta, dims, atts, deployment)
%
%  See also:
%    WRITENETCDFDATA
%    UTC_TIME
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(6, 6, nargin, 'struct'));

  %% Set dynamic global attributes.
  dyn_atts = struct();
  dyn_atts.date_modified = datestr(utc2datenum(utc_time), 'yyyy-mm-ddTHH:MM:SS+00');
  if isfield(data, 'm_present_time')
    dyn_atts.time_coverage_start = datestr(utc2datenum(min(data.m_present_time)), 'yyyy-mm-ddTHH:MM:SS+00');
    dyn_atts.time_coverage_end = datestr(utc2datenum(max(data.m_present_time)), 'yyyy-mm-ddTHH:MM:SS+00');
    dyn_atts.time_coverage_resolution = sprintf('P%.2fS', min(abs(diff(data.m_present_time))));
  end
  if isfield(data, 'm_gps_lat') && isfield(meta, 'm_gps_lat')
    dyn_atts.geospatial_lat_min = min(data.m_gps_lat);
    dyn_atts.geospatial_lat_max = max(data.m_gps_lat);
    dyn_atts.geospatial_lat_resolution = min(abs(diff(data.m_gps_lat)));
    [lat_has_units, lat_units_idx] = ismember('units', {meta.m_gps_lat.attributes.name});
    if lat_has_units
      dyn_atts.geospatial_lat_units = meta.m_gps_lat.attributes(lat_units_idx).value;
    end
  end
  if isfield(data, 'm_gps_lon') && isfield(meta, 'm_gps_lon')
    dyn_atts.geospatial_lon_min = min(data.m_gps_lon);
    dyn_atts.geospatial_lon_max = max(data.m_gps_lon);
    dyn_atts.geospatial_lon_resolution = min(abs(diff(data.m_gps_lon)));
    [lon_has_units, lon_units_idx] = ismember('units', {meta.m_gps_lon.attributes.name});
    if lon_has_units
      dyn_atts.geospatial_lon_units = meta.m_gps_lon.attributes(lon_units_idx).value;
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
  data_sel = struct();
  data_field_list = fieldnames(data);
  for data_field_idx = 1:numel(data_field_list)
    data_field = data_field_list(data_field_idx);
    if isfield(meta, data_field);
      data_sel.(data_field) = data.(data_field);
    end
  end  
  
  
  %% Set dimension lengths.
  dim_info = struct(dims.time, {0});
  
  
  %% Create base directory of target file if needed.
  [file_dir, ~, ~] = fileparts(filename);
  if ~exist(file_dir,'dir')
    [success, error_msg] = mkdir(file_dir);
    if ~success
      error('glider_toolbox:netcdf_tools:NetCDFDirectoryError', error_msg);
    end
  end
  
  
  %% Generate the file.
  writeNetCDFData(filename, data, meta, dim_info, global_atts);
  
  
  %% Return the name of the generated file.
  ncl0 = filename;

end
