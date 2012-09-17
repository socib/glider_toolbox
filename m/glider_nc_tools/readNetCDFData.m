function [var_data, var_meta, global_attr] = readNetCDFData(url, var_names, field_names)
%READNETCDFDATA  Interface to low level functions to read data from a NetCDF source.
%
%  VAR_DATA = READNETCDFDATA(URL) reads data from all variables in the NetCDF 
%  source defined by string URL to struct VAR_DATA. For every variable there is 
%  a field with the variable name as field name and the variable data as value.
%  See note on variable renaming.
%
%  VAR_DATA = READNETCDFDATA(URL, VAR_NAMES) retrieves only variables named in 
%  string cell array VAR_NAMES. See note on variable renaming.
%
%  VAR_DATA = READNETCDFDATA(URL, VAR_NAMES, FIELD_NAMES) also retrieves 
%  variables named in string cell array VAR_NAMES but performs a renaming,
%  storing them in fields named by string cell array FIELD_NAMES, which must
%  have the size of VAR_NAMES.
%
%  [VAR_DATA, VAR_META] = READNETCDFDATA(...) reads also variable metadata to 
%  struct VAR_META. For every variable field in VAR_DATA there is a field in 
%  VAR_META with the same name, containing the variable metadata in a struct
%  with fields:
%    NAME: string with the original variable name in the NetCDF source.
%    DIMENSIONS: cell array with the name of the dimensions of the variable.
%    ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' specifying the 
%      attributes of the variable.
%
%  [VAR_DATA, VAR_META, GLOBAL_ATTR] = READNETCDFDATA(...) reads also global 
%  attributes of the NetCDF source to struct array GLOBAL_ATTR, which has fields
%  'NAME' and  'VALUE'.
%    
%  Notes:
%    Some variable names might not be valid field names. If field names are
%    not given, they are generated with the function GENVARNAME.
%    The original variable names are included in the variable metadata.
%
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
%    var_data = readNetCDFData(url, {'time', 'lon', 'lat', 'tos'})
%    % Retrieve data of interest with metadata.
%    [var_data, var_meta] = readNetCDFData(url, {'time', 'lon', 'lat', 'tos'})
%    % Retrieve data renaming variables.
%    var_names = {'time', 'lon', 'lat', 'tos'}
%    new_names = {'time', 'longitude', 'latitude', 'temperature'}
%    var_data = readNetCDFData(url, var_names, new_names)
%    [var_data, var_meta] = readNetCDFData(url, var_names, new_names)
%
%  See also:
%    WRITENETCDFDATA
%    GENVARNAME
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % Consider make the variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  error(nargchk(1, 3, nargin, 'struct'));

  if ISOCTAVE
    error('Not implemented yet!');
  else
    if (nargout < 2) && (nargin > 2)
      % Only selected variable data required,
      % so go ahead for it.
      if nargin < 3
        field_names = genvarname(var_names);
      end
      for var_idx = 1:numel(var_names)
        var_data.(field_names{var_idx}) = nc_varget(url, var_names{var_idx});
      end
    else
      % Metadata required or variables not specified,
      % so full NetCDF description needed.
      full_info = nc_info(url);
      % Get global attributes if any.
      if isempty(full_info.Attribute)
        global_attr = struct('name', {}, 'value', {});
      else
        % Perform renaming to follow coding style guidelines.
        global_attr = struct('name', {full_info.Attribute.Name}, ...
                             'value', {full_info.Attribute.Value});
      end
      % Get available variables, variable dimensions and attributes if any, 
      % and variable data.
      if nargin < 2
        var_infos = full_info.Dataset(:)';
        var_names = {var_infos.Name};
      else
        [~, var_info_sel] = ismember(var_names, {full_info.Dataset.Name});
        var_infos = full_info.Dataset(var_info_sel)';
      end
      if nargin < 3
        field_names = genvarname(var_names);
      end
      var_meta = struct();
      for var_idx = 1:numel(var_infos)
        var_meta.(field_names{var_idx}).name = var_infos(var_idx).Name;
        var_meta.(field_names{var_idx}).dimensions = ...
          var_infos(var_idx).Dimension;
        if isempty(var_infos(var_idx).Attribute)
          var_meta.(field_names{var_idx}).attributes = ...
            struct('name', {}, 'value', {});
        else
          % Perform renaming to follow coding style guidelines.
          var_meta.(field_names{var_idx}).attributes = ...
            struct('name', {var_infos(var_idx).Attribute.Name}, ...
                   'value', {var_infos(var_idx).Attribute.Value});
        end
        var_data.(field_names{var_idx}) = nc_varget(url, var_names{var_idx});
      end
    end
  end
  
end
