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
  
    %% Initialize results 
    data_qc = data_proc;
    meta_qc = meta_proc;

    %% Time Quality control
    if isfield(data_qc, 'time')
        meta_qc.time_qc.sources = 'time'; 
        meta_qc.time_qc.method = 'default0';
        data_qc.time_qc = zeros(size(data_qc.time));
        %TODO: Complete ancillary_variable ??
    end

    %% Geospatial Quality control
    if isfield(data_qc, 'latitude') && isfield(data_qc, 'longitude')
        meta_qc.position_qc.sources = 'latitude longitude'; 
        meta_qc.position_qc.method = 'default0';
        data_qc.position_qc = zeros(size(data_qc.latitude));
        %TODO: Complete ancillary_variable ??
    end
    
    %% JULD Quality control
    if isfield(data_qc, 'juld')
        meta_qc.juld_qc.sources = 'juld'; 
        meta_qc.juld_qc.method = 'default0';
        data_qc.juld_qc = zeros(size(data_qc.juld));
        %TODO: Complete juld.ancillary_variable = juld_qc ??
    end



end