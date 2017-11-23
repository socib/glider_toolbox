function [data_conv, meta_conv] = postProcessGliderData( data_proc, meta_proc, varargin )
% POSTPROCESSGLIDERDATA    Transform processed data to fit EGO standards
%
%  Syntax:
%    [DATA_CONV, META_CONV] = POSTPROCESSGLIDERDATA( DATA_PROC, META_PROC)
%    [DATA_CONV, META_CONV] = POSTPROCESSGLIDERDATA( DATA_PROC, META_PROC, PARAM1, VAL1)
%
%  Description:
%    POSTPROCESSGLIDERDATA converts names and units of the variables of the
%    inputs to fit the EGO standards.
%
%  Input:
%
%    DATA_PROC should be a struct in the format returned by POSTPROCESSGLIDERDATA,
%    where each field is a sequence of measurements of the variable with the 
%    same name.

%    META_PROC should be a struct in the format returned by POSTPROCESSGLIDERDATA,
%    where each field is a sequence of meta data of the variable with the 
%    same name.
%
%  Output:
%
%    DATA_CONV is a struct in the same format as DATA_PROC, with time sequences 
%    resulting from the processing actions described above, performed according
%    to the options described below.
%
%    META_CONV is also a struct with one field per variable, adding processing 
%    metadata to any existing metadata in META_PROC.
%
%  Options:
%
%    TIME: Variable name to be used as time.
%
%    PARAM_CONVERT: Defines the parameters to be renamed as an array of
%      strings {param_ego_1 param_socib_1 param_ego_2 param_socib_1 ...}
%
%    DEPLOYMENT contains the information of the deployment to be processed.
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
  

    narginchk(2, 4);

    %% Set parameter changes options.
    options = struct();
    
    options.time = {'time'};
    options.param_convert = ...
        struct('cndc',                           'conductivity', ...
               'psal',                           'salinity', ...
               'temp',                           'temperature', ...
               'pres',                           'pressure', ...
               'molar_doxy',                     'oxygen_concentration', ...
               'oxygen_saturation',              'sci_oxy3835_saturation', ...
               'temp_doxy',                      'temperature_oxygen', ...
               'chla',                           'chlorophyll', ...
               'temp_spectrophotometer_nitrate', 'temperature_optics');
    options.deployment = struct();
    
    %% Get options from extra arguments.
    % Parse option key-value pairs in any accepted call signature.
    if isscalar(varargin) && isstruct(varargin{1})
        % Options passed as a single option struct argument:
        % field names are option keys and field values are option values.
        option_key_list = fieldnames(varargin{1});
        option_val_list = struct2cell(varargin{1});
    elseif mod(numel(varargin), 2) == 0
        % Options passed as key-value argument pairs.
        option_key_list = varargin(1:2:end);
        option_val_list = varargin(2:2:end);
    else
        error('glider_toolbox:postProcessGliderData:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(option_key_list)
        opt = lower(option_key_list{opt_idx});
        val = option_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:postProcessGliderData:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end

    %% Initialize output variables.
    data_conv = data_proc;
    meta_conv = meta_proc;

    %% Create Julian date field
    % Assumes time is in senconds since 1970.    
    time_field_list = cellstr(options.time);
    time_field_present = isfield(data_conv, time_field_list);

    if any(time_field_present) && ~isfield(data_conv, 'juld')
        time_field_index = find(time_field_present, 1);
        time_field = time_field_list{time_field_index};
        if isfield(data_conv, time_field) 
            data_conv(:).juld = data_conv(:).(time_field)/86400 + daysact('1-jan-1950',  '1-jan-1970');
            meta_conv.juld.sources = 'time';
            meta_conv.juld.filling = 'linear';
        end
    end 

    %% Phase and phase number
    meta_conv.phase.sources = 'profile_direction positioning_method';
    meta_conv.phase.method = 'postProcessGliderData';
    meta_conv.phase_number.sources = 'profile_direction positioning_method';
    meta_conv.phase_number.method = 'postProcessGliderData';
    profile_direction = data_conv.profile_direction;   
    positioning_method = data_conv.positioning_method; 
    data_conv.phase = zeros(size(profile_direction));
    data_conv.phase_number = zeros(size(profile_direction));
    
    %TODO: More accurate calculations of phase and phase_number
    for i=2:numel(data_conv.profile_direction)
        if profile_direction(i) == profile_direction(i-1);
            data_conv.phase_number(i) = data_conv.phase_number(i-1);
            data_conv.phase(i) = data_conv.phase(i-1);
        else
            data_conv.phase_number(i) = data_conv.phase_number(i-1) + 1;
            
            % Check the phase according to profile direction
            if profile_direction(i) == 0 
                if positioning_method == 0
                    data_conv.phase(i) = 0;
                else
                    data_conv.phase(i) = 2;
                end
            elseif profile_direction(i) == 1
                data_conv.phase(i) = 1;
            elseif profile_direction(i) == -1
                data_conv.phase(i) = 4;
            else
                data_conv.phase(i) = 6;
            end
        end
    end
    
    %% Data variables
    param_convert_list = fieldnames(options.param_convert);
    field_list = fieldnames(data_conv);
    for param_change_idx = 1:numel(param_convert_list)
        param_convert_name = param_convert_list{param_change_idx};
        param_choice = options.param_convert.(param_convert_name);
        if isfield(meta_conv, param_choice) && ismember(param_choice, field_list) && any(data_conv.(param_choice) > 0) 
            [data_conv(:).(param_convert_name)] = deal(data_conv(:).(param_choice));
            data_conv = rmfield(data_conv,param_choice);
            
            [meta_conv(:).(param_convert_name)] = deal(meta_conv(:).(param_choice));
            meta_conv = rmfield(meta_conv,param_choice);
        end
    end
  
    %% Create glider_original_parameter_name from field
    meta_conv_list = fieldnames(meta_conv);
    for param_change_idx = 1:numel(meta_conv_list)
        param_convert_name = meta_conv_list{param_change_idx};
        if isfield(meta_conv.(param_convert_name), 'sources')
            meta_conv.(param_convert_name).glider_original_parameter_name = meta_conv.(param_convert_name).sources;
            meta_conv.(param_convert_name) = rmfield(meta_conv.(param_convert_name),'sources');
        end
    end
    
    %TODO: Allow deployment to be input and complete data variable
    %attributes if deployment contains the data that is needed. These are:
    %        - sensor_orientation: downward, upward, vertical, horizontal.
    %        - sensor_name
    %        - sensor_serial_number
    %        - ancillary_variables: PARAM_QC. Could be completed in QC processing
    %        - accuracy, precision, resolution: BD
    %        - cell_methods: require new implementation which considers
    %               this info in the instrumentation webapp
    %        - DM_indicator: needs to be completed from general config
    %        processing_mode
    
    
    %% Fill History information 
    %TODO: The values should be filled along the process, in
    %      particular the history, and then the dimension of the variable
    %      will be set automatically by generateOutputNetCDF. I leave these
    %      lines as a reference of the data that should be filled but it is
    %      to be removed when it is correctly implemented. 
    meta_conv.history_institution.sources = 'postProcessGliderData';
    meta_conv.history_institution.method = 'postProcessGliderData';
    if isfield(options.deployment, 'data_center')
        data_conv.history_institution      = options.deployment.data_center(1:2);
    else
        data_conv.history_institution      = 'SO';
    end

    meta_conv.history_step.sources = 'postProcessGliderData';
    meta_conv.history_step.method  = 'postProcessGliderData';
    data_conv.history_step         = 'ARFM';   %TODO: confirm value

    meta_conv.history_software.sources = 'postProcessGliderData';
    meta_conv.history_software.method  = 'postProcessGliderData';
    data_conv.history_software         = 'GTBSOCIB';

    meta_conv.history_software_release.sources = 'postProcessGliderData';
    meta_conv.history_software_release.method  = 'postProcessGliderData';
    data_conv.history_software_release = configGliderToolboxVersion('short');

    meta_conv.history_reference.sources = 'postProcessGliderData';
    meta_conv.history_reference.method  = 'postProcessGliderData';
    data_conv.history_reference         = 'NA';

    meta_conv.history_date.sources = 'postProcessGliderData';
    meta_conv.history_date.method  = 'postProcessGliderData';
    data_conv.history_date         = datestr(posixtime2utc(posixtime()), 'yyyymmddHHMMSS');

    meta_conv.history_action.sources = 'postProcessGliderData';
    meta_conv.history_action.method  = 'postProcessGliderData';
    data_conv.history_action         = 'IP';          % TODO: verify value

    meta_conv.history_parameter.sources = 'postProcessGliderData';
    meta_conv.history_parameter.method  = 'postProcessGliderData';
    data_conv.history_parameter         = 'All Data';    % TODO: verify value

    meta_conv.history_previous_value.sources = 'postProcessGliderData';
    meta_conv.history_previous_value.method  = 'postProcessGliderData';
    data_conv.history_previous_value         = 99999;         % TODO: verify value

    meta_conv.history_start_time_index.sources = 'postProcessGliderData';
    meta_conv.history_start_time_index.method  = 'postProcessGliderData';
    data_conv.history_start_time_index         = int32(1);

    meta_conv.history_stop_time_index.sources = 'postProcessGliderData';
    meta_conv.history_stop_time_index.method  = 'postProcessGliderData';
    data_conv.history_stop_time_index         = int32(1);

    meta_conv.history_qctest.sources = 'postProcessGliderData';
    meta_conv.history_qctest.method  = 'postProcessGliderData';
    data_conv.history_qctest         = '00';

    %% Fill Glider metadata
    meta_conv.trans_system.sources = 'postProcessGliderData';
    meta_conv.trans_system.method  = 'postProcessGliderData';
    data_conv.trans_system         = 'IRIDIUM';

    meta_conv.trans_system_id.sources = 'postProcessGliderData';
    meta_conv.trans_system_id.method  = 'postProcessGliderData';
    data_conv.trans_system_id         = 'N/A';

    meta_conv.trans_frequency.sources = 'postProcessGliderData';
    meta_conv.trans_frequency.method  = 'postProcessGliderData';
    data_conv.trans_frequency         = 'N/A';       % TODO: verify value

    meta_conv.positioning_system.sources = 'postProcessGliderData';
    meta_conv.positioning_system.method  = 'postProcessGliderData';
    data_conv.positioning_system         = 'GPS';

    meta_conv.platform_family.sources = 'postProcessGliderData';
    meta_conv.platform_family.method  = 'postProcessGliderData';
    data_conv.platform_family         = 'coastal glider';    % TODO: verify value

    meta_conv.platform_type.sources = 'postProcessGliderData';
    meta_conv.platform_type.method  = 'postProcessGliderData';
    meta_conv.platform_maker.sources = 'postProcessGliderData';
    meta_conv.platform_maker.method  = 'postProcessGliderData';
    data_conv.platform_maker         = 'N/A';
    if isfield(options.deployment, 'glider_model')
        data_conv.platform_type         = options.deployment.glider_model; 
        
        if ~isempty(regexpi(options.deployment.glider_model, '.*slocum.*g1.*', 'match', 'once'))
        	data_conv.platform_maker         = 'Webb Research Corporation';
        elseif ~isempty(regexpi(options.deployment.glider_model, '.*slocum.*g2.*', 'match', 'once'))
        	data_conv.platform_maker         = 'Webb Research Corporation';
        elseif ~isempty(regexpi(options.deployment.glider_model, '.*seaglider.*', 'match', 'once'))
        	data_conv.platform_maker         = 'Kongsberg';
        elseif ~isempty(regexpi(options.deployment.glider_model, '.*seaexplorer.*', 'match', 'once'))
        	data_conv.platform_maker         = 'Alseamar';
        end
    else
        data_conv.platform_type         = 'N/A';         % TODO: verify value
    end
    
    meta_conv.firmware_version_navigation.sources = 'postProcessGliderData';
    meta_conv.firmware_version_navigation.method  = 'postProcessGliderData';
    data_conv.firmware_version_navigation         = 'N/A';    % TODO: verify value

    meta_conv.firmware_version_science.sources = 'postProcessGliderData';
    meta_conv.firmware_version_science.method  = 'postProcessGliderData';
    data_conv.firmware_version_science         = 'N/A';    % TODO: verify value

    meta_conv.manual_version.sources = 'postProcessGliderData';
    meta_conv.manual_version.method  = 'postProcessGliderData';
    data_conv.manual_version         = 'N/A';    % TODO: verify value

    meta_conv.glider_serial_no.sources = 'postProcessGliderData';
    meta_conv.glider_serial_no.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_serial')
        data_conv.glider_serial_no         = options.deployment.glider_serial;    
    else
        data_conv.glider_serial_no         = 'N/A';    
    end
    
    meta_conv.standard_format_id.sources = 'postProcessGliderData';
    meta_conv.standard_format_id.method  = 'postProcessGliderData';
    data_conv.standard_format_id         = 'N/A';    % TODO: verify value

    meta_conv.dac_format_id.sources = 'postProcessGliderData';
    meta_conv.dac_format_id.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_model')
        data_conv.dac_format_id         = options.deployment.glider_model;    
    else
        data_conv.dac_format_id         = 'N/A';    
    end
    
    meta_conv.wmo_inst_type.sources = 'postProcessGliderData';
    meta_conv.wmo_inst_type.method  = 'postProcessGliderData';
    data_conv.wmo_inst_type         = '870';    % TODO: verify value

    meta_conv.project_name.sources = 'postProcessGliderData';
    meta_conv.project_name.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_name')
        data_conv.project_name     = options.deployment.deployment_name;    
    else
        data_conv.project_name     = 'N/A';    % TODO: verify value
    end
    
    meta_conv.data_center.sources = 'postProcessGliderData';
    meta_conv.data_center.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'data_center')
        data_conv.data_center      = options.deployment.data_center(1:2);
    else
        data_conv.data_center      = 'SO';
    end

    meta_conv.pi_name.sources = 'postProcessGliderData';
    meta_conv.pi_name.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'principal_investigator')
        data_conv.pi_name      = options.deployment.principal_investigator;
    else
        data_conv.pi_name         = 'N/A';    
    end
    
    meta_conv.anomaly.sources = 'postProcessGliderData';
    meta_conv.anomaly.method  = 'postProcessGliderData';
    data_conv.anomaly         = 'None';    

    meta_conv.battery_type.sources = 'postProcessGliderData';
    meta_conv.battery_type.method  = 'postProcessGliderData';
    data_conv.battery_type         = 'N/A';    % TODO: verify value

    meta_conv.battery_packs.sources = 'postProcessGliderData';
    meta_conv.battery_packs.method  = 'postProcessGliderData';
    data_conv.battery_packs         = 'N/A';    % TODO: verify value

    meta_conv.special_features.sources = 'postProcessGliderData';
    meta_conv.special_features.method  = 'postProcessGliderData';
    data_conv.special_features         = 'N/A';    % TODO: verify value

    meta_conv.glider_owner.sources = 'postProcessGliderData';
    meta_conv.glider_owner.method  = 'postProcessGliderData';
    data_conv.glider_owner         = 'SOCIB';    % TODO: verify value

    meta_conv.operating_institution.sources = 'postProcessGliderData';
    meta_conv.operating_institution.method  = 'postProcessGliderData';
    data_conv.operating_institution         = 'SOCIB';    % TODO: verify value

    meta_conv.customization.sources = 'postProcessGliderData';
    meta_conv.customization.method  = 'postProcessGliderData';
    data_conv.customization         = 'None';    % TODO: verify value

    meta_conv.deployment_start_date.sources = 'postProcessGliderData';
    meta_conv.deployment_start_date.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_start')
        data_conv.deployment_start_date      = datestr(options.deployment.deployment_start, 'yyyymmddHHMMSS'); 
    else
        data_conv.deployment_start_date      = 'yyyymmddHHMMSS'; 
    end

    meta_conv.deployment_start_latitude.sources = 'postProcessGliderData';
    meta_conv.deployment_start_latitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'latitude_start')
        data_conv.deployment_start_latitude      = options.deployment.latitude_start; % TODO: not really this one
    else
        data_conv.deployment_start_latitude      = 99999; 
    end

    meta_conv.deployment_start_longitude.sources = 'postProcessGliderData';
    meta_conv.deployment_start_longitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'longitude_start')
        data_conv.deployment_start_longitude      = options.deployment.longitude_start; % TODO: not really this one
    else
        data_conv.deployment_start_longitude      = 99999;
    end

    meta_conv.deployment_start_qc.sources = 'postProcessGliderData';
    meta_conv.deployment_start_qc.method  = 'postProcessGliderData';
    data_conv.deployment_start_qc         = -128;    % TODO: verify value

    meta_conv.deployment_platform.sources = 'postProcessGliderData';
    meta_conv.deployment_platform.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_name')
        data_conv.deployment_platform      = options.deployment.glider_name; % TODO: not really this one
    else
        data_conv.deployment_platform      = 'N/A';    
    end
    

    meta_conv.deployment_cruise_id.sources = 'postProcessGliderData';
    meta_conv.deployment_cruise_id.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_cruise_id')
        data_conv.deployment_cruise_id      = num2str(options.deployment.deployment_cruise_id); % TODO: not really this one
    else
        data_conv.deployment_cruise_id         = 'N/A';    % TODO: verify value
    end

    meta_conv.deployment_reference_station_id.sources = 'postProcessGliderData';
    meta_conv.deployment_reference_station_id.method  = 'postProcessGliderData';
    data_conv.deployment_reference_station_id         = 'None';    % TODO: verify value

    meta_conv.deployment_end_date.sources = 'postProcessGliderData';
    meta_conv.deployment_end_date.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_end') && ~isnan(options.deployment.deployment_end)
        data_conv.deployment_end_date      = datestr(options.deployment.deployment_end, 'yyyymmddHHMMSS'); 
    else
        data_conv.deployment_end_date      = 'yyyymmddHHMMSS'; % TODO: verify value
    end

    meta_conv.deployment_end_latitude.sources = 'postProcessGliderData';
    meta_conv.deployment_end_latitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'latitude_end')
        data_conv.deployment_end_latitude      = options.deployment.latitude_end; % TODO: not really this one
    else
        data_conv.deployment_end_latitude      = 99999; % TODO: verify value
    end

    meta_conv.deployment_end_longitude.sources = 'postProcessGliderData';
    meta_conv.deployment_end_longitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'longitude_end')
        data_conv.deployment_end_longitude      = options.deployment.longitude_end; % TODO: not really this one
    else
        data_conv.deployment_end_longitude      = 99999; % TODO: verify value
    end

    meta_conv.deployment_end_qc.sources = 'postProcessGliderData';
    meta_conv.deployment_end_qc.method  = 'postProcessGliderData';
    data_conv.deployment_end_qc         = -128;    % TODO: verify value

    meta_conv.deployment_end_status.sources = 'postProcessGliderData';
    meta_conv.deployment_end_status.method  = 'postProcessGliderData';
    data_conv.deployment_end_status         = 'R';    % TODO: verify value

    meta_conv.deployment_operator.sources = 'postProcessGliderData';
    meta_conv.deployment_operator.method  = 'postProcessGliderData';
    data_conv.deployment_operator         = 'N/A';    % TODO: verify value

    %TODO: filling correctly the list of sensors and derivations for a
    %      specific data set. This will require more complex
    %      work in the database query which is out of scope of this
    %      development.
    meta_conv.sensor.sources = 'postProcessGliderData';
    meta_conv.sensor.method  = 'postProcessGliderData';
    data_conv.sensor         = 'N/A';    % TODO: verify value

    meta_conv.sensor_maker.sources = 'postProcessGliderData';
    meta_conv.sensor_maker.method  = 'postProcessGliderData';
    data_conv.sensor_maker         = 'N/A';    % TODO: verify value

    meta_conv.sensor_model.sources = 'postProcessGliderData';
    meta_conv.sensor_model.method  = 'postProcessGliderData';
    data_conv.sensor_model         = 'N/A';    % TODO: verify value

    meta_conv.sensor_no.sources = 'postProcessGliderData';
    meta_conv.sensor_no.method  = 'postProcessGliderData';
    data_conv.sensor_no         = 'N/A';    % TODO: verify value

    meta_conv.sensor_units.sources = 'postProcessGliderData';
    meta_conv.sensor_units.method  = 'postProcessGliderData';
    data_conv.sensor_units         = 'N/A';    % TODO: verify value

    meta_conv.sensor_accuracy.sources = 'postProcessGliderData';
    meta_conv.sensor_accuracy.method  = 'postProcessGliderData';
    data_conv.sensor_accuracy         = 'N/A';    % TODO: verify value

    meta_conv.sensor_resolution.sources = 'postProcessGliderData';
    meta_conv.sensor_resolution.method  = 'postProcessGliderData';
    data_conv.sensor_resolution         = 'N/A';    % TODO: verify value

    meta_conv.derivation_parameter.sources = 'postProcessGliderData';
    meta_conv.derivation_parameter.method  = 'postProcessGliderData';
    data_conv.derivation_parameter         = 'N/A';    % TODO: verify value

    meta_conv.derivation_equation.sources = 'postProcessGliderData';
    meta_conv.derivation_equation.method  = 'postProcessGliderData';
    data_conv.derivation_equation         = 'N/A';    % TODO: verify value

    meta_conv.derivation_coefficient.sources = 'postProcessGliderData';
    meta_conv.derivation_coefficient.method  = 'postProcessGliderData';
    data_conv.derivation_coefficient         = 'N/A';    % TODO: verify value

    meta_conv.derivation_comment.sources = 'postProcessGliderData';
    meta_conv.derivation_comment.method  = 'postProcessGliderData';
    data_conv.derivation_comment         = 'N/A';    % TODO: verify value

    meta_conv.derivation_date.sources = 'postProcessGliderData';
    meta_conv.derivation_date.method  = 'postProcessGliderData';
    data_conv.derivation_date         = datestr(posixtime2utc(posixtime()), 'yyyymmddHHMMSS');   
    
end

