function [ var_attr, var_attrtype ] = Dictionary_SOCIBNetCDFL1Parameters(varargin)
%LISTNETCDFL1PARAMETERS  Create structure from the available parameter
%                         description
%
%  Syntax:
%    [ VAR_ATTR, VAR_ATTRTYPE ] = DICTIONARY_SOCIBNETCDFL1PARAMETERS()
%    [ VAR_ATTR, VAR_ATTRTYPE ] = DICTIONARY_SOCIBNETCDFL1PARAMETERS(OPTIONS)
%    [ VAR_ATTR, VAR_ATTRTYPE ] = DICTIONARY_SOCIBNETCDFL1PARAMETERS(OPT1, VAL1, ...)
%
%  Description:
%    [ VAR_ATTR, VAR_ATTRTYPE ] = DICTIONARY_SOCIBNETCDFL1PARAMETERS() 
%    should return a struct describing the structure of parameters of the NetCDF file. 
%    This function contains the definition of all available parameters of EGO
%    standards. 
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
%                  one used by SOCIB standards
%                 + long_name: Quality flag of [long_name of variable]
%                 + standard_name: Quality flag of [standard_name of variable]
%                 + quality_control_convention: SOCIB Quality control
%                 + comment: None
%                 + valid_min: 0
%                 + valid_max: 9
%                 + _FillValue: 0
%                 + QC_procedure: 1
%                 + flag_values: [0,1,2,3,4,8,9]
%                 + flag_meanings: no_qc_performed 
%                                  good_data 
%                                  probably_good_data
%                                  probably_bad_data 
%                                  bad_data
%                                  interpolated_value 
%                                  missing_value  
%             + QC_ATTRIBUTE_TYPE: [empty]
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
%    [ var_attr, var_attrtype ] = Dictionary_SOCIBNetCDFL1Parameters()
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
%  <http://www.es>
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
  
  options.qc_prefix = 'QC_';
  options.qc_suffix = '';
  options.qc_attributes  = {
    'long_name'                         'Quality flag'
    'standard_name'                     ''
    'quality_control_convention'        'SOCIB Quality control'
    'comment'                           'None'
    'valid_min'                         0
    'valid_max'                         9
    '_FillValue'                        -128
    'QC_procedure'                      '1'
    'flag_values'                       [0,1,2,3,4,8,9]
    'flag_meanings'                     'no_qc_performed good_data probably_good_data probably_bad_data bad_data interpolated_value missing_value'};
  options.qc_attribute_type = '';
  options.update_long_name = false;
  options.uncertainty_attributes = {
    'long_name'                         'Uncertainty'
    '_FillValue'                        99999
    'units'                             'n/a'};
  options.uncertainty_attribute_type = 'single';
  options.uncertainty_prefix = 'UNCERTAINTY_';
  options.uncertainty_suffix = '';

    
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
    'long_name'     'navigation epoch time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'axis'          'T'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                [] };

  %% Depth parameter         
  var_attr_list.depth = {
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
  var_attr_list.latitude = {
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

  var_attr_list.longitude = {
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
      
  %% Motion and orientation
  var_attr_list.heading = {
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

  var_attr_list.roll = {
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

  var_attr_list.pitch = {
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
  var_attr_list.waypoint_latitude = {
    'long_name'     'waypoint latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.waypoint_longitude = {
    'long_name'     'waypoint longitude'
    'standard_name' 'longitude'
    'units'         'degree_east'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'conversion'                                    []
    'filling'                                       [] };

  var_attr_list.distance_over_ground = {
    'long_name'     'distance over ground flown since mission start'
    'standard_name' 'distance'
    'units'         'km'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.transect_index = {
    'long_name'     'transect index'
    'standard_name' ''
    'units'         '1'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  var_attr_list.profile_index = {
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

  var_attr_list.profile_direction = {
    'long_name'     'glider vertical speed direction'
    'standard_name' ''
    'units'         '1'
    'comment'       '-1 = ascending, 0 = inflecting or stalled, 1 = descending'
    'coordinates'   'time latitude longitude depth'
    '_FillValue'    default_fill_value
    'glider_original_parameter_name'                [] 
    'sources'                                       []
    'method'                                        [] };

  %%%%%%%%%%%%%%%%%%%%
  %% Data Parameters
  %%%%%%%%%%%%%%%%%%%%
  
  %% Conductivity      
  var_attr_list.conductivity = {
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
  var_attr_list.temperature = {
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
  var_attr_list.pressure = {
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
  var_attr_list.time_ctd = {
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

  var_attr_list.depth_ctd = {
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
  var_attr_list.temperature_corrected_sensor = {
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

  var_attr_list.temperature_corrected_thermal = {
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

  var_attr_list.conductivity_corrected_sensor = {
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

  var_attr_list.conductivity_corrected_thermal = {
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
  var_attr_list.salinity = {
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

  var_attr_list.salinity_corrected_thermal = {
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

  var_attr_list.salinity_corrected_sensor = {
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

  var_attr_list.salinity_corrected_sensor_thermal = {
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
  var_attr_list.density = {
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

  var_attr_list.density_corrected_thermal = {
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

  var_attr_list.density_corrected_sensor = {
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

  var_attr_list.density_corrected_sensor_thermal = {
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
  var_attr_list.potential_temperature = {
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

  var_attr_list.potential_density = {
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
  var_attr_list.backscatter_470 = {
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

  var_attr_list.backscatter_532 = {
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

  var_attr_list.backscatter_660 = {
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

  var_attr_list.backscatter_700 = {
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

  var_attr_list.backscatter = {
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

  var_attr_list.turbidity = {
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

  var_attr_list.scatter_650 = {
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
  var_attr_list.chlorophyll = {
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

  var_attr_list.cdom = {
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
  var_attr_list.temperature_optics = {
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

  var_attr_list.time_optics = {
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
  var_attr_list.oxygen_concentration = {
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

  var_attr_list.oxygen_saturation = {
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

  var_attr_list.oxygen_frequency = {
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

  var_attr_list.time_oxygen = {
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

  var_attr_list.temperature_oxygen = {
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
  var_attr_list.irradiance_412 = {
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

  var_attr_list.irradiance_442 = {
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

  var_attr_list.irradiance_491 = {
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

  var_attr_list.irradiance_664 = {
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

  var_attr_list.water_velocity_eastward = {
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
  var_attr_list.sound_velocity = {
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

  var_attr_list.water_velocity_northward = {
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
  var_attr_list.fluorescence_270_340 = {
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

  var_attr_list.fluorescence_255_360 = {
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

  var_attr_list.fluorescence_monitoring_270_340 = {
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

  var_attr_list.fluorescence_monitoring_255_360 = {
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

  var_attr_list.fluorescence_260_315 = {
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

  var_attr_list.fluorescence_270_376 = {
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

  var_attr_list.fluorescence_monitoring_260_315 = {
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

  var_attr_list.fluorescence_monitoring_270_376 = {
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

  var_attr_list.methane_concentration = {
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

  
  %% Set QC variables
  %[var_attr, var_attrtype] = completeQCDictionary(var_attr_list, var_attrtype_list);
  [var_attr, var_attrtype] = completeQCDictionary(var_attr_list, var_attrtype_list, ...
                                  'qc_prefix', options.qc_prefix, 'qc_suffix', options.qc_suffix, ...
                                  'qc_attributes', options.qc_attributes, ...
                                  'qc_attribute_type', options.qc_attribute_type, ...
                                  'update_long_name', options.update_long_name);
  
  %% Set Uncertainty variables
  [var_attr, var_attrtype] = completeUncertaintyDictionary(var_attr_list, var_attrtype, 'init_attr_list', var_attr, ...
                                       'uncertainty_attributes', options.uncertainty_attributes, ...
                                       'uncertainty_attribute_type', options.uncertainty_attribute_type, ...
                                       'uncertainty_prefix', options.uncertainty_prefix, ...
                                       'uncertainty_suffix', options.uncertainty_suffix);
                                   
end

