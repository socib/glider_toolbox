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
    'ancillary_variable'  'TIME_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'time latitude longitude depth'
    'comment'              'None'
    '_FillValue'           default_fill_value
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
    'ancillary_variable'  'TIME_GPS_QC'
    'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
    'sdn_uom_urn'          'SDN:P061::UTBB'
    'coordinates'          'time_gps'
    'comment'              'None'
    '_FillValue'           -128
    'glider_original_parameter_name'                [] 
    'sources'                [] };

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
    'coordinates'          'time latitude longitude depth'
    'comment'              'None'
    '_FillValue'           default_fill_value
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
    'axis'                    'Z'
    'coordinates'             'time latitude longitude depth'
    'ancillary_variable'      'DEPTH_QC'
    '_FillValue'              default_fill_value
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
    'long_name'                   'Gps fixed latitude'
    'standard_name'               'latitude'
    'units'                       'degrees_north'
    'axis'                        'Y'
    'coordinates'                 'time latitude longitude depth'
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
    'long_name'                    'Gps fixed longitude'
    'standard_name'                'longitude'
    'axis'                         'X'
    'units'                        'degrees_east'
    'coordinates'                  'time latitude longitude depth'
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
    'units'                        'degrees_north'
    'axis'                         'Y'
    'coordinates'                  'TIME_GPS LATITUDE LONGITUDE DEPTH'
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
    'units'                        'degrees_east'
    'coordinates'                  'TIME_GPS LATITUDE LONGITUDE DEPTH'
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
      
  %% Motion and orientation
  var_attr_list.socib.heading = {
    'long_name'               'glider heading angle'
    'standard_name'           'heading'
    'units'                   'rad'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'standard_name' ''
    'conventions'   'EGO reference table 9'
    'units'         '1'
    'flag_values'   [0,1,2,3,4,5,6]
    'flag_meanings' 'surface_drift descent subsurface_drift inflexion ascent grounded inconsistent'
    'coordinates'   'time latitude longitude depth'
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
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'units'                   'Celcius'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'units'                   'dbar'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'units'                   'PSU'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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

  var_attr_list.socib.turbidity = {
    'long_name'               'Sea water turbidity'
    'standard_name'           'sea_water_turbidity'
    'units'                   'NTU'
    'coordinates'             'time latitude longitude depth'
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'units'                   'mg m-3'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'coordinates'             'time latitude longitude depth'
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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

  var_attr_list.ego.molar_doxy = {
    'long_name'               'Uncompensated (pressure and salinity) oxygen concentration reported by the oxygen sensor'
    'standard_name'           'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'                   'umol l-1'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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

  var_attr_list.ego.temp_doxy = {
    'long_name'               'Sea temperature from oxygen sensor ITS-90 scale'
    'standard_name'           'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'                   'Celsius'
    'coordinates'             'time latitude longitude depth'
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
    '_FillValue'              default_fill_value
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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
    'sensor_mount'            ''
    'sensor_orientation'      ''
    'sensor_name'             ''
    'sensor_serial_number'    ''
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

