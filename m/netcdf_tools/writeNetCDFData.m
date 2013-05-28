function writeNetCDFData(var_data, var_meta, global_meta, filename)
%WRITENETCDFDATA  Interface to low level functions to write data to a NetCDF file.
%
%  WRITENETCDFDATA(VAR_DATA, VAR_META, GLOBAL_META)  creates a NetCDF file 
%  according to global properties given in struct GLOBAL_META with the variables 
%  defined by the structs VAR_META and VAR_DATA.
%  GLOBAL_META is struct with the following fields:
%    NAME: string with the name of the NetCDF file to be written.
%    DIMENSIONS: struct array describing the dimensions, with fields:
%      NAME: string with the name of the dimension.
%      LENGTH: number with the length of the dimension (0 for record dimension).
%    ATTRIBUTES: struct array with global attributes with fields:
%      NAME: string with the name of the attribute.
%      VALUE: arbitrary typed value with the value of the attribute.
%  For every field in struct VAR_DATA a variable is created with the values in 
%  the field value. VAR_META should have a field with the same name containing 
%  the metadata for that variable in a struct with fields:
%    DIMENSIONS: (mandatory) cell array with the name of the dimensions of the
%      variable.
%    ATTRIBUTES: (optional) struct array with fields 'NAME' and 'VALUE' 
%      specifying the attributes of the variable.
%    NAME: (optional) string with the variable name as it should appear in the
%      NetCDF file. If this field is missing the variable is named after the
%      field name.
%
%  WRITENETCDFDATA(VAR_DATA, VAR_META, GLOBAL_META, FILENAME) will create a 
%  NetCDF file named FILENAME, overriding the 'NAME' field in GLOBAL_META.
%
%  Notes:
%    Fill value and scale conversions are always performed.
%
%    Only variables present in both VAR_DATA and VAR_META are written in to the
%    NetCDF file. Any field in VAR_DATA not present in VAR_META and viceversa is
%    silently omitted.
%
%    It would be more convenient to specify attributes and dimensions in structs
%    with attribute and dimension names as field names, and attribute values and
%    dimension lengths as field values. But due to a MATLAB limitation, it will 
%    cause trouble with attributes like '_FillValue' (because it is not a valid
%    field name).
%
%  Examples:
%    global_meta = struct()
%    global_meta.name = 'random.nc'
%    global_meta.dimensions = ...
%      struct('name', {'dim1' 'dim2' 'dim3'}, 'length', {0 5 10})
%    var_meta = struct()
%    var_meta.rand_vec = struct('dimensions', {{'dim1'}});
%    var_meta.rand_mat = struct('dimensions', {{'dim2' 'dim3'}});
%    var_data = struct()
%    var_data.rand_vec = rand(25, 1)
%    var_data.rand_mat = rand(5, 10)
%    writeNetCDFData(var_data, var_meta, global_meta)
%    filename = 'random_with_atts.nc'
%    var_meta.rand_vec.attributes = ...
%      struct('name', {'comment'}, 'value', {'This is a random vector'})
%    var_meta.rand_mat.attributes = ...
%      struct('name', {'comment', '_FillValue'}, ...
%             'value', {'This is a random matrix', sqrt(realmax())})
%    global_meta.attributes = ...
%      struct('name', 'creation_date', 'value', datestr(now))
%    writeNetCDFData(var_data, var_meta, global_meta, filename)
%
%  See also:
%    READNETCDFDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % Consider make this variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  error(nargchk(3, 4, nargin, 'struct'));

  if nargin < 4
    filename = global_meta.name;
  end
  
  if ISOCTAVE
    % Create the resource.
    nc = netcdf(filename, 'c');
    try
      % Set global attributes.
      if isfield(global_meta, 'attributes')
        for global_att = global_meta.attributes(:)'
          nc.(global_att.name) = global_att.value;
        end
      end
      % Set dimensions.
      if isfield(global_meta, 'dimensions')
        for global_dim = global_meta.dimensions(:)'
          nc(global_dim.name) = global_dim.length;      
        end
      end
      % Set variable dimensions and attributes, and variable data.
      field_name_list = intersect(fieldnames(var_data), fieldnames(var_meta));
      for var_idx = 1:numel(field_name_list)
        field_name = field_name_list{var_idx};
        if isfield(var_meta.(field_name), 'name')
          var_name = var_meta.(field_name).name;
        else
          var_name = field_name;
        end
        nc{var_name} = ncdouble(var_meta.(field_name).dimensions{:});
        if isfield(var_meta.(var_name), 'attributes')
          for var_att = var_meta.(var_name).attributes(:)'
            nc{var_name}.(var_att.name) = var_att.value;
          end
        end
        % Set the variable data with fill value and scale handling enabled.
        % Give the range for record dimensions.
        nc_var = nc{var_name};
        nc_var = ncautonan(nc_var, 1);
        nc_var = ncautoscale(nc_var, 1);
        nc_var_ranges = arrayfun(@(s)(1:s), size(var_data.(field_name)), ...
                                 'UniformOutput', false);
        nc_var(nc_var_ranges{:}) = var_data.(field_name);
      end
    catch
      close(nc);
      delete(filename);
      rethrow(lasterror());
    end
    % Close the resource.
    close(nc);
  else
    % Create empty NetCDF file.
    nc_create_empty(filename);
    try
      % Set global attributes.
      if isfield(global_meta, 'attributes')
        arrayfun(@(a) nc_attput(filename, nc_global, a.name, a.value), ...
                 global_meta.attributes);
      end
      % Set dimensions.
      if isfield(global_meta, 'dimensions')
        arrayfun(@(d) nc_adddim(filename, d.name, d.length), ...
                 global_meta.dimensions);
      end
      % Set variable dimensions and attributes, and variable data.
      field_name_list = intersect(fieldnames(var_data), fieldnames(var_meta));
      for var_idx = 1:numel(field_name_list)
        field_name = field_name_list{var_idx};
        if isfield(var_meta.(field_name), 'name')
          var_name = var_meta.(field_name).name;
        else
          var_name = field_name;
        end
        nc_var = struct('Name', {var_name}, ...
                        'Dimension', {var_meta.(field_name).dimensions});
        if isfield(var_meta.(field_name), 'attributes')
          % Rename fields as required by low level library.
          nc_var.Attribute = ...
            struct('Name', {var_meta.(field_name).attributes.name}, ...
                   'Value', {var_meta.(field_name).attributes.value});
        end
        nc_addvar(filename, nc_var);
        nc_varput(filename, var_name, var_data.(field_name))
      end
    catch exception
      delete(filename);
      rethrow(exception);
    end
  end

end
