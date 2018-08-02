function [var_attr_list, var_attrtype_list ] = completeUncertaintyDictionary(input_attr_list, input_attrtype_list, varargin)
% COMPLETEUNCERTAINTYDICTIONARY  Create structure from the available parameter
%                         description
%
%  Syntax:
%    [ VAR_ATTR_LIST ] = COMPLETEUNCERTAINTYDICTIONARY(INPUT_ATTR_LIST, DEFAULT_QC_ATTR)
%    [ VAR_ATTR_LIST ] = COMPLETEUNCERTAINTYDICTIONARY(INPUT_ATTR_LIST, DEFAULT_QC_ATTR, OPTIONS)
%    [ VAR_ATTR_LIST ] = COMPLETEUNCERTAINTYDICTIONARY(INPUT_ATTR_LIST, DEFAULT_QC_ATTR, OPT1, VAL1, ...)
%
%  Description:
%    [ VAR_ATTR_LIST ] = COMPLETEUNCERTAINTYDICTIONARY() 
%    returns a struct containing the cell arrays of input attributes
%    definition and the corresponding uncertainty attribute based on UNCERTAINTY_ATTRIBUTES
%    definition. An UNCERTAINTY attribute will be added to the initial
%    INIT_ATTR_LIST structure. The initial structure is by default empty.
%    Contrary to the COMPLETEQCDICTIONARY routine, the new variables are
%    not added to the input variable INPUT_ATTR_LIST.
%
%    
%  Input:
%    The input structures are as follow: 
%         - INPUT_ATTR_LIST: Structure containing the list of variables and
%                 their attributes
%         - INPUT_ATTRTYPE_LIST: Structure containing the types of specific
%                 variables (single, double,...)
%  
%  Ouput:
%    The output lists are structures describing the resulting variables
%    attributes and variable types
%         - VAR_ATTR_LIST: Structure containing the list of variables and
%                 their attributes
%         - VAR_ATTRTYPE_LIST: Structure containing the types of specific
%                 variables (single, double,...)
%
%  Options:
%         - UNCERTAINTY_ATTRIBUTES: Default accuracy attributes. 
%         - INIT_ATTR_LIST: List to be completed. Default is empty structure.
%         - UNCERTAINTY_ATTRIBUTE_TYPE: Additionally, a type may be given
%                  to the uncertainty variables.
%         - UNCERTAINTY_PREFIX, UNCERTAINTY_SUFFIX: The name of the Attributes parameters
%                  are by default written as QC_[variable_name]. 
%                  Defaults are then UNCERTAINTY_PREFIX='' and
%                  UNCERTAINTY_SUFFIX='_UNCERTAINTY'. 
%                  Prefix and suffix may be used to change the format of
%                  the attribute name.
%
%  Examples:
%    input_attr_list = struct;
%    var_attr_list.time = {
%         'long_name'            'Epoch time'
%         'standard_name'        'time'
%         'units'                'seconds since 1970-01-01T00:00:00Z'
%         'axis'                 'T'
%         'valid_min'            0.0
%         'valid_max'            90000.0
%         'QC_procedure'         '1'
%         'ancillary_variable'  'TIME_QC'
%         'sdn_parameter_urn'    'SDN:P01::ELTMEP01'
%         'sdn_uom_urn'          'SDN:P061::UTBB'
%         'coordinates'          'TIME LATITUDE LONGITUDE PRES'
%         'comment'              'None'
%         '_FillValue'           9999999999
%         'glider_original_parameter_name'                [] 
%         'sources'                [] };          
%    var_attrtype_list.depth = 'single';
%    var_attr_list.depth = {
%         'long_name'               'glider depth'
%         'standard_name'           'depth'
%         'units'                   'm'
%         'positive'                'down'
%         'coordinates'             'TIME LATITUDE LONGITUDE PRES'
%         'ancillary_variable'      'DEPTH_QC'
%         '_FillValue'              99999
%         'comment'                 'None'
%         'glider_original_parameter_name'                [] 
%         'sources'                                       []
%         'conversion'                                    []
%         'filling'                                       [] };
%    [ v ] = completeUncertaintyDictionary(var_attrtype_list, var_attr_list)
%    Returns v containinng time_UNCERTAINTY and depth_UNCERTAINTY 
%
%  See also:
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
  
    narginchk(2, 12);
  
    options.init_attr_list = struct;
    options.uncertainty_attribute_type = '';
    options.uncertainty_attributes  = {
    'long_name'                         'Uncertainty'
    '_FillValue'                        99999
    'units'                             'n/a'};
    options.uncertainty_attribute_type = '';
    options.uncertainty_prefix = '';
    options.uncertainty_suffix = '_UNCERTAINTY';
    
    %% Parse optional arguments.
    % Get option key-value pairs in any accepted call signature.
    argopts = varargin;
    if isscalar(argopts) && isstruct(argopts{1})
        % Options passed as a single option struct argument:
        % field names are option keys and field values are option values.
        opt_key_list = fieldnames(argopts{1});
        opt_val_list = struct2cell(argopts{1});
    elseif mod(numel(argopts), 2) == 0
        % Options passed as key-value argument pairs.
        opt_key_list = argopts(1:2:end);
        opt_val_list = argopts(2:2:end);
    else
        error('glider_toolbox:completeUncertaintyDictionary:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:completeUncertaintyDictionary:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
  
    in_var_attr_list = input_attr_list;
    var_attrtype_list = input_attrtype_list;
    var_attr_list = options.init_attr_list;
    size_uncertainty_prefix = length(options.uncertainty_prefix);
    size_uncertainty_suffix = length(options.uncertainty_suffix);
    if (size_uncertainty_prefix == 0) && (size_uncertainty_suffix == 0)
        error('glider_toolbox:completeUncertaintyDictionary:InvalidOptions', ...
              'Empty prefix and suffix for quality variable names.');        
    end
    
    % Create for each input variable name an uncertainty variable
    var_attr_names = fieldnames(in_var_attr_list);
    for var_name_idx = 1:numel(var_attr_names)
        vuatts = options.uncertainty_attributes;
        var_name = var_attr_names{var_name_idx};
        vatts = in_var_attr_list.(var_name);
        uncertainty_var_name = strcat(options.uncertainty_prefix,var_name,options.uncertainty_suffix);
        
        % Update units field 
        idx_unitname = find(cellfun(@(x) strcmp(x,'units'), vatts(:,1)));
        idx_unituname = find(cellfun(@(x) strcmp(x,'units'), vuatts(:,1)));
        if ~isempty(idx_unitname) && ~isempty(idx_unituname)
          vuatts(idx_unituname(1),2) = vatts(idx_unitname(1),2);
        end
        
        % Create Uncertainty variable. Assumes no uncertainty is in the
        % metadata structure
        var_attr_list.(uncertainty_var_name) = vuatts;
        if ~isempty(options.uncertainty_attribute_type) 
            var_attrtype_list.(uncertainty_var_name) = options.uncertainty_attribute_type;
        end
        
    end
    
end