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
    
end

