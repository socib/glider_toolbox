function attArray = getProcGliderVarAtts(varName)
%GETPROCGLIDERVARATTS - Gets the netcdf attributes for a processed variable name
% This function contains a "table" that provides the values for a certain
% set of attributes of a given processed variable name.
% It provides a array structure with the attributes:
%    - long_name
%    - standard_name
%    - units
%    - _FillValue
%    - comments (optionally, not on all variables)
%
% Syntax: attArray = getProcGliderVarAtts(varName)
%
% Inputs:
%    varName - The processed variable name
%
% Outputs:
%    attArray - Structure array with two fields:
%       attArray(ordinalIdx).Name  - name of the variable attribute
%       attArray(ordinalIdx).Value - value of the variable attribute
%
% Example:
%    attArray = getRawVarAtts('time');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: GENPROCGLIDERNCFILE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 18-Feb-2011
%
    % Attributes name definition
    attArray(1).Name  = 'long_name';
	attArray(2).Name  = 'standard_name';
    attArray(3).Name  = 'units';
    attArray(4).Name  = '_FillValue';

    % Some default value to reduce copy&paste
    attArray(4).Value = -1e6;

    switch varName
        case {'time', 'navTime', 'sciTime'}
            attArray(1).Value = 'epoch time';
            attArray(2).Value = 'time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
        case 'latitude'
            attArray(1).Value = 'latitude';
            attArray(2).Value = 'latitude';
            attArray(3).Value = 'degree_north';
        case 'longitude'
            attArray(1).Value = 'longitude';
            attArray(2).Value = 'longitude';
            attArray(3).Value = 'degree_east';
        case 'wptLat'
            attArray(1).Value = 'next waypoint latitude';
            attArray(2).Value = 'latitude';
            attArray(3).Value = 'degree_north';
        case 'wptLon'
            attArray(1).Value = 'next waypoint longitude';
            attArray(2).Value = 'longitude';
            attArray(3).Value = 'degree_east';
        case {'distance', 'distanceOverGround'}
            attArray(1).Value = 'distance flown since mission start';
            attArray(2).Value = 'distance';
            attArray(3).Value = 'm';
        case {'depth', 'continousDepth'}
            attArray(1).Value = 'glider depth';
            attArray(2).Value = 'depth';
            attArray(3).Value = 'm';
        case 'pitch'
            attArray(1).Value = 'glider pitch angle';
            attArray(2).Value = 'pitch';
            attArray(3).Value = 'degree';
        case 'temperature'
            attArray(1).Value = 'water temperature';
            attArray(2).Value = 'sea_water_temperature';
            attArray(3).Value = 'Celsius';
        case 'Tcor'
            attArray(1).Value = 'water temperature time response corrected';
            attArray(2).Value = 'sea_water_temperature';
            attArray(3).Value = 'Celsius';
        case 'conductivity'
            attArray(1).Value = 'water conductivity';
            attArray(2).Value = 'sea_water_conductivity';
            attArray(3).Value = 'S m-1';
        case 'Ccor'
            attArray(1).Value = 'water conductivity tiem response corrected';
            attArray(2).Value = 'sea_water_conductivity';
            attArray(3).Value = 'S m-1';
        case 'conductivity_ratio'
            attArray(1).Value = 'water conductivity ratio wrt 35PSU15C';
            attArray(2).Value = 'sea_water_conductivity_ratio';
            attArray(3).Value = 'S m-1';
        case 'salinity'
            attArray(1).Value = 'water salinity';
            attArray(2).Value = 'sea_water_salinity';
            attArray(3).Value = 'PSU';
        case 'salinity_corrected_TH'
            attArray(1).Value = 'water salinity thermal lag corrected';
            attArray(2).Value = 'sea_water_salinity';
            attArray(3).Value = 'PSU';
        case 'salinity_corrected_Tcor_TH'
            attArray(1).Value = 'water salinity thermal lag corrected and Tcor';
            attArray(2).Value = 'sea_water_salinity';
            attArray(3).Value = 'PSU';
        case 'salinity_corrected_Tcor_Ccor_TH'
            attArray(1).Value = 'water salinity thermal lag corrected and Tcor and Ccor';
            attArray(2).Value = 'sea_water_salinity';
            attArray(3).Value = 'PSU';
        case 'density'
            attArray(1).Value = 'water density';
            attArray(2).Value = 'sea_water_density';
            attArray(3).Value = 'Kg m-3';
        case 'density_corrected'
            attArray(1).Value = 'water density using salinity thermal lag corrected';
            attArray(2).Value = 'sea_water_density';
            attArray(3).Value = 'Kg m-3';
        case 'potential_temperature'
            attArray(1).Value = 'water potential temperature';
            attArray(2).Value = 'sea_water_potential_temperature';
            attArray(3).Value = 'Celsius';
        case 'potential_density'
            attArray(1).Value = 'water potential density';
            attArray(2).Value = 'sea_water_potential_density';
            attArray(3).Value = 'Kg m-3';
        case 'sound_velocity'
            attArray(1).Value = 'sound velocity';
            attArray(2).Value = 'sea_water_sound_velocity';
            attArray(3).Value = 'Kg m-3';
        case 'pressure'
            attArray(1).Value = 'water pressure';
            attArray(2).Value = 'pressure';
            attArray(3).Value = 'decibar';
        case 'profile_index'
            attArray(1).Value = 'profile index';
            attArray(2).Value = 'profile_index';
            attArray(3).Value = '1';
         case 'backscatter470'
            attArray(1).Value = 'blue backscatter';
            attArray(2).Value = 'blue_backscatter';
            attArray(3).Value = '1';
         case 'backscatter532'
            attArray(1).Value = 'green backscatter';
            attArray(2).Value = 'green_backscatter';
            attArray(3).Value = '1';
         case 'backscatter660'
            attArray(1).Value = 'red backscatter';
            attArray(2).Value = 'red_backscatter';
            attArray(3).Value = '1';
         case 'backscatter'
            attArray(1).Value = 'backscatter';
            attArray(2).Value = 'backscatter';
            attArray(3).Value = '1';
         case 'chlorophyll'
            attArray(1).Value = 'chlorophyll';
            attArray(2).Value = 'concentration_of_chlorophyll_in_sea_water';
            attArray(3).Value = 'mg m-3';
         case 'turbidity'
            attArray(1).Value = 'turbidity';
            attArray(2).Value = 'turbidity';
            attArray(3).Value = 'NTU';
         case 'cdom'
            attArray(1).Value = 'cdom';
            attArray(2).Value = 'cdom';
            attArray(3).Value = '1';
         case 'oxygen'
            attArray(1).Value = 'oxygen';
            attArray(2).Value = 'moles_of_oxygen_per_unit_mass_in_sea_water';
            attArray(3).Value = 'mol kg-1';
         case 'oxygen_saturation'
            attArray(1).Value = 'oxygen saturation';
            attArray(2).Value = 'fractional_saturation_of_oxygen_in_sea_water';
            attArray(3).Value = '1';
         case 'oxygen_temperature'
            attArray(1).Value = 'temperature';
            attArray(2).Value = 'temperature_of_sensor_for_oxygen_in_sea_water';
            attArray(3).Value = 'Celsius';
        case 'irradiance412nm'
            attArray(1).Value = 'irradiance at 412nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'irradiance442nm'
            attArray(1).Value = 'irradiance at 442nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'irradiance491nm'
            attArray(1).Value = 'irradiance at 491nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'irradiance664nm'
            attArray(1).Value = 'irradiance at 664nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'inflecting'
            attArray(1).Value = 'glider inflecting marker';
            attArray(2).Value = 'inflection';
            attArray(3).Value = '1';
         case 'numHalfYosInSegment'
            attArray(1).Value = 'glider half yos number in segment';
            attArray(2).Value = 'half_yos_number';
            attArray(3).Value = '1';
         case 'totNumInflections'
            attArray(1).Value = 'total number of glider inflections ';
            attArray(2).Value = 'total_num_inflections';
            attArray(3).Value = '1';

        otherwise
            disp(['Unknown sensor: ', varName]);
            disp(['Please add related entry on this sensor on file ', mfilename]);
            attArray(1).Value = varName;
            attArray(2).Value = varName;
            attArray(3).Value = '1';
    end;

end
