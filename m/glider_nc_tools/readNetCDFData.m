function [var_data, var_meta, global_attr] = readNetCDFData(url, var_names)
%READNETCDFDATA  Interface to low level functions to read data from a NetCDF source.
%
%  VAR_DATA = READNETCDFDATA(URL) reads data from all variables in the NetCDF 
%  source defined by string URL to struct DATA. For every variable there is a 
%  field  with the variable name as field name and the variable data as value.
%
%  [VAR_DATA, VAR_META] = READNETCDFDATA(URL) reads also variable metadata to 
%  struct META. For every variable there is a field named after the variable 
%  name containing the variable metadata in a struct with fields:
%    DIMENSIONS: cell array with the name of the dimensions of the variable.
%    ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' specifying the 
%      attributes of the variable.
%
%  [VAR_DATA, VAR_META, GLOBAL_ATTR] = READNETCDFDATA(URL) reads also global 
%  attributes of the NetCDF source to struct array GLOBAL_ATTR, which has fields
%  'NAME' and  'VALUE'.
%    
%  ... = READNETCDFDATA(URL, VAR_NAMES) retrieves only variables named in string
%  cell array VAR_NAMES.
%
%  Notes:
%    It would be more convenient to specify attributes in a struct with
%    attribute names as field names and attribute values as field values.
%    But due to a MATLAB limitation, it will cause trouble with attributes like
%    '_FillValue' (because it is not a valid field name).
%
%    Fill value and scale conversions are always performed.
%
%  Examples:
%    url = 'http://test.opendap.org:80/opendap/netcdf/examples/tos_O1_2001-2002.nc'
%    % Read all information at once.
%    [var_data, var_meta, global_atts] = readNetCDFData(url)
%    % Retrieve data of interest without metadata.
%    [var_data, var_meta] = readNetCDFData(url, {'time', 'lon', 'lat', 'tos'})
%    var_data = readNetCDFData(url, {'time', 'lon', 'lat', 'tos'})
%    % Retrieve data of interest with metadata.
%    var_data = readNetCDFData(url, {'time', 'lon', 'lat', 'tos'})
%
%  See also:
%    WRITENETCDFDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % Consider make the variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  error(nargchk(1, 2, nargin, 'struct'));

  if ISOCTAVE
    error('Not implemented yet!');
  else
    if (nargout > 1) || (nargin < 2)
      full_info = nc_info(url);
      % Get global attributes if any.
      if isempty(full_info.Attribute)
        global_attr = struct('name', {}, 'value', {});
      else
        % Perform renaming to follow coding style guidelines.
        global_attr = struct('name', {full_info.Attribute.Name}, ...
                             'value', {full_info.Attribute.Value});
      end
      % Get available variables, and variable dimensions and attributes if any.
      if nargin > 1
        [~, var_info_sel] = ismember(var_names, {full_info.Dataset.Name});
        var_info_list = full_info.Dataset(var_info_sel)';
      else
        var_info_list = full_info.Dataset(:)';
        var_names = {var_info_list.Name};
      end
      var_meta = struct();
      for var_info = var_info_list
        var_meta.(var_info.Name).dimensions = var_info.Dimension;
        if isempty(var_info.Attribute)
          var_meta.(var_info.Name).attributes = struct('name', {}, 'value', {});
        else
          % Perform renaming to follow coding style guidelines.
          var_meta.(var_info.Name).attributes = struct('name', {var_info.Attribute.Name}, ...
                                                       'value', {var_info.Attribute.Value});
        end
      end
    end
    % Get variable data.
    var_data = struct();
    for var_name_idx = 1:numel(var_names)
      var_data.(var_names{var_name_idx}) = nc_varget(url, var_names{var_name_idx});
    end
  end
  
end
