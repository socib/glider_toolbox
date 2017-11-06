function [ data_qc, meta_qc ] = postProcessQCGliderData( data_proc, meta_proc, varargin )
% TODO: This is to be completed later, for now is to add a default value to _QC
% variables for EGO formats

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