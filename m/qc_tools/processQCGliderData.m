function [ data_qc, meta_qc ] = processQCGliderData( data_proc, meta_proc, varargin )
% TODO: This is to be completed later, for now is to add a default value to _QC
% variables for EGO formats

    data_qc = data_proc;
    meta_qc = meta_proc;

    %TODO: Check if juld exists 
    meta_qc.juld_qc.sources = 'juld'; 
    meta_qc.juld_qc.method = 'default0';
    data_qc.juld_qc = zeros(size(data_qc.juld));
    %TODO: Complete juld.ancillary_variable = juld_qc ??

    %TODO: Check if time exists ?
    meta_qc.time_qc.sources = 'time'; 
    meta_qc.time_qc.method = 'default0';
    data_qc.time_qc = zeros(size(data_qc.time));
    %TODO: Complete ancillary_variable ??

    %TODO: Check if time exists ?
    meta_qc.position_qc.sources = 'latitude longitude'; 
    meta_qc.position_qc.method = 'default0';
    data_qc.position_qc = zeros(size(data_qc.latitude));
    %TODO: Complete ancillary_variable ??


end

