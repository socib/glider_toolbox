function [var_attr_list, var_attrtype_list ] = completeQCDictionary(input_attr_list, input_attrtype_list, varargin)
% COMPLETEQCDICTIONARY  Create structure from the available parameter
%                         description
%
%  Syntax:
%    [ VAR_ATTR_LIST ] = COMPLETEQCDICTIONARY(INPUT_ATTR_LIST, INPUT_ATTRTYPE_LIST)
%    [ VAR_ATTR_LIST ] = COMPLETEQCDICTIONARY(INPUT_ATTR_LIST, INPUT_ATTRTYPE_LIST, OPTIONS)
%    [ VAR_ATTR_LIST ] = COMPLETEQCDICTIONARY(INPUT_ATTR_LIST, INPUT_ATTRTYPE_LIST, OPT1, VAL1, ...)
%
%  Description:
%    [ VAR_ATTR_LIST ] = COMPLETEQCDICTIONARY(INPUT_ATTR_LIST, INPUT_ATTRTYPE_LIST) 
%    returns a struct containing the cell arrays of input attributes
%    definition and the corresponding qc attribute based on QC_ATTRIBUTES
%    definition. A QC attribute will only be created if the input attribute
%    list does not contain already the QC attribute.
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
%         - QC_ATTRIBUTES: Default QC attributes to be used to create the
%                  QC variables. If not input the default structure is the
%                  one used by SOCIB standards
%                 + long_name: Quality flag of [long_name of variable]
%                 + standard_name: Quality flag of [standard_name of variable]
%                 + quality_control_convention: SOCIB Quality control
%                 + comment: None
%                 + valid_min: 0
%                 + valid_max: 9
%                 + _FillValue: 0
%                 + QC_procedure: 1
%                 + flag_values: [0,1,2,3,4,8,9]
%                 + flag_meanings: no_qc_performed 
%                                  good_data 
%                                  probably_good_data
%                                  probably_bad_data 
%                                  bad_data
%                                  interpolated_value 
%                                  missing_value  
%         - QC_ATTRIBUTE_TYPE: Additionally, a type may be given to the qc
%                  variables.
%         - QC_PREFIX, QC_SUFFIX: The name of the QC parameters
%                  are by default written as QC_[variable_name]. Defaults
%                  are then QC_PREFIX='QC_' and QC_SUFFIX=''.
%                  Prefix and suffix may be used to change the format of
%                  the attribute name.
%         - UPDATE_LONG_NAME: Change the default long name to 
%                  'QC of [variable_name]'
%
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
%    [ v ] = completeQCDictionary(var_attrtype_list, var_attr_list)
%    Returns v containinng time, depth, time_QC and depth_QC 
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
  
    options.qc_attributes  = {
    'long_name'                         'Quality flag'
    'standard_name'                     ''
    'quality_control_convention'        'SOCIB Quality control'
    'comment'                           'None'
    'valid_min'                         0
    'valid_max'                         9
    '_FillValue'                        -128
    'QC_procedure'                      '1'
    'flag_values'                       [0,1,2,3,4,8,9]
    'flag_meanings'                     'no_qc_performed good_data probably_good_data probably_bad_data bad_data interpolated_value missing_value'};
    options.qc_attribute_type = '';
    options.qc_prefix = 'QC_';
    options.qc_suffix = '';
    options.update_long_name = true;
    
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
        error('glider_toolbox:completeQCDictionary:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:completeQCDictionary:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
  
    var_attr_list = input_attr_list;
    var_attrtype_list = input_attrtype_list;
    size_qc_prefix = length(options.qc_prefix);
    size_qc_suffix = length(options.qc_suffix);
    if (size_qc_prefix == 0) && (size_qc_suffix == 0)
        error('glider_toolbox:completeQCDictionary:InvalidOptions', ...
              'Empty prefix and suffix for quality variable names.');        
    end
    
    % Create for each input variable name a QC variable
    var_attr_names = fieldnames(var_attr_list);
    for var_name_idx = 1:numel(var_attr_names)
        var_name = var_attr_names{var_name_idx};
        vatts = var_attr_list.(var_name);
        qc_var_name = strcat(options.qc_prefix,var_name,options.qc_suffix);
        var_name_size = length(var_name);
        isQCvariable = true;
        % Check if the current variable is not already a QC variable.
        % The check consists of comparing the prefix and the suffix
        if size_qc_prefix > 0
            if ~strcmpi(var_name(1:size_qc_prefix),options.qc_prefix)
                isQCvariable=false;
            end
        end
        if size_qc_suffix > 0
            if ~strcmpi(var_name(var_name_size-size_qc_suffix+1:end),options.qc_suffix)
                isQCvariable=false;
            end
        end
        
        % Create QC variable if it does not exist already in the input
        % variable list and the current variable is not a QC variable. 
        if ~isQCvariable && ~isfield(var_attr_list,qc_var_name) 
            vqcatts = options.qc_attributes;
            
            % Change long name
            if options.update_long_name
                idx_stdname = find(cellfun(@(x) strcmp(x,'long_name'), vatts(:,1)));
                idx_qcstdname = find(cellfun(@(x) strcmp(x,'long_name'), vqcatts(:,1)));
                if ~isempty(idx_stdname) && ~isempty(idx_qcstdname)
                  vqcatts(idx_qcstdname(1),2) = {strcat('QC of',{' '}, vatts(idx_stdname(1),2))};
                end
            end
            
            % Change standard name
            idx_stdname = find(cellfun(@(x) strcmp(x,'standard_name'), vatts(:,1)));
            idx_qcstdname = find(cellfun(@(x) strcmp(x,'standard_name'), vqcatts(:,1)));
            if ~isempty(idx_stdname) && ~isempty(idx_qcstdname)
              vqcatts(idx_qcstdname(1),2) = {strcat('QC_', vatts(idx_stdname(1),2))};
            end
            
            var_attr_list.(qc_var_name) = vqcatts;
            if ~isempty(options.qc_attribute_type) 
                var_attrtype_list.(qc_var_name) = options.qc_attribute_type;
            end
        end
    end
    
end