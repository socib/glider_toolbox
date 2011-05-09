function [fetchedSbdList, fetchedLogList] = getDockserverFiles(gliderName, gliderParams)
%GETDOCKSERVERFILES - Gets binary data files and logs from dockserver through FTP
% Retrieves .?bd files and surface dialog files from the dockserver URL
% contained in the glider parameters structure.
%
% Syntax: [fetchedSbdList, fetchedLogList] = getDockserverFiles(gliderName, gliderParams)
%
% Inputs:
%    gliderName - name of the glider from which to retrieve the data
%    gliderParams - structure with information on where to get files from
%
% Outputs:
%    fetchedSbdList - list of binary data files
%    fetchedLogList - list of log files
%
% Example:
%    [fetchedSbdList, fetchedLogList] = getDockserverFiles(gliderName, gliderParams)
%
% Other m-files required: none
% Subfunctions: ftpConnect, ftpReconnect, downloadFiles
% MAT-files required: none
%
% See also: PARSECONFIGFILE, FTP
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

%% Initialize output as empty files list
    fetchedSbdList = {};
    fetchedLogList = {};

%% Dockserver (remote) folder definition and parameters checking
    dockserverDataBaseDir = ['/var/opt/gmc/gliders/', lower(gliderName)];
    % Old dockservers used this other path:
    %dockserverDataBaseDir = ['/home/dockserver/gliders/', lower(gliderName)];

    if isempty(gliderParams)
        disp(['Empty glider parameters data structure provided to ', mfilename]);
        return;
    end

    % Set the glider data root directory
    if ~isfield(gliderParams, 'DATA_ROOT')
        disp('Missing DATA_ROOT config parameter!');
        return;
    end
    localDataBaseDir = fullfile(gliderParams.DATA_ROOT, gliderName);

    if ~(isfield(gliderParams, 'DOCKSERVER_URL') && ~isempty(gliderParams.DOCKSERVER_URL))
        disp(['Could not find dockserver URL in glider parameters data structure provided to ', mfilename]);
        return;
    end

%% Open ftp connection

    ftpStruct.dockURL = gliderParams.DOCKSERVER_URL;
    ftpStruct.ftpUser = gliderParams.DOCKSERVER_USER;
    ftpStruct.ftpPass = gliderParams.DOCKSERVER_PASS;
    disp(['Connecting to ' ftpStruct.dockURL ' ...']);
    try
        ftpStruct = ftpConnect(ftpStruct);
    catch ME
        disp('Could not connect to dockserver');
        disp(getReport(ME, 'extended'));
        return;
    end;

