function [ meta_variables ] = listNetCDFL1Parameters(time_dimension_name, varargin)
%LISTNETCDFL1PARAMETERS  Create structure from the available parameter
%                         description
%
%  Syntax:
%    META_VARIABLES = LISTNETCDFL1PARAMETERS()
%
%  Description:
%    META_VARIABLES = LISTNETCDFL1PARAMETERS() should return a struct
%    describing the structure of parameters of the NetCDF file. This
%    function contains the definition of all available parameters of EGO
%    and SOCIB standards. The output variable contains the parameters
%    defined in the input arguments as well as the input dimension.
%    
%  Input:
%    The input structure is as follow:
%       TIME_DIMENSION_NAME: name of the time dimension to which
%            each output will be related. 
%       OPTIONS: A structure defining the parameters to add to the output 
%           FORMAT (ego/socib), {param1, param2, param3,...}
%           For each format and paramX the output will contain the
%           parameter define as var_attr_list.(format).(paramX).
%
%  Ouput:
%    The returned struct should have the following fields:
%      VARIABLES: struct defining variable metadata. Field names are variable
%        names and field values are structs as needed by function SAVENC.
%        It should have the following fields:
%          DIMENSIONS: string cell array with the names of the dimensions
%            of the variable.
%          ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining
%            the attributes of the variable.
%          TYPE: Optionally, attributes may contain the type of the field 
%            if a type different than double is required. Notice that float
%            is represented by single in MATLAB. 
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


  if isempty(time_dimension_name)
      error('glider_toolbox:listNetCDFL1Parameters:MissingInput', ...
            'No time dimension');
  end
  
  default_fill_value = realmax('double');
  default_float_fill_value = realmax('single');
  
  var_attr_list =struct();
  var_attrtype_list = struct();
  
  %% Time Parameters
  var_attr_list.ego.time = {
    'long_name'            'Epoch time'
    'standard_name'        'time'
    'units'                'seconds since 1970-01-01T00:00:00Z'
    'axis'                 'T'
    'valid_min'            0.0
    'valid_max'            90000.0
    'QC_procedure'         '1'
    'ancillary_variable'   'TIME_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'TIME LATITUDE LONGITUDE PRES'
    'comment'              'None'
    '_FillValue'           9999999999.
    'glider_original_parameter_name'                [] 
    'sources'                [] };
  
  var_attr_list.socib.time = {
    'long_name'     'navigation epoch time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'axis'          'T'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                [] };

  var_attr_list.ego.time_gps = {
    'long_name'            'Epoch time of the GPS fixes'
    'standard_name'        'time'
    'units'                'seconds since 1970-01-01T00:00:00Z'
    'axis'                 'T'
    'valid_min'            0.0
    'valid_max'            90000.0
    'QC_procedure'         '1'
    'ancillary_variable'   'TIME_GPS_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'time_gps'
    'comment'              'None'
    'glider_original_parameter_name'                [] 
    'sources'                [] };

  var_attr_list.ego.time_gps_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'time_gps_qc'
    'conventions'          'EGO reference table 2'
    'valid_min'            0
    'valid_max'            9
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'           -128};

  var_attr_list.ego.juld = {
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
    'comment'              'None'
    '_FillValue'           999999
    'comment'              ''
    'glider_original_parameter_name'                [] 
    'sources'                [] };

  %% Depth parameter                      
  var_attrtype_list.ego.depth = 'single';
  var_attr_list.ego.depth = {
    'long_name'               'glider depth'
    'standard_name'           'depth'
    'units'                   'm'
    'positive'                'down'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'ancillary_variable'      'DEPTH_QC'
    '_FillValue'              default_float_fill_value
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };
  
  var_attr_list.socib.depth = {
    'long_name'     'glider depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'axis'          'Z'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  %% Geolocation
  var_attr_list.ego.latitude = {
    'long_name'                   'Measurement latitude'
    'standard_name'               'latitude'
    'units'                       'degree_north'
    'axis'                        'Y'
    'valid_min'                   -90.0
    'valid_max'                   90.0
    'QC_procedure'                1
    'ancillary_variable'          'POSITION_QC'
    'comment'                     'None'
    'reference'                   'WGS84'
    'coordinate_reference_frame'  'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'           'SDN:P01::ALATZZ01'
    'sdn_uom_name'                'SDN:P061::DEGN'
    'sdn_uom_urn'                 'SDN:P061::DEGN'
    '_FillValue'                  99999
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.ego.longitude = {
    'long_name'                    'Measurement longitude'
    'standard_name'                'longitude'
    'axis'                         'X'
    'units'                        'degree_east'
    'valid_min'                    -180.0
    'valid_max'                    180.0
    'QC_procedure'                 1
    'ancillary_variable'           'POSITION_QC'
    'comment'                      'None'
    'reference'                    'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALONZZ01'
    'sdn_uom_name'                 'SDN:P061::DEGE'
    'sdn_uom_urn'                  'SDN:P061::DEGE'
    '_FillValue'                   99999
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };
  
  var_attr_list.socib.latitude = {
    'long_name'     'latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'
    'axis'          'Y'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.socib.longitude = {
    'long_name'     'longitude'
    'standard_name' 'longitude'
    'axis'          'X'
    'units'         'degree_east'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };

  
  var_attr_list.ego.latitude_gps = {
    'long_name'                    'Gps fixed latitude'
    'standard_name'                'latitude'
    'units'                        'degree_north'
    'axis'                         'Y'
    'valid_min'                    -90.0
    'valid_max'                    90.0
    'QC_procedure'                 1
    'ancillary_variable'           'POSITION_GPS_QC'
    'comment'                      'None'
    'reference'                    'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALATZZ01'
    'sdn_uom_urn'                  'SDN:P061::DEGN'
    '_FillValue'                   99999.0
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.ego.longitude_gps = {
    'long_name'                    'Gps fixed longitude'
    'standard_name'                'longitude'
    'axis'                         'X'
    'units'                        'degree_east'
    'valid_min'                    -180.0
    'valid_max'                    180.0
    'QC_procedure'                 1
    'ancillary_variable'           'POSITION_GPS_QC'
    'comment'                      'None'
    'reference'                    'WGS84'
    'coordinate_reference_frame'   'urn:ogc:crs:EPSG::4326'
    'sdn_parameter_urn'            'SDN:P01::ALONZZ01'
    'sdn_uom_urn'                  'SDN:P061::DEGE'
    '_FillValue'                   99999.0
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'position_good'                                 []
    'position_bad'                                  []
    'conversion'                                    []
    'filling'                                       [] };


  var_attr_list.ego.position_gps_qc = {
    'long_name'            'Quality flag'
    'standard_name'        'time_gps_qc'
    'conventions'          'EGO reference table 2'
    'valid_min'            0
    'valid_max'            9
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'           -128};
      
  %% Motion and orientation
  var_attr_list.socib.heading = {
    'long_name'               'glider heading angle'
    'standard_name'           'heading'
    'units'                   'rad'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.socib.roll = {
    'long_name'              'glider roll angle'
    'standard_name'          'roll'
    'units'                  'rad'
    'coordinates'            'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.socib.pitch = {
    'long_name'               'glider pitch angle'
    'standard_name'           'pitch'
    'units'                   'rad'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };
    
  %% Trajectory and profile
  var_attr_list.socib.waypoint_latitude = {
    'long_name'     'waypoint latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.socib.waypoint_longitude = {
    'long_name'     'waypoint longitude'
    'standard_name' 'longitude'
    'units'         'degree_east'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.socib.distance_over_ground = {
    'long_name'     'distance over ground flown since mission start'
    'standard_name' 'distance'
    'units'         'km'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.transect_index = {
    'long_name'     'transect index'
    'standard_name' ''
    'units'         '1'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.profile_index = {
    'long_name'     'profile index'
    'standard_name' ''
    'units'         '1'
    'comment'       'N = inside profile N, N + 0.5 = between profiles N and N + 1'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        []
    'length'                                        []
    'period'                                        []
    'inversion'                                     []
    'interrupt'                                     []
    'stall'                                         []
    'shake'                                         [] };

  var_attr_list.socib.profile_direction = {
    'long_name'     'glider vertical speed direction'
    'standard_name' ''
    'units'         '1'
    'comment'       '-1 = ascending, 0 = inflecting or stalled, 1 = descending'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attrtype_list.ego.phase = 'int8';
  var_attr_list.ego.phase = {
    'long_name'     'Glider trajectory phase code'
    'conventions'   'EGO reference table 9'
    'units'         '1'
    'flag_values'   [0,1,2,3,4,5,6]
    'flag_meanings' 'surface_drift descent subsurface_drift inflexion ascent grounded inconsistent'
    '_FillValue'    -128
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };
  
  var_attrtype_list.ego.phase_number = 'int32';
  var_attr_list.ego.phase_number = {
    'long_name'     'Glider trajectory phase number'
    '_FillValue'    99999 };
  
  var_attrtype_list.ego.positioning_method = 'int8';
  var_attr_list.ego.positioning_method = {
    'long_name'     'Positioning method'
    'conventions'   'EGO reference table 10'
    '_FillValue'    -128
    'flag_values'   [0,1,2]
    'flag_meanings' 'GPS Argos interpolated'};

  %%%%%%%%%%%%%%%%%%%%
  %% Data Parameters
  %%%%%%%%%%%%%%%%%%%%
  
  %% Conductivity
  var_attrtype_list.ego.cndc = 'single';
  var_attr_list.ego.cndc = {
    'long_name'               'Electrical conductivity'
    'standard_name'           'sea_water_electrical_conductivity'
    'units'                   'mhos/m'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'valid_min'               0.0
    'valid_max'               8.5
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'CNDC_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'sdn_parameter_urn'       'SDN:P01::CNDCST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/CNDCST01/'
    'sdn_uom_name'             'SDN:P061::UECA'
    'sdn_uom_urn'             'SDN:P061::UECA'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UECA/'
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };
      
  var_attr_list.socib.conductivity = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    'coordinates'   'time depth latitude longitude'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  
  %% Temperature
  var_attrtype_list.ego.temp = 'single';
  var_attr_list.ego.temp = {
    'long_name'               'Sea temperature in-situ ITS-90 scale'
    'standard_name'           'sea_water_temperature'
    'units'                   'degree_Celsius'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'valid_min'               -2.5
    'valid_max'               40.0
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'TEMP_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'sdn_parameter_urn'       'SDN:P01::TEMPST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/TEMPST01/'
    'sdn_uom_name'             'SDN:P061::UPAA'
    'sdn_uom_urn'             'SDN:P061::UPAA'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UPAA/'
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.temperature = {
    'long_name'               'water temperature'
    'standard_name'           'sea_water_temperature'
    'units'                   'Celsius'
    'coordinates'             'time depth latitude longitude'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  %% Pressure
  var_attrtype_list.ego.pres = 'single';
  var_attr_list.ego.pres = {
    'long_name'               'Sea water pressure, equals 0 at sea-level'
    'standard_name'           'sea_water_pressure'
    'units'                   'decibar'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'axis'                    'Z'
    'valid_min'               0.0
    'valid_max'               12000.0
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'PRES_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'sdn_parameter_urn'       'SDN:P01::PRESPR01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/PRESPR01/'
    'sdn_uom_name'            'SDN:P061::UPDB'
    'sdn_uom_urn'             'SDN:P061::UPDB'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UPDB/'
    'comment'                 '19/10/2013 : revision of the long name'
    'glider_original_parameter_name'                [] 
    'sources   '                                    []
    'method'                                        []
    'calibration'                                   []
    'calibration_parameters'                        []
    'filter_method'                                 []
    'filter_parameters'                             [] };

  var_attr_list.socib.pressure = {
    'long_name'               'water pressure'
    'standard_name'           'pressure'
    'units'                   'dbar'
    'coordinates'             'time depth latitude longitude'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        []
    'filter_method'                                 []
    'filter_parameters'                             [] };

  %% CTD
  var_attr_list.socib.time_ctd = {
    'long_name'               'CTD epoch time'
    'standard_name'           'time'
    'units'                   'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'                 'CTD time stamp'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    [] };

  var_attr_list.socib.depth_ctd = {
    'long_name'               'CTD depth'
    'standard_name'           'depth'
    'units'                   'm'
    'comment'                 'depth derived from CTD pressure sensor'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  %% CTD corrected values
  var_attr_list.socib.temperature_corrected_sensor = {
    'long_name'               'water temperature with sensor time response corrected'
    'standard_name'           'sea_water_temperature'
    'units'                   'Celsius'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        []
    'parameters'                                    []
    'parameter_method'                              []
    'parameter_estimator'                           []
    'profile_min_range'                             []
    'profile_gap_ratio'                             [] };

  var_attr_list.socib.temperature_corrected_thermal = {
    'long_name'               'water temperature with thermal lag corrected'
    'standard_name'           'sea_water_temperature'
    'units'                   'Celsius'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        []
    'parameters'                                    []
    'parameter_method'                              []
    'parameter_estimator'                           []
    'profile_min_range'                             []
    'profile_gap_ratio'                             [] };

  var_attr_list.socib.conductivity_corrected_sensor = {
    'long_name'               'water conductivity with sensor time response corrected'
    'standard_name'           'sea_water_conductivity'
    'units'                   'S m-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        []
    'parameters'                                    []
    'parameter_method'                              []
    'parameter_estimator'                           []
    'profile_min_range'                             []
    'profile_gap_ratio'                             [] };

  var_attr_list.socib.conductivity_corrected_thermal = {
    'long_name'               'water conductivity with thermal lag corrected'
    'standard_name'           'sea_water_conductivity'
    'units'                   'S m-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        []
    'parameters'                                    []
    'parameter_method'                              []
    'parameter_estimator'                           []
    'profile_min_range'                             []
    'profile_gap_ratio'                             [] };

  %% Salinity products
  var_attrtype_list.ego.psal = 'single';
  var_attr_list.ego.psal = {
    'long_name'               'Practical salinity'
    'standard_name'           'sea_water_salinity'
    'units'                   'psu'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'valid_min'               2.0
    'valid_max'               41.0
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'PSAL_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'sdn_parameter_urn'       'SDN:P01::PSALST01'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/PSALST01/'
    'sdn_uom_name'            'SDN:P061::UUUU'
    'sdn_uom_urn'             'SDN:P061::UUUU'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/UUUU/'
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.salinity = {
    'long_name'               'water salinity'
    'standard_name'           'sea_water_salinity'
    'units'                   'PSU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.salinity_corrected_thermal = {
    'long_name'               'water salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name'           'sea_water_salinity'
    'units'                   'PSU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.salinity_corrected_sensor = {
    'long_name'               'water salinity from conductivity and temperature with sensor lag corrected'
    'standard_name'           'sea_water_salinity'
    'units'                   'PSU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.salinity_corrected_sensor_thermal = {
    'long_name'               'water salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name'           'sea_water_salinity'
    'units'                   'PSU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  %% Density products
  var_attr_list.socib.density = {
    'long_name'               'water density using salinity from raw temperature and raw conductivity'
    'standard_name'           'sea_water_density'
    'units'                   'kg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.density_corrected_thermal = {
    'long_name'               'water density using salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name'           'sea_water_density'
    'units'                   'kg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.density_corrected_sensor = {
    'long_name'               'water density using salinity from conductivity and temperature with sensor lag corrected'
    'standard_name'           'sea_water_density'
    'units'                   'kg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.density_corrected_sensor_thermal = {
    'long_name'               'water density using salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name'           'sea_water_density'
    'units'                   'kg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  %% Potential products
  var_attr_list.socib.potential_temperature = {
    'long_name'               'water potential temperature'
    'standard_name'           'sea_water_potential_temperature'
    'units'                   'Celsius'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.potential_density = {
    'long_name'               'water potential density'
    'standard_name'           'sea_water_potential_density'
    'units'                   'kg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  %% Backstatter
  var_attr_list.socib.backscatter_470 = {
    'long_name'               'blue backscattering'
    'standard_name'           'blue_backscattering'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.backscatter_532 = {
    'long_name'               'green backscattering'
    'standard_name'           'green_backscattering'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.backscatter_660 = {
    'long_name'               'red backscattering'
    'standard_name'           'red_backscattering'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.backscatter_700 = {
    'long_name'               '700 nm wavelength backscatter'
    'standard_name'           '700nm_backscatter'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.backscatter = {
    'long_name'               'backscattering'
    'standard_name'           'backscattering'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attrtype_list.ego.turbidity = 'single';
  var_attr_list.ego.turbidity = {
    'long_name'               'Sea water turbidity'
    'standard_name'           'sea_water_turbidity'
    'units'                   'ntu'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'TURBIDITY_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'sdn_parameter_urn'       'SDN:P01::TURBXXXX'
    'sdn_parameter_uri'       'http://vocab.nerc.ac.uk/collection/P01/current/TURBXXXX/'
    'sdn_uom_name'            'SDN:P061::USTU'
    'sdn_uom_urn'             'SDN:P061::USTU'
    'sdn_uom_uri'             'http://vocab.nerc.ac.uk/collection/P06/current/USTU/'
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.socib.turbidity = {
    'long_name'               'Sea water turbidity'
    'standard_name'           'sea_water_turbidity'
    'units'                   'NTU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.scatter_650 = {
    'long_name'               '650 nm wavelength scattering'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  %% Fluorescence
  var_attrtype_list.ego.chla = 'single';
  var_attr_list.ego.chla = {
    'long_name'               'Chlorophyll-A'
    'standard_name'           'mass_concentration_of_chlorophyll_a_in_sea_water'
    'units'                   'mg/m3'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'CHLA_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.chlorophyll = {
    'long_name'               'chlorophyll'
    'standard_name'           'concentration_of_chlorophyll_in_sea_water'
    'units'                   'mg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.cdom = {
    'long_name'               'CDOM'
    'standard_name'           'concentration_of_coloured_dissolved_organic_matter'
    'units'                   'ppb'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  %% Spectro and photometric 
  var_attr_list.ego.temp_spectrophotometer_nitrate = {
    'long_name'               'Temperature of the spectrometer'
    'standard_name'           'temperature_of_optic_sensor_in_sea_water'
    'units'                   'Celsius'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'TEMP_SPECTROPHOTOMETER_NITRATE_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.temperature_optics = {
    'long_name'               'optic sensor temperature'
    'standard_name'           'temperature_of_optic_sensor_in_sea_water'
    'units'                   'Celsius'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.time_optics = {
    'long_name'               'optic sensor epoch time'
    'standard_name'           'time'
    'units'                   'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'                 'optic sensor time stamp'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    [] };

  %% Oxygen 
  var_attr_list.socib.oxygen_concentration = {
    'long_name'               'oxygen concentration'
    'standard_name'           'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'                   'umol l-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attrtype_list.ego.molar_doxy = 'single';
  var_attr_list.ego.molar_doxy = {
    'long_name'               'Uncompensated (pressure and salinity) oxygen concentration reported by the oxygen sensor'
    'standard_name'           'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'                   'micromole/l'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'MOLAR_DOXY_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.oxygen_saturation = {
    'long_name'               'oxygen saturation'
    'standard_name'           'fractional_saturation_of_oxygen_in_sea_water'
    'units'                   '1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.oxygen_frequency = {
    'long_name'               'oxygen frequency'
    'standard_name'           'frequency_output_of_sensor_for_oxygen_in_sea_water'
    'units'                   'Hz'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  var_attr_list.socib.time_oxygen = {
    'long_name'               'oxygen sensor epoch time'
    'standard_name'           'time'
    'units'                   'seconds since 1970-01-01 00:00:00 +00:00'
    'comment'                 'oxygen sensor time stamp'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    [] };

  var_attrtype_list.ego.temp_doxy = 'single';
  var_attr_list.ego.temp_doxy = {
    'long_name'               'Sea temperature from oxygen sensor ITS-90 scale'
    'standard_name'           'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'                   'degree_Celsius'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'sensor_mount'            'mounted_on_glider'
    'sensor_orientation'      'downward'
    'sensor_name'             'Undefined'
    'sensor_serial_number'    'Undefined'
    'ancillary_variable'      'TEMP_DOXY_QC'
    'accuracy'                0.0001
    'precision'               0.0001
    'resolution'              0.0
    'cell_methods'            'point'
    'DM_indicator'            'R'
    'reference_scale'         'Undefined'
    '_FillValue'              99999
    'glider_original_parameter_name'         [] 
    'sources'                                []
    'conversion'                             []
    'calibration'                            []
    'calibration_parameters'                 [] };

  var_attr_list.socib.temperature_oxygen = {
    'long_name'     'oxygen sensor temperature'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    'coordinates'   'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  %% Irrandiance
  var_attr_list.socib.irradiance_412 = {
    'long_name'               'irradiance at 412nm wavelength'
    'standard_name'           'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'                   'uW cm-2 nm-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.irradiance_442 = {
    'long_name'               'irradiance at 442nm wavelength'
    'standard_name'           'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'                   'uW cm-2 nm-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.irradiance_491 = {
    'long_name'               'irradiance at 491nm wavelength'
    'standard_name'           'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'                   'uW cm-2 nm-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.irradiance_664 = {
    'long_name'               'irradiance at 664nm wavelength'
    'standard_name'           'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'                   'uW cm-2 nm-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.water_velocity_eastward = {
    'long_name'               'mean eastward water velocity in segment'
    'standard_name'           'eastward_water_velocity'
    'units'                   'm s-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    [] };

  %% Velocities
  var_attr_list.socib.sound_velocity = {
    'long_name'               'sound velocity'
    'standard_name'           'sea_water_sound_velocity'
    'units'                   'm s-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.water_velocity_northward = {
    'long_name'               'mean northward water velocity in segment'
    'standard_name'           'northward_water_velocity'
    'units'                   'm s-1'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    [] };

  %% Fluorescense
  var_attr_list.socib.fluorescence_270_340 = {
    'long_name'               'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
    'standard_name'           'fluorescence_excitation_270nm_emission_340nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Tryptophan-like or Naphtalene-like measurements'
    'comment2'                '270nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_255_360 = {
    'long_name'               'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
    'standard_name'           'fluorescence_excitation_255nm_emission_360nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Phenanthren-like measurements or water-soluble fraction of petroleum'
    'comment2'                '255nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_monitoring_270_340 = {
    'long_name'               'Minifluo-UV1 monitoring channel of the 270nm LED'
    'standard_name'           'fluorescence_monitoring_270_340nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Measures variations in LED excitation wavelength'
    'comment2'                '270nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_monitoring_255_360 = {
    'long_name'               'Minifluo-UV1 monitoring channel of the 255nm LED'
    'standard_name'           'fluorescence_monitoring_255_360nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Measures variations in LED excitation wavelength'
    'comment2'                '255nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_260_315 = {
    'long_name'               'Minifluo-UV2 fluorescence Ex./Em. = 260/315nm'
    'standard_name'           'fluorescence_excitation_260nm_emission_315nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Fluorene-like measurements'
    'comment2'                '260nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_270_376 = {
    'long_name'               'Minifluo-UV2 fluorescence Ex./Em. = 270/376nm'
    'standard_name'           'fluorescence_excitation_270nm_emission_376nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Pyrene-like measurements'
    'comment2'                '270nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_monitoring_260_315 = {
    'long_name'               'Minifluo-UV2 monitoring channel of the 260nm LED'
    'standard_name'           'fluorescence_monitoring_260_315nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Measures variations in LED excitation wavelength'
    'comment2'                '260nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.fluorescence_monitoring_270_376 = {
    'long_name'               'Minifluo-UV2 monitoring channel of the 270nm LED'
    'standard_name'           'fluorescence_monitoring_270_376nm'
    'units'                   'counts'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    'comment1'                'Measures variations in LED excitation wavelength'
    'comment2'                '270nm is the nominal wavelength of the LED'
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  var_attr_list.socib.methane_concentration = {
    'long_name'               'Methane concentration (scaled)'
    'standard_name'           'methane_concentration'
    'units'                   'mg m-3'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ' '
    'sensor_orientation'      ' '
    'sensor_name'             ' '
    'sensor_serial_number'    ' '
    'ancillary_variable'      ''
    'accuracy'                ''
    'precision'               ''
    'resolution'              ''
    'cell_methods'            ''
    'DM_indicator'            ''
    'reference_scale'         ''
    '_FillValue'              default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       [] };

  %% History parameters
  var_attr_list.ego.n_history = {
    'long_name'            'Number of history records'
    'standard_name'        'n_history'};
  
  var_attr_list.ego.history_institution = {
    'long_name'               'Institution which performed action'
    'standard_name'           'history_institution'
    'conventions'             'EGO reference table 4'
    'coordinates'             'n_history string2'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_step = {
    'long_name'               'Step in data processing'
    'standard_name'           'history_step'
    'conventions'             'EGO reference table 12'
    'coordinates'             'n_history string4'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_software = {
    'long_name'               'Name of software which performed action'
    'standard_name'           'history_software'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string8'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_software_release = {
    'long_name'               'Version/release of software which performed action'
    'standard_name'           'history_software_release'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string4'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_reference = {
    'long_name'               'Reference of database'
    'standard_name'           'history_reference'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_date = {
    'long_name'               'Date the history record was created'
    'standard_name'           'history_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'n_history date_time'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_action = {
    'long_name'               'Action performed on data'
    'standard_name'           'history_action'
    'conventions'             'EGO reference table 7'
    'coordinates'             'n_history string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.history_parameter = {
    'long_name'               'Parameter action is performed on'
    'standard_name'           'history_parameter'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_history string16'
    '_FillValue'              ' '};
  
  var_attrtype_list.ego.history_previous_value = 'single';
  var_attr_list.ego.history_previous_value  = {
    'long_name'               'Parameter or flag previous value before action'
    'standard_name'           'history_previous_value'
    'conventions'             'EGO reference table 3'
    '_FillValue'              99999};
  
  var_attrtype_list.ego.history_start_time_index = 'int32';
  var_attr_list.ego.history_start_time_index = {
    'long_name'               'Start time index action applied on'
    'standard_name'           'history_start_time_index'
    'coordinates'             'n_history'
    '_FillValue'              99999};
  
  var_attrtype_list.ego.history_stop_time_index = 'int32';
  var_attr_list.ego.history_stop_time_index = {
    'long_name'               'Stop time index action applied on'
    'standard_name'           'history_stop_time_index'
    'coordinates'             'n_history'
    '_FillValue'              99999};
  
  var_attr_list.ego.history_qctest = {
    'long_name'               'Documentation of tests performed, tests failed (in hex form)'
    'standard_name'           'history_qctest'
    'conventions'             'Write tests performed when ACTION=QCP$; tests failed when ACTION=QCF$'
    'coordinates'             'n_history string16'
    '_FillValue'              ' '};

  %% Glider characteristics parameter
  var_attr_list.ego.n_param = {
    'long_name'            'Number of parameters measured or calculated during glider deployment'
    'standard_name'        'n_param'};
  var_attr_list.ego.n_derivation = {
    'long_name'            'Maximum number of calibrations for a parameter'
    'standard_name'        'n_derivation'};
  var_attr_list.ego.n_positioning_system = {
    'long_name'            'Number of positioning systems'
    'standard_name'        'n_positioning_system'};
  var_attr_list.ego.n_trans_system = {
    'long_name'            'Number of transmission systems'
    'standard_name'        'n_trans_system'};
  
  var_attr_list.ego.trans_system = {
    'long_name'               'Telecommunication system used'
    'standard_name'           'trans_system'
    'conventions'             'Write tests performed when ACTION=QCP$; tests failed when ACTION=QCF$'
    'coordinates'             'n_trans_system string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.trans_system_id = {
    'long_name'               'Program identifier used by the transmission system'
    'standard_name'           'trans_system_id'
    'coordinates'             'n_trans_system string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.trans_frequency = {
    'long_name'               'Frequency of transmission from the glider'
    'standard_name'           'trans_frequency'
    'units'                   'hertz'
    'coordinates'             'n_trans_system string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.positioning_system = {
    'long_name'               'Positioning system'
    'standard_name'           'positioning_system'
    'coordinates'             'n_positioning_system string8'
    '_FillValue'              ' '};
  
  var_attr_list.ego.platform_family = {
    'long_name'               'Category of instrument'
    'standard_name'           'platform_family'
    'conventions'             'EGO reference table 22'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.platform_type = {
    'long_name'               'Type of glider'
    'standard_name'           'platform_type'
    'conventions'             'EGO reference table XX'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.platform_maker = {
    'long_name'               'Name of the manufacturer'
    'standard_name'           'platform_maker'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.firmware_version_navigation = {
    'long_name'               'Firmware version of the navigation controller board'
    'standard_name'           'firmware_version_navigation'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.firmware_version_science = {
    'long_name'               'Firmware version of the scientific sensors controller board'
    'standard_name'           'firmware_version_science'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.manual_version = {
    'long_name'               'Manual version of the glider'
    'standard_name'           'manual_version'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.glider_serial_no = {
    'long_name'               'Serial number of the glider'
    'standard_name'           'glider_serial_no'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.standard_format_id = {
    'long_name'               'Standard format number which describes the data format type for each glider'
    'standard_name'           'standard_format_id'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.dac_format_id = {
    'long_name'               'Format number used by the DAC to describe the data format type for each glider'
    'standard_name'           'dac_format_id'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.wmo_inst_type = {
    'long_name'               'Coded instrument type'
    'standard_name'           'wmo_inst_type'
    'conventions'             'EGO reference table 8'
    'coordinates'             'string4'
    '_FillValue'              ' '};
  
  var_attr_list.ego.project_name = {
    'long_name'               'Program under which the glider was deployed'
    'standard_name'           'project_name'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.data_centre = {
    'long_name'               'Data centre in charge of glider real-time processing'
    'standard_name'           'data_centre'
    'conventions'             'EGO reference table 4'
    'coordinates'             'string4'
    '_FillValue'              ' '};
  
  var_attr_list.ego.pi_name = {
    'long_name'               'Name of the Principal Investigator'
    'standard_name'           'pi_name'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.anomaly = {
    'long_name'               'Describe any anomalies or problems the glider may have had'
    'standard_name'           'anomaly'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.battery_type = {
    'long_name'               'Type of battery packs in the glider'
    'standard_name'           'battery_type'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.battery_packs = {
    'long_name'               'Configuration of battery packs in the glider'
    'standard_name'           'battery_packs'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.special_features = {
    'long_name'               'Extra features of the glider (algorithms, compressee etc.)'
    'standard_name'           'special_features'
    'coordinates'             'string1024'
    '_FillValue'              ' '};
  
  var_attr_list.ego.glider_owner = {
    'long_name'               'Glider owner'
    'standard_name'           'glider_owner'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.operating_institution = {
    'long_name'               'Operating institution of the glider'
    'standard_name'           'operating_institution'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.customization = {
    'long_name'               'Glider customization, i.e. (institutionand modifications)'
    'standard_name'           'customization'
    'coordinates'             'string1024'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_start_date = {
    'long_name'               'Date (UTC) of the deployment'
    'standard_name'           'deployment_start_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'date_time'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_start_latitude = {
    'long_name'               'Latitude of the glider when deployed'
    'standard_name'           'deployment_start_latitude'
    'units'                   'degree_north'
    'valid_min'               -90
    'valid_max'               90
    '_FillValue'              99999};
  
  var_attr_list.ego.deployment_start_longitude = {
    'long_name'               'Longitude of the glider when deployed'
    'standard_name'           'deployment_start_longitude'
    'units'                   'degree_east'
    'valid_min'               -180
    'valid_max'               180
    '_FillValue'              99999};
  
  var_attrtype_list.ego.deployment_start_qc = 'int8';
  var_attr_list.ego.deployment_start_qc = {
    'long_name'               'Quality on DEPLOYMENT_START date, time and location'
    'standard_name'           'deployment_start_date'
    'conventions'             'EGO reference table 2'
    'flag_values'             [0,1,2,3,4,5,8,9]
    'flag_meanings'           'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'              -128};
  
  var_attr_list.ego.deployment_platform = {
    'long_name'               'Identifier of the deployment platform'
    'standard_name'           'deployment_platform'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_cruise_id = {
    'long_name'               'Identifier of the cruise that deployed the glider'
    'standard_name'           'deployment_cruise_id'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_reference_station_id = {
    'long_name'               'Identifier of stations used to verify the parameter measurements'
    'standard_name'           'deployment_reference_station_id'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_end_date = {
    'long_name'               'Date (UTC) of the glider recovery'
    'standard_name'           'deployment_end_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'date_time'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_end_latitude = {
    'long_name'               'Latitude of the glider recovery'
    'standard_name'           'deployment_end_latitude'
    'units'                   'degree_north'
    'valid_min'               -90
    'valid_max'               90
    '_FillValue'              99999};
  
  var_attr_list.ego.deployment_end_longitude = {
    'long_name'               'Longitude of the glider recovery'
    'standard_name'           'deployment_end_longitude'
    'units'                   'degree_east'
    'valid_min'               -180
    'valid_max'               180
    '_FillValue'              99999};
  
  var_attrtype_list.ego.deployment_end_qc = 'int8';
  var_attr_list.ego.deployment_end_qc = {
    'long_name'               'Quality on DEPLOYMENT_END date, time and location'
    'standard_name'           'deployment_end_qc'
    'conventions'             'EGO reference table 2'
    'flag_values'             [0,1,2,3,4,5,8,9]
    'flag_meanings'           'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'              -128};
  
  var_attr_list.ego.deployment_end_status = {
    'long_name'               'Status of the end of mission of the glider'
    'standard_name'           'deployment_end_status'
    'conventions'             'R: retrieved, L: lost'
    '_FillValue'              ' '};
  
  var_attr_list.ego.deployment_operator = {
    'long_name'               'Name of the person in charge of the glider deployment'
    'standard_name'           'deployment_operator'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor = {
    'long_name'               'List of sensors on the glider'
    'standard_name'           'sensor'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_param, string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_maker = {
    'long_name'               'Name of the sensor manufacturer'
    'standard_name'           'sensor_maker'
    'coordinates'             'n_param, string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_model = {
    'long_name'               'Model of the sensor'
    'standard_name'           'sensor_model'
    'coordinates'             'n_param, string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_serial_no = {
    'long_name'               'Serial number of the sensor'
    'standard_name'           'sensor_serial_no'
    'coordinates'             'n_param, string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_units = {
    'long_name'               'Units of the parameter measured by the sensor'
    'standard_name'           'sensor_units'
    'coordinates'             'n_param, string16'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_accuracy = {
    'long_name'               'Accuracy of the parameter measured by the sensor'
    'standard_name'           'sensor_accuracy'
    'coordinates'             'n_param, string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.sensor_resolution = {
    'long_name'               'Resolution of the parameter measured by the sensor'
    'standard_name'           'sensor_resolution'
    'coordinates'             'n_param, string32'
    '_FillValue'              ' '};
  
  var_attr_list.ego.derivation_parameter = {
    'long_name'               'List of parameters with derivation or calibration information'
    'standard_name'           'derivation_parameter'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_derivation, string64'
    '_FillValue'              ' '};
  
  var_attr_list.ego.derivation_equation = {
    'long_name'               'Derivation or calibration equation for this parameter'
    'standard_name'           'derivation_equation'
    'coordinates'             'n_derivation, string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.derivation_coefficient = {
    'long_name'               'Derivation or calibration coeffcicients for this equation'
    'standard_name'           'derivation_coefficient'
    'coordinates'             'n_derivation, string512'
    '_FillValue'              ' '};
  
  var_attr_list.ego.derivation_comment = {
    'long_name'               'Comment applying to this parameter derivation or calibration'
    'standard_name'           'derivation_comment'
    'coordinates'             'n_derivation, string256'
    '_FillValue'              ' '};
  
  var_attr_list.ego.derivation_date = {
    'long_name'               'Date (UTC) of derivation or calibration'
    'standard_name'           'derivation_date'
    'coordinates'             'n_derivation, date_time'
    'conventions'             'YYYYMMDDHHMISS'
    '_FillValue'              ' '};

  %% Quality control
  var_attrtype_default = 'int8';
  var_attr_default = {
    'long_name'            'Quality flag'
    'standard_name'        ''
    'conventions'          'EGO reference table 2'
    'comment'              'None'
    'valid_min'            0
    'valid_max'            9
    '_FillValue'           -128
    'QC_procedure'         '1'
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'};
    
  var_attrtype_list.ego.time_qc = var_attrtype_default;
  var_attr_list.ego.time_qc = var_attr_default;
  var_attr_list.ego.time_qc(end+1,:) = {'axis', 'T'};


  %% Select parameters based on input params structure
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument.
    format_list = fieldnames(varargin{1});
    param_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    format_list = varargin(1:2:end);
    param_list = varargin(2:2:end);
  else
    error('glider_toolbox:preprocessGliderData:InvalidOption', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  
  
  for format_idx = 1:numel(format_list)
    format = lower(format_list{format_idx});
    
    format_param_list = param_list{format_idx};
    for param_idx = 1:numel(format_param_list)
      param = format_param_list{param_idx};
      if isfield(var_attr_list, format)
        if isfield(var_attr_list.(format), param)
          var_attr.(param) = var_attr_list.(format).(param);
          if isfield(var_attrtype_list, format) && isfield(var_attrtype_list.(format), param)
            var_attrtype.(param) = var_attrtype_list.(format).(param);
          end
        end
      end
    end
  end  
  
  % Set the variable metadata.
  meta_variables = struct();
  var_name_list = fieldnames(var_attr);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    
    % Add attributes that are defined in the dictionary
    % and that it was not added earlier in metadata
    if isfield(var_attr,var_name) && ~isfield(meta_variables, var_name)
      vatts = var_attr.(var_name);
      meta_variables.(var_name).dimensions = {time_dimension_name};
      meta_variables.(var_name).attributes = ...
        cell2struct(vatts, {'name' 'value'}, 2);
      if isfield(var_attrtype, var_name)
        meta_variables.(var_name).type = var_attrtype.(var_name);
      end
        
      % Create QC field for attributes containing 
      % ancillary_variable to FIELD_QC:
      %     - Checks ancillary fields
      %     - Finds existing definitions in dictionnary or create default one 
      %     - Changes standard name
      %     - Adds to metadata
      idx_ancillary = find(cellfun(@(x) strcmp(x,'ancillary_variable'), vatts(:,1)));
      if ~isempty(idx_ancillary) 
        ancillary_var = vatts(idx_ancillary(1),2);
        if ~isempty(ancillary_var{1})
          qc_var_name = lower(ancillary_var{1});
          if strcmp(qc_var_name(end-2:end), '_qc')
            % Add QC to metadata if it was not there already
            if ~isfield(meta_variables, qc_var_name)
              % Add the one defined in the dictionary if it
              % exists or a default one otherwise  
              if isfield(var_attr,qc_var_name)
                 vqcatts = var_attr.(qc_var_name);
              else
                vqcatts = var_attr_default;
                
                % Change standard name
                idx_stdname = find(cellfun(@(x) strcmp(x,'standard_name'), vqcatts(:,1)));
                if ~isempty(idx_stdname) 
                  vqcatts(idx_stdname(1),2) = {qc_var_name};
                end
              end
              if isfield(var_attrtype,qc_var_name)
                vqcattstype = var_attrtype.(qc_var_name);
              else
                vqcattstype = var_attrtype_default;
              end
              

              meta_variables.(qc_var_name).dimensions = {time_dimension_name};
              meta_variables.(qc_var_name).attributes = ...
                cell2struct(vqcatts, {'name' 'value'}, 2);
              meta_variables.(qc_var_name).type = vqcattstype;
              
            end
          end
        end
      end
    end
  end
end

