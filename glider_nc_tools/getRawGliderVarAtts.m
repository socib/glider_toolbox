function attArray = getRawGliderVarAtts(varName)
%GETRAWGLIDERVARATTS - Gets the netcdf attributes for a raw variable name
% This function contains a "table" that provides the values for a certain
% set of attributes of a given raw variable name.
% It provides a array structure with the attributes:
%    - long_name
%    - standard_name
%    - units
%    - _FillValue
%    - comments (optionally, not on all variables)
%
% Syntax: attArray = getRawGliderVarAtts(varName)
%
% Inputs:
%    varName - The raw variable name
%
% Outputs:
%    attArray - Structure array with two fields:
%       attArray(ordinalIdx).Name  - name of the variable attribute
%       attArray(ordinalIdx).Value - value of the variable attribute
%
% Example:
%    attArray = getRawVarAtts('m_present_time');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
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
% GLIDER VARS
        case 'm_present_time'
            attArray(1).Value = 'epoch time (navigation board)';
            attArray(2).Value = 'time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
        case 'sci_m_present_time'
            attArray(1).Value = 'epoch time (science bay)';
            attArray(2).Value = 'time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
        case 'm_lat'
            attArray(1).Value = 'latitude (dead reckoned)';
            attArray(2).Value = 'latitude';
            attArray(3).Value = 'degree_north';
        case 'm_lon'
            attArray(1).Value = 'longitude (dead reckoned)';
            attArray(2).Value = 'longitude';
            attArray(3).Value = 'degree_east';
        case 'm_gps_lat'
            attArray(1).Value = 'latitude (GPS fix)';
            attArray(2).Value = 'latitude';
            attArray(3).Value = 'degree_north';
        case 'm_gps_lon'
            attArray(1).Value = 'longitude (GPS fix)';
            attArray(2).Value = 'longitude';
            attArray(3).Value = 'degree_east';
        case 'c_wpt_lat'
            attArray(1).Value = 'next waypoint latitude';
            attArray(2).Value = 'latitude';
            attArray(3).Value = 'degree_north';
        case 'c_wpt_lon'
            attArray(1).Value = 'next waypoint longitude';
            attArray(2).Value = 'longitude';
            attArray(3).Value = 'degree_east';
        case 'm_speed'
            attArray(1).Value = 'glider speed through water';
            attArray(2).Value = 'speed';
            attArray(3).Value = 'm s-1';

% WATER INFO
        case 'm_water_vx'
            attArray(1).Value = 'zonal water current';
            attArray(2).Value = 'eastward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_water_vy'
            attArray(1).Value = 'meridional water current';
            attArray(2).Value = 'northward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_initial_water_vx'
            attArray(1).Value = 'initial zonal water current';
            attArray(2).Value = 'eastward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_initial_water_vy'
            attArray(1).Value = 'initial meridional water current';
            attArray(2).Value = 'northward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_final_water_vx'
            attArray(1).Value = 'final zonal water current';
            attArray(2).Value = 'eastward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_final_water_vy'
            attArray(1).Value = 'final meridional water current';
            attArray(2).Value = 'northward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_water_delta_vx'
            attArray(1).Value = 'delta zonal water current';
            attArray(2).Value = 'eastward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_water_delta_vy'
            attArray(1).Value = 'delta meridional water current';
            attArray(2).Value = 'northward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'x_prior_seg_water_vx'
            attArray(1).Value = 'prior segment zonal water current';
            attArray(2).Value = 'eastward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'x_prior_seg_water_vy'
            attArray(1).Value = 'prior segment meridional water current';
            attArray(2).Value = 'northward_water_velocity';
            attArray(3).Value = 'm s-1';
        case 'm_water_depth'
            attArray(1).Value = 'bathymetry';
            attArray(2).Value = 'depth';
            attArray(3).Value = 'm';
        case 'm_pitch'
            attArray(1).Value = 'glider pitch angle';
            attArray(2).Value = 'pitch';
            attArray(3).Value = 'degree';
        case 'm_roll'
            attArray(1).Value = 'glider roll';
            attArray(2).Value = 'roll';
            attArray(3).Value = 'rad';
            attArray(5).Name  = 'comments';
            attArray(5).Value = 'greater than 0 is port wing up';
        case 'm_fin'
            attArray(1).Value = 'glider rudder';
            attArray(2).Value = 'fin_position';
            attArray(3).Value = 'rad';
        case 'm_heading'
            attArray(1).Value = 'glider heading';
            attArray(2).Value = 'heading';
            attArray(3).Value = 'rad';
         case 'c_heading'
            attArray(1).Value = 'glider commanded heading';
            attArray(2).Value = 'heading';
            attArray(3).Value = 'rad';
         case 'm_depth'
            attArray(1).Value = 'glider measured depth';
            attArray(2).Value = 'depth';
            attArray(3).Value = 'm';
         case 'x_inflecting'
            attArray(1).Value = 'glider inflecting marker';
            attArray(2).Value = 'inflection';
            attArray(3).Value = '1';
         case 'm_num_half_yos_in_segment'
            attArray(1).Value = 'glider half yos number in segment';
            attArray(2).Value = 'half_yos_number';
            attArray(3).Value = '1';
         case 'm_tot_num_inflections'
            attArray(1).Value = 'total number of inflections';
            attArray(2).Value = 'half_yos_number';
            attArray(3).Value = '1';
        case 'm_battery'
            attArray(1).Value = 'battery voltage';
            attArray(2).Value = 'voltage';
            attArray(3).Value = 'V';
        case 'm_vacuum'
            attArray(1).Value = 'vacuum';
            attArray(2).Value = 'vacuum';
            attArray(3).Value = 'inHg';
        case 'm_leakdetect_voltage'
            attArray(1).Value = 'leak detector';
            attArray(2).Value = 'leak';
            attArray(3).Value = 'V';
            attArray(5).Name  = 'comments';
            attArray(5).Value = '2.5V means no leak; voltage drops if leak detected';

