function writeNetCDFData(filename, var_data, var_meta, dims, global_atts)
%WRITENETCDFDATA  Interface to low level functions to write data to a NetCDF file.
%
%  WRITENETCDFDATA(FILENAME, VAR_DATA, VAR_META, DIMS)  creates a NetCDF file 
%  named FILENAME with the dimensions given in struct DIMS and the variables 
%  defined by the structs VAR_META and VAR_DATA.  For every field in DIMS one 
%  dimension is created with the size given in the field value. For every field
%  in struct VAR_DATA a variable with the same name is created with the
%  values in the field value. VAR_META should have a field with the same name
%  containing the metadata for that variable in a struct with fields:
%    DIMENSIONS: (mandatory) cell array with the name of the dimensions of the
%      variable.
%    ATTRIBUTES: (optional) struct array with fields 'NAME' and 'VALUE' 
%      specifying the attributes of the variable.
%
%  WRITENETCDFDATA(...,  GLOBAL_ATTS) also adds file global attributes in struct
%  array GLOBAL_ATTS, which should have'NAME' and 'VALUE' fields.
%
%  Notes:
%    It would be more convenient to specify attributes in a struct with
%    attribute names as field names and attribute values as field values.
%    But due to a MATLAB limitation, it will cause trouble with attributes like
%    '_FillValue' (because it is not a valid field name).
%
%  Examples:
%    filename = 'random.nc'
%    dims = struct('dim1', 0, 'dim2', 5, 'dim3', 10)
%    var_meta = struct()
%    var_meta.rand_vec = struct('dimensions', {{'dim1'}});
%    var_meta.rand_mat = struct('dimensions', {{'dim2' 'dim3'}});
%    var_data = struct()
%    var_data.rand_vec = rand(25,1)
%    var_data.rand_mat = rand(5,10)
%    writeNetCDFData(filename, var_data, var_meta, dims)
%    filename = 'random_with_atts.nc'
%    var_meta.rand_vec.attributes = struct('name', {'comment'}, ...
%                                          'value', {'This is a random vector'})
%    var_meta.rand_mat.attributes = struct('name', {'comment', '_FillValue'}, ...
%                                          'value', {'This is a random matrix', sqrt(realmax())})
%    global_atts = struct('name', 'creation_date', 'value', datestr(now))
%    writeNetCDFData(filename, var_data, var_meta, dims, global_atts)
%
%  See also:
%    READNETCDFDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % Consider make the variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  error(nargchk(4, 5, nargin, 'struct'));

  if nargin < 5
    global_atts = struct('name', {}, 'value', {});
  end
  
  if ISOCTAVE
    nc = netcdf(filename, 'c');
    try
      % Set global attributes.
      for global_attr = global_atts(:)'
        nc.(global_attr.name) = global_attr.value;
      end
      % Set dimensions.
      dim_name_list = fieldnames(dims);
      for dim_idx = 1:numel(dim_name_list)
        dim_name = dim_name_list{dim_idx};
        nc(dim_name) = dims.(dim_name);      
      end
      % Set variable dimensions and attributes, and variable data.
      var_name_list = fieldnames(var_data);
      for var_idx = 1:numel(var_name_list)
        var_name = var_name_list{var_idx};
        var_dims = var_meta.(var_name).dimensions;
        nc{var_name} = ncdouble(var_dims{:});
        if isfield(var_meta.(var_name), 'attributes')
          var_attr_list = var_meta.(var_name).attributes;
          for var_attr = var_attr_list(:)'
            nc{var_name}.(var_attr.name) = var_attr.value;
          end
        end
        % Turn on handling of fill value and scaling.
        nc{var_name} = ncautonan(nc{var_name},1);
        nc{var_name} = ncautoscale(nc{var_name},1);
        % Give the range for record dimensions.
        nc{var_name}(1:numel(var_data.(var_name))) = var_data.(var_name); 
      end
    catch
      close(nc);
      delete(filename);
      rethrow(lasterror());
    end
    close(nc);    
  else
    nc_create_empty(filename);
    try
      % Set global attributes.
      arrayfun(@(g) nc_attput(filename, nc_global, g.name, g.value), global_atts);
      % Set dimensions.
      cellfun(@(d) nc_adddim(filename, d, dims.(d)), fieldnames(dims));
      % Set variable dimensions and attributes and variable data.
      var_name_list = fieldnames(var_data);
      for var_idx = 1:numel(var_name_list)
        var_name = var_name_list{var_idx};
        var_dims = var_meta.(var_name).dimensions;
        nc_var = struct('Name', {var_name}, 'Dimension', {var_dims});
        if isfield(var_meta.(var_name), 'attributes')
          % Rename fields as required by low level library.
          var_atts = var_meta.(var_name).attributes;
          nc_var.Attribute = struct('Name', {var_atts.name}, ...
                                    'Value', {var_atts.value});
        end
        nc_addvar(filename, nc_var);
        nc_varput(filename, var_name, var_data.(var_name))
      end
    catch exception
      delete(filename);
      rethrow(exception);
    end
  end

end
