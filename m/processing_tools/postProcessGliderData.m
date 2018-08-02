function [data_conv, meta_conv] = postProcessGliderData( data_proc, meta_proc, vars, varargin )
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
  

    narginchk(3, 7);

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
               'chla',                           'chlorophyll');
    options.deployment = struct();
    options.attributes = struct();
    
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
    
    
    %% Data and sensor variables. Populate sensor list and convert the variable names as indicated by param_convert option
    % Initial definition
    meta_conv.sensor.sources = 'postProcessGliderData';
    meta_conv.sensor.method  = 'postProcessGliderData';
    data_conv.sensor         = [];    
    meta_conv.sensor_maker.sources = 'postProcessGliderData';
    meta_conv.sensor_maker.method  = 'postProcessGliderData';
    data_conv.sensor_maker         = []; 
    meta_conv.sensor_model.sources = 'postProcessGliderData';
    meta_conv.sensor_model.method  = 'postProcessGliderData';
    data_conv.sensor_model         = []; 
    meta_conv.sensor_serial_no.sources = 'postProcessGliderData';
    meta_conv.sensor_serial_no.method  = 'postProcessGliderData';
    data_conv.sensor_serial_no         = []; 
    meta_conv.sensor_units.sources = 'postProcessGliderData';
    meta_conv.sensor_units.method  = 'postProcessGliderData';
    data_conv.sensor_units         = []; 
    meta_conv.sensor_accuracy.sources = 'postProcessGliderData';
    meta_conv.sensor_accuracy.method  = 'postProcessGliderData';
    data_conv.sensor_accuracy         = []; 
    meta_conv.sensor_resolution.sources = 'postProcessGliderData';
    meta_conv.sensor_resolution.method  = 'postProcessGliderData';
    data_conv.sensor_resolution         = []; 
    
    % Fill values
    param_convert_list = fieldnames(options.param_convert);
    empty_string16 = '                ';
    empty_string32 = char(strcat({empty_string16},{empty_string16}));                     
    empty_string64 = char(strcat({empty_string32},{empty_string32}));
    empty_string256 = char(strcat({empty_string64},{empty_string64},{empty_string64},{empty_string64})); 
    field_list = fieldnames(data_conv);
    for param_change_idx = 1:numel(param_convert_list)
        param_convert_sensor = empty_string64;
        param_convert_name = param_convert_list{param_change_idx};
        laux = min(length(param_convert_sensor),length(param_convert_name));
        param_convert_sensor(1:laux) = upper(param_convert_name(1:laux));
        
        param_choice = options.param_convert.(param_convert_name);
        if isfield(meta_conv, param_choice) && ismember(param_choice, field_list) && any(data_conv.(param_choice) > 0) 
            [data_conv(:).(param_convert_name)] = deal(data_conv(:).(param_choice));
            data_conv = rmfield(data_conv,param_choice);
            
            [meta_conv(:).(param_convert_name)] = deal(meta_conv(:).(param_choice));
            meta_conv = rmfield(meta_conv,param_choice);
        end
        field_list = fieldnames(data_conv);
        if isfield(meta_conv, param_convert_name) && ismember(param_convert_name, field_list) && any(data_conv.(param_convert_name) > 0) 
            % TODO: Could input dimensions and read the structure to know
            % how to truncate/extend the size of the strings.            
            param_convert_serial_number = empty_string16;
            param_convert_units         = empty_string16;
            param_convert_accuracy      = empty_string32; 
            param_convert_resolution    = empty_string32; 
            
            % Check values in attributes
            if isfield(vars,param_convert_name) && isfield(vars.(param_convert_name), 'attributes')
                param_convert_atts = vars.(param_convert_name).attributes;
                
                % Check sensor_serial_number attribute in vars.(param_convert_name)
                param_convert_serial_number_select = strcmp('sensor_serial_number', {param_convert_atts.name});
                if any(param_convert_serial_number_select)
                    auxval = param_convert_atts(param_convert_serial_number_select).value;
                    laux = min(length(param_convert_serial_number),length(auxval));
                    param_convert_serial_number(1:laux) = auxval(1:laux);
                end
                
                % Check units attribute in vars.(param_convert_name)
                param_convert_units_select = strcmp('units', {param_convert_atts.name});
                if any(param_convert_units_select)
                    auxval = param_convert_atts(param_convert_units_select).value;
                    laux = min(length(param_convert_units),length(auxval));
                    param_convert_units(1:laux) = auxval(1:laux);
                end
                
                % Check accuracy attribute in vars.(param_convert_name)
                param_convert_accuracy_select = strcmp('accuracy', {param_convert_atts.name});
                if any(param_convert_accuracy_select)
                    auxval = param_convert_atts(param_convert_accuracy_select).value;
                    laux = min(length(param_convert_accuracy),length(auxval));
                    param_convert_accuracy(1:laux) = auxval(1:laux);
                end
                
                % Check resolution attribute in vars.(param_convert_name)
                param_convert_resolution_select = strcmp('resolution', {param_convert_atts.name});
                if any(param_convert_resolution_select)
                    auxval = param_convert_atts(param_convert_resolution_select).value;
                    laux = min(length(param_convert_resolution),length(auxval));
                    param_convert_resolution(1:laux) = auxval(1:laux);
                end
            end
            
            % Complete values
            if numel(data_conv.sensor) == 0
                data_conv.sensor            = param_convert_sensor;
                data_conv.sensor_maker      = empty_string256; 
                data_conv.sensor_model      = empty_string256; 
                data_conv.sensor_serial_no  = param_convert_serial_number; 
                data_conv.sensor_units      = param_convert_units;             
                data_conv.sensor_accuracy   = param_convert_accuracy; 
                data_conv.sensor_resolution = param_convert_resolution; 
            else
                data_conv.sensor(end+1,:)            = param_convert_sensor;
                data_conv.sensor_maker(end+1,:)      = empty_string256; 
                data_conv.sensor_model(end+1,:)      = empty_string256; 
                data_conv.sensor_serial_no(end+1,:)  = param_convert_serial_number; 
                data_conv.sensor_units(end+1,:)      = param_convert_units;             
                data_conv.sensor_accuracy(end+1,:)   = param_convert_accuracy; 
                data_conv.sensor_resolution(end+1,:) = param_convert_resolution; 
            end
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
    data_conv.history_step         = 'ARFM';   

    meta_conv.history_software.sources = 'postProcessGliderData';
    meta_conv.history_software.method  = 'postProcessGliderData';
    data_conv.history_software         = 'GTBSOCIB';

    meta_conv.history_software_release.sources = 'postProcessGliderData';
    meta_conv.history_software_release.method  = 'postProcessGliderData';
    data_conv.history_software_release = configGliderToolboxVersion('short');

    meta_conv.history_reference.sources = 'postProcessGliderData';
    meta_conv.history_reference.method  = 'postProcessGliderData';
    data_conv.history_reference         = 'N/A';

    meta_conv.history_date.sources = 'postProcessGliderData';
    meta_conv.history_date.method  = 'postProcessGliderData';
    data_conv.history_date         = datestr(posixtime2utc(posixtime()), 'yyyymmddHHMMSS');

    meta_conv.history_action.sources = 'postProcessGliderData';
    meta_conv.history_action.method  = 'postProcessGliderData';
    data_conv.history_action         = 'IP';         

    meta_conv.history_parameter.sources = 'postProcessGliderData';
    meta_conv.history_parameter.method  = 'postProcessGliderData';
    data_conv.history_parameter         = 'All Data';    

    meta_conv.history_previous_value.sources = 'postProcessGliderData';
    meta_conv.history_previous_value.method  = 'postProcessGliderData';
    data_conv.history_previous_value         = 99999;         

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
    data_conv.trans_frequency         = 'N/A';       

    meta_conv.positioning_system.sources = 'postProcessGliderData';
    meta_conv.positioning_system.method  = 'postProcessGliderData';
    data_conv.positioning_system         = 'GPS';

    meta_conv.platform_family.sources = 'postProcessGliderData';
    meta_conv.platform_family.method  = 'postProcessGliderData';
    data_conv.platform_family         = 'coastal glider';    % TODO: verify value

    meta_conv.platform_type.sources = 'postProcessGliderData';
    meta_conv.platform_type.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'platform_type')
        data_conv.platform_type         = options.deployment.platform_type; 
    elseif isfield(options.deployment, 'glider_model')
        data_conv.platform_type         = options.deployment.glider_model; 
    else
        data_conv.platform_type         = 'N/A';         
    end
    
    meta_conv.platform_maker.sources = 'postProcessGliderData';
    meta_conv.platform_maker.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'platform_maker')
        data_conv.platform_maker         = options.deployment.platform_maker; 
    elseif isfield(options.deployment, 'glider_model')
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
        data_conv.platform_maker         = 'N/A';
    end
    
    meta_conv.firmware_version_navigation.sources = 'postProcessGliderData';
    meta_conv.firmware_version_navigation.method  = 'postProcessGliderData';
    data_conv.firmware_version_navigation         = 'N/A';   

    meta_conv.firmware_version_science.sources = 'postProcessGliderData';
    meta_conv.firmware_version_science.method  = 'postProcessGliderData';
    data_conv.firmware_version_science         = 'N/A';    

    meta_conv.manual_version.sources = 'postProcessGliderData';
    meta_conv.manual_version.method  = 'postProcessGliderData';
    data_conv.manual_version         = 'N/A';    

    meta_conv.glider_serial_no.sources = 'postProcessGliderData';
    meta_conv.glider_serial_no.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_serial')
        data_conv.glider_serial_no         = options.deployment.glider_serial;    
    else
        data_conv.glider_serial_no         = 'N/A';    
    end
    
    meta_conv.standard_format_id.sources = 'postProcessGliderData';
    meta_conv.standard_format_id.method  = 'postProcessGliderData';
    data_conv.standard_format_id         = 'N/A';    

    meta_conv.dac_format_id.sources = 'postProcessGliderData';
    meta_conv.dac_format_id.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_model')
        data_conv.dac_format_id         = options.deployment.glider_model;    
    else
        data_conv.dac_format_id         = 'N/A';    
    end
    
    meta_conv.wmo_inst_type.sources = 'postProcessGliderData';
    meta_conv.wmo_inst_type.method  = 'postProcessGliderData';
    data_conv.wmo_inst_type         = '870';    

    meta_conv.project_name.sources = 'postProcessGliderData';
    meta_conv.project_name.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_name')
        data_conv.project_name     = options.deployment.deployment_name;    
    else
        data_conv.project_name     = 'N/A';    
    end
    
    meta_conv.data_centre.sources = 'postProcessGliderData';
    meta_conv.data_centre.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'data_center')
        data_conv.data_centre      = options.deployment.data_center(1:2);
    else
        data_conv.data_centre      = 'SO';
    end
    
    if isfield(options.deployment, 'deployment_start') && ...
       isfield(options.deployment, 'glider_name') && ...
       isfield(options.deployment, 'glider_deployment_code')
   
        meta_conv.id.sources = 'postProcessGliderData';
        meta_conv.id.method  = 'postProcessGliderData';
        id_date = datestr(options.deployment.deployment_start, 'yyyymmdd');
        id_glider = options.deployment.glider_name;
        id_dep = options.deployment.glider_deployment_code;
                
        if isfield(options.attributes, 'data_mode')
            id_mode = options.attributes.data_mode;
        else
            id_mode = 'R';
        end
        data_conv.id      = strcat(['GL_', id_date, '_', id_glider, '_', id_dep, '_', id_mode]);
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
    data_conv.anomaly         = 'N/A';    

    meta_conv.battery_type.sources = 'postProcessGliderData';
    meta_conv.battery_type.method  = 'postProcessGliderData';
    data_conv.battery_type         = 'N/A';   

    meta_conv.battery_packs.sources = 'postProcessGliderData';
    meta_conv.battery_packs.method  = 'postProcessGliderData';
    data_conv.battery_packs         = 'N/A';    

    meta_conv.special_features.sources = 'postProcessGliderData';
    meta_conv.special_features.method  = 'postProcessGliderData';
    data_conv.special_features         = 'N/A';    

    meta_conv.glider_owner.sources = 'postProcessGliderData';
    meta_conv.glider_owner.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_owner')
        data_conv.glider_owner         = options.deployment.glider_owner;
    else
        data_conv.glider_owner         = 'N/A';    
    end
    
    meta_conv.operating_institution.sources = 'postProcessGliderData';
    meta_conv.operating_institution.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'operating_institution')
        data_conv.operating_institution  = options.deployment.operating_institution;
    else
        data_conv.operating_institution  = 'N/A';    
    end
    
    meta_conv.customization.sources = 'postProcessGliderData';
    meta_conv.customization.method  = 'postProcessGliderData';
    data_conv.customization         = 'None';    

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
        data_conv.deployment_start_latitude      = options.deployment.latitude_start; 
    else
        data_conv.deployment_start_latitude      = 99999; 
    end

    meta_conv.deployment_start_longitude.sources = 'postProcessGliderData';
    meta_conv.deployment_start_longitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'longitude_start')
        data_conv.deployment_start_longitude      = options.deployment.longitude_start; 
    else
        data_conv.deployment_start_longitude      = 99999;
    end


    meta_conv.deployment_platform.sources = 'postProcessGliderData';
    meta_conv.deployment_platform.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'glider_name')
        data_conv.deployment_platform      = options.deployment.glider_name; 
    else
        data_conv.deployment_platform      = 'N/A';    
    end
    

    meta_conv.deployment_cruise_id.sources = 'postProcessGliderData';
    meta_conv.deployment_cruise_id.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_cruise_id')
        data_conv.deployment_cruise_id      = num2str(options.deployment.deployment_cruise_id); 
    else
        data_conv.deployment_cruise_id         = 'N/A';
    end

    meta_conv.deployment_reference_station_id.sources = 'postProcessGliderData';
    meta_conv.deployment_reference_station_id.method  = 'postProcessGliderData';
    data_conv.deployment_reference_station_id         = 'N/A';   

    meta_conv.deployment_end_date.sources = 'postProcessGliderData';
    meta_conv.deployment_end_date.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'deployment_end') && ~isnan(options.deployment.deployment_end)
        data_conv.deployment_end_date      = datestr(options.deployment.deployment_end, 'yyyymmddHHMMSS'); 
    else
        data_conv.deployment_end_date      = 'yyyymmddHHMMSS'; 
    end

    meta_conv.deployment_end_latitude.sources = 'postProcessGliderData';
    meta_conv.deployment_end_latitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'latitude_end')
        data_conv.deployment_end_latitude      = options.deployment.latitude_end; 
    else
        data_conv.deployment_end_latitude      = 99999; 
    end

    meta_conv.deployment_end_longitude.sources = 'postProcessGliderData';
    meta_conv.deployment_end_longitude.method  = 'postProcessGliderData';
    if isfield(options.deployment, 'longitude_end')
        data_conv.deployment_end_longitude      = options.deployment.longitude_end; 
    else
        data_conv.deployment_end_longitude      = 99999; 
    end

    meta_conv.deployment_end_status.sources = 'postProcessGliderData';
    meta_conv.deployment_end_status.method  = 'postProcessGliderData';
    if isfield(options.attributes, 'data_mode')
        data_conv.deployment_end_status         = options.attributes.data_mode;   
    else
        data_conv.deployment_end_status         = 'R';   
    end
    
    meta_conv.deployment_operator.sources = 'postProcessGliderData';
    meta_conv.deployment_operator.method  = 'postProcessGliderData';
    data_conv.deployment_operator         = 'N/A';    

    meta_conv.derivation_parameter.sources = 'postProcessGliderData';
    meta_conv.derivation_parameter.method  = 'postProcessGliderData';
    data_conv.derivation_parameter         = 'N/A';    

    meta_conv.derivation_equation.sources = 'postProcessGliderData';
    meta_conv.derivation_equation.method  = 'postProcessGliderData';
    data_conv.derivation_equation         = 'N/A';    

    meta_conv.derivation_coefficient.sources = 'postProcessGliderData';
    meta_conv.derivation_coefficient.method  = 'postProcessGliderData';
    data_conv.derivation_coefficient         = 'N/A';    

    meta_conv.derivation_comment.sources = 'postProcessGliderData';
    meta_conv.derivation_comment.method  = 'postProcessGliderData';
    data_conv.derivation_comment         = 'N/A';   

    meta_conv.derivation_date.sources = 'postProcessGliderData';
    meta_conv.derivation_date.method  = 'postProcessGliderData';
    data_conv.derivation_date         = datestr(posixtime2utc(posixtime()), 'yyyymmddHHMMSS');   
    
end

