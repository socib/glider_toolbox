function [ convert_data, convert_meta ] = convert2NetCDFEGO( variable_data, variable_meta )
% TODO: Add description convert2NetCDFEGO

    narginchk(2, 2);
    
    convert_data = variable_data;
    convert_meta = variable_meta;
        
    % Make all attributes uppercase
    meta_var_name_list = fieldnames(convert_meta);
    for var_name_idx = 1:numel(meta_var_name_list)
      var_name = meta_var_name_list{var_name_idx};
      new_var_name = upper(var_name);
      [convert_meta(:).(new_var_name)] = deal(convert_meta(:).(var_name));
      convert_meta = rmfield(convert_meta,var_name);
    end   
    
    
    % Make all data uppercase and convert values to have STRINGXX dims
    data_var_name_list = fieldnames(convert_data);
    for var_name_idx = 1:numel(data_var_name_list)
      var_name = data_var_name_list{var_name_idx};
      new_var_name = upper(var_name);
      [convert_data(:).(new_var_name)] = deal(convert_data(:).(var_name));
      convert_data = rmfield(convert_data,var_name);
      
      % Truncate values for STRINGXX dimensions
      if isfield(convert_meta, new_var_name)
          if isfield(convert_meta(:).(new_var_name),'dimensions')
              % Browse dimensions looking for STRINGXX
              for k=1:length(convert_meta.(new_var_name).dimensions)
                  % Check if dimension is of type STRINGXX
                  if strfind(convert_meta.(new_var_name).dimensions{k}, 'STRING')
                      % Extract XX dimension from name
                      dim_bytes = str2num(strrep(convert_meta.(new_var_name).dimensions{k}, 'STRING',''));
                      
                      % Truncate string to the maximum allowed if larger
                      % than dimension specifications
                      if length(convert_data.(new_var_name)) > dim_bytes
                          convert_data.(new_var_name) = convert_data.(new_var_name)(1:dim_bytes);
                      end
                  end
              end
          end
      end
    end   

end