% CTD
        case {'m_water_temp', 'sci_water_temp'}
            attArray(1).Value = 'water temperature';
            attArray(2).Value = 'sea_water_temperature';
            attArray(3).Value = 'Celsius';
        case {'m_water_cond', 'sci_water_cond'}
            attArray(1).Value = 'water conductivity';
            attArray(2).Value = 'sea_water_conductivity';
            attArray(3).Value = 'S m-1';
        case {'m_water_pressure', 'sci_water_pressure'}
            attArray(1).Value = 'water pressure';
            attArray(2).Value = 'pressure';
            attArray(3).Value = 'decibar';
        case 'sci_ctd41cp_timestamp'
            attArray(1).Value = 'epoch time (CTD sensor)';
            attArray(2).Value = 'time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
% BB3SLO
        case 'sci_bb3slo_b470_scaled'
            attArray(1).Value = 'blue backscatter';
            attArray(2).Value = 'blue_backscatter';
            attArray(3).Value = '1';
         case 'sci_bb3slo_b532_scaled'
            attArray(1).Value = 'green backscatter';
            attArray(2).Value = 'green_backscatter';
            attArray(3).Value = '1';
         case 'sci_bb3slo_b660_scaled'
            attArray(1).Value = 'red backscatter';
            attArray(2).Value = 'red_backscatter';
            attArray(3).Value = '1';
% BBFL2S
        case 'sci_bbfl2s_bb_scaled'
            attArray(1).Value = 'backscatter';
            attArray(2).Value = 'backscatter';
            attArray(3).Value = '1';
         case 'sci_bbfl2s_cdom_scaled'
            attArray(1).Value = 'cdom';
            attArray(2).Value = 'cdom';
            attArray(3).Value = '1';
         case 'sci_bbfl2s_chlor_scaled'
            attArray(1).Value = 'chlorophyll';
            attArray(2).Value = 'chlorophyll';
            attArray(3).Value = 'mg Kg-3';
% OCR504I
        case 'sci_ocr504I_irrad1'
            attArray(1).Value = 'irradiance at 412nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'sci_ocr504I_irrad2'
            attArray(1).Value = 'irradiance at 442nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'sci_ocr504I_irrad3'
            attArray(1).Value = 'irradiance at 491nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
         case 'sci_ocr504I_irrad4'
            attArray(1).Value = 'irradiance at 664nm wavelength';
            attArray(2).Value = 'downwelling_spectral_spherical_irradiance_in_sea_water';
            attArray(3).Value = 'uW cm-2 nm-1';
