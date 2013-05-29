function nc_l0_info = configDTOutputNetCDFL0()
%CONFIGDTOUTPUTNETCDFL0  Configure NetCDF output for raw glider deployment data in delayed time.
%
%  NC_L0_INFO = CONFIGDTOUTPUTNETCDFL0() should return a struct describing the
%  structure of the NetCDF file for raw glider deployment data in delayed time 
%  (see the note about the file generation for more details).
%  The returned struct should have the following fields:
%    DIM_NAMES: struct with string fields defining the dimension names.
%      The size of the dimensions are inferred from the data during the
%      processing, so only dimension names need to be provided. It should have
%      the following fields:
%        TIME: time dimension name.
%    GLOBAL_ATTS: A struct array with fields 'NAME' and 'VALUE' defining global
%      attributes of the file.
%    VAR_META: A struct defining variable metadata. Field names are variable
%      names and field values are structs as needed by function WRITENETCDFDATA.
%      They should have the following fields:
%        DIMENSIONS: string cell array with the name of the dimensions of the
%          variable.
%        ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining the
%          attributes of the variable.
%      More variables than the ones present in one specific deployment may be
%      described here. Only metadata corresponding variables in the deployment
%      data will be used.
%
%  Notes:
%    The NetCDF file will be created by the function GENERATEOUTPUTNETCDFL0 with
%    the metadata provided here and the data returned by PREPROCESSGLIDERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    nc_l0_info = configDTOutputNetCDFL0()
%
%  See also:
%    GENERATENETCDFL0
%    WRITENETCDFDATA
%    PREPROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  %% Define variable information.
  % To define the variable attributes easily and readably, add the corresponding
  % variable field to the struct defined below, with its attributes defined in 
  % a cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by WRITENETCDFDATA.

  default_fill_value = realmax('double');

  % Navigation time.
  var_attr_list.m_present_time = { 
    'long_name'     'epoch time (navigation board)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'  
    '_FillValue'    default_fill_value };

  % Navigation data.
  var_attr_list.m_lat = {
    'long_name'     'latitude (dead reckoned)'
    'standard_name' 'latitude'
    'units'         'degree_north'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_lon = {
    'long_name'     'longitude (dead reckoned)'
    'standard_name' 'longitude'
    'units'         'degree_east'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_lat = {
    'long_name'     'latitude (GPS fix)'
    'standard_name' 'latitude'
    'units'         'degree_north'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_lon = {
    'long_name'     'longitude (GPS fix)'
    'standard_name' 'longitude'
    'units'         'degree_east'  
    '_FillValue'    default_fill_value };

  var_attr_list.c_wpt_lat = {
    'long_name'     'next waypoint latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'  
    '_FillValue'    default_fill_value };

  var_attr_list.c_wpt_lon = {
    'long_name'     'next waypoint longitude'
    'standard_name' 'longitude'
    'units'         'degree_east'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_speed = {
    'long_name'     'glider speed through water'
    'standard_name' 'speed'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_pitch = {
    'long_name'     'glider pitch angle'
    'standard_name' 'pitch'
    'units'         'rad'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_roll = {
    'long_name'     'glider roll'
    'standard_name' 'roll'
    'units'         'rad'
    'comments'      'greater than 0 is port wing up'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_fin = {
    'long_name'     'glider rudder'
    'standard_name' 'fin_position'
    'units'         'rad'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_heading = {
    'long_name'     'glider heading'
    'standard_name' 'heading'
    'units'         'rad'  
    '_FillValue'    default_fill_value };

  var_attr_list.c_heading = {
    'long_name'     'glider commanded heading'
    'standard_name' 'heading'
    'units'         'rad'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_depth = {
    'long_name'     'glider measured depth'
    'standard_name' 'depth'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  var_attr_list.x_inflecting = {
    'long_name'     'glider inflecting marker'
    'standard_name' 'inflection'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_num_half_yos_in_segment = {
    'long_name'     'glider half yos number in segment'
    'standard_name' 'half_yos_number'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_tot_num_inflections = {
    'long_name'     'total number of inflections'
    'standard_name' 'half_yos_number'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_battery = {
    'long_name'     'battery voltage'
    'standard_name' 'voltage'
    'units'         'V'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_vacuum = {
    'long_name'     'vacuum'
    'standard_name' 'vacuum'
    'units'         'inHg'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_leakdetect_voltage = {
    'long_name'     'leak detector'
    'standard_name' 'leak'
    'units'         'V'
    'comments'      '2.5V means no leak; voltage drops if leak detected'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_call_num = {
    'long_name'     'number of iridium calls'
    'standard_name' 'number_of_iridium_calls'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_connected = {
    'long_name'     'iridium connected'
    'standard_name' 'iridium_connected'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_iridium_dialed_num = {
    'long_name'     'number of iridium dials'
    'standard_name' 'number_of_iridium_dials'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.x_dr_state = {
    'long_name'     'dead reckoning state'
    'standard_name' 'dead_reckoning_state'
    'units'         '1'
    'comments'      '0 = mission_start, 1 = underwater, 2 = awaiting_fix, 3 = awaiting_postfix, 4 = awaiting_dive'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_fix_time = {
    'long_name'     'dead reckoning fix time'
    'standard_name' 'dead_reckoning_fix_time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_dr_postfix_time = {
    'long_name'     'dead reckoning postfix time'
    'standard_name' 'dead_reckoning_postfix_time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_fix_x_lmc = {
    'long_name'     'x gps fix in local mission coordinates'
    'standard_name' 'x_gps_fix_in_local_mission_coordinates'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_fix_y_lmc = {
    'long_name'     'y gps fix in local mission coordinates'
    'standard_name' 'y_gps_fix_in_local_mission_coordinates'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_postfix_x_lmc = {
    'long_name'     'x gps postfix in local mission coordinates'
    'standard_name' 'x_gps_postfix_in_local_mission_coordinates'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_gps_postfix_y_lmc = {
    'long_name'     'y gps postfix in local mission coordinates'
    'standard_name' 'y_gps_postfix_in_local_mission_coordinates'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  % Navigation water information.
  var_attr_list.m_water_vx = {
    'long_name'     'eastward water current'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_vy = {
    'long_name'     'northward water current'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_initial_water_vx = {
    'long_name'     'initial eastward water current'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_initial_water_vy = {
    'long_name'     'initial northward water current'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_final_water_vx = {
    'long_name'     'final eastward water current'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_final_water_vy = {
    'long_name'     'final northward water current'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_delta_vx = {
    'long_name'     'delta eastward water current'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_delta_vy = {
    'long_name'     'delta northward water current'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.x_prior_seg_water_vx = {
    'long_name'     'prior segment eastward water current'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.x_prior_seg_water_vy = {
    'long_name'     'prior segment northward water current'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_depth = {
    'long_name'     'bathymetry'
    'standard_name' 'depth'
    'units'         'm'  
    '_FillValue'    default_fill_value };

  % Navigation CTD.
  var_attr_list.m_water_temp = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_cond = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.m_water_pressure = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'decibar'  
    '_FillValue'    default_fill_value };

  % Navigation FLNTU.
  var_attr_list.u_flntu_chlor_do = {
    'long_name'     'chlorophyll dark water offset'
    'standard_name' 'chlorophyll'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_turb_do = {
    'long_name'     'turbidity dark water offset'
    'standard_name' 'turbidity_dark_water_offset'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_chlor_sf = {
    'long_name'     'chlorophyll scale factor'
    'standard_name' 'chlorophyll_scale_factor'
    'units'         'mg m-3'  
    '_FillValue'    default_fill_value };

  var_attr_list.u_flntu_turb_sf = {
    'long_name'     'turbidity scale factor'
    'standard_name' 'turbidity_scale_factor'
    'units'         'NTU'  
    '_FillValue'    default_fill_value };

  % Science time.
  var_attr_list.sci_m_present_time = {
    'long_name'     'epoch time (science bay)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % Science CTD.
  var_attr_list.sci_water_temp = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_water_cond = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_water_pressure = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'decibar'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ctd41cp_timestamp = {
    'long_name'     'epoch time (CTD sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % BB3SLO sensor.
  var_attr_list.sci_bb3slo_b470_scaled = {
    'long_name'     'blue backscatter'
    'standard_name' 'blue_backscatter'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b532_scaled = {
    'long_name'     'green backscatter'
    'standard_name' 'green_backscatter'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bb3slo_b660_scaled = {
    'long_name'     'red backscatter'
    'standard_name' 'red_backscatter'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  % BBFL2S sensor.
  var_attr_list.sci_bbfl2s_bb_scaled = {
    'long_name'     'backscatter'
    'standard_name' 'backscatter'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_cdom_scaled = {
    'long_name'     'cdom'
    'standard_name' 'cdom'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_bbfl2s_chlor_scaled = {
    'long_name'     'chlorophyll'
    'standard_name' 'chlorophyll'
    'units'         'mg Kg-3'  
    '_FillValue'    default_fill_value };

  % OCR504I sensor.
  var_attr_list.sci_ocr504I_irrad1 = {
    'long_name'     'irradiance at 412nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad2 = {
    'long_name'     'irradiance at 442nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad3 = {
    'long_name'     'irradiance at 491nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_ocr504I_irrad4 = {
    'long_name'     'irradiance at 664nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1' 
    '_FillValue'    default_fill_value };

  % FLNTU sensor.
  var_attr_list.sci_flntu_chlor_ref = {
    'long_name'     'chlorophyll reference'
    'standard_name' 'chlorophyll_reference'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_chlor_sig = {
    'long_name'     'chlorophyll signal'
    'standard_name' 'chlorophyll_signal'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_chlor_units = {
    'long_name'     'chlorophyll'
    'standard_name' 'concentration_of_chlorophyll_in_sea_water'
    'units'         'mg m-3'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_temp = {
    'long_name'     'temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_ref = {
    'long_name'     'turbidity reference'
    'standard_name' 'turbidity_reference'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_sig = {
    'long_name'     'turbidity signal'
    'standard_name' 'turbidity_signal'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_flntu_turb_units = {
    'long_name'     'turbidity'
    'standard_name' 'turbidity'
    'units'         'NTU' 
    '_FillValue'    default_fill_value };
  
  var_attr_list.sci_flntu_timestamp = {
    'long_name'     'epoch time (FLNTU sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % OXY3835 sensor.
  var_attr_list.sci_oxy3835_oxygen = {
    'long_name'     'oxygen concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy3835_saturation = {
    'long_name'     'oxygen saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '1'  
    '_FillValue'    default_fill_value };

  var_attr_list.sci_oxy3835_temp = {
    'long_name'     'temperature'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'  
    '_FillValue'    default_fill_value };
  
  var_attr_list.sci_oxy3835_timestamp = {
    'long_name'     'epoch time (OXY3835 sensor)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };


  %% Define global attributes (they may be overwritten with deployment values).
  % To define the global attributes easily and readably, add them to this
  % cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by WRITENETCDFDATA.
  global_atts = ...
  {
    'abstract'                     '' % deployment_description
    'acknowledgement'              '' % deployment_acknowledgement
    'author'                       '' % deployment_author
    'author_email'                 '' % deployment_author_email
    'cdm_data_type'                'Trajectory'
    'citation'                     '' % deployment_citation
    'comment'                      'Data provided as it comes from the glider.'
    'Conventions'                  'CF-1.6'
    'creator_email'                '' % deployment_author_email
    'creator_name'                 '' % deployment_author
    'creator_url'                  '' % deployment_author_url
    'data_center'                  '' % deployment_data_center
    'data_center_email'            '' % deployment_data_center_email
    'data_mode'                    'delayed time'
    'date_modified'                'undefined'
    'featureType'                  'trajectory'
    'geospatial_lat_max'           'undefined'
    'geospatial_lat_min'           'undefined'
    'geospatial_lat_units'         'undefined'
    'geospatial_lon_max'           'undefined'
    'geospatial_lon_min'           'undefined'
    'geospatial_lon_units'         'undefined'
    'history'                      ''
    'institution'                  '' % institution_name
    'institution_references'       '' % institution_references
    'instrument_model'             '' % instrument_model
    'instrument_manufacturer'      '' % instrument_manufacturer
    'license'                      'Approved for public release. Distribution Unlimited.' % deployment_distribution_statement
    'netcdf_version'               '4.0.1'
    'positioning_system'           'GPS and dead reckoning'
    'principal_investigator'       '' % deployment_principal_investigator
    'principal_investigator_email' '' % deployment_principal_investigator_email
    'processing_level'             'L0 raw data not calibrated'
    'project'                      '' % deployment_project
    'publisher_email'              '' % deployment_publisher_email
    'publisher_name'               '' % deployment_publisher_name
    'publisher_url'                '' % deployment_publisher_url
    'source'                       'glider'
    'source_files'                 'undefined' % source_files field set by processing script after loading data.
    'standard_name_vocabulary'     'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/16/cf-standard-name-table.html'
    'summary'                      '' % deployment_description
    'time_coverage_end'            'undefined'
    'time_coverage_start'          'undefined'
    'title'                        'Glider deployment delayed time raw data'
    'transmission_system'          'IRIDIUM'
  };


  %% Define dimension names.
  time_dim_name = 'time';


  %% Return global and variable metadata in the correct format.
  nc_l0_info = struct();
  % Set the dimension names.
  nc_l0_info.dim_names.time = time_dim_name;
  % Set the global attributes.
  nc_l0_info.global_atts = ...
    struct('name', global_atts(:,1), 'value', global_atts(:,2));
  % Set the variable metadata.
  nc_l0_info.var_meta = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    nc_l0_info.var_meta.(var_name).dimensions = {time_dim_name};
    nc_l0_info.var_meta.(var_name).attributes = ...
      struct('name',  var_atts(:,1), 'value', var_atts(:,2));
  end

end
