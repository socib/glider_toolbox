function [ meta, data, dims, atts, deployment  ] = loadNetCDF( filename, varargin )
%GETNCVARS Reads data from NC file
%
%  Syntax: 
%     [ META, DATA, DIMS, ATTS  ] = LOADNETCDF( FILENAME );
%
%  Description:
%     Reads the netCDF file and returns a structure containing the data.
%     The fields of the structure correspond to the names of the data. The
%     values of the structures are the values for each specific variable.
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>

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

    narginchk(1, 3);
    options.dictionary = '';
  
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
        error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
            options.(opt) = val;
        else
            error(strcat('glider_toolbox:', mfilename, ':InvalidOptions'), ...
                'Invalid option: %s.', opt);
        end
    end
    
    % TODO: Check against XML dictionary
    
    % Read NC file
    fileContent = nc_info(filename);
    
    %% Run through the list of global attributes
    disp('Reading global attributes...');
    natts = length(fileContent.Attribute);
    atts = [];
    deployment = struct();
    for attIdx = 1:natts
        varname = fileContent.Attribute(attIdx).Name;
        deployment.(varname) = fileContent.Attribute(attIdx).Value;                
        
        atts(end+1).name = fileContent.Attribute(attIdx).Name;
        atts(end).value = fileContent.Attribute(attIdx).Value;
        %matlabCommand = ['atts.', attName, ' = ncreadatt(filename, ''/'', ''', attName, ''');'];
        %eval(matlabCommand);
    end
    
    %% Run through the list of dimensions
    disp('Reading dimensions...');
    ndims = length(fileContent.Dimension);
    dims = [];
    for dimIdx = 1:ndims
        dims(end+1).name = fileContent.Dimension(dimIdx).Name;
        if fileContent.Dimension(dimIdx).Unlimited
            dims(end).length = 0;
        else 
            dims(end).length = fileContent.Dimension(dimIdx).Length;
        end
    end
    
    %% Run through the list of available variables
    disp('Reading variables...');
    ndata = length(fileContent.Dataset);
    data = struct();
    meta = struct();
    for varIdx = 1:ndata
        % Get the variable name
        varName = fileContent.Dataset(varIdx).Name;
        % Build a command to load that variable
        matlabCommand = ['data.', varName, ' = nc_varget(filename, ''', varName, ''');'];
        % Evaluate the command
        eval(matlabCommand);
        %disp( varName);
        
        % get attributes for this variable
        meta.(varName).dimensions = fileContent.Dataset(varIdx).Dimension;
        att_array = fileContent.Dataset.Attribute;
        natts = length(att_array);
        meta.(varName).attributes = [];
        for attIdx = 1:natts
            meta.(varName).attributes(end+1).name = att_array(attIdx).Name;
            meta.(varName).attributes(end).value = att_array(attIdx).Value;
        end
    end
  
end

