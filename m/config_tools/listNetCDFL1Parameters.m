function [ meta_variables ] = listNetCDFL1Parameters(qc_prefix, qc_suffix, time_dimension_name, varargin)
%LISTNETCDFL1PARAMETERS  Create structure from the available parameter
%                         description
%
%  Syntax:
%    META_VARIABLES = LISTNETCDFL1PARAMETERS()
%
%  Description:
%    META_VARIABLES = LISTNETCDFL1PARAMETERS() should return a struct
%    describing the structure of parameters of the NetCDF file. This
%    function contains the definition of all available parameters of EGO
%    and SOCIB standards. The output variable contains the parameters
%    defined in the input arguments as well as the input dimension.
%    
%  Input:
%    The input structure is as follow:
%       TIME_DIMENSION_NAME: name of the time dimension to which
%            each output will be related. 
%       OPTIONS: A structure defining the parameters to add to the output 
%           FORMAT (ego/socib), {param1, param2, param3,...}
%           For each format and paramX the output will contain the
%           parameter define as var_attr_list.(format).(paramX).
%
%  Ouput:
%    The returned struct should have the following fields:
%      VARIABLES: struct defining variable metadata. Field names are variable
%        names and field values are structs as needed by function SAVENC.
%        It should have the following fields:
%          DIMENSIONS: string cell array with the names of the dimensions
%            of the variable.
%          ATTRIBUTES: struct array with fields 'NAME' and 'VALUE' defining
%            the attributes of the variable.
%          TYPE: Optionally, attributes may contain the type of the field 
%            if a type different than double is required. Notice that float
%            is represented by single in MATLAB. 
%
%  Notes:
%    The NetCDF file will be created by the function GENERATEOUTPUTNETCDF with
%    the metadata provided here and the data returned by PROCESSGLIDERDATA.
%
%    Please note that global attributes described here may be overwritten by
%    deployment field values whenever the names match. This allows adding file
%    attributes whose values are known only at runtime.
%
%  Examples:
%    ncl1_info = configRTOutputNetCDFEGOL1()
%
%  See also:
%    GENERATEOUTPUTNETCDF
%    SAVENC
%    PROCESSGLIDERDATA
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

  if isempty(time_dimension_name)
      error('glider_toolbox:listNetCDFL1Parameters:MissingInput', ...
            'No time dimension');
  end
    
  var_attr_list = struct();
  var_attrtype_list = struct();
  
  [var_attr_list.ego, var_attrtype_list.ego ] = Dictionary_EGONetCDFL1Parameters('qc_prefix', qc_prefix, 'qc_suffix', qc_suffix);
  [var_attr_list.socib, var_attrtype_list.socib ] = Dictionary_SOCIBNetCDFL1Parameters('qc_prefix', qc_prefix, 'qc_suffix', qc_suffix);
  

  % Select parameters based on input params structure
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument.
    format_list = fieldnames(varargin{1});
    param_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    format_list = varargin(1:2:end);
    param_list = varargin(2:2:end);
  else
    error('glider_toolbox:preprocessGliderData:InvalidOption', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  
  var_attr = struct();
  var_attrtype = struct();
  for format_idx = 1:numel(format_list)
    format = lower(format_list{format_idx});
    
    format_param_list = param_list{format_idx};
    for param_idx = 1:numel(format_param_list)
      param = format_param_list{param_idx};
      if isfield(var_attr_list, format)
        if isfield(var_attr_list.(format), param)
          var_attr.(param) = var_attr_list.(format).(param);
          if isfield(var_attrtype_list, format) && isfield(var_attrtype_list.(format), param)
            var_attrtype.(param) = var_attrtype_list.(format).(param);
          end
        end
      end
    end
  end  
  
  % Set the variable metadata.
  meta_variables = struct();
  var_name_list = fieldnames(var_attr);
  for var_name_idx = 1:numel(var_name_list)
    var_name = var_name_list{var_name_idx};
    
    % Add attributes that are defined in the dictionary
    % and that it was not added earlier in metadata
    if isfield(var_attr,var_name) && ~isfield(meta_variables, var_name)
      vatts = var_attr.(var_name);
      meta_variables.(var_name).dimensions = {time_dimension_name};
      meta_variables.(var_name).attributes = ...
        cell2struct(vatts, {'name' 'value'}, 2);
        if ~isempty(var_attrtype)
          if isfield(var_attrtype, var_name)
            meta_variables.(var_name).type = var_attrtype.(var_name);
          end
        end
    end
  end
end

