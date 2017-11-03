function [data_conv, meta_conv] = postProcessGliderData( data_proc, meta_proc, varargin )
%TODO: Help
% This function converts the data and meta data to EGO standards
% It can be generalized using the varargin option to any conversion but for
% now I am going to hard code the entire change

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

    % TODO: Check if juld exist?
    if any(time_field_present)
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
    profile_direction = data_conv.profile_direction;   % TODO: Check if it exists and generalize
    positioning_method = data_conv.positioning_method; % TODO: Check if it exists and generalize
    data_conv.phase = zeros(size(profile_direction));
    data_conv.phase_number = zeros(size(profile_direction));
    
    %TODO: Not very elegant, check if we can optimize the algorithm using
    %      array operations
    for i=2:numel(data_conv.profile_direction)
        if profile_direction(i) == profile_direction(i-1);
            data_conv.phase_number(i) = data_conv.phase_number(i-1);
            data_conv.phase(i) = data_conv.phase(i-1);
        else
            data_conv.phase_number(i) = data_conv.phase_number(i-1);
            
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
  
end

