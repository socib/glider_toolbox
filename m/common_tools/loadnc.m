function [var_data, var_meta, global_meta] = loadnc(url, var_names, field_names)
%LOADNC  Interface to low level functions to read data from a NetCDF source.
%
%  Syntax:
%    VAR_DATA = LOADNC(URL)
%    VAR_DATA = LOADNC(URL, VAR_NAMES)
%    VAR_DATA = LOADNC(URL, VAR_NAMES, FIELD_NAMES)
%    [VAR_DATA, VAR_META, GLOBAL_META] = LOADNC(...)
%
%  Description:
%    VAR_DATA = LOADNC(URL) reads data from all variables in the NetCDF source 
%    defined by string URL to struct VAR_DATA. For every variable there is a 
%    field with the variable name as field name and the variable data as value
%    (see note on variable renaming). The URL might be the name of a local file
%    or an OPeNDAP url.
%
%    VAR_DATA = LOADNC(URL, VAR_NAMES) retrieves only variables named in string 
%    cell array VAR_NAMES.
%
%    VAR_DATA = LOADNC(URL, VAR_NAMES, FIELD_NAMES) also retrieves variables 
%    named in string cell array VAR_NAMES but performs a renaming, storing them
%    in fields named by string cell array FIELD_NAMES, which must be the same 
%    size as VAR_NAMES.
%
%    [VAR_DATA, VAR_META] = LOADNC(...) reads also variable metadata to struct 
%    VAR_META. For every variable field in VAR_DATA there is a field in VAR_META 
%    with the same name, containing the metadata in a struct with fields:
%      NAME: string with the original variable name in the NetCDF source.
%      DATATYPE: string with the original variable NetCDF data type.
%      DIMENSIONS: cell array with the name of the dimensions of the variable.
%      ATTRIBUTES: struct array with the attributes of the variable with fields:
%        NAME: string with the attribute name.
%        VALUE: arbitrary typed value with the value of the attribute.
%
%    [VAR_DATA, VAR_META, GLOBAL_META] = LOADNC(...) reads also global 
%    attributes and dimensions present in the NetCDF source to struct 
%    GLOBAL_META, which has the following fields:
%      NAME: string with the url of the NetCDF resource (same as URL).
%      DIMENSIONS: struct array describing the dimensions with fields:
%        NAME: string with the dimension name.
%        LENGTH: number with the length of the dimension.
%        UNLIMITED: 1 if this is a record dimension, 0 otherwise.
%      ATTRIBUTES: struct array with global attributes with fields:
%        NAME: string with the attribute name.
%        VALUE: arbitrary typed value with the value of the attribute.
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
%    [var_data, var_meta, global_meta] = loadnc(url)
%    % Retrieve data of interest without metadata.
%    var_data = loadnc(url, {'time', 'lon', 'lat', 'tos'})
%    % Retrieve data of interest with metadata.
%    [var_data, var_meta] = loadnc(url, {'time', 'lon', 'lat', 'tos'})
%    % Retrieve data renaming variables.
%    var_names = {'time', 'lon', 'lat', 'tos'}
%    new_names = {'time', 'longitude', 'latitude', 'temperature'}
%    var_data = loadnc(url, var_names, new_names)
%    [var_data, var_meta] = loadnc(url, var_names, new_names)
%
%  See also:
%    SAVENC
%    GENVARNAME
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

  % Consider make the variable persistent.
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  error(nargchk(1, 3, nargin, 'struct'));

  if ISOCTAVE
    % Open the resource.
    nc = netcdf(url, 'r');
    if (nargout < 2) && (nargin > 1)
      % Only selected variable data required, so go ahead for it.
      var_data = struct();
      % If no variable renaming is specified preserve names as much as possible.
      if nargin < 3
        field_names = genvarname(var_names);
      end
      % Retrieve selected variable data.
      for var_idx = 1:numel(var_names)
        var_data.(field_names{var_idx}) = nc{var_names{var_idx}}(:);
      end
    else
      % Metadata required or selected variables not specified.
      var_data = struct();
      var_meta = struct();
      global_meta = struct();
      % If no selected variables are specified, retrieve all variables.
      if nargin < 2
        nc_var_list = ncvar(nc);
        var_names = cellfun(@ncname, nc_var_list, 'UniformOutput', false);
      else
        nc_var_list = cellfun(@(v)(nc{v}), var_names, 'UniformOutput', false);
      end
      % If no variable renaming is specified preserve names as much as possible.
      if nargin < 3
        field_names = genvarname(var_names);
      end
      % Get available or selected variables, 
      % variable data type, dimensions and attributes if any, 
      % and variable data.
      for var_idx = 1:numel(nc_var_list)
        % Go for variable metadata.
        var_meta.(field_names{var_idx}) = struct();
        % Get variable original name.
        var_meta.(field_names{var_idx}).name = ncname(nc_var_list{var_idx});
        % Get variable original data type.
        var_meta.(field_names{var_idx}).datatype = ...
          ncdatatype(nc_var_list{var_idx});
        % Get variable dimensions.
        nc_var_dim_list = ncdim(nc_var_list{var_idx});
        var_meta.(field_names{var_idx}).dimensions = ...
          cellfun(@ncname, nc_var_dim_list, 'UniformOutput', false);
        % Get variable attributes.
        nc_var_att_list = ncatt(nc_var_list{var_idx});
        var_meta.(field_names{var_idx}).attributes = ...
          struct('name', cell(size(nc_var_att_list)), ...
                 'value', cell(size(nc_var_att_list)));
        for nc_var_att_idx = 1:numel(nc_var_att_list)
          var_meta.(field_names{var_idx}).attributes(nc_var_att_idx).name = ...
            ncname(nc_var_att_list{nc_var_att_idx});
          var_meta.(field_names{var_idx}).attributes(nc_var_att_idx).value = ...
            nc_var_att_list{nc_var_att_idx}(:);
        end
        % Get variable data with invalid value and scale conversions enabled.
        ncautonan(nc_var_list{var_idx}, 1);
        ncautoscale(nc_var_list{var_idx}, 1);
        var_data.(field_names{var_idx}) = nc_var_list{var_idx}(:);
      end
      % Get global metadata: list of dimensions with its length and attributes.
      % Set global name (the url).
      global_meta.name = url;
      % Get global list of dimensions.
      nc_dim_list = ncdim(nc);
      global_meta.dimensions = struct('name', cell(size(nc_dim_list)), ...
                                      'length', cell(size(nc_dim_list)), ...
                                      'unlimited', cell(size(nc_dim_list)));
      for nc_dim_idx = 1:numel(nc_dim_list)
        global_meta.dimensions(nc_dim_idx).name = ...
          ncname(nc_dim_list{nc_dim_idx});
        global_meta.dimensions(nc_dim_idx).length = ...
          nc_dim_list{nc_dim_idx}(:);
        global_meta.dimensions(nc_dim_idx).unlimited = ...
          ncisrecord(nc_dim_list{nc_dim_idx});
      end
      % Get global attributes.
      nc_att_list = ncatt(nc);
      global_meta.attributes = struct('name', cell(size(nc_att_list)), ...
                                      'value', cell(size(nc_att_list)));
      for nc_att_idx = 1:numel(nc_att_list)
        global_meta.attributes(nc_att_idx).name = ...
          ncname(nc_att_list{nc_att_idx});
        global_meta.attributes(nc_att_idx).value = nc_att_list{nc_att_idx}(:);
      end
    end
    % Close the resource.
    close(nc);
  else
    if (nargout < 2) && (nargin > 1)
      % Only selected variable data required, so go ahead for it.
      var_data = struct();
      % If no variable renaming is specified preserve names as much as possible.
      if nargin < 3
        field_names = genvarname(var_names);
      end
      % Retrieve selected variable data.
      for var_idx = 1:numel(var_names)
        var_data.(field_names{var_idx}) = nc_varget(url, var_names{var_idx});
      end
    else
      % Metadata required or selected variables not specified,
      % so full NetCDF description needed.
      var_data = struct();
      var_meta = struct();
      global_meta = struct();
      nc_full_info = nc_info(url);
      % If no selected variables are specified, retrieve all variables.
      if nargin < 2
        % Dataset has no fields when there are no variables
        % (instead of being an empty struct but with the proper fields).
        nc_var_list = nc_full_info.Dataset;
        if isempty(nc_var_list) 
          var_names = {};
        else
          var_names = {nc_var_list.Name};
        end
      else
        [nc_var_present, nc_var_select] = ...
          ismember(var_names, {nc_full_info.Dataset.Name});
        nc_var_list = nc_full_info.Dataset(nc_var_select);
      end
      % If no variable renaming is specified preserve names as much as possible.
      if nargin < 3
        field_names = genvarname(var_names);
      end
      % Get available or selected variables, 
      % variable data type, dimensions and attributes if any, 
      % and variable data.
      for var_idx = 1:numel(nc_var_list)
        % Go for variable metadata.
        var_meta.(field_names{var_idx}) = struct();
        % Get variable original name.
        var_meta.(field_names{var_idx}).name = nc_var_list(var_idx).Name;
        % Get variable original data type.
        var_meta.(field_names{var_idx}).datatype = ...
          nc_var_list(var_idx).Datatype;
        % Get variable dimensions.
        % Perform renaming to follow coding style guidelines, 
        % and handle empty case for coherence.
        nc_var_dim_list = nc_var_list(var_idx).Dimension;
        if isempty(nc_var_dim_list)
          var_meta.(field_names{var_idx}).dimensions = {};
        else
          var_meta.(field_names{var_idx}).dimensions = ...
            nc_var_list(var_idx).Dimension;
        end
        % Get variable attributes.
        % Perform renaming to follow coding style guidelines, 
        % and handle empty case for coherence.
        nc_var_att_list = nc_var_list(var_idx).Attribute;
        if isempty(nc_var_att_list)
          var_meta.(field_names{var_idx}).attributes = ...
            struct('name', {}, 'value', {});
        else
          var_meta.(field_names{var_idx}).attributes = ...
            struct('name', {nc_var_att_list.Name}, ...
                   'value', {nc_var_att_list.Value});
        end
        % Get variable data with invalid value and scale conversions enabled.
        var_data.(field_names{var_idx}) = nc_varget(url, var_names{var_idx});
      end
      % Get global metadata: list of dimensions with its length and attributes.
      % Set global name (the url).
      global_meta.name = url;
      % Get global list of dimensions if any.
      % Perform renaming to follow coding style guidelines, 
      % and handle empty case for coherence.
      nc_dim_list = nc_full_info.Dimension;
      if isempty(nc_dim_list)
        global_meta.dimensions = ...
          struct('name', {}, 'length', {}, 'unlimited', {});
      else
        global_meta.dimensions = struct('name', {nc_dim_list.Name}, ...
                                        'length', {nc_dim_list.Length}, ...
                                        'unlimited', {nc_dim_list.Unlimited});
      end
      % Get global attributes if any.
      % Perform renaming to follow coding style guidelines, 
      % and handle empty case for coherence.
      nc_att_list = nc_full_info.Attribute;
      if isempty(nc_att_list)
        global_meta.attributes = struct('name', {}, 'value', {});
      else
        global_meta.attributes = struct('name', {nc_att_list.Name}, ...
                                        'value', {nc_att_list.Value});
      end
    end
  end
  
end