%% Starting date management
    if ~isfield(gliderParams, 'START_DATE')
        disp('No START_DATE parameter found in config file.');
        startingDate = datenum([1970 1 1], 'yyyy-mm-dd');
    else
        startingDate = gliderParams.START_DATE;
        if isfield(gliderParams, 'START_TIME');
            timeNumbers = sscanf(gliderParams.START_TIME, '%2d:%02d:%02d');
            startingDate = datenum(datevec(startingDate) + [0 0 0 timeNumbers(:)']);
        end;
    end;
    if ~isfield(gliderParams, 'END_DATE')
        disp('No END_DATE parameter found in config file.');
        endingDate = now;
    else
        endingDate = gliderParams.END_DATE;
        if isfield(gliderParams, 'END_TIME');
            timeNumbers = sscanf(gliderParams.END_TIME, '%2d:%02d:%02d');
            endingDate = datenum(datevec(endingDate) + [0 0 0 timeNumbers(:)']);
        end;
    end;
    
    disp(['Downloading files between ', datestr(startingDate), ' and ', datestr(endingDate)]);

%% Binary data files downloading
    filePattern = [lower(gliderName) '*.*bd'];
    remoteSbdDir = [dockserverDataBaseDir, '/from-glider'];
    localSbdDir = fullfile(localDataBaseDir, 'binary');
    if ~exist(localSbdDir, 'dir')
        [success, errorMsg] = mkdir(localSbdDir);
        if isequal(success, 0)
            disp(errorMsg);
            return;
        end;
    end;
    
    fetchedSbdList = downloadFiles(ftpStruct, filePattern, ...
        remoteSbdDir, localSbdDir, ...
        startingDate, endingDate);
    disp([num2str(length(fetchedSbdList), '%0.0f') ' new/updated binary data files fetched.']);
    
%% Surface log files downloading
    filePattern = [lower(gliderName) '*.log'];
    remoteLogDir = [dockserverDataBaseDir, '/logs'];
    localLogDir = fullfile(localDataBaseDir, 'logs');
    if ~exist(localLogDir, 'dir')
        [success, errorMsg] = mkdir(localLogDir);
        if isequal(success, 0)
            disp(errorMsg);
            return;
        end;
    end;
    
    fetchedLogList = downloadFiles(ftpStruct, filePattern, ...
        remoteLogDir, localLogDir, ...
        startingDate, endingDate);
    disp([num2str(length(fetchedLogList), '%0.0f') ' new/updated surface log files fetched.']);
    
%% Close the ftp connection
    close(ftpStruct.ftpHandle);
    return;

%% Sub-function downloadFiles
    function fetchedFilesList = downloadFiles(ftpStruct, filePattern, remoteDir, localDir, ...
        startingDate, endingDate)
    
        % Initialize output
        fetchedFilesList = {};
        
        % Get list of remote files
        try
            cd(ftpStruct.ftpHandle, remoteDir);
            remoteFiles = dir(ftpStruct.ftpHandle, filePattern);
            if isempty(remoteFiles)
                disp(['No files on dockserver following pattern ', filePattern]);
                return;
            else
                filesTimestamp = [remoteFiles(:).datenum]';
                areInPeriodIdx = (filesTimestamp >= startingDate & filesTimestamp <= endingDate);
                remoteFiles = remoteFiles(areInPeriodIdx);
                remoteFilenames = {remoteFiles.name}';
            end;
        catch MatExcep
            disp('Could not get remote file list');
            disp(getReport(MatExcep.stack, 'extended'));
            return;
        end;

        % Get list of local files
        localFiles = dir(fullfile(localDir, filePattern));
        localFilenames = {localFiles.name}';
        
        % Loop through the list of remote (dockserver) files:
        % 1 - if the file is not found locally, fetch it.
        % 2 - if the file is found locally, re-fetch it only if
        % it's size has increased.
        for fileIdx = 1:length(remoteFilenames)
            % If there is no local copy
            if isempty(strmatch(remoteFilenames{fileIdx}, localFilenames))
                disp(['Downloading new file: ', remoteFilenames{fileIdx}]);
                [ftpStruct, fetchedFileName] = fetchOneFile(ftpStruct, remoteFilenames{fileIdx}, localDir);
                if ~isempty(fetchedFileName)
                    fetchedFilesList{end+1} = fetchedFileName{:};
                end;
                
            % Get remote file if is larger than local one
            else 
                remoteSize = remoteFiles(fileIdx).bytes;
                localFile = dir(fullfile(localDir, remoteFilenames{fileIdx}));
                if ~isempty(localFile)
                    localSize = localFile.bytes;
                    if remoteSize > localSize
                        disp(['Updating file: ', remoteFilenames{fileIdx}]);
                        [ftpStruct, fetchedFileName] = fetchOneFile(ftpStruct, remoteFilenames{fileIdx}, localDir);
                        if ~isempty(fetchedFileName)
                            fetchedFilesList{end+1} = fetchedFileName{:};
                        end
                    end; % if remoteSize > localSize
                end; % if ~isempty(localFile)
            end; % if isempty(strmatch(remoteFilenames{fileIdx}, localFilenames))
        end; % for fileIdx = 1:length(remoteFilenames)
    end

    function [ftpStruct, fetchedFileName] = fetchOneFile(ftpStruct, remoteFileName, localDir)
        try
            fetchedFileName = mget(ftpStruct.ftpHandle, remoteFileName, localDir);
        catch MatExcep
            disp('Fetch Error');
            disp(getReport(MatExcep.stack, 'extended'));
            try
                ftpStruct = ftpReconnect(ftpStruct);
            catch MatExcep2
                disp('Reconnection failed too');
                disp(getReport(MatExcep2.stack, 'extended'));
            end;
        end;
    end

%% Sub-function ftp handling
    function newFtpStruct = ftpConnect(ftpStruct)
        newFtpStruct = ftpStruct;
        newFtpStruct.ftpHandle = ...
            ftp(ftpStruct.dockURL, ftpStruct.ftpUser, ftpStruct.ftpPass);
    end

    function newFtpStruct = ftpReconnect(ftpStruct)
        newFtpStruct = ftpStruct;
        close(ftpStruct.ftpHandle);
        newFtpStruct.ftpHandle = ...
            ftp(ftpStruct.dockURL, ftpStruct.ftpUser, ftpStruct.ftpPass);
    end

end

