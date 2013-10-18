function ncl0 = generateOutputNetCDFL0(filename, data, meta, dims, atts, deployment)
%GENERATEOUTPUTNETCDFL0  Generate NetCDF output for raw glider deployment data.
%
%  Syntax:
%    NCL0 = GENERATEOUTPUTNETCDFL0(FILENAME, DATA, META, DIMS, ATTS, DEPLOYMENT)
%
%  NCL0 = GENERATEOUTPUTNETCDFL0(FILENAME, DATA, META, DIMS, ATTS, DEPLOYMENT)
%  calls WRITENETCDFDATA to generate a NetCDF file named FILENAME from raw 
%  deployment data in struct DATA, variable metadata in struct META, dimension
%  names in struct DIMS and global attributes in struct array ATTS, and returns
%  the absolute name of the generated file in string NCL0.
%  DATA and META should be structs with one field per variable with the variable
%  data and the variable metadata respectively, as needed by WRITENETCDFDATA.
%  For raw data, the DIMS argument should be a struct with the following fields 
%  defining dimension names:
%    TIME: name of the time dimension (record dimension).
%  ATTS should be a struct array as needed by WRITENETCDFDATA, too. To allow 
%  runtime defined attributes, attributes in ATTS whose name match a field name 
%  in struct DEPLOYMENT are overwritten with the field value.
%  In addition, if the following global attributes are present in struct ATTS, 
%  they are updated with values computed from deployment data:
%    DATE_MODIFIED: modification time given by POSIXTIME ('yyyy-mm-ddTHH:MM:SSZ').
%    GEOSPATIAL_LAT_MAX: maximum latitude value inferred from data (M_GPS_LAT).
%    GEOSPATIAL_LAT_MIN: minimum latitude value inferred from data (M_GPS_LAT).
%    GEOSPATIAL_LAT_UNITS: latitude units inferred from metadata (M_GPS_LAT).
%    GEOSPATIAL_LON_MAX: maximum longitude value inferred from data (M_GPS_LON).
%    GEOSPATIAL_LON_MIN: minimum longitude value inferred from data (M_GPS_LON).
%    GEOSPATIAL_LON_UNITS: longitude units inferred from metadata (M_GPS_LON).
%    TIME_COVERAGE_END: maximum time value inferred from value (M_PRESENT_TIME).
%    TIME_COVERAGE_START: minimum time value inferred from data (M_PRESENT_TIME).
%
%  Notes:
%    Usually input data is the output of PREPROCESSGLIDERDATA.
%    Be aware that only variables present in struct META are added to the NetCDF
%    file. If there is any field in DATA not present in META, it is omited.
%
%  Examples:
%    ncl0 = generateOutputNetCDFL0(filename, data, meta, dims, atts, deployment)
%
%  See also:
%    PREPROCESSGLIDERDATA
%    WRITENETCDFDATA
%    POSIXTIME2UTC
%    POSIXTIME
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

  error(nargchk(6, 6, nargin, 'struct'));

  %% Get dynamic global attribute values.
  dyn_atts = struct();
  dyn_atts.date_modified = ...
    datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00');
  if isfield(data, 'm_present_time')
    dyn_atts.time_coverage_start = ...
      datestr(posixtime2utc(min(data.m_present_time)), ...
              'yyyy-mm-ddTHH:MM:SS+00:00');
    dyn_atts.time_coverage_end = ...
      datestr(posixtime2utc(max(data.m_present_time)), ...
              'yyyy-mm-ddTHH:MM:SS+00:00');
  end
  if isfield(data, 'm_gps_lat') && isfield(meta, 'm_gps_lat')
    dyn_atts.geospatial_lat_min = min(data.m_gps_lat);
    dyn_atts.geospatial_lat_max = max(data.m_gps_lat);
    [lat_has_units, lat_units_idx] = ...
      ismember('units', {meta.m_gps_lat.attributes.name});
    if lat_has_units
      dyn_atts.geospatial_lat_units = ...
        meta.m_gps_lat.attributes(lat_units_idx).value;
    end
  end
  if isfield(data, 'm_gps_lon') && isfield(meta, 'm_gps_lon')
    dyn_atts.geospatial_lon_min = min(data.m_gps_lon);
    dyn_atts.geospatial_lon_max = max(data.m_gps_lon);
    [lon_has_units, lon_units_idx] = ...
      ismember('units', {meta.m_gps_lon.attributes.name});
    if lon_has_units
      dyn_atts.geospatial_lon_units = ...
        meta.m_gps_lon.attributes(lon_units_idx).value;
    end
  end


  %% Aggregate global metadata (global attributes and dimension definitions).
  global_meta = struct();
  % Set dimension lengths.
  global_meta.dimensions = struct('name', {dims.time}, 'length', {0});
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
  
  
  %% Create base directory of target file if needed.
  % This seems to be the best way to check if a relative path points to
  % an existing directory (EXIST checks for existance in the whole load path).
  [file_dir, ~, ~] = fileparts(filename);
  [status, attrout] = fileattrib(file_dir);
  if ~status
    [success, message] = mkdir(file_dir);
    if ~success
      error('glider_toolbox:netcdf_tools:NetCDFDirectoryError', ...
            'Could not create directory %s: %s.', file_dir, message);
    end
  elseif ~attrout.directory
    error('glider_toolbox:netcdf_tools:NetCDFDirectoryError', ...
          'Not a directory: %s.', attrout.Name);
  end
  
  
  %% Generate the file.
  writeNetCDFData(data, meta, global_meta, filename);
  
  
  %% Return the absolute name of the generated file.
  [status, attrout, ~] = fileattrib(filename);
  if status==0
    % We should never get here (if NetCDF creation succeed, file must exist).
    error('glider_toolbox:netcdf_tools:NetCDFFileError', ...
          'NetCDF generation succeed but problems with output file %s: %s.', ...
          filename, attrout);
  end
  ncl0 = attrout.Name;

end
