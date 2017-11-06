function ncl1_info = configRTOutputNetCDFEGO()
%CONFIGRTOUTPUTNETCDFEGOL1  Configure NetCDF output for processed glider deployment data in real time.
%
%  Syntax:
%    NCL1_INFO = CONFIGRTOUTPUTNETCDFEGOL1()
%
%  Description:
%    NCL1_INFO = CONFIGRTOUTPUTNETCDFEGOL1() should return a struct
%    describing the structure of the NetCDF file for processed glider
%    deployment data in real time (see the note about the file generation).
%    The returned struct should have the following fields:
%      DIMENSIONS: struct array with fields 'NAME' and 'LENGTH' defining the
%        dimensions for variables in the file.
%        A variable may have dimensions not listed here or with their length
%        left undefined (empty field value), and they are inferred from the
%        data during the generation of the file. However, it is useful to preset
%        the length of a dimension for record or string size dimensions.
%      ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining global
%        attributes of the file. Optionally, attributes may contain the
%        field 'TYPE' if a type different than double is required. Notice
%        that float is represented by single in MATLAB.
%        Global attributes might be overwritten by deployment fields
%        with the same name.
%      VARIABLES: struct defining variable metadata. Field names are variable
%        names and field values are structs as needed by function SAVENC.
%        It should have the following fields:
%          DIMENSIONS: string cell array with the names of the dimensions
%            of the variable.
%          ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining
%            the attributes of the variable.
%        More variables than the ones present in one specific deployment may be
%        described here. Only metadata corresponding variables in the deployment
%        data will be used.
%
%  Notes:
%    The NetCDF file will be created by the function GENERATEOUTPUTNETCDF with
%    the metadata provided here and the data returned by PROCESSGLIDERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl1_info = configRTOutputNetCDFEGOL1()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
%    PROCESSGLIDERDATA
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
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

  narginchk(0, 0);

  %% Define preset dimensions.
  time_dimension = struct('name', {'TIME'}, ...
                          'length', {0});
  time_gps = struct('name', {'TIME_GPS'}, ...
                          'length', {1});
                        
  %% Define variable information.
  % To define the variable attributes easily and readably, add the corresponding
  % variable field to the struct defined below, with its attributes defined in
  % a cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.

  default_fill_value = realmax('double');

  var_attr_list.time = {
    'long_name'            'Epoch time'
    'standard_name'        'time'
    'units'                'seconds since 1970-01-01T00:00:00Z'
    'axis'                 'T'
    'valid_min'            0.0
    'valid_max'            90000.0
    'QC_procedure'         '1'
    'ancillary_variable'  'TIME_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'TIME LATITUDE LONGITUDE DEPTH'
    'comment'              'None'
    '_FillValue'           default_fill_value
    'glider_original_parameter_name'                [] };

  var_attrtype_list.time_qc = 'int8';
  var_attr_list.time_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'time_qc'
    'conventions'          'EGO reference table 2'
    'comment'              'None'
    'axis'                 'T'
    'valid_min'            0
    'valid_max'            9
    '_FillValue'           -128
    'QC_procedure'         '1'
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'};
    

  var_attr_list.time_gps = {
    'long_name'            'Epoch time of the GPS fixes'
    'standard_name'        'time'
    'units'                'seconds since 1970-01-01T00:00:00Z'
    'axis'                 'T'
    'valid_min'            0.0
    'valid_max'            90000.0
    'QC_procedure'         '1'
    'ancillary_variable'  'TIME_GPS_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'time_gps'
    'comment'              'None'
    '_FillValue'           -128
    'glider_original_parameter_name'                [] };

  var_attr_list.juld = {
    'long_name'            'Julian 1950 time'
    'standard_name'        'time'
    'units'                'days since 1950-01-01T00:00:00Z'
    'axis'                 'T'
    'valid_min'            0.0
    'valid_max'            90000.0
    'QC_procedure'         '1'
    'ancillary_variable'  'JULD_QC'
    'sdn_parameter_urn'    'SDN:P01::XXX'
    'sdn_uom_urn'          'SDN:P061::UTAA'
    'coordinates'          'TIME LATITUDE LONGITUDE DEPTH'
    'comment'              'None'
    '_FillValue'           default_fill_value
    'comment'              ''
    'glider_original_parameter_name'                [] };

  var_attrtype_list.juld_qc = 'int8';
  var_attr_list.juld_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'juld_qc'
    'conventions'          'EGO reference table 2'
    'axis'                 'T'
    'valid_min'            0
    'valid_max'            9
    '_FillValue'           -128
    'comment'              'None'
    'QC_procedure'         '1'
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'};
    
                        
  var_attrtype_list.depth = 'single';
  var_attr_list.depth = {
    'long_name'     'glider depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'axis'          'Z'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'comment'              'None'
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.latitude = {
    'long_name'                   'Gps fixed latitude'
    'standard_name'               'latitude'
    'units'                       'degrees_north'
    'axis'                        'Y'
    'coordinates'                 'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'                   -90.0
    'valid_max'                   90.0
    'QC_procedure'                1
    'ancillary_variable'          'POSITION_QC'
    'comment'              'None'
    'reference'                    'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALATZZ01'
    'sdn_uom_name'                  'SDN:P061::DEGN'
    'sdn_uom_urn'                  'SDN:P061::DEGN'
    '_FillValue'    99999
    'glider_original_parameter_name'                []
    'position_good'          []
    'position_bad'           []
    'conversion'             []
    'filling'                [] };

  var_attr_list.longitude = {
    'long_name'     'Gps fixed longitude'
    'standard_name' 'longitude'
    'axis'          'X'
    'units'         'degrees_east'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'     -180.0
    'valid_max'     180.0
    'QC_procedure'  1
    'ancillary_variable' 'POSITION_QC'
    'comment'              'None'
    'reference'     'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALONZZ01'
    'sdn_uom_name'   'SDN:P061::DEGE'
    'sdn_uom_urn'   'SDN:P061::DEGE'
    '_FillValue'    99999
    'glider_original_parameter_name'                []
    'position_good'          []
    'position_bad'           []
    'conversion'             []
    'filling'                [] };

  var_attrtype_list.position_qc = 'int8';
  var_attr_list.position_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'position_qc'
    'conventions'          'EGO reference table 2'
    'axis'                 'T'
    'valid_min'            0
    'valid_max'            9
    '_FillValue'           -128
    'comment'              'None'
    'QC_procedure'         '1'
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'};
  
  var_attr_list.latitude_gps = {
    'long_name'     'Gps fixed latitude'
    'standard_name' 'latitude'
    'units'         'degrees_north'
    'axis'          'Y'
    'coordinates'   'TIME_GPS LATITUDE LONGITUDE DEPTH'
    'valid_min'     -90.0
    'valid_max'     90.0
    'QC_procedure'  1
    'ancillary_variable' 'POSITION_GPS_QC'
    'comment'              'None'
    'reference'     'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALATZZ01'
    'sdn_uom_urn'   'SDN:P061::DEGN'
    '_FillValue'    99999.0
    'glider_original_parameter_name'                []
    'position_good'          []
    'position_bad'           []
    'conversion'             []
    'filling'                [] };

  var_attr_list.longitude_gps = {
    'long_name'     'Gps fixed longitude'
    'standard_name' 'longitude'
    'axis'          'X'
    'units'         'degrees_east'
    'coordinates'   'TIME_GPS LATITUDE LONGITUDE DEPTH'
    'valid_min'     -180.0
    'valid_max'     180.0
    'QC_procedure'  1
    'ancillary_variable' 'POSITION_GPS_QC'
    'comment'              'None'
    'reference'     'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALONZZ01'
    'sdn_uom_urn'   'SDN:P061::DEGE'
    '_FillValue'    99999.0
    'glider_original_parameter_name'                []
    'position_good'          []
    'position_bad'           []
    'conversion'             []
    'filling'                [] };

  var_attrtype_list.position_gps_qc = 'int8';
  var_attr_list.position_gps_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'position_qc'
    'convention'           'EGO reference table 2'
    'axis'                 'T'
    'valid_min'            0
    'valid_max'            9
    'QC_procedure'         '1'
    'comment'              'None'
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'};
                        
  var_attr_list.heading = {
    'long_name'     'glider heading angle'
    'standard_name' 'heading'
    'units'         'rad'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.roll = {
    'long_name'     'glider roll angle'
    'standard_name' 'roll'
    'units'         'rad'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.pitch = {
    'long_name'     'glider pitch angle'
    'standard_name' 'pitch'
    'units'         'rad'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.waypoint_latitude = {
    'long_name'     'waypoint latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.waypoint_longitude = {
    'long_name'     'waypoint longitude'
    'standard_name' 'longitude'
    'units'         'degree_east'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'filling'                [] };

  var_attr_list.distance_over_ground = {
    'long_name'     'distance over ground flown since mission start'
    'standard_name' 'distance'
    'units'         'km'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.transect_index = {
    'long_name'     'transect index'
    'standard_name' ''
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.profile_index = {
    'long_name'     'profile index'
    'standard_name' ''
    'units'         '1'
    'comment'       'N = inside profile N, N + 0.5 = between profiles N and N + 1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 []
    'length'                 []
    'period'                 []
    'inversion'              []
    'interrupt'              []
    'stall'                  []
    'shake'                  [] };

  var_attr_list.profile_direction = {
    'long_name'     'glider vertical speed direction'
    'standard_name' ''
    'units'         '1'
    'comment'       '-1 = ascending, 0 = inflecting or stalled, 1 = descending'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attrtype_list.phase = 'int8';
  var_attr_list.phase = {
    'long_name'     'Glider trajectory phase code'
    'standard_name' ''
    'conventions'   'EGO reference table 9'
    'units'         '1'
    'flag_values'   [0,1,2,3,4,5,6]
    'flag_meanings' 'surface_drift descent subsurface_drift inflexion ascent grounded inconsistent'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    -128
    'glider_original_parameter_name'                []
    'method'                 [] };
  
  var_attrtype_list.phase_number = 'int32';
  var_attr_list.phase_number = {
    'long_name'     'Glider trajectory phase number'
    '_FillValue'    99999 };
  
  var_attrtype_list.positioning_method = 'int8';
  var_attr_list.positioning_method = {
    'long_name'     'Positioning method'
    'conventions'   'EGO reference table 10'
    '_FillValue'    -128
    'flag_values'   [0,1,2]
    'flag_meanings' 'GPS Argos interpolated'};

  var_attrtype_list.cndc = 'single';
  var_attr_list.cndc = {
    'long_name'     'Electrical conductivity'
    'standard_name' 'sea_water_electrical_conductivity'
    'units'         'mhos/m'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'     0.0
    'valid_max'     8.5
    'sensor_mount'            'NA'
    'sensor_orientation'      'NA'
    'sensor_name'             'NA'
    'sensor_serial_number'    'NA'
    'ancillary_variable'      'NA'
    'accuracy'                'NA'
    'precision'               'NA'
    'resolution'              'NA'
    'cell_methods'            'NA'
    'DM_indicator'            'NA'
    'reference_scale'         'NA'
    '_FillValue'    default_fill_value
    'sdn_parameter_urn'       'SDN:P01::CNDCST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/CNDCST01/'
    'sdn_uom_name'             'SDN:P061::UECA'
    'sdn_uom_urn'             'SDN:P061::UECA'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UECA/'
    'comment'                 'None'
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attrtype_list.temp = 'single';
  var_attr_list.temp = {
    'long_name'               'Sea temperature in-situ ITS-90 scale'
    'standard_name'           'sea_water_temperature'
    'units'                   'Celcius'
    'coordinates'             'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'               -2.5
    'valid_max'               40.0
    'sensor_mount'            'NA'
    'sensor_orientation'      'NA'
    'sensor_name'             'NA'
    'sensor_serial_number'    'NA'
    'ancillary_variable'      'NA'
    'accuracy'                'NA'
    'precision'               'NA'
    'resolution'              'NA'
    'cell_methods'            'NA'
    'DM_indicator'            'NA'
    'reference_scale'         'NA'
    '_FillValue'              default_fill_value
    'sdn_parameter_urn'       'SDN:P01::TEMPST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/TEMPST01/'
    'sdn_uom_name'             'SDN:P061::UPAA'
    'sdn_uom_urn'             'SDN:P061::UPAA'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UPAA/'
    'comment'                 'None'
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attrtype_list.pres = 'single';
  var_attr_list.pres = {
    'long_name'     'Sea water pressure, equals 0 at sea-level'
    'standard_name' 'sea_water_pressure'
    'units'         'dbar'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'     0.0
    'valid_max'     12000.0
    'sensor_mount'            'NA'
    'sensor_orientation'      'NA'
    'sensor_name'             'NA'
    'sensor_serial_number'    'NA'
    'ancillary_variable'      'NA'
    'accuracy'                'NA'
    'precision'               'NA'
    'resolution'              'NA'
    'cell_methods'            'NA'
    'DM_indicator'            'NA'
    'reference_scale'         'NA'
    '_FillValue'    default_fill_value
    'sdn_parameter_urn'       'SDN:P01::PRESPR01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/PRESPR01/'
    'sdn_uom_name'            'SDN:P061::UPDB'
    'sdn_uom_urn'             'SDN:P061::UPDB'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UPDB/'
    'comment'                 '19/10/2013 : revision of the long name'
    'glider_original_parameter_name'             []
    'method'                 []
    'calibration'            []
    'calibration_parameters' []
    'filter_method'          []
    'filter_parameters'      [] };

  var_attr_list.time_ctd = {
    'long_name'     'CTD epoch time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'       'CTD time stamp'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             [] };

  var_attr_list.depth_ctd = {
    'long_name'     'CTD depth'
    'standard_name' 'depth'
    'units'         'm'
    'comment'       'depth derived from CTD pressure sensor'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.temperature_corrected_sensor = {
    'long_name'     'water temperature with sensor time response corrected'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      [] };

  var_attr_list.temperature_corrected_thermal = {
    'long_name'     'water temperature with thermal lag corrected'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      [] };

  var_attr_list.conductivity_corrected_sensor = {
    'long_name'     'water conductivity with sensor time response corrected'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      [] };

  var_attr_list.conductivity_corrected_thermal = {
    'long_name'     'water conductivity with thermal lag corrected'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      [] };

  var_attrtype_list.psal = 'single';
  var_attr_list.psal = {
    'long_name'     'Practical salinity'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'valid_min'     2.0
    'valid_max'     41.0
    'sensor_mount'            'NA'
    'sensor_orientation'      'NA'
    'sensor_name'             'NA'
    'sensor_serial_number'    'NA'
    'ancillary_variable'      'NA'
    'accuracy'                'NA'
    'precision'               'NA'
    'resolution'              'NA'
    'cell_methods'            'NA'
    'DM_indicator'            'NA'
    'reference_scale'         'NA'
    '_FillValue'    default_fill_value
    'sdn_parameter_urn'       'SDN:P01::PSALST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/PSALST01/'
    'sdn_uom_name'            'SDN:P061::UUUU'
    'sdn_uom_urn'             'SDN:P061::UUUU'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UUUU/'
    'comment'                 'None'
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.salinity_corrected_thermal = {
    'long_name'     'water salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.salinity_corrected_sensor = {
    'long_name'     'water salinity from conductivity and temperature with sensor lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.salinity_corrected_sensor_thermal = {
    'long_name'     'water salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.density = {
    'long_name'     'water density using salinity from raw temperature and raw conductivity'
    'standard_name' 'sea_water_density'
    'units'         'kg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.density_corrected_thermal = {
    'long_name'     'water density using salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'kg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.density_corrected_sensor = {
    'long_name'     'water density using salinity from conductivity and temperature with sensor lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'kg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.density_corrected_sensor_thermal = {
    'long_name'     'water density using salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'kg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'method'                 [] };

  var_attr_list.potential_temperature = {
    'long_name'     'water potential temperature'
    'standard_name' 'sea_water_potential_temperature'
    'units'         'Celsius'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.potential_density = {
    'long_name'     'water potential density'
    'standard_name' 'sea_water_potential_density'
    'units'         'kg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.sound_velocity = {
    'long_name'     'sound velocity'
    'standard_name' 'sea_water_sound_velocity'
    'units'         'm s-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.backscatter_470 = {
    'long_name'     'blue backscattering'
    'standard_name' 'blue_backscattering'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.backscatter_532 = {
    'long_name'     'green backscattering'
    'standard_name' 'green_backscattering'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.backscatter_660 = {
    'long_name'     'red backscattering'
    'standard_name' 'red_backscattering'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.backscatter_700 = {
    'long_name'     '700 nm wavelength backscatter'
    'standard_name' '700nm_backscatter'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.backscatter = {
    'long_name'     'backscattering'
    'standard_name' 'backscattering'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attrtype_list.chla = 'single';
  var_attr_list.chla = {
    'long_name'     'Chlorophyll-A'
    'standard_name' 'mass_concentration_of_chlorophyll_a_in_sea_water'
    'units'         'mg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.turbidity = {
    'long_name'     'Sea water turbidity'
    'standard_name' 'sea_water_turbidity'
    'units'         'NTU'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.cdom = {
    'long_name'     'CDOM'
    'standard_name' 'concentration_of_coloured_dissolved_organic_matter'
    'units'         'ppb'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.scatter_650 = {
    'long_name'     '650 nm wavelength scattering'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.temp_spectrophotometer_nitrate = {
    'long_name'     'Temperature of the spectrometer'
    'standard_name' 'temperature_of_optic_sensor_in_sea_water'
    'units'         'Celsius'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.time_optics = {
    'long_name'     'optic sensor epoch time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'       'optic sensor time stamp'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             [] };

  var_attr_list.molar_doxy = {
    'long_name'     'Uncompensated (pressure and salinity) oxygen concentration reported by the oxygen sensor'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.oxygen_saturation = {
    'long_name'     'oxygen saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.oxygen_frequency = {
    'long_name'     'oxygen frequency'
    'standard_name' 'frequency_output_of_sensor_for_oxygen_in_sea_water'
    'units'         'Hz'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.time_oxygen = {
    'long_name'     'oxygen sensor epoch time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'       'oxygen sensor time stamp'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             [] };

  var_attr_list.temp_doxy = {
    'long_name'     'Sea temperature from oxygen sensor ITS-90 scale'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] };

  var_attr_list.irradiance_412 = {
    'long_name'     'irradiance at 412nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.irradiance_442 = {
    'long_name'     'irradiance at 442nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.irradiance_491 = {
    'long_name'     'irradiance at 491nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.irradiance_664 = {
    'long_name'     'irradiance at 664nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.water_velocity_eastward = {
    'long_name'     'mean eastward water velocity in segment'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             [] };

  var_attr_list.water_velocity_northward = {
    'long_name'     'mean northward water velocity in segment'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                []
    'conversion'             [] };

  var_attr_list.fluorescence_270_340 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
    'standard_name' 'fluorescence_excitation_270nm_emission_340nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Tryptophan-like or Naphtalene-like measurements'
    'comment2'      '270nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_255_360 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
    'standard_name' 'fluorescence_excitation_255nm_emission_360nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Phenanthren-like measurements or water-soluble fraction of petroleum'
    'comment2'      '255nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_monitoring_270_340 = {
    'long_name'     'Minifluo-UV1 monitoring channel of the 270nm LED'
    'standard_name' 'fluorescence_monitoring_270_340nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Measures variations in LED excitation wavelength'
    'comment2'      '270nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_monitoring_255_360 = {
    'long_name'     'Minifluo-UV1 monitoring channel of the 255nm LED'
    'standard_name' 'fluorescence_monitoring_255_360nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Measures variations in LED excitation wavelength'
    'comment2'      '255nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_260_315 = {
    'long_name'     'Minifluo-UV2 fluorescence Ex./Em. = 260/315nm'
    'standard_name' 'fluorescence_excitation_260nm_emission_315nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Fluorene-like measurements'
    'comment2'      '260nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_270_376 = {
    'long_name'     'Minifluo-UV2 fluorescence Ex./Em. = 270/376nm'
    'standard_name' 'fluorescence_excitation_270nm_emission_376nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Pyrene-like measurements'
    'comment2'      '270nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_monitoring_260_315 = {
    'long_name'     'Minifluo-UV2 monitoring channel of the 260nm LED'
    'standard_name' 'fluorescence_monitoring_260_315nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Measures variations in LED excitation wavelength'
    'comment2'      '260nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.fluorescence_monitoring_270_376 = {
    'long_name'     'Minifluo-UV2 monitoring channel of the 270nm LED'
    'standard_name' 'fluorescence_monitoring_270_376nm'
    'units'         'counts'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    'comment1'      'Measures variations in LED excitation wavelength'
    'comment2'      '270nm is the nominal wavelength of the LED'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };

  var_attr_list.methane_concentration = {
    'long_name'     'Methane concentration (scaled)'
    'standard_name' 'methane_concentration'
    'units'         'mg m-3'
    'coordinates'   'TIME LATITUDE LONGITUDE DEPTH'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] };


  %% Define global attributes (they may be overwritten with deployment values).
  % To define the global attributes easily and readably, add them to this
  % cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.
  global_atts = ...
  {
    'abstract'                     '' % deployment_description
    'acknowledgement'              '' % deployment_acknowledgement
    'author'                       '' % deployment_author
    'author_email'                 '' % deployment_author_email
    'cdm_data_type'                'Trajectory'
    'citation'                     '' % deployment_citation
    'comment'                      'Data regularized, corrected and/or derived from raw glider data.'
    'Conventions'                  'CF-1.4 EGO-1.0'
    'creator'                      '' % deployment_author
    'creator_email'                '' % deployment_author_email
    'creator_url'                  '' % deployment_author_url
    'data_center'                  '' % deployment_data_center
    'data_center_email'            '' % deployment_data_center_email
    'data_mode'                    'R'
    'data_type'                    'EGO glider time-series data'
    'date_update'                  'undefined'
    'featureType'                  'trajectory'
    'format_version'               '1.0'
    'geospatial_lat_max'           'undefined'
    'geospatial_lat_min'           'undefined'
    'geospatial_lat_units'         'undefined'
    'geospatial_lon_max'           'undefined'
    'geospatial_lon_min'           'undefined'
    'geospatial_lon_units'         'undefined'
    'history'                      sprintf('Product generated by the glider toolbox version %s (https://github.com/socib/glider_toolbox).', configGliderToolboxVersion())
    'id'                           ''
    'institution'                  '' % institution_name
    'institution_references'       '' % institution_references
    'instrument'                   '' % instrument_name
    'instrument_manufacturer'      '' % instrument_manufacturer
    'instrument_model'             '' % instrument_model
    'license'                      'Approved for public release. Distribution Unlimited.' % deployment_distribution_statement
    'naming_authority'             'EGO'
    'netcdf_version'               '4.1.3'
    'platform_code'                '99999'
    'positioning_system'           'GPS and dead reckoning'
    'principal_investigator'       '' % deployment_principal_investigator
    'principal_investigator_email' '' % deployment_principal_investigator_email
    'processing_level'             'L1 processed data with corrections and derivations'
    'project'                      '' % deployment_project
    'publisher'                    '' % deployment_publisher
    'publisher_email'              '' % deployment_publisher_email
    'publisher_url'                '' % deployment_publisher_url
    'source'                       'Glider observation'
    'source_files'                 'undefined' % source_files field set by processing script after loading data.
    'standard_name_vocabulary'     'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/16/cf-standard-name-table.html'
    'summary'                      '' % deployment_description
    'time_coverage_end'            'undefined'
    'time_coverage_start'          'undefined'
    'title'                        'Glider deployment real time processed data'
    'transmission_system'          'IRIDIUM'
    'wmo_platform_code'            '830'
  };



  %% Return global and variable metadata in the correct format.
  ncl1_info = struct();
  % Set the dimensions.
  ncl1_info.dimensions = time_dimension; %[time_dimension, time_gps];
  % Set the global attributes.
  ncl1_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  % Set the variable metadata.
  ncl1_info.variables = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    ncl1_info.variables.(var_name).dimensions = {time_dimension.name};
    ncl1_info.variables.(var_name).attributes = ...
      cell2struct(var_atts, {'name' 'value'}, 2);
    if isfield(var_attrtype_list, var_name)
      ncl1_info.variables.(var_name).type = var_attrtype_list.(var_name);
    end
  end
   

  % GPS variables are a special case. We could generalize this but it is a
  % simple way to make it work for now
  ncl1_info.variables.time_gps.dimensions = {time_gps.name};
  ncl1_info.variables.latitude_gps.dimensions = {time_gps.name};
  ncl1_info.variables.longitude_gps.dimensions = {time_gps.name};
end
