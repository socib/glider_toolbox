function savenc(var_data, var_meta, global_meta, filename)
%SAVENC  Interface to low level functions to write data to a NetCDF file.
%
%  Syntax:
%    SAVENC(VAR_DATA, VAR_META, GLOBAL_META)
%    SAVENC(VAR_DATA, VAR_META, GLOBAL_META, FILENAME)
%
%  Description:
%    SAVENC(VAR_DATA, VAR_META, GLOBAL_META) creates a NetCDF file according to
%    global properties given in struct GLOBAL_META with the variables defined by
%    the structs VAR_META and VAR_DATA.
%    GLOBAL_META is struct with the following fields:
%      DIMENSIONS: struct array describing the dimensions with fields:
%        NAME: string with the name of the dimension.
%        LENGTH: number with the length of the dimension, or 0 to indicate
%          a record dimension.
%      ATTRIBUTES: struct array with global attributes with fields:
%        NAME: string with the name of the attribute.
%        VALUE: arbitrary typed value with the value of the attribute.
%      NAME: string with the name of the NetCDF file to be written.
%    For every field in struct VAR_DATA a variable is created with the values in
%    the field value. VAR_META should have a field with the same name containing
%    the metadata for that variable in a struct with fields:
%      DIMENSIONS: (mandatory) string cell array with the name of the dimensions
%        of the variable.
%      ATTRIBUTES: (optional) struct array with fields 'NAME' and 'VALUE' 
%        specifying the attributes of the variable.
%      DATATYPE: (optional) string with the NetCDF data type of the variable.
%        Allowed types are 'double', 'float', 'int', 'short', 'byte', or 'char'.
%        If this field is missing, the type is derived from the class of the 
%        data, and if it is not valid the default data type 'double' is used.
%      NAME: (optional) string with the variable name as it should appear in the
%        NetCDF file. If this field is missing the variable is named after the
%        field name. This is useful when the desired variable name can not be
%        used as field name.
%
%    SAVENC(VAR_DATA, VAR_META, GLOBAL_META, FILENAME) will create a NetCDF file 
%    named FILENAME, overriding the 'NAME' field in GLOBAL_META.
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
%    var_meta.rand_num = struct('dimensions', {{}})
%    var_meta.rand_vec = struct('dimensions', {{'dim1'}})
%    var_meta.rand_mat = struct('dimensions', {{'dim2' 'dim3'}}, ...
%                               'datatype', {'int'})
%    var_data = struct()
%    var_data.rand_num = int8(round(12 * rand([1 1])))
%    var_data.rand_vec = randn([25 1])
%    var_data.rand_mat = round(12 * rand([5 10]))
%    var_data.rand_mat(var_data.rand_mat == 1) = nan
%    savenc(var_data, var_meta, global_meta)
%    filename = 'random_with_atts.nc'
%    var_meta.rand_num.attributes = ...
%      struct('name', {'comment'}, ...
%             'value', {'This is a random signed 8 bit integer'})
%    var_meta.rand_vec.attributes = ...
%      struct('name', {'comment', 'add_offset', 'scale_factor'}, ...
%             'value', {'This is a random vector', 10, 2.5})
%    var_meta.rand_mat.attributes = ...
%      struct('name', {'comment', '_FillValue'}, ...
%             'value', {'This is a random matrix', intmax()})
%    global_meta.attributes = ...
%      struct('name', {'creation_date'}, 'value', {datestr(now)})
%    savenc(var_data, var_meta, global_meta, filename)
%
%  See also:
%    LOADNC
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  % Consider make this variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');
  NETCDF_TYPES = {'double' 'float'  'int'   'short' 'byte' 'char'};
  NATIVE_TYPES = {'double' 'single' 'int32' 'int16' 'int8' 'char'};

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
          if isfield(global_dim, 'unlimited') && (global_dim.unlimited)
            nc(global_dim.name) = 0;
          else
            nc(global_dim.name) = global_dim.length;
          end
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
        if isfield(var_meta.(field_name), 'datatype')
          var_type = var_meta.(field_name).datatype;
        else
          data_type = class(var_data.(field_name));
          data_type_select = strcmp(data_type, NATIVE_TYPES);
          if any(data_type_select)
            var_type = NETCDF_TYPES{data_type_select};
          else
            var_type = 'double';
          end
        end
        nc_var_type_func = str2func(['nc' var_type]);
        nc{var_name} = nc_var_type_func(var_meta.(field_name).dimensions{:});
        if isfield(var_meta.(var_name), 'attributes')
          for var_att = var_meta.(var_name).attributes(:)'
            nc{var_name}.(var_att.name) = var_att.value;
          end
        end
      end
      for var_idx = 1:numel(field_name_list)
        field_name = field_name_list{var_idx};
        if isfield(var_meta.(field_name), 'name')
          var_name = var_meta.(field_name).name;
        else
          var_name = field_name;
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
        for global_att = global_meta.attributes(:)'
          nc_attput(filename, nc_global, global_att.name, global_att.value);
        end
      end
      % Set dimensions.
      if isfield(global_meta, 'dimensions')
        for global_dim = global_meta.dimensions(:)'
          if isfield(global_dim, 'unlimited') && (global_dim.unlimited)
            nc_adddim(filename, global_dim.name, 0);
          else
            nc_adddim(filename, global_dim.name, global_dim.length);
          end
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
        if isfield(var_meta.(field_name), 'datatype')
          var_type = var_meta.(field_name).datatype;
        else
          data_type = class(var_data.(field_name));
          data_type_select = strcmp(data_type, NATIVE_TYPES);
          if any(data_type_select)
            var_type = NETCDF_TYPES{data_type_select};
          else
            var_type = 'double';
          end
        end
        nc_var = struct('Name', {var_name}, ...
                        'Dimension', {var_meta.(field_name).dimensions}, ...
                        'Datatype', var_type);
        if isfield(var_meta.(field_name), 'attributes')
          % Rename fields as required by low level library.
          nc_var.Attribute = ...
            struct('Name', {var_meta.(field_name).attributes.name}, ...
                   'Value', {var_meta.(field_name).attributes.value});
        end
        nc_addvar(filename, nc_var);
      end
      for var_idx = 1:numel(field_name_list)
        field_name = field_name_list{var_idx};
        if isfield(var_meta.(field_name), 'name')
          var_name = var_meta.(field_name).name;
        else
          var_name = field_name;
        end
        nc_varput(filename, var_name, var_data.(field_name))
      end
    catch exception
      delete(filename);
      rethrow(exception);
    end
  end

end
