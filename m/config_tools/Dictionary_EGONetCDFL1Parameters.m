function [ var_attr_list, var_attrtype_list ] = Dictionary_EGONetCDFL1Parameters(varargin)
%LISTNETCDFL1PARAMETERS  Create structure from the available parameter
%                         description
%
%  Syntax:
%    [ VAR_ATTR_LIST, VAR_ATTRTYPE_LIST ] = DICTIONARY_EGONETCDFL1PARAMETERS()
%    [ VAR_ATTR_LIST, VAR_ATTRTYPE_LIST ] = DICTIONARY_EGONETCDFL1PARAMETERS(OPTIONS)
%    [ VAR_ATTR_LIST, VAR_ATTRTYPE_LIST ] = DICTIONARY_EGONETCDFL1PARAMETERS(OPT1, VAL1, ...)
%
%  Description:
%    [ VAR_ATTR_LIST, VAR_ATTRTYPE_LIST ] = DICTIONARY_EGONETCDFL1PARAMETERS() 
%    should return a struct describing the structure of parameters of the NetCDF file. 
%    This function contains the definition of all available parameters of EGO
%    standards. It will return a structure with the entire dictionary of
%    variables of the EGO format as well as their corresponding QC and
%    UNCERTAINTY variables.
%    
%  Input:
%    No input
%  
%  Ouput:
%    The output lists are structures describing the resulting variables
%    attributes and variable types
%         - VAR_ATTR_LIST: Structure containing the list of variables and
%                 their attributes
%         - VAR_ATTRTYPE_LIST: Structure containing the types of specific
%                 variables (single, double,...)
%
%  Options:
%         - QC_ATTRIBUTES, QC_ATTRIBUTE_TYPE, QC_PREFIX, QC_SUFFIX and
%             UPDATE_LONG_NAME: see options for competeQCDictionary
%
%             + QC_ATTRIBUTES: Default QC attributes to be used to create the
%                  QC variables. If not input the default structure is the
%                  one used by EGO standards
%                 + long_name: Quality flag 
%                 + standard_name: 
%                 + quality_control_convention: EGO reference table 2
%                 + comment: None
%                 + valid_min: 0
%                 + valid_max: 9
%                 + _FillValue: -128
%                 + QC_procedure: 1
%                 + flag_values: [0,1,2,3,4,8,9]
%                 + flag_meanings: no_qc_performed 
%                                  good_data 
%                                  probably_good_data
%                                  probably_bad_data 
%                                  bad_data
%                                  interpolated_value 
%                                  missing_value  
%             + QC_ATTRIBUTE_TYPE: int8
%
%         - UNCERTAINTY_ATTRIBUTES, UNCERTAINTY_ATTRIBUTE_TYPE,
%             UNCERTAINTY_PREFIX and UNCERTAINTY_SUFFIX: see options for
%             completeUncertaintyDictionary 
%
%             + UNCERTAINTY_ATTRIBUTES: Default uncertainty attributes to be used to create the
%                  uncertainty variables. If not input the default structure is the
%                  one used by EGO standards
%                 + long_name: Uncertainty
%                 + _FillValue: 0
%                 + units: na 
%              + QC_ATTRIBUTE_TYPE: single
%
%  Examples:
%    [ var_attr_list, var_attrtype_list ] = Dictionary_EGONetCDFL1Parameters()
%
%  See also:
%    COMPLETEQCDICTIONARY
%    COMPLETEUNCERTAINTYDICTIONARY
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


  narginchk(0, 18);
  
  options.qc_prefix = '';
  options.qc_suffix = '_QC';  
  options.qc_attributes = {
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
  options.qc_attribute_type = 'int8';
  options.update_long_name = true;
  options.uncertainty_attributes = {
    'long_name'                         'Uncertainty'
    '_FillValue'                        99999
    'units'                             'n/a'};
  options.uncertainty_attribute_type = 'single';
  options.uncertainty_prefix = '';
  options.uncertainty_suffix = '_UNCERTAINTY';
  

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
        error('glider_toolbox:combineDataAndQc:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
     opt = lower(opt_key_list{opt_idx});
     val = opt_val_list{opt_idx};
     if isfield(options, opt)
        options.(opt) = val;
     else
          error('glider_toolbox:combineDataAndQc:InvalidOption', ...
                'Invalid option: %s.', opt);
     end
  end
    
  default_fill_value = realmax('double');
  
  var_attr_list     = struct();
  var_attrtype_list = struct();
  
  %% Time Parameters
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
    'coordinates'          'TIME LATITUDE LONGITUDE PRES'
    'comment'              'None'
    '_FillValue'           9999999999
    'glider_original_parameter_name'                [] 
    'sources'                [] };
 
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
    '_FillValue'           -1
    'glider_original_parameter_name'                [] 
    'sources'                [] };


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
    'comment'              'None'
    '_FillValue'           999999
    'comment'              ''
    'glider_original_parameter_name'                [] 
    'sources'                [] };

  %% Depth parameter                      
  var_attrtype_list.depth = 'single';
  var_attr_list.depth = {
    'long_name'               'glider depth'
    'standard_name'           'depth'
    'units'                   'm'
    'positive'                'down'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
    'ancillary_variable'      'DEPTH_QC'
    '_FillValue'              99999
    'comment'                 'None'
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };
  

  %% Geolocation
  var_attr_list.latitude = {
    'long_name'                   'Measurement latitude'
    'standard_name'               'latitude'
    'units'                       'degree_north'
    'axis'                        'Y'
    'coordinates'                 'TIME LATITUDE LONGITUDE PRES'
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

  var_attr_list.longitude = {
    'long_name'                    'Measurement longitude'
    'standard_name'                'longitude'
    'axis'                         'X'
    'units'                        'degree_east'
    'coordinates'                  'TIME LATITUDE LONGITUDE PRES'
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
  
  var_attr_list.latitude_gps = {
    'long_name'                    'Gps fixed latitude'
    'standard_name'                'latitude'
    'units'                        'degree_north'
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

  var_attr_list.longitude_gps = {
    'long_name'                    'Gps fixed longitude'
    'standard_name'                'longitude'
    'axis'                         'X'
    'units'                        'degree_east'
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

  var_attrtype_list.phase = 'int8';
  var_attr_list.phase = {
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

  %%%%%%%%%%%%%%%%%%%%
  %% Data Parameters
  %%%%%%%%%%%%%%%%%%%%
  
  %% Conductivity
  var_attrtype_list.cndc = 'single';
  var_attr_list.cndc = {
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
  
  %% Temperature
  var_attrtype_list.temp = 'single';
  var_attr_list.temp = {
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

  %% Pressure
  var_attrtype_list.pres = 'single';
  var_attr_list.pres = {
    'long_name'               'Sea water pressure, equals 0 at sea-level'
    'standard_name'           'sea_water_pressure'
    'units'                   'decibar'
    'axis'                    'Z'
    'coordinates'             'TIME LATITUDE LONGITUDE PRES'
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

  %% Salinity products
  var_attrtype_list.psal = 'single';
  var_attr_list.psal = {
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

  %% Fluorescence
  var_attrtype_list.chla = 'single';
  var_attr_list.chla = {
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
    '_FillValue'              99999.0
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'calibration'                                   []
    'calibration_parameters'                        [] };

  %% Spectro and photometric 
  var_attr_list.temp_spectrophotometer_nitrate = {
    'long_name'               'Temperature of the spectrometer'
    'standard_name'           'temperature_of_optic_sensor_in_sea_water'
    'units'                   'degree_Celsius'
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

  var_attrtype_list.molar_doxy = 'single';
  var_attr_list.molar_doxy = {
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

  var_attrtype_list.temp_doxy = 'single';
  var_attr_list.temp_doxy = {
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


  var_attrtype_list.turbidity = 'single';
  var_attr_list.turbidity = {
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


  %% History parameters
  var_attr_list.n_history = {
    'long_name'            'Number of history records'
    'standard_name'        'n_history'};
  
  var_attr_list.history_institution = {
    'long_name'               'Institution which performed action'
    'standard_name'           'history_institution'
    'conventions'             'EGO reference table 4'
    'coordinates'             'n_history string2'
    '_FillValue'              ' '};
  
  var_attr_list.history_step = {
    'long_name'               'Step in data processing'
    'standard_name'           'history_step'
    'conventions'             'EGO reference table 12'
    'coordinates'             'n_history string4'
    '_FillValue'              ' '};
  
  var_attr_list.history_software = {
    'long_name'               'Name of software which performed action'
    'standard_name'           'history_software'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string8'
    '_FillValue'              ' '};
  
  var_attr_list.history_software_release = {
    'long_name'               'Version/release of software which performed action'
    'standard_name'           'history_software_release'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string4'
    '_FillValue'              ' '};
  
  var_attr_list.history_reference = {
    'long_name'               'Reference of database'
    'standard_name'           'history_reference'
    'conventions'             'Institution dependent'
    'coordinates'             'n_history string64'
    '_FillValue'              ' '};
  
  var_attr_list.history_date = {
    'long_name'               'Date the history record was created'
    'standard_name'           'history_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'n_history date_time'
    '_FillValue'              ' '};
  
  var_attr_list.history_action = {
    'long_name'               'Action performed on data'
    'standard_name'           'history_action'
    'conventions'             'EGO reference table 7'
    'coordinates'             'n_history string64'
    '_FillValue'              ' '};
  
  var_attr_list.history_parameter = {
    'long_name'               'Parameter action is performed on'
    'standard_name'           'history_parameter'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_history string16'
    '_FillValue'              ' '};
  
  var_attrtype_list.history_previous_value = 'single';
  var_attr_list.history_previous_value  = {
    'long_name'               'Parameter or flag previous value before action'
    'standard_name'           'history_previous_value'
    'conventions'             'EGO reference table 3'
    '_FillValue'              99999};
  
  var_attrtype_list.history_start_time_index = 'int32';
  var_attr_list.history_start_time_index = {
    'long_name'               'Start time index action applied on'
    'standard_name'           'history_start_time_index'
    'coordinates'             'n_history'
    '_FillValue'              99999};
  
  var_attrtype_list.history_stop_time_index = 'int32';
  var_attr_list.history_stop_time_index = {
    'long_name'               'Stop time index action applied on'
    'standard_name'           'history_stop_time_index'
    'coordinates'             'n_history'
    '_FillValue'              99999};
  
  var_attr_list.history_qctest = {
    'long_name'               'Documentation of tests performed, tests failed (in hex form)'
    'standard_name'           'history_qctest'
    'conventions'             'Write tests performed when ACTION=QCP$; tests failed when ACTION=QCF$'
    'coordinates'             'n_history string16'
    '_FillValue'              ' '};

  %% Glider characteristics parameter
  var_attr_list.n_param = {
    'long_name'            'Number of parameters measured or calculated during glider deployment'
    'standard_name'        'n_param'};
  var_attr_list.n_derivation = {
    'long_name'            'Maximum number of calibrations for a parameter'
    'standard_name'        'n_derivation'};
  var_attr_list.n_positioning_system = {
    'long_name'            'Number of positioning systems'
    'standard_name'        'n_positioning_system'};
  var_attr_list.n_trans_system = {
    'long_name'            'Number of transmission systems'
    'standard_name'        'n_trans_system'};
  
  var_attr_list.trans_system = {
    'long_name'               'Telecommunication system used'
    'standard_name'           'trans_system'
    'conventions'             'Write tests performed when ACTION=QCP$; tests failed when ACTION=QCF$'
    'coordinates'             'n_trans_system string16'
    '_FillValue'              ' '};
  
  var_attr_list.trans_system_id = {
    'long_name'               'Program identifier used by the transmission system'
    'standard_name'           'trans_system_id'
    'coordinates'             'n_trans_system string32'
    '_FillValue'              ' '};
  
  var_attr_list.trans_frequency = {
    'long_name'               'Frequency of transmission from the glider'
    'standard_name'           'trans_frequency'
    'units'                   'hertz'
    'coordinates'             'n_trans_system string16'
    '_FillValue'              ' '};
  
  var_attr_list.positioning_system = {
    'long_name'               'Positioning system'
    'standard_name'           'positioning_system'
    'coordinates'             'n_positioning_system string8'
    '_FillValue'              ' '};
  
  var_attr_list.platform_family = {
    'long_name'               'Category of instrument'
    'standard_name'           'platform_family'
    'conventions'             'EGO reference table 22'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.platform_type = {
    'long_name'               'Type of glider'
    'standard_name'           'platform_type'
    'conventions'             'EGO reference table XX'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.platform_maker = {
    'long_name'               'Name of the manufacturer'
    'standard_name'           'platform_maker'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.firmware_version_navigation = {
    'long_name'               'Firmware version of the navigation controller board'
    'standard_name'           'firmware_version_navigation'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.firmware_version_science = {
    'long_name'               'Firmware version of the scientific sensors controller board'
    'standard_name'           'firmware_version_science'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.manual_version = {
    'long_name'               'Manual version of the glider'
    'standard_name'           'manual_version'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.glider_serial_no = {
    'long_name'               'Serial number of the glider'
    'standard_name'           'glider_serial_no'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.standard_format_id = {
    'long_name'               'Standard format number which describes the data format type for each glider'
    'standard_name'           'standard_format_id'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.dac_format_id = {
    'long_name'               'Format number used by the DAC to describe the data format type for each glider'
    'standard_name'           'dac_format_id'
    'coordinates'             'string16'
    '_FillValue'              ' '};
  
  var_attr_list.wmo_inst_type = {
    'long_name'               'Coded instrument type'
    'standard_name'           'wmo_inst_type'
    'conventions'             'EGO reference table 8'
    'coordinates'             'string4'
    '_FillValue'              ' '};
  
  var_attr_list.project_name = {
    'long_name'               'Program under which the glider was deployed'
    'standard_name'           'project_name'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.data_centre = {
    'long_name'               'Data centre in charge of glider real-time processing'
    'standard_name'           'data_centre'
    'conventions'             'EGO reference table 4'
    'coordinates'             'string4'
    '_FillValue'              ' '};
  
  var_attr_list.pi_name = {
    'long_name'               'Name of the Principal Investigator'
    'standard_name'           'pi_name'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.anomaly = {
    'long_name'               'Describe any anomalies or problems the glider may have had'
    'standard_name'           'anomaly'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.battery_type = {
    'long_name'               'Type of battery packs in the glider'
    'standard_name'           'battery_type'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.battery_packs = {
    'long_name'               'Configuration of battery packs in the glider'
    'standard_name'           'battery_packs'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.special_features = {
    'long_name'               'Extra features of the glider (algorithms, compressee etc.)'
    'standard_name'           'special_features'
    'coordinates'             'string1024'
    '_FillValue'              ' '};
  
  var_attr_list.glider_owner = {
    'long_name'               'Glider owner'
    'standard_name'           'glider_owner'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.operating_institution = {
    'long_name'               'Operating institution of the glider'
    'standard_name'           'operating_institution'
    'coordinates'             'string64'
    '_FillValue'              ' '};
  
  var_attr_list.customization = {
    'long_name'               'Glider customization, i.e. (institutionand modifications)'
    'standard_name'           'customization'
    'coordinates'             'string1024'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_start_date = {
    'long_name'               'Date (UTC) of the deployment'
    'standard_name'           'deployment_start_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'date_time'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_start_latitude = {
    'long_name'               'Latitude of the glider when deployed'
    'standard_name'           'deployment_start_latitude'
    'units'                   'degree_north'
    'valid_min'               -90
    'valid_max'               90
    '_FillValue'              99999};
  
  var_attr_list.deployment_start_longitude = {
    'long_name'               'Longitude of the glider when deployed'
    'standard_name'           'deployment_start_longitude'
    'units'                   'degree_east'
    'valid_min'               -180
    'valid_max'               180
    '_FillValue'              99999};
    
  var_attr_list.deployment_platform = {
    'long_name'               'Identifier of the deployment platform'
    'standard_name'           'deployment_platform'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_cruise_id = {
    'long_name'               'Identifier of the cruise that deployed the glider'
    'standard_name'           'deployment_cruise_id'
    'coordinates'             'string32'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_reference_station_id = {
    'long_name'               'Identifier of stations used to verify the parameter measurements'
    'standard_name'           'deployment_reference_station_id'
    'coordinates'             'string256'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_end_date = {
    'long_name'               'Date (UTC) of the glider recovery'
    'standard_name'           'deployment_end_date'
    'conventions'             'YYYYMMDDHHMISS'
    'coordinates'             'date_time'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_end_latitude = {
    'long_name'               'Latitude of the glider recovery'
    'standard_name'           'deployment_end_latitude'
    'units'                   'degree_north'
    'valid_min'               -90
    'valid_max'               90
    '_FillValue'              99999};
  
  var_attr_list.deployment_end_longitude = {
    'long_name'               'Longitude of the glider recovery'
    'standard_name'           'deployment_end_longitude'
    'units'                   'degree_east'
    'valid_min'               -180
    'valid_max'               180
    '_FillValue'              99999};
  
  var_attr_list.deployment_end_status = {
    'long_name'               'Status of the end of mission of the glider'
    'standard_name'           'deployment_end_status'
    'conventions'             'R: retrieved, L: lost'
    '_FillValue'              ' '};
  
  var_attr_list.deployment_operator = {
    'long_name'               'Name of the person in charge of the glider deployment'
    'standard_name'           'deployment_operator'
    '_FillValue'              ' '};
  
  var_attr_list.sensor = {
    'long_name'               'List of sensors on the glider'
    'standard_name'           'sensor'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_param, string64'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_maker = {
    'long_name'               'Name of the sensor manufacturer'
    'standard_name'           'sensor_maker'
    'coordinates'             'n_param, string256'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_model = {
    'long_name'               'Model of the sensor'
    'standard_name'           'sensor_model'
    'coordinates'             'n_param, string256'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_serial_no = {
    'long_name'               'Serial number of the sensor'
    'standard_name'           'sensor_serial_no'
    'coordinates'             'n_param, string16'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_units = {
    'long_name'               'Units of the parameter measured by the sensor'
    'standard_name'           'sensor_units'
    'coordinates'             'n_param, string16'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_accuracy = {
    'long_name'               'Accuracy of the parameter measured by the sensor'
    'standard_name'           'sensor_accuracy'
    'coordinates'             'n_param, string32'
    '_FillValue'              ' '};
  
  var_attr_list.sensor_resolution = {
    'long_name'               'Resolution of the parameter measured by the sensor'
    'standard_name'           'sensor_resolution'
    'coordinates'             'n_param, string32'
    '_FillValue'              ' '};
  
  var_attr_list.derivation_parameter = {
    'long_name'               'List of parameters with derivation or calibration information'
    'standard_name'           'derivation_parameter'
    'conventions'             'EGO reference table 3'
    'coordinates'             'n_derivation, string64'
    '_FillValue'              ' '};
  
  var_attr_list.derivation_equation = {
    'long_name'               'Derivation or calibration equation for this parameter'
    'standard_name'           'derivation_equation'
    'coordinates'             'n_derivation, string256'
    '_FillValue'              ' '};
  
  var_attr_list.derivation_coefficient = {
    'long_name'               'Derivation or calibration coeffcicients for this equation'
    'standard_name'           'derivation_coefficient'
    'coordinates'             'n_derivation, string512'
    '_FillValue'              ' '};
  
  var_attr_list.derivation_comment = {
    'long_name'               'Comment applying to this parameter derivation or calibration'
    'standard_name'           'derivation_comment'
    'coordinates'             'n_derivation, string256'
    '_FillValue'              ' '};
  
  var_attr_list.derivation_date = {
    'long_name'               'Date (UTC) of derivation or calibration'
    'standard_name'           'derivation_date'
    'coordinates'             'n_derivation, date_time'
    'conventions'             'YYYYMMDDHHMISS'
    '_FillValue'              ' '};
  

  %% Store dictionary values before adding QC so we can use the structures 
  %  to make the uncertainty variables
  var_attr = var_attr_list;
  
  %% Set QC variables
  [var_attr_list, var_attrtype_list] = completeQCDictionary(var_attr_list, var_attrtype_list, ...
                                  'qc_prefix', options.qc_prefix, 'qc_suffix', options.qc_suffix, ...
                                  'qc_attributes', options.qc_attributes, ...
                                  'qc_attribute_type', options.qc_attribute_type, ...
                                  'update_long_name', options.update_long_name);
  
  %% Special QC cases
  var_attr_list.time_gps_QC = {
    'long_name'            'Quality flag'
    'standard_name'        'time_gps_qc'
    'conventions'          'EGO reference table 2'
    'valid_min'            0
    'valid_max'            9
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'           -128};
                              
  var_attrtype_list.position_QC = 'int8';    
  var_attr_list.position_QC = {
    'long_name'            'Quality flag'
    'standard_name'        'position_qc'
    'conventions'          'EGO reference table 2'
    'valid_min'            0
    'valid_max'            9
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'           -128};
                    
  var_attrtype_list.position_gps_QC = 'int8';          
  var_attr_list.position_gps_QC = {
    'long_name'            'Quality flag'
    'standard_name'        'position_gps_qc'
    'conventions'          'EGO reference table 2'
    'valid_min'            0
    'valid_max'            9
    'flag_values'          [0,1,2,3,4,5,8,9]
    'flag_meanings'        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'           -128};

  var_attrtype_list.deployment_start_QC = 'int8';
  var_attr_list.deployment_start_QC = {
    'long_name'               'Quality on DEPLOYMENT_START date, time and location'
    'standard_name'           'deployment_start_date'
    'conventions'             'EGO reference table 2'
    'flag_values'             [0,1,2,3,4,5,8,9]
    'flag_meanings'           'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'              -128};

  var_attrtype_list.deployment_end_QC = 'int8';
  var_attr_list.deployment_end_QC = {
    'long_name'               'Quality on DEPLOYMENT_END date, time and location'
    'standard_name'           'deployment_end_qc'
    'conventions'             'EGO reference table 2'
    'flag_values'             [0,1,2,3,4,5,8,9]
    'flag_meanings'           'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed interpolated_value missing_value'
    '_FillValue'              -128};

  % Add axis to time_qc
  var_attr_list.time_QC(end+1,:) = {'axis', 'T'};
  
  
  %% Set Uncertainty variables
  [var_attr_list, var_attrtype_list] = completeUncertaintyDictionary(var_attr, var_attrtype_list, 'init_attr_list', var_attr_list, ...
                                       'uncertainty_attributes', options.uncertainty_attributes, ...
                                       'uncertainty_attribute_type', options.uncertainty_attribute_type, ...
                                       'uncertainty_prefix', options.uncertainty_prefix, ...
                                       'uncertainty_suffix', options.uncertainty_suffix);
  
end

