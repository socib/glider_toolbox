function generateNcProduct(currentDeployment, outputDirs, gliderName, levelStr, data)
%GENERATENCPRODUCT - Generates a netcdf file from data and desired level
% This function takes the current deployment metadata, the dataset and,
% based on the desired level, generates a netcdf product.
%
%
% Syntax: generateNcProduct(currentDeployment, gliderName, levelStr, data)
%
% Inputs:
%    currentDeployment - structure with deployment metadata
%    gliderName - string with the glider name
%    levelStr - string, value should be 'L0', 'L1' or 'L2'
%    data - structure with the dataset
%
% Outputs: none
%
% Example:
%    Line 1 of example
%    Line 2 of example
%
% Other m-files required: genRawGliderNcFile, genProcGliderNcFile, genGriddedGliderNcFile
% Subfunctions: none
% MAT-files required: none
%
% See also: GENRAWGLIDERNCFILE, GENPROCGLIDERNCFILE, GENGRIDDEDGLIDERNCFILE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 21-May-2012
%

    % Store data in netcdf
    try
        % Generate level nc file
        ncFileName = [gliderName, '_', levelStr, '_', datestr(currentDeployment.start_date, 'yyyy-mm-dd'), '.nc'];
        ncDataFilename = fullfile(currentDeployment.dataRoot, 'netcdf', ncFileName);
        switch levelStr
            case 'L0'
                genRawGliderNcFile(ncDataFilename, data, currentDeployment);
            case 'L1'
                genProcGliderNcFile(ncDataFilename, data, currentDeployment);
            case 'L2'
                genGriddedGliderNcFile(ncDataFilename, data, currentDeployment);
        end;
        % Move to folder for THREDDS catalog
        ncThreddsFilePath = fullfile(outputDirs.ncBasePath, ...
            gliderName, levelStr, datestr(currentDeployment.start_date, 'yyyy'));
        % First stage: connection
        theCommand = 'ssh dataprocuser@SCB-DATPROC';
        % Second stage: create destination directory
        theCommand = [theCommand, ' "mkdir -p ', ncThreddsFilePath];
        % Third stage: copy file
        theCommand = [theCommand, '; cp ', ncDataFilename, ' ', ncThreddsFilePath, '"'];
        [anyError, errMsg] = system(theCommand);
        if anyError ~= 0
            disp(errMsg);
        end;
    catch ME
        disp('could not generate glider raw netcdf file');
        disp(getReport(ME, 'extended'));
    end;

end