% FLNTU
         case 'u_flntu_chlor_do'
            attArray(1).Value = 'chlorophyll dark water offset';
            attArray(2).Value = 'chlorophyll';
            attArray(3).Value = '1';
         case 'u_flntu_turb_do'
            attArray(1).Value = 'turbidity dark water offset';
            attArray(2).Value = 'turbidity_dark_water_offset';
            attArray(3).Value = '1';
         case 'u_flntu_chlor_sf'
            attArray(1).Value = 'chlorophyll scale factor';
            attArray(2).Value = 'chlorophyll_scale_factor';
            attArray(3).Value = 'mg m-3';
         case 'u_flntu_turb_sf'
            attArray(1).Value = 'turbidity scale factor';
            attArray(2).Value = 'turbidity_scale_factor';
            attArray(3).Value = 'NTU';
         case 'sci_flntu_chlor_ref'
            attArray(1).Value = 'chlorophyll reference';
            attArray(2).Value = 'chlorophyll_reference';
            attArray(3).Value = '1';
         case 'sci_flntu_chlor_sig'
            attArray(1).Value = 'chlorophyll signal';
            attArray(2).Value = 'chlorophyll_signal';
            attArray(3).Value = '1';
         case 'sci_flntu_chlor_units'
            attArray(1).Value = 'chlorophyll';
            attArray(2).Value = 'concentration_of_chlorophyll_in_sea_water';
            attArray(3).Value = 'mg m-3';
         case 'sci_flntu_temp'
            attArray(1).Value = 'temperature';
            attArray(2).Value = 'sea_water_temperature';
            attArray(3).Value = 'Celsius';
         case 'sci_flntu_turb_ref'
            attArray(1).Value = 'turbidity reference';
            attArray(2).Value = 'turbidity_reference';
            attArray(3).Value = '1';
         case 'sci_flntu_turb_sig'
            attArray(1).Value = 'turbidity signal';
            attArray(2).Value = 'turbidity_signal';
            attArray(3).Value = '1';
         case 'sci_flntu_turb_units'
            attArray(1).Value = 'turbidity';
            attArray(2).Value = 'turbidity';
            attArray(3).Value = 'NTU';
% OXY3835
         case 'sci_oxy3835_oxygen'
            attArray(1).Value = 'oxygen';
            attArray(2).Value = 'moles_of_oxygen_per_unit_mass_in_sea_water';
            attArray(3).Value = 'mol kg-1';
         case 'sci_oxy3835_saturation'
            attArray(1).Value = 'oxygen saturation';
            attArray(2).Value = 'fractional_saturation_of_oxygen_in_sea_water';
            attArray(3).Value = '1';
         case 'sci_oxy3835_temp'
            attArray(1).Value = 'temperature';
            attArray(2).Value = 'temperature_of_sensor_for_oxygen_in_sea_water';
            attArray(3).Value = 'Celsius';

% DEDUCED RECKONING
        case 'm_dr_fix_time'
            attArray(1).Value = 'deduced reckoning fix time';
            attArray(2).Value = 'deduced_reckoning_fix_time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
        case 'm_dr_postfix_time'
            attArray(1).Value = 'deduced reckoning post fix time';
            attArray(2).Value = 'deduced_reckoning_postfix_time';
            attArray(3).Value = 'seconds since 1970-01-01 00:00:00';
        case 'm_gps_fix_x_lmc'
            attArray(1).Value = 'x gps fix in local mission coordinates';
            attArray(2).Value = 'x_gps_fix_in_local_mission_coordinates';
            attArray(3).Value = 'm';
        case 'm_gps_fix_y_lmc'
            attArray(1).Value = 'y gps fix in local mission coordinates';
            attArray(2).Value = 'y_gps_fix_in_local_mission_coordinates';
            attArray(3).Value = 'm';
        case 'm_gps_postfix_x_lmc'
            attArray(1).Value = 'x gps postfix in local mission coordinates';
            attArray(2).Value = 'x_gps_postfix_in_local_mission_coordinates';
            attArray(3).Value = 'm';
        case 'm_gps_postfix_y_lmc'
            attArray(1).Value = 'y gps postfix in local mission coordinates';
            attArray(2).Value = 'y_gps_postfix_in_local_mission_coordinates';
            attArray(3).Value = 'm';
        case 'm_iridium_call_num'
            attArray(1).Value = 'number of iridium calls';
            attArray(2).Value = 'number_of_iridium_calls';
            attArray(3).Value = '1';
        case 'm_iridium_connected'
            attArray(1).Value = 'iridium connected';
            attArray(2).Value = 'iridium_connected';
            attArray(3).Value = '1';
        case 'm_iridium_dialed_num'
            attArray(1).Value = 'number of iridium dials';
            attArray(2).Value = 'number_of_iridium_dials';
            attArray(3).Value = '1';
        case 'x_dr_state'
            attArray(1).Value = 'state machine used in computing water velocity';
            attArray(2).Value = 'state machine used in computing water velocity';
            attArray(3).Value = '1';
            attArray(5).Name  = 'comments';
            attArray(5).Value = 'mission_start=0, underwater=1,awaiting_fix=2, awaiting_postfix=3, awaiting_dive=4';

        otherwise
            disp(['Unknown sensor: ', varName]);
            disp(['Please add related entry on this sensor on file ', mfilename]);
            attArray(1).Value = varName;
            attArray(2).Value = varName;
            attArray(3).Value = '1';
    end;

end
