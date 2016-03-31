function ncl0_info = configDTOutputNetCDFL0SeaExplorer()
%CONFIGDTOUTPUTNETCDFL0  Configure NetCDF output for raw SeaExplorer glider deployment data in delayed time.
%
%  Syntax:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SEAEXPLORER()
%
%  Description:
%    NCL0_INFO = CONFIGDTOUTPUTNETCDFL0SEAEXPLORER() should return a struct 
%    describing the structure of the NetCDF file for raw SeaExplorer glider 
%    deployment data in delayed time (see the note about the file generation).
%    The returned struct should have the following fields:
%      DIMENSIONS: struct array with fields 'NAME' and 'LENGTH' defining the 
%        dimensions for variables in the file.
%        A variable may have dimensions not listed here or with their length
%        left undefined (empty field value), and they are inferred from the 
%        data during the generation of the file. However, it is useful to preset
%        the length of a dimension for record or string size dimensions.
%      ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining global
%        attributes of the file.
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
%    the structure provided here and the metadata and data returned by 
%    LOADSEAEXPLORERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl0_info = configDTOutputNetCDFL0SeaExplorer()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
%    LOADSEAEXPLORERDATA
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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

  error(nargchk(0, 0, nargin, 'struct'));

  %% Define variable information.
  % To define the variable attributes easily and readably, add the corresponding
  % variable field to the struct defined below, with its attributes defined in 
  % a cell array (attribute name in first column and attribute value in second).
  % This cell array will be converted at the end of the function to the proper
  % representation needed by SAVENC.

  default_fill_value = realmax('double');

  %% From navigation files.

  % Navigation time.
  var_attr_list.Timestamp = {
    'long_name'     'epoch time (navigation board)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  var_attr_list.Lat = {
    'long_name'     'GPS latitude (low freq.)'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.Lon = {
    'long_name'     'GPS longitude (low freq.)'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.Depth = {
    'long_name'     'glider measured depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    '_FillValue'    default_fill_value };

  var_attr_list.Roll = {
    'long_name'     'glider roll'
    'units'         'Degrees'
    'comments'      'greater than 0 is port wing up'
    '_FillValue'    default_fill_value };

  var_attr_list.Pitch = {
    'long_name'     'glider pitch'
    'units'         'Degrees'
    '_FillValue'    default_fill_value };

  var_attr_list.Heading = {
    'long_name'     'Measured heading'
    'units'         'Degrees'
    '_FillValue'    default_fill_value };

  var_attr_list.DesireH = {
    'long_name'     'Target heading commanded by user'
    'units'         'Degrees'
    '_FillValue'    default_fill_value };

  var_attr_list.Voltage = {
    'long_name'     'battery voltage'
    'units'         'V'
    '_FillValue'    default_fill_value };

  var_attr_list.NavState = {
    'long_name'     'Number describing navigation state (see manual)'
    'units'         'N/A'
    '_FillValue'    default_fill_value };

  var_attr_list.SecurityLevel = {
    'long_name'     'Sum of security code (see Appendix).'
    'units'         'N/A'
    '_FillValue'    default_fill_value };
  
  var_attr_list.Pa = {
    'long_name'     'Internal body pressure'
    'units'         'Pa'
    '_FillValue'    default_fill_value };

  var_attr_list.BallastCmd = {
    'long_name'     'Ballast volume commanded by user'
    'units'         'ml'
    '_FillValue'    default_fill_value };

  var_attr_list.BallastPos = {
    'long_name'     'Ballast volume measured by potentiometer'
    'units'         'ml'
    '_FillValue'    default_fill_value };

  var_attr_list.LinCmd = {
    'long_name'     'Linear position commanded for batteries'
    'units'         'mm'
    '_FillValue'    default_fill_value };

  var_attr_list.LinPos = {
    'long_name'     'Linear position returned by potentiometer'
    'units'         'mm'
    '_FillValue'    default_fill_value };   

  var_attr_list.AngCmd = {
    'long_name'     'Rotational position commanded for batteries'
    'units'         'rad'
    '_FillValue'    default_fill_value };

  var_attr_list.AngPos = {
    'long_name'     'Rotational position returned by potentiometer'
    'units'         'rad'
    '_FillValue'    default_fill_value };   

  var_attr_list.Altitude = {
    'long_name'     'Measured distance to seabed'
    'units'         'm'
    '_FillValue'    default_fill_value };


  %% From science files.

  % Science time.
  var_attr_list.PLD_REALTIMECLOCK = { 
    'long_name'     'epoch time (science bay)'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    '_FillValue'    default_fill_value };

  % Other navigation info
  var_attr_list.NAV_LATITUDE = {
    'long_name'     'GPS latitude (High freq.)'
    'standard_name' 'latitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.NAV_LONGITUDE = {
    'long_name'     'GPS longitude (High freq.)'
    'standard_name' 'longitude'
    'units'         'nmea_degree'
    '_FillValue'    default_fill_value };

  var_attr_list.NAV_NUMBEROFYO = {
    'long_name'     'Yo number (from glider)'
    'units'         '1'
    '_FillValue'    default_fill_value };

  var_attr_list.NAV_MISSIONID = {
    'long_name'     'Mission reference ID (from glider)'
    'units'         '1'
    '_FillValue'    default_fill_value };    

   var_attr_list.NAV_RESSOURCE = {
    'long_name'     ['Number describing navigation state (same ' ...
                     'as NavState from glider)']
    'units'         'N/A'
    '_FillValue'    default_fill_value };       

  % Science CTD (legacy)
  var_attr_list.SBD_TEMPERATURE = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.SBD_CONDUCTIVITY = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    '_FillValue'    default_fill_value };

  var_attr_list.SBD_PRESSURE = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'dbar'
    '_FillValue'    default_fill_value };

  var_attr_list.SBD_DOF = {
    'long_name'     'dissolved oxygen frequency'
    'standard_name' 'dissolved_oxygen_frequency'
    'units'         'Hz'
    '_FillValue'    default_fill_value };

  % Science CTD (new)
  var_attr_list.GPCTD_TEMPERATURE = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.GPCTD_CONDUCTIVITY = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    '_FillValue'    default_fill_value };

  var_attr_list.GPCTD_PRESSURE = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'dbar'
    '_FillValue'    default_fill_value };

  var_attr_list.GPCTD_DOF = {
    'long_name'     'dissolved oxygen frequency'
    'standard_name' 'dissolved_oxygen_frequency'
    'units'         'Hz'
    '_FillValue'    default_fill_value };

  % FLBBCD sensor
  var_attr_list.TRI_CHL_COUNT = {
    'long_name'     'Chlorophyll raw'
    'standard_name' 'Chlorophyll_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.TRI_CHL_SCALED = {
    'long_name'     'Chlorophyll concentration'
    'standard_name' 'Chlorophyll_concentration'
    'units'         'ug L-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.TRI_CDOM_COUNT = {
    'long_name'     'Coloured dissolved organic matter raw'
    'standard_name' 'CDOM_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.TRI_CDOM_SCALED = {
    'long_name'     'Coloured dissolved organic matter concentration'
    'standard_name' 'CDOM_concentration'
    'units'         'ug L-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.TRI_BB_700_COUNT = {
    'long_name'     'Backscattering raw'
    'standard_name' 'Backscattering_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.TRI_BB_700_SCALED = {
    'long_name'     'Backscattering scaled'
    'standard_name' 'Backscattering_scaled'
    'units'         'm-1 (sr-1)-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  % FLBBCD sensor (same, different var names)
  var_attr_list.FLBBCD_CHL_COUNT = {
    'long_name'     'Chlorophyll raw'
    'standard_name' 'Chlorophyll_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.FLBBCD_CHL_SCALED = {
    'long_name'     'Chlorophyll concentration'
    'standard_name' 'Chlorophyll_concentration'
    'units'         'ug L-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.FLBBCD_CDOM_COUNT = {
    'long_name'     'Coloured dissolved organic matter raw'
    'standard_name' 'CDOM_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.FLBBCD_CDOM_SCALED = {
    'long_name'     'Coloured dissolved organic matter concentration'
    'standard_name' 'CDOM_scaled'
    'units'         'ug L-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.FLBBCD_BB_700_COUNT = {
    'long_name'     'Backscattering raw'
    'standard_name' 'Backscattering_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  var_attr_list.FLBBCD_BB_700_SCALED = {
    'long_name'     'Backscattering scaled'
    'standard_name' 'Backscattering_scaled'
    'units'         'm-1 (sr-1)-1'
    'comments'      'WETLabs ECO puck FLBBCD'
    '_FillValue'    default_fill_value };

  % FLNTU sensor
  var_attr_list.FLNTU_CHL_COUNT = {
    'long_name'     'Chlorophyll raw'
    'standard_name' 'Chlorophyll_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLNTU'
    '_FillValue'    default_fill_value };

  var_attr_list.FLNTU_CHL_SCALED = {
    'long_name'     'Chlorophyll concentration'
    'standard_name' 'Chlorophyll_concentration'
    'units'         'ug L-1'
    'comments'      'WETLabs ECO puck FLNTU'
    '_FillValue'    default_fill_value };

  var_attr_list.FLNTU_CDOM_COUNT = {
    'long_name'     'Turbidity raw'
    'standard_name' 'Turbidity_raw_counts'
    'units'         'counts'
    'comments'      'WETLabs ECO puck FLNTU'
    '_FillValue'    default_fill_value };
  
  var_attr_list.FLNTU_CDOM_SCALED = {
    'long_name'     'Turbidity scaled'
    'standard_name' 'Turbidity_scaled'
    'units'         'NTU'
    'comments'      'WETLabs ECO puck FLNTU'
    '_FillValue'    default_fill_value };    

  % METS sensor
  var_attr_list.METS_METHANE_VOLT = {
    'long_name'     'Methane concentration raw'
    'standard_name' 'methane_concentration_raw'
    'units'         'Volts'
    'comments'      'Alseamar methane sensor'
    '_FillValue'    default_fill_value };

  var_attr_list.METS_METHANE_SCALED = {
    'long_name'     'Methane concentration scaled'
    'standard_name' 'methane_concentration'
    'units'         'ug L-1'
    'comments'      'Alseamar methane sensor'
    '_FillValue'    default_fill_value };
  
  var_attr_list.TEMP_METHANE_VOLT = {
    'long_name'     'Methane sensor temperature raw'
    'standard_name' 'Methane_sensor_temperature_raw'
    'units'         'Volts'
    'comments'      'Alseamar methane sensor'
    '_FillValue'    default_fill_value };

  var_attr_list.TEMP_METHANE_SCALED = {
    'long_name'     'Methane sensor temperature'
    'standard_name' 'Methane_sensor_temperature'
    'units'         'Celsius'
    'comments'      'Alseamar methane sensor'
    '_FillValue'    default_fill_value };    

  % MFL sensor (actual variable names).
  var_attr_list.MFL_TMPD = {
    'long_name'     'Minifluo-UV1 detection circuit temperature'
    'standard_name' 'temperature_of_MiniFluo_detection_circuit'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.MFL_TMPE = {
    'long_name'     'Minifluo-UV1 emission circuit temperature'
    'standard_name' 'temperature_of_MiniFluo_emission_circuit'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };
  
  var_attr_list.MFL_V1 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
    'standard_name' 'fluorescence_excitation_270nm_emission_340nm'
    'units'         'counts'
    'comment1'      'Tryptophan-like or Naphtalene-like measurements'
    'comment2'      '270nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.MFL_V2 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
    'standard_name' 'fluorescence_excitation_255nm_emission_360nm'
    'units'         'counts'
    'comment1'      'Phenanthren-like measurements'
    'comment2'      '255nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.MFL_V3 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 270nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_270nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };

  var_attr_list.MFL_V4 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 255nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_255nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };

  % MFL sensor (earlier variable names).
  var_attr_list.UV1_TMPD = {
    'long_name'     'Minifluo-UV1 detection circuit temperature'
    'standard_name' 'temperature_of_MiniFluo_detection_circuit'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_TMPE = {
    'long_name'     'Minifluo-UV1 emission circuit temperature'
    'standard_name' 'temperature_of_MiniFluo_emission_circuit'
    'units'         'Celsius'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_V1 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
    'standard_name' 'fluorescence_excitation_270nm_emission_340nm'
    'units'         'counts'
    'comment1'      'Tryptophan-like or Naphtalene-like measurements'
    'comment2'      '270nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_V2 = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
    'standard_name' 'fluorescence_excitation_255nm_emission_360nm'
    'units'         'counts'
    'comment1'      'Phenanthren-like measurements'
    'comment2'      '255nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_V3 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 270nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_270nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_V4 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 255nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_255nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };

  % another earlier version:
  var_attr_list.UV1_TRY = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
    'standard_name' 'fluorescence_excitation_270nm_emission_340nm'
    'units'         'counts'
    'comment1'      'Tryptophan-like or Naphtalene-like measurements'
    'comment2'      '270nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_PHE = {
    'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
    'standard_name' 'fluorescence_excitation_255nm_emission_360nm'
    'units'         'counts'
    'comment1'      'Phenanthren-like measurements'
    'comment2'      '255nm is excitation wavelength of the LED'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_LD1 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 270nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_270nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };

  var_attr_list.UV1_LD2 = {
    'long_name'     'Minifluo-UV1 fluorescence monitoring of excitation 255nm LED'
    'standard_name' 'fluorescence_excitation_monitoring_255nm'
    'units'         'counts'
    '_FillValue'    default_fill_value };


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
    'comment'                      'Data provided as it comes from the glider.'
    'Conventions'                  'CF-1.6'
    'creator'                      '' % deployment_author
    'creator_email'                '' % deployment_author_email
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
    'history'                      sprintf('Product generated by the glider toolbox version %s (https://github.com/socib/glider_toolbox).', configGliderToolboxVersion())
    'institution'                  '' % institution_name
    'institution_references'       '' % institution_references
    'instrument'                   '' % instrument_name
    'instrument_manufacturer'      '' % instrument_manufacturer
    'instrument_model'             '' % instrument_model
    'license'                      'Approved for public release. Distribution Unlimited.' % deployment_distribution_statement
    'netcdf_version'               '4.0.1'
    'positioning_system'           'GPS and dead reckoning'
    'principal_investigator'       '' % deployment_principal_investigator
    'principal_investigator_email' '' % deployment_principal_investigator_email
    'processing_level'             'L0 raw data not calibrated'
    'project'                      '' % deployment_project
    'publisher'                    '' % deployment_publisher_name
    'publisher_email'              '' % deployment_publisher_email
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


  %% Define preset dimensions.
  time_dimension = struct('name', {'time'}, 'length', {0});


  %% Return global and variable metadata in the correct format.
  ncl0_info = struct();
  % Set the dimensions.
  ncl0_info.dimensions = time_dimension;
  % Set the global attributes.
  ncl0_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  % Set the variable metadata.
  ncl0_info.variables = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    ncl0_info.variables.(var_name).dimensions = {time_dimension.name};
    ncl0_info.variables.(var_name).attributes = ...
      cell2struct(var_atts, {'name' 'value'}, 2);
  end

end
