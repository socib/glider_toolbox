function ncl2_info = configDTOutputNetCDFL2()
%CONFIGDTOUTPUTNETCDFL2  Configure NetCDF output for gridded glider deployment data in delayed time.
%
%  Syntax:
%    NCL2_INFO = CONFIGDTOUTPUTNETCDFL2()
%
%  Description:
%    NCL2_INFO = CONFIGDTOUTPUTNETCDFL2() should return a struct
%    describing the structure of the NetCDF file for gridded glider
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
%    the metadata provided here and the data returned by GRIDGLIDERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl2_info = configDTOutputNetCDFL2()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
%    GRIDGLIDERDATA
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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

  var_attr_list.time = {
    'long_name'     'profile grid time'
    'standard_name' 'time'
    'units'         'seconds since 1970-01-01 00:00:00 +00:00'
    'axis'          'T'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_resolution'  []
    'grid_min'         []
    'grid_max'         [] };

  var_attr_list.depth = {
    'long_name'     'profile grid depth'
    'standard_name' 'depth'
    'units'         'm'
    'positive'      'down'
    'axis'          'Z'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_resolution'  []
    'grid_min'         []
    'grid_max'         [] };

  var_attr_list.latitude = {
    'long_name'     'profile grid latitude'
    'standard_name' 'latitude'
    'units'         'degree_north'
    'axis'          'Y'
    'coordinates'   'time'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.longitude = {
    'long_name'     'profile grid longitude'
    'standard_name' 'longitude'
    'axis'          'X'
    'units'         'degree_east'
    'coordinates'   'time'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.heading = {
    'long_name'     'glider heading angle'
    'standard_name' 'heading'
    'units'         'rad'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.roll = {
    'long_name'     'glider roll angle'
    'standard_name' 'roll'
    'units'         'rad'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.pitch = {
    'long_name'     'glider pitch angle'
    'standard_name' 'pitch'
    'units'         'rad'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'filling'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.profile_index = {
    'long_name'     'profile index'
    'standard_name' ''
    'units'         '1'
    'coordinates'   'time latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'min_range'        []
    'join_equal'       []
    'source_filling'   []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.conductivity = {
    'long_name'     'water conductivity'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.temperature = {
    'long_name'     'water temperature'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.pressure = {
    'long_name'     'water pressure'
    'standard_name' 'pressure'
    'units'         'decibar'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'filter_method'          []
    'filter_parameters'      []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.temperature_corrected_sensor = {
    'long_name'     'water temperature with sensor time response corrected'
    'standard_name' 'sea_water_temperature'
    'units'         'Celsius'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.conductivity_corrected_sensor = {
    'long_name'     'water conductivity with sensor time response corrected'
    'standard_name' 'sea_water_conductivity'
    'units'         'S m-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'method'                 []
    'parameters'             []
    'parameter_method'       []
    'parameter_estimator'    []
    'profile_min_range'      []
    'profile_gap_ratio'      []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.salinity = {
    'long_name'     'water salinity'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.salinity_corrected_thermal = {
    'long_name'     'water salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.salinity_corrected_temperature_thermal = {
    'long_name'     'water salinity from raw conductivity and temperature with sensor lag and thermal lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.salinity_corrected_sensor = {
    'long_name'     'water salinity from conductivity and temperature with sensor lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.salinity_corrected_sensor_thermal = {
    'long_name'     'water salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name' 'sea_water_salinity'
    'units'         'PSU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.density = {
    'long_name'     'water density using salinity from raw temperature and raw conductivity'
    'standard_name' 'sea_water_density'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.density_corrected_thermal = {
    'long_name'     'water density using salinity from raw conductivity and temperature with thermal lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.density_corrected_sensor = {
    'long_name'     'water density using salinity from conductivity and temperature with sensor lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.density_corrected_sensor_thermal = {
    'long_name'     'water density using salinity from conductivity and temperature with sensor lag corrected and thermal lag corrected'
    'standard_name' 'sea_water_density'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'method'           []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.potential_temperature = {
    'long_name'     'water potential temperature'
    'standard_name' 'sea_water_potential_temperature'
    'units'         'Celsius'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.potential_density = {
    'long_name'     'water potential density'
    'standard_name' 'sea_water_potential_density'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.sound_velocity = {
    'long_name'     'sound velocity'
    'standard_name' 'sea_water_sound_velocity'
    'units'         'Kg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.backscatter_470 = {
    'long_name'     'blue backscatter'
    'standard_name' 'blue_backscatter'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.backscatter_532 = {
    'long_name'     'green backscatter'
    'standard_name' 'green_backscatter'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.backscatter_660 = {
    'long_name'     'red backscatter'
    'standard_name' 'red_backscatter'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

    var_attr_list.backscatter_700 = {
    'long_name'     '700 nm wavelength backscatter'
    'standard_name' '700nm_backscatter'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'       [] 
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };
  
  var_attr_list.backscatter = {
    'long_name'     'backscatter'
    'standard_name' 'backscatter'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.chlorophyll = {
    'long_name'     'chlorophyll'
    'standard_name' 'concentration_of_chlorophyll_in_sea_water'
    'units'         'mg m-3'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.turbidity = {
    'long_name'     'turbidity'
    'standard_name' 'turbidity'
    'units'         'NTU'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.cdom = {
    'long_name'     'cdom'
    'standard_name' 'concentration_of_coloured_dissolved_organic_matter'
    'units'         'ppb'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.scatter_650 = {
    'long_name'     '650 nm wavelength scattering'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.oxygen_concentration = {
    'long_name'     'oxygen concentration'
    'standard_name' 'mole_concentration_of_dissolved_molecular_oxygen_in_sea_water'
    'units'         'umol l-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.oxygen_saturation = {
    'long_name'     'oxygen saturation'
    'standard_name' 'fractional_saturation_of_oxygen_in_sea_water'
    'units'         '1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  
    var_attr_list.oxygen_frequency = {
    'long_name'     'oxygen frequency'
    'standard_name' 'oxygen_frequency_from_GPCTD'
    'units'         'Hz'
    'coordinates'   'time depth latitude longitude'
    'comments'      'from Seabird GPCTD with SBE 43F oxygen sensor'                  
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' [] 
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };
    
 
  var_attr_list.temperature_oxygen = {
    'long_name'     'oxygen sensor temperature'
    'standard_name' 'temperature_of_sensor_for_oxygen_in_sea_water'
    'units'         'Celsius'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'                []
    'conversion'             []
    'calibration'            []
    'calibration_parameters' []
    'grid_sources'           []
    'grid_coordinates'       []
    'grid_method'            [] };

  var_attr_list.irradiance_412 = {
    'long_name'     'irradiance at 412nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.irradiance_442 = {
    'long_name'     'irradiance at 442nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.irradiance_491 = {
    'long_name'     'irradiance at 491nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.irradiance_664 = {
    'long_name'     'irradiance at 664nm wavelength'
    'standard_name' 'downwelling_spectral_spherical_irradiance_in_sea_water'
    'units'         'uW cm-2 nm-1'
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };
  
  var_attr_list.water_velocity_eastward = {
    'long_name'     'mean eastward water velocity in segment'
    'standard_name' 'eastward_water_velocity'
    'units'         'm s-1'  
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  var_attr_list.water_velocity_northward = {
    'long_name'     'mean northward water velocity in segment'
    'standard_name' 'northward_water_velocity'
    'units'         'm s-1'  
    'coordinates'   'time depth latitude longitude'
    '_FillValue'    default_fill_value
    'sources'          []
    'conversion'       []
    'grid_sources'     []
    'grid_coordinates' []
    'grid_method'      [] };

  %% Variables specific to SeaExplorer
  var_attr_list.fluorescence_270_340 = {
      'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 270/340nm'
      'standard_name' 'fluorescence_excitation_270nm_emission_340nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Tryptophan-like or Naphtalene-like measurements'
      'comment2'      '270nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
  
  var_attr_list.fluorescence_255_360 = {
      'long_name'     'Minifluo-UV1 fluorescence Ex./Em. = 255/360nm'
      'standard_name' 'fluorescence_excitation_255nm_emission_360nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Phenanthren-like measurements or water-soluble fraction of petroleum'
      'comment2'      '255nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_monitoring_270_340 = {
      'long_name'     'Minifluo-UV1 monitoring channel of the 270nm LED'
      'standard_name' 'fluorescence_monitoring_270_340nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Measures variations in LED excitation wavelength'
      'comment2'      '270nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_monitoring_255_360 = {
      'long_name'     'Minifluo-UV1 monitoring channel of the 255nm LED'
      'standard_name' 'fluorescence_monitoring_255_360nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Measures variations in LED excitation wavelength'
      'comment2'      '255nm is the nominal wavelength of the LED'
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_260_315 = {
      'long_name'     'Minifluo-UV2 fluorescence Ex./Em. = 260/315nm'
      'standard_name' 'fluorescence_excitation_260nm_emission_315nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Fluorene-like measurements'
      'comment2'      '260nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_270_376 = {
      'long_name'     'Minifluo-UV2 fluorescence Ex./Em. = 270/376nm'
      'standard_name' 'fluorescence_excitation_270nm_emission_376nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Pyrene-like measurements'
      'comment2'      '270nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
       'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_monitoring_260_315 = {
      'long_name'     'Minifluo-UV2 monitoring channel of the 260nm LED'
      'standard_name' 'fluorescence_monitoring_260_315nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Measures variations in LED excitation wavelength'
      'comment2'      '260nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
  var_attr_list.fluorescence_monitoring_270_376 = {
      'long_name'     'Minifluo-UV2 monitoring channel of the 270nm LED'
      'standard_name' 'fluorescence_monitoring_270_376nm'
      'units'         'counts'
      'coordinates'   'time depth latitude longitude'      
      'comment1'      'Measures variations in LED excitation wavelength'
      'comment2'      '270nm is the nominal wavelength of the LED'
      '_FillValue'    default_fill_value
      'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };
      
    var_attr_list.methane_concentration = {
      'long_name'     'Methane concentration (scaled)'
      'standard_name' 'methane_concentration'
      'units'         'ug/L'
      'coordinates'   'time depth latitude longitude'
      '_FillValue'    default_fill_value
       'sources'       []
      'conversion'       []
      'grid_sources'     []
      'grid_coordinates' []
      'grid_method'      [] };   
  
  
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
    'comment'                      'Instantaneous regularly sampled vertical profiles generated from depth binning of already processed (regularized, corrected and/or derived) glider data.'
    'Conventions'                  'CF-1.6'
    'creator'                      '' % deployment_author
    'creator_email'                '' % deployment_author_email
    'creator_url'                  '' % deployment_author_url
    'data_center'                  '' % deployment_data_center
    'data_center_email'            '' % deployment_data_center_email
    'data_mode'                    'delayed time'
    'date_modified'                'undefined'
    'featureType'                  'trajectoryProfile'
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
    'processing_level'             'L2 interpolated data at selected locations and instants'
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
    'title'                        'Glider deployment delayed time gridded data'
    'transmission_system'          'IRIDIUM'
  };


  %% Define preset dimensions.
  time_dimension = struct('name', {'time'}, 'length', {0});
  dpth_dimension = struct('name', {'depth'}, 'length', {[]});


  %% Return variable metadata in the correct format.
  ncl2_info = struct();
  % Set the dimension names.
  ncl2_info.dimensions = [time_dimension dpth_dimension];
  % Set the global attributes.
  ncl2_info.attributes = cell2struct(global_atts, {'name' 'value'}, 2);
  % Set the variable metadata.
  ncl2_info.variables = struct();
  var_name_list = fieldnames(var_attr_list);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    var_atts = var_attr_list.(var_name);
    switch var_name
      case {'time' 'profile_index' 'longitude' 'latitude' 'distance'}
        var_dims = {time_dimension.name};
      case {'depth'}
        var_dims = {dpth_dimension.name};
      otherwise
        var_dims = {time_dimension.name dpth_dimension.name};
    end
    ncl2_info.variables.(var_name).dimensions = var_dims;
    ncl2_info.variables.(var_name).attributes = ...
      cell2struct(var_atts, {'name' 'value'}, 2);
  end

end
