function [ data_qc, meta_qc ] = postProcessQCGliderData( data_proc, meta_proc, varargin )
% POSTPROCESSQCGLIDERDATA  Perform quality control to post process data
%
%  Syntax:
%    [DATA_QC, META_QC] = POSTPROCESSQCGLIDERDATA( DATA_PROC, META_PROC )
%    [DATA_QC, META_QC] = POSTPROCESSQCGLIDERDATA( DATA_PROC, META_PROC, PARAM1, VAL1 )
%
%  Description:
%    POSTPROCESSQCGLIDERDATA is intended to perform the quality control to
%    post process data. Currently, this function only creates the required
%    variables that are required by the NetCDF-EGO format and fills them
%    with default values.
%
%  Input:
%
%    DATA_PROC should be a struct in the format returned by POSTPROCESSGLIDERDATA,
%    where each field is a sequence of measurements of the variable with the 
%    same name.

%    META_PROC should be a struct in the format returned by POSTPROCESSGLIDERDATA,
%    where each field is a sequence of meta data of the variable with the 
%    same name.
%
%  Output:
%
%    DATA_QC is a struct in the same format as DATA_PROC, with time sequences 
%    resulting from the processing actions described above, performed according
%    to the options described below.
%
%    META_QC is also a struct with one field per variable, adding processing 
%    metadata to any existing metadata in META_PROC.
%
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
  
    %% Check inputs.
    narginchk(2,2)
    
    %% Initialize results 
    data_qc = data_proc;
    meta_qc = meta_proc;
    
    %% Start assembling.
    names_data = fieldnames(data_qc);
    for i=1:numel(names_data)
        var_name = names_data{i};
        if isnumeric(data_qc.(var_name)) && ...
            ~strcmp(var_name(1:min(8,length(var_name))), 'history_')
            new_name = strcat(names_data{i},'_QC');
            data_qc.(new_name) = zeros(size(data_qc.(var_name)));
            meta_qc.(new_name).sources = var_name; 
            meta_qc.(new_name).method = 'default0';
            
            new_name = strcat(names_data{i},'_UNCERTAINTY');
            data_qc.(new_name) = zeros(size(data_qc.(var_name)));
            meta_qc.(new_name).sources = var_name; 
            meta_qc.(new_name).method = 'default0';
        end
    end

    %% Special cases
    % Geospatial Quality control
    if isfield(data_qc, 'latitude') && ...
            isfield(data_qc, 'longitude')
        meta_qc.position_QC.sources = 'latitude longitude'; 
        meta_qc.position_QC.method = 'default0';
        data_qc.position_QC = zeros(size(data_qc.latitude));
        
        meta_qc.position_UNCERTAINTY.sources = 'latitude longitude'; 
        meta_qc.position_UNCERTAINTY.method = 'default0';
        data_qc.position_UNCERTAINTY = zeros(size(data_qc.latitude));
    end

    % Geospatial GPS Quality control
    if isfield(data_qc, 'latitude_gps') && ...
            isfield(data_qc, 'longitude_gps') 
        meta_qc.position_gps_QC.sources = 'latitude_gps longitude_gps'; 
        meta_qc.position_gps_QC.method = 'default0';
        data_qc.position_gps_QC = zeros(size(data_qc.latitude_gps));
        
        meta_qc.position_gps_UNCERTAINTY.sources = 'latitude_gps longitude_gps'; 
        meta_qc.position_gps_UNCERTAINTY.method = 'default0';
        data_qc.position_gps_UNCERTAINTY = zeros(size(data_qc.latitude_gps));
    end

    % dates Quality control
    data_qc.deployment_start_QC         = -128;    % TODO: verify value
    meta_qc.deployment_start_QC.sources = 'deployment_start'; 
    meta_qc.deployment_start_QC.method  = 'default0';
    
    data_qc.deployment_end_QC         = -128;    % TODO: verify value
    meta_qc.deployment_end_QC.sources = 'deployment_start'; 
    meta_qc.deployment_end_QC.method  = 'default0';
    
end