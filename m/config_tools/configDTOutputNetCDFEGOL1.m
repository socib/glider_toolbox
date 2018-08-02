function ncl1_info = configDTOutputNetCDFEGOL1()
%CONFIGDTOUTPUTNETCDFEGOL1  Configure NetCDF output for processed glider deployment data in delayed time.
%
%  Syntax:
%    NCL1_INFO = CONFIGDTOUTPUTNETCDFEGOL1()
%
%  Description:
%    NCL1_INFO = CONFIGDTOUTPUTNETCDFEGOL1() should return a struct
%    describing the structure of the NetCDF file for processed glider
%    deployment data in delayed time (see the note about the file generation).
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
%    ncl1_info = configDTOutputNetCDFEGOL1()
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
  time_gps_dimension = struct('name', {'TIME_GPS'}, ...
                          'length', {1});
  n_history_dimension = struct('name', {'N_HISTORY'}, ...
                          'length', {1});
  n_param_dimension = struct('name', {'N_PARAM'}, ...
                          'length', {1});
  n_trans_system_dimension = struct('name', {'N_TRANS_SYSTEM'}, ...
                          'length', {1});
  n_positioning_system_dimension = struct('name', {'N_POSITIONING_SYSTEM'}, ...
                          'length', {1});
  n_derivation_dimension = struct('name', {'N_DERIVATION'}, ...
                          'length', {1});
  date_time_dimension = struct('name', {'DATE_TIME'}, ...
                          'length', {14});
  string1024_dimension = struct('name', {'STRING1024'}, ...
                          'length', {1024});
  string512_dimension = struct('name', {'STRING512'}, ...
                          'length', {512});
  string256_dimension = struct('name', {'STRING256'}, ...
                          'length', {256});
  string64_dimension = struct('name', {'STRING64'}, ...
                          'length', {64});
  string32_dimension = struct('name', {'STRING32'}, ...
                          'length', {32});
  string16_dimension = struct('name', {'STRING16'}, ...
                          'length', {16});
  string8_dimension = struct('name', {'STRING8'}, ...
                          'length', {8});
  string4_dimension = struct('name', {'STRING4'}, ...
                          'length', {4});
  string2_dimension = struct('name', {'STRING2'}, ...
                          'length', {2});
                        
  %% Define variable information.
  % To define the variable attributes easily and readably, add the corresponding
  % variable field to the struct defined below, with its attributes defined in
  % a cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.
  
  param_list = ...
       struct('ego', ...
              {{'time', 'time_gps', 'juld', ...
                'depth', 'latitude', 'longitude', ...
                'latitude_gps', 'longitude_gps', ...
                'time_gps_qc', 'position_gps_qc', ...
                'phase', 'phase_number', 'positioning_method', ...
                'cndc', 'temp', 'pres', 'psal', 'chla', ...
                'temp_doxy', 'molar_doxy', ...
                'temp_spectrophotometer_nitrate', ...
                'n_history', 'history_institution', 'history_step', 'history_software', ...
                'history_software_release', 'history_reference', 'history_date', 'history_action', ...
                'history_parameter', 'history_previous_value', 'history_start_time_index', ...
                'history_stop_time_index', 'history_qctest', ...
                'n_param', 'n_derivation', 'n_positioning_system', 'n_trans_system', ...
                'trans_system', 'trans_system_id', 'trans_frequency', 'positioning_system', ...
                'platform_family', 'platform_type', 'platform_maker', ...
                'firmware_version_navigation', 'firmware_version_science', 'manual_version', ...
                'glider_serial_no', 'standard_format_id', 'dac_format_id', 'wmo_inst_type', ...
                'project_name', 'data_centre', 'pi_name', 'anomaly', ...
                'battery_type', 'battery_packs', 'special_features', ...
                'glider_owner', 'operating_institution', 'customization', ...
                'deployment_start_date', 'deployment_start_latitude', 'deployment_start_longitude', ...
                'deployment_start_qc', 'deployment_platform', ...
                'deployment_cruise_id', 'deployment_reference_station_id', ...
                'deployment_end_date', 'deployment_end_latitude', 'deployment_end_longitude', ...
                'deployment_end_qc', 'deployment_end_status', 'deployment_operator', ...
                'sensor', 'sensor_maker', 'sensor_model', 'sensor_serial_no', ...
                'sensor_units', 'sensor_accuracy', 'sensor_resolution', ...
                'derivation_parameter', 'derivation_equation', 'derivation_coefficient', ...
                'derivation_comment', 'derivation_date'}}, ...
              'socib', ...  
              {{'time', 'QC_time', ... 
                'depth', 'QC_depth', ...
                'latitude', 'QC_latitude', ...
                'longitude', 'QC_longitude', ...
                'heading', ...
                'roll', ...
                'pitch', ...
                'waypoint_latitude', 'QC_waypoint_latitude', ...
                'waypoint_longitude', 'QC_waypoint_longitude'...
                'distance_over_ground', ...
                'transect_index', ...
                'profile_index', ...
                'profile_direction', ...
                'conductivity', 'QC_conductivity', ...
                'temperature', 'QC_temperature', ...
                'pressure', 'QC_pressure', ...
                'time_ctd', 'QC_time_ctd', ...
                'depth_ctd', 'QC_depth_ctd', ...                
                'temperature_corrected_sensor', 'QC_temperature_corrected_sensor', ...
                'temperature_corrected_thermal', 'QC_temperature_corrected_thermal', ...
                'conductivity_corrected_sensor', 'QC_conductivity_corrected_sensor', ...
                'conductivity_corrected_thermal', 'QC_conductivity_corrected_thermal', ...
                'salinity', 'QC_salinity', ...
                'salinity_corrected_thermal', 'QC_salinity_corrected_thermal', ...
                'salinity_corrected_sensor', 'QC_salinity_corrected_sensor', ...
                'salinity_corrected_sensor_thermal', 'QC_salinity_corrected_sensor_thermal', ...
                'density', 'QC_density', ...
                'density_corrected_thermal', 'QC_density_corrected_thermal', ...
                'density_corrected_sensor', 'QC_density_corrected_sensor', ...
                'density_corrected_sensor_thermal', 'QC_density_corrected_sensor_thermal', ...
                'potential_temperature', 'QC_potential_temperature', ...
                'potential_density', 'QC_potential_density', ...
                'sound_velocity', 'QC_sound_velocity', ...
                'backscatter_470', 'QC_backscatter_470', ...
                'backscatter_532', 'QC_backscatter_532', ...
                'backscatter_660', 'QC_backscatter_660', ...
                'backscatter_700', 'QC_backscatter_700', ... 
                'backscatter', 'QC_backscatter', ...
                'chlorophyll', 'QC_chlorophyll', ...
                'turbidity', 'QC_turbidity', ...
                'cdom', 'QC_cdom', ...
                'scatter_650', 'QC_scatter_650', ...
                'temperature_optics', 'QC_temperature_optics', ...
                'time_optics', 'QC_time_optics', ...
                'oxygen_concentration', 'QC_oxygen_concentration', ...
                'oxygen_saturation', 'QC_oxygen_saturation', ...
                'oxygen_frequency', 'QC_oxygen_frequency', ...
                'time_oxygen', 'QC_time_oxygen', ...
                'temperature_oxygen', 'QC_temperature_oxygen', ...
                'irradiance_412', 'QC_irradiance_412', ...
                'irradiance_442', 'QC_irradiance_442', ...
                'irradiance_491', 'QC_irradiance_491', ...
                'irradiance_664', 'QC_irradiance_664', ...
                'water_velocity_eastward', 'QC_water_velocity_eastward', ...
                'water_velocity_northward', 'QC_water_velocity_northward'...
                'fluorescence_270_340', 'QC_fluorescence_270_340', ...
                'fluorescence_255_360', 'QC_fluorescence_255_360', ...
                'fluorescence_monitoring_270_340', 'QC_fluorescence_monitoring_270_340', ...
                'fluorescence_monitoring_255_360', 'QC_fluorescence_monitoring_255_360', ...
                'fluorescence_260_315', 'QC_fluorescence_260_315', ...
                'fluorescence_270_376', 'QC_fluorescence_270_376', ...
                'fluorescence_monitoring_260_315', 'QC_fluorescence_monitoring_260_315', ...
                'fluorescence_monitoring_270_376', 'QC_fluorescence_monitoring_270_376', ...
                'methane_concentration', 'QC_methane_concentration'}});
              

  %% Define global attributes (they may be overwritten with deployment values).
  % To define the global attributes easily and readably, add them to this
  % cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.
  global_atts = ...
  {
    'abstract'                     '' % deployment_description
    'acknowledgement'              '' % deployment_acknowledgement
    'area'                         ''
    'author'                       '' % deployment_author
    'author_email'                 '' % deployment_author_email
    'cdm_data_type'                'Trajectory'
    'citation'                     '' % deployment_citation
    'comment'                      'Data regularized, corrected and/or derived from raw glider data.'
    'Conventions'                  'CF-1.4 EGO-1.2'
    'creator'                      '' % deployment_author
    'creator_email'                '' % deployment_author_email
    'creator_url'                  '' % deployment_author_url
    'data_assembly_center'         'SCB'
    'data_center'                  '' % deployment_data_center
    'data_center_email'            '' % deployment_data_center_email
    'data_mode'                    'D'
    'data_type'                    'EGO glider time-series data'
    'date_update'                  'undefined'
    'deployment_code'              'TBD'
    'deployment_label'             ''
    'distribution_statement'       'see citation'
    'featureType'                  'trajectory'
    'format_version'               '1.2'
    'geospatial_lat_max'           'undefined'
    'geospatial_lat_min'           'undefined'
    'geospatial_lat_units'         'undefined'
    'geospatial_lon_max'           'undefined'
    'geospatial_lon_min'           'undefined'
    'geospatial_lon_units'         'undefined'
    'history'                      sprintf('Product generated by the glider toolbox version %s (https://github.com/socib/glider_toolbox).', configGliderToolboxVersion())
    'ices_platform_code'           ''
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
    'qc_manual'                    'none'
    'quality_index'                'unknown quality'
    'sdn_edmo_code'                '3410'
    'source'                       'Glider observation'
    'source_files'                 'undefined' % source_files field set by processing script after loading data.
    'standard_name_vocabulary'     'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/16/cf-standard-name-table.html'
    'summary'                      '' % deployment_description
    'time_coverage_end'            'undefined'
    'time_coverage_start'          'undefined'
    'title'                        'Glider deployment delayed time processed data'
    'transmission_system'          'IRIDIUM'
    'update_interval'              'void'
    'wmo_platform_code'            '830'
  };



  %% Global attributes required only contains the attributes with the required values (no empty or undefined)
  global_atts_required = ...
  {
    'cdm_data_type'                'Trajectory'
    'comment'                      'Data regularized, corrected and/or derived from raw glider data.'
    'Conventions'                  'CF-1.4 EGO-1.2'
    'data_assembly_center'         'SCB'
    'data_mode'                    'D'
    'data_type'                    'EGO glider time-series data'
    'history'                      sprintf('Product generated by the glider toolbox version %s (https://github.com/socib/glider_toolbox).', configGliderToolboxVersion())
    'naming_authority'             'EGO'
    'netcdf_version'               '4.1.3'
    'processing_level'             'L1 processed data with corrections and derivations'
    'standard_name_vocabulary'     'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/16/cf-standard-name-table.html'
  };


  %% Return global and variable metadata in the correct format.
  ncl1_info = struct();
  % Set the dimensions.
  ncl1_info.dimensions = time_dimension; 
  % Set the global attributes.
  ncl1_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  
  ncl1_info.attributes_required = cell2struct(global_atts_required, {'name' 'value'}, 2);
  
  
  % Set the variable metadata.
  ego_qc_attributes = {
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

  ego_uncertainty_attributes = {
    'long_name'                         'Uncertainty'
    '_FillValue'                        99999
    'units'                             'n/a'}; 
   
  ncl1_info.variables = listNetCDFL1Parameters('', '_QC', ...
                                  ego_qc_attributes, 'int8', false, ...
                                  '', '_UNCERTAINTY', ...
                                  ego_uncertainty_attributes, 'single', ...
                                  time_dimension.name, param_list);  

  %% Set GPS dimessions
  % GPS variables are a special case. We could generalize this but it is a
  % simple way to make it work for now
  ncl1_info.variables.time_gps.dimensions = {time_gps_dimension.name};
  ncl1_info.variables.time_gps_qc.dimensions = {time_gps_dimension.name};
  ncl1_info.variables.latitude_gps.dimensions = {time_gps_dimension.name};
  ncl1_info.variables.longitude_gps.dimensions = {time_gps_dimension.name};
  ncl1_info.variables.position_gps_qc.dimensions = {time_gps_dimension.name};
  
  %% Set history dimensions 
  ncl1_info.variables.history_institution.dimensions = {n_history_dimension.name, string2_dimension.name};
  ncl1_info.variables.history_step.dimensions = {n_history_dimension.name, string4_dimension.name};
  ncl1_info.variables.history_software.dimensions = {n_history_dimension.name, string8_dimension.name};
  ncl1_info.variables.history_software_release.dimensions = {n_history_dimension.name, string4_dimension.name};
  ncl1_info.variables.history_reference.dimensions = {n_history_dimension.name, string64_dimension.name};
  ncl1_info.variables.history_date.dimensions = {n_history_dimension.name, date_time_dimension.name};
  ncl1_info.variables.history_action.dimensions = {n_history_dimension.name, string64_dimension.name};
  ncl1_info.variables.history_parameter.dimensions = {n_history_dimension.name, string16_dimension.name};
  ncl1_info.variables.history_previous_value.dimensions = {n_history_dimension.name};
  ncl1_info.variables.history_start_time_index.dimensions = {n_history_dimension.name};
  ncl1_info.variables.history_stop_time_index.dimensions = {n_history_dimension.name};
  ncl1_info.variables.history_qctest.dimensions = {n_history_dimension.name, string16_dimension.name};
  
  %% Set glider metadata dimensions
  ncl1_info.variables.trans_system.dimensions = {n_trans_system_dimension.name, string16_dimension.name};
  ncl1_info.variables.trans_system_id.dimensions = {n_trans_system_dimension.name, string32_dimension.name};
  ncl1_info.variables.trans_frequency.dimensions = {n_trans_system_dimension.name, string16_dimension.name};
  
  ncl1_info.variables.positioning_system.dimensions = {n_positioning_system_dimension.name, string8_dimension.name};
  
  ncl1_info.variables.platform_family.dimensions = {string256_dimension.name};
  ncl1_info.variables.platform_type.dimensions = {string32_dimension.name};
  ncl1_info.variables.platform_maker.dimensions = {string256_dimension.name};
  ncl1_info.variables.firmware_version_navigation.dimensions = {string16_dimension.name};
  ncl1_info.variables.firmware_version_science.dimensions = {string16_dimension.name};
  ncl1_info.variables.manual_version.dimensions = {string16_dimension.name};
  
  ncl1_info.variables.glider_serial_no.dimensions = {string16_dimension.name};
  ncl1_info.variables.standard_format_id.dimensions = {string16_dimension.name};
  ncl1_info.variables.dac_format_id.dimensions = {string16_dimension.name};
  ncl1_info.variables.wmo_inst_type.dimensions = {string4_dimension.name};
  ncl1_info.variables.project_name.dimensions = {string64_dimension.name};
  ncl1_info.variables.data_centre.dimensions = {string2_dimension.name};
  ncl1_info.variables.pi_name.dimensions = {string64_dimension.name};
  ncl1_info.variables.anomaly.dimensions = {string256_dimension.name};
  ncl1_info.variables.battery_type.dimensions = {string64_dimension.name};
  ncl1_info.variables.battery_packs.dimensions = {string64_dimension.name};
  ncl1_info.variables.special_features.dimensions = {string1024_dimension.name};
  ncl1_info.variables.glider_owner.dimensions = {string64_dimension.name};
  ncl1_info.variables.operating_institution.dimensions = {string64_dimension.name};
  ncl1_info.variables.customization.dimensions = {string1024_dimension.name};
  ncl1_info.variables.deployment_start_date.dimensions = {date_time_dimension.name};
  ncl1_info.variables.deployment_platform.dimensions = {string32_dimension.name};
  ncl1_info.variables.deployment_cruise_id.dimensions = {string32_dimension.name};
  ncl1_info.variables.deployment_reference_station_id.dimensions = {string256_dimension.name};
  ncl1_info.variables.deployment_end_date.dimensions = {date_time_dimension.name};
  ncl1_info.variables.deployment_operator.dimensions = {string256_dimension.name};
  
  ncl1_info.variables.sensor.dimensions = {n_param_dimension.name, string64_dimension.name};
  ncl1_info.variables.sensor_maker.dimensions = {n_param_dimension.name, string256_dimension.name};
  ncl1_info.variables.sensor_model.dimensions = {n_param_dimension.name, string256_dimension.name};
  ncl1_info.variables.sensor_serial_no.dimensions = {n_param_dimension.name, string16_dimension.name};
  ncl1_info.variables.sensor_units.dimensions = {n_param_dimension.name, string16_dimension.name};
  ncl1_info.variables.sensor_accuracy.dimensions = {n_param_dimension.name, string32_dimension.name};
  ncl1_info.variables.sensor_resolution.dimensions = {n_param_dimension.name, string32_dimension.name};
                    
  ncl1_info.variables.derivation_parameter.dimensions = {n_derivation_dimension.name, string64_dimension.name};
  ncl1_info.variables.derivation_equation.dimensions = {n_derivation_dimension.name, string256_dimension.name};
  ncl1_info.variables.derivation_coefficient.dimensions = {n_derivation_dimension.name, string512_dimension.name};
  ncl1_info.variables.derivation_comment.dimensions = {n_derivation_dimension.name, string256_dimension.name};
  ncl1_info.variables.derivation_date.dimensions = {n_derivation_dimension.name, date_time_dimension.name};
  
  % Note: The dimension length will be set by generateOutputNetCDF
  %       depending on the number of items in each of these variables
  
  %% Set other EGO dimensions
  ncl1_info.dimensions(end+1) = date_time_dimension;
  ncl1_info.dimensions(end+1) = string1024_dimension;  
  ncl1_info.dimensions(end+1) = string512_dimension;   
  ncl1_info.dimensions(end+1) = string256_dimension;    
  ncl1_info.dimensions(end+1) = string64_dimension;  
  ncl1_info.dimensions(end+1) = string32_dimension;  
  ncl1_info.dimensions(end+1) = string16_dimension;  
  ncl1_info.dimensions(end+1) = string8_dimension;  
  ncl1_info.dimensions(end+1) = string4_dimension;  
  ncl1_info.dimensions(end+1) = string2_dimension; 
  
  
  %% Set coordinates for EGO (uppercase) and DM_indicator to R
  var_list = fieldnames(ncl1_info.variables);
  for idx_var = 1:numel(var_list)
     var_name = var_list(idx_var);
     if isfield(ncl1_info.variables, var_name{1}) && ...
             isfield(ncl1_info.variables.(var_name{1}), 'attributes')
         attr_list = ncl1_info.variables.(var_name{1}).attributes;
         for idx_attr = 1:numel(attr_list)
             if  strcmp(attr_list(idx_attr).name, 'coordinates')
                 coordval = ncl1_info.variables.(var_name{1}).attributes(idx_attr).value;
                 if any([strfind(coordval, 'time'), strfind(coordval, 'TIME')]) && ...
                    any([strfind(coordval, 'latitude'), strfind(coordval, 'LATITUDE')]) && ...
                    any([strfind(coordval, 'longitude'), strfind(coordval, 'LONGITUDE')]) && ...
                    any([strfind(coordval, 'depth'), strfind(coordval, 'DEPTH')]) 
                    
                    ncl1_info.variables.(var_name{1}).attributes(idx_attr).value = 'TIME LATITUDE LONGITUDE PRES'; %upper(attr_list(idx_attr).value);
                 end
            end
             if  strcmp(attr_list(idx_attr).name, 'DM_indicator')
               ncl1_info.variables.(var_name{1}).attributes(idx_attr).value = 'D';
            end
         end
     end
  end
  
end
