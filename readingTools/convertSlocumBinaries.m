function asciis = convertSlocumBinaries(files, varargin)
%CONVERTSLOCUMBINARIES - generates ascii files from binary glider files
% Convert Webb Research Corporation Slocum coastal electric glider binary
% data files (*.*bd) to ASCII text and create .m-script files for loading on a
% segment by segment basis.  The files cell array argument should contain a
% list of binary files to convert. 
%
% The default behavior is as follows: Source files are taken from the files
% cell array or, if empty, the current working directory is searched and is
% also the default destination for the converted ASCII files.   Source files
% named with the 8.3 naming convention are not renamed.  Cache (.cac) files
% used in the conversion and/or created are placed in a directory (./cache)
% directly below the destination directory.
%
% See dbd_file_format.txt for data file specs and an in-depth explanation of
% the conversions.
%
% Optional arguments to modify the default behavior:
%
%
% Syntax: asciis = convertSlocumBinaries(files, varargin)
%
% Inputs:
%    files - files list or empty
%    varargin - a list of pairs specifying parameter and value as follows:
%    - s|source <DIRECTORY> - location of *.*bd files.  This option is 
%      ignored if the files cell array is not empty.
%    - d|dest|destination <DIRECTORY> - destination for the converted files.
%    - e|extensions <FILETYPES> - string specifying a single filetype 
%      to convert or a cell array of filetypes to convert.
%    -f|filter <sensor_list> - Converted files will contain only 
%      the sensors listed in the file named sensor_list.
%    - c|cache|cachedir <directory> - specify the location of the .cac files used.
%
% Outputs:
%    asciis - converted files list
%
% Example:
%    Line 1 of example
%    Line 2 of example
%
% Other m-files required: dirToCell
% Subfunctions: relPathToAbsPath
% MAT-files required: none
%
% See also: DIRTOCELL
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

    % Return value contains all successfully converted .m file segments
    asciis = {};

    % Add this path and all child directories to path
    [thisRoot, thisMfile] = fileparts(mfilename('fullpath'));
    computerOS = computer;
    switch computerOS
        case {'PCWIN', 'PCWIN64'}
            pathSuffix      = 'windoze';
            binaryExtension = '.exe';
            commandPreffix  = 'call ';
        case {'GLNX86', 'GLNXA64'}
            pathSuffix      = 'linux';
            binaryExtension = '';
            commandPreffix  = '';
        case 'MACI64'
            disp('No binary executables for Apple Macintosh');
            return;
        otherwise
            disp(['Unknown platform: ' computerOS]);
            return;
    end;
    binaryBasePath = fullfile(thisRoot, 'WRC', [pathSuffix, '-bin']);
    % exeFile = fullfile(binaryBasePath, ['<anyBinary>', binaryExtension]);

    % Store the current working directory
    currentDir = pwd;

    % Validate input arguments:
    % No input args:
    %   1. Set files to an empty cell array.
    %   2. Use pwd for ALL directories
    % 1 input arg:
    %   1. If arg is a cell array, assume qualified filenams and store in files
    %   cell array.
    %   2. If not, return error.
    % > 1 input arg:
    %   1. If first arg is a cell array, assume qualified filenames and store in
    %   files cell array.
    %   2. If not, place first arg in options cell array.
    %   3. Place rest of args in options cell array.
    options = varargin;

    % Location of temporary directory for doing the conversions
    try
        temporalDir = [tempname '_' thisMfile];
    catch ME %#ok<NASGU>
        temporalDir = [pwd '_' thisMfile];
    end;
    % Default all directories to the current working directory
    sourceDir = '';
    destDir   = pwd;
    cacheDir  = fullfile(pwd, 'cac');
    % Boolean: 1 renames the 8.3s and 0 leaves them 8.3
    renameFlag = 0;
    filterListFile = [];
    % Binary file extension
    navExtensions = {'sbd'; 'mbd'; 'dbd'};
    sciExtensions = {'tbd'; 'nbd'; 'ebd'};
    extensions = vertcat(navExtensions, sciExtensions);
    EXT = extensions;

    % Validate the first argument, this list of filenames to convert
    if isempty(files)
        files = {};
    elseif ~iscell(files)
        disp('Files argument must be a cell array of valid filenames!');
        return;
    end;

    % Process args
    for x = 1:2:length(options)

        name  = options{x};
        value = options{x+1};

        switch name
            case {'s', 'source'}
                % Validate and set the source directory
                if ~isempty(files)
                    disp('Source files already specified!');
                    return;
                elseif isdir(value)
                    sourceDir = value;
                else
                    disp(['Invalid source directory: ' value]);
                    return;
                end;

            case {'d', 'dest', 'destination'}
                % Create the directory if it does not exist
                if ~isdir(value)
                    [success,msg] = mkdir(value);
                    if isequal(success, 0)
                        disp(['Cannot create destination: ' msg]);
                        return;
                    end;
                end;
                % Validate and set the destination directory
                [success,msg] = fileattrib(value);
                if isequal(success,1)
                    if isequal(msg.UserWrite,1)
                        destDir = value;
                    else
                        disp(['Destination Directory not writeable: ' value]);
                        return;
                    end;
                else
                    disp(['Invalid destination directory: ' value]);
                    return;
                end;

            case {'e', 'extension'}
                % Validate and set the extension type(s)
                C = intersect(extensions, lower(value));
                if length(C) ~= length(value)
                    disp('Invalid extension(s) specified!');
                    return;
                end;
                if ~iscell(C)
                    EXT = cell2mat(C, 1, 3);
                else
                    EXT = C;
                end;

            case {'f', 'filter'}
                % Check that dba_sensor_filter is on the path
                dba_sensor_filter = ...
                    fullfile(binaryBasePath, ['dba_sensor_filter', binaryExtension]);
                % Validate and set the flag to filter the sensor list'
                if exist(dba_sensor_filter, 'file') &&...
                        ~isempty(value) &&...
                        exist(value, 'file')
                    filterListFile = value;
                end;

            case {'c', 'cache'}
                % Use value as the location for the cache directory (create if
                % necessary
                if ~isdir(value)
                    [success,msg] = mkdir(value);
                    if isequal(success,0)
                        disp(['Cache dir error: ' msg]);
                        return;
                    end;
                end;
                cacheDir = value;

            otherwise
                disp(['Unknown option: ' name]);
                return;
        end; % switch name

    end; % for x = 1:2:length(options)

    % Validate directories
    if isempty(files)
        sourceDir = relPathToAbsPath(sourceDir);
    end;
    
    destDir = relPathToAbsPath(destDir);
    
    if ~isdir(cacheDir)
        [success, msg] = mkdir(cacheDir);
        if ~isequal(success,0)
            disp(['Error creating cache dir: ' msg]);
        end;
    end;
    cacheDir = relPathToAbsPath(cacheDir);
    
    if isdir(temporalDir)
        temporalDir = relPathToAbsPath(temporalDir);
    end;

    % Display the output parameters
    disp(['Source      : ' sourceDir]);
    disp(['Destination : ' destDir]);
    disp(['Cache       : ' cacheDir]);
    disp(['Temp        : ' temporalDir]);
    
    filetypes = '';
    for x = 1:length(EXT)
        filetypes = strcat(filetypes, ' ', EXT{x}, ',');
    end;
    filetypes(end) = '';
    disp(['Filetypes   : ' filetypes]);

    if isequal(renameFlag, 1)
        disp('Renaming 8.3: YES');
    else
        disp('Renaming 8.3: NO');
    end;
    
    if isempty(filterListFile)
        disp('Sensor list : None');
    else
        disp(['Sensor list : ' filterListFile]);
    end;

    % Make sure we can write to the destination directory
    [~, msg] = fileattrib(destDir);
    if ~isequal(msg.UserWrite, 1)
        disp('Destination directory is not writeable!');
        return;
    end;

    % Check if merging is required
    mergingRequired = ~isempty(intersect(sciExtensions, EXT)) &&...
                      ~isempty(intersect(navExtensions, EXT));

    % Look for the REQUIRED WRC binaries depending on platform type
    rename_dbd_files = fullfile(binaryBasePath, ['rename_dbd_files', binaryExtension]);
    dbd2asc = fullfile(binaryBasePath, ['dbd2asc', binaryExtension]);
    if mergingRequired
        dba_merge = fullfile(binaryBasePath, ['dba_merge', binaryExtension]);
    end;
    dba2_orig_matlab = fullfile(binaryBasePath, ['dba2_orig_matlab', binaryExtension]);

    % Validate the existence of the REQUIRED executables
    binaryMissing = false;
    if renameFlag && ~exist(rename_dbd_files, 'file')
        disp(['Missing: ' rename_dbd_files]);
        binaryMissing = true;
    end;
    if ~exist(dbd2asc, 'file')
        disp(['Missing: ' dbd2asc]);
        binaryMissing = true;
    end;
    if ~exist(dba2_orig_matlab, 'file')
        disp(['Missing: ' dba2_orig_matlab]);
        binaryMissing = true;
    end;
    if mergingRequired && ~exist(dba_merge, 'file')
        disp(['Missing: ' dba_merge]);
        binaryMissing = true;
    end
    if binaryMissing
        return;
    end;

    % Use the files cell array for the list of files to convert OR,
    % If sourceDir is set, search for file of the type specified by EXT
    if isempty(files) && isempty(sourceDir)
        disp('No files  or source directory specified!');
        return;
    elseif ~isempty(sourceDir)

        fprintf('Getting file listing...');
        files = {};
        for x = 1:length(EXT)

            % Lowercase (ie: *.sbd)
            dbds = dirToCell(dir(fullfile(sourceDir,...
                ['*.*' lower(EXT{x})])), sourceDir);
            files = [files; dbds]; %#ok<AGROW>
            % Uppercase (ie: *.SBD)
            dbds = dirToCell(dir(fullfile(sourceDir,...
                ['*.*' upper(EXT{x})])), sourceDir);
            files = [files; dbds]; %#ok<AGROW>
        end
        files = unique(files);
        fprintf('%0.0f files found.\n', length(files));
    end

    % Return if no files found
    if isempty(files)
        return;
    end

    % Create the temporary directory
    if isdir(temporalDir)
        disp(['Temporary dir: ' temporalDir ' already exists!']);
        return;
    else
        [success, msg] = mkdir(temporalDir);
        if ~isequal(success, 1)
            disp(['Cannot create temp dir: ', msg]);
            return;
        end
    end

    % Copy the list of files to the temporary directory
    fprintf('Copying dbds...');
    binFileCounter = 0;
    for fileIdx = 1:length(files)
        dbd = files{fileIdx};
        [success, msg] = copyfile(dbd, temporalDir);
        if isequal(success, 0) % copy failed
            disp(['Copy Error: ' msg]);
            continue;
        else
            binFileCounter = binFileCounter + 1;
        end
        % Update the file status
        if isequal(binFileCounter,1)
            format_string = '%0.0f';
        elseif binFileCounter <= 10
            format_string = '\b%0.0f';
        elseif binFileCounter <= 100
            format_string = '\b\b%0.0f';
        elseif binFileCounter <= 1000
            format_string = '\b\b\b%0.0f';
        elseif binFileCounter <= 10000
            format_string = '\b\b\b\b%0.0f';
        end;
        fprintf(format_string, binFileCounter);

    end
    fprintf('\n');

    % Exit if no files were copied
    if isequal(binFileCounter, 0)
        disp('No files copied!');
        fprintf('Cleaning up...');
        [success, msg] = rmdir(temporalDir, 's');
        if isequal(success, 0)
            disp(['Error removing temp dir (', temporalDir, '): ', msg]);
        end;
        return;
    end;

    % Change to temporalDir before converting and
    % make sure we can write to the temporary directory
    cd(temporalDir);
    [~, msg] = fileattrib(temporalDir);
    if ~isequal(msg.UserWrite,1)
        disp('Temporary directory is not writeable!');
        return;
    end;

    % Rename the files first (if asked)
    if isequal(renameFlag, 1)
        disp('Renaming files...');
        switch computer
            case {'PCWIN', 'PCWIN64'}
                dos(['dir | call ', rename_dbd_files, ' -s']);
            otherwise
                unix(['ls | ', rename_dbd_files, ' -s']);
        end;
    end;

    % Get the new file listing
    if mergingRequired
        initialFiles = {};
        for extIdx = 1:length(EXT)
            currentExtension = intersect(lower(EXT{extIdx}), sciExtensions);
            if isempty(currentExtension)
                continue;
            end;
            % Lowercase (ie: *.sbd)
            partialFiles = dirToCell(dir(['*.', lower(cell2mat(currentExtension))]), pwd);
            initialFiles = [initialFiles; partialFiles]; %#ok<AGROW>
            % Uppercase (ie: *.SBD)
            partialFiles = dirToCell(dir(['*.', upper(cell2mat(currentExtension))]), pwd);
            initialFiles = [initialFiles; partialFiles]; %#ok<AGROW>
        end
        initialFiles = unique(initialFiles);
    else
        initialFiles = dirToCell(dir, pwd);
    end;

    % Create the string to execute
    % dbd2asc <-c cacheDir> -o filename | <dba_sensor_filter -f filename> |
    % dba2_orig_matlab
    totalCount = 0;
    for fileIdx = 1:length(initialFiles)

        if isdir(initialFiles{fileIdx})
            continue;
        end;

        % Increment the total file count
        totalCount = totalCount + 1;
        fprintf('Converting (%d of %d): %s ...\n', ...
            fileIdx, length(initialFiles), initialFiles{fileIdx});

        % Convert from binary to ascii and print to STDOUT (pipe)
        if mergingRequired
            scienceFile = initialFiles{fileIdx};
            [fileRoute, fileName, fileExtension] = fileparts(scienceFile);
            [membership, position] = ismember(lower(fileExtension(2:end)), sciExtensions);
            if membership
                navFile = fullfile(fileRoute, [fileName, '.', navExtensions{position}]);
                if ~exist(navFile, 'file')
                    navFile = fullfile(fileRoute, [fileName, '.', upper(navExtensions{position})]);
                    if ~exist(navFile, 'file')
                        disp('Error locating corresponding navigation file');
                        continue;
                    end;
                end;
            else
                disp('Error locating corresponding navigation file');
                continue;
            end;

            theCommand = [commandPreffix, dbd2asc, ' -o -c ', cacheDir, ' ', scienceFile, ' >', scienceFile, '.asc'];
            system(theCommand);

            theCommand = [commandPreffix, dbd2asc, ' -o -c ', cacheDir, ' ', navFile, ' >', navFile, '.asc'];
            system(theCommand);

            theCommand = [commandPreffix, dba_merge, ' ', navFile, '.asc ', scienceFile, '.asc | '];
        else
            navFile = initialFiles{x};
            theCommand = [commandPreffix, dbd2asc, ' -o -c ', cacheDir, ' ', navFile, ' | '];
        end;

        % Filter the output sensors if requested
        if ~isempty(filterListFile)
            theCommand = [theCommand, commandPreffix, ...
                dba_sensor_filter, ' -f ', filterListFile, ' | ']; %#ok<AGROW>
        end;

        % Create the .dat and .m files
        theCommand = [theCommand, commandPreffix, dba2_orig_matlab]; %#ok<AGROW>
        [~, resultOutput] = system(theCommand);

        resultOutput = strtrim(resultOutput); % remove newlines
        disp(['Generated file: ', resultOutput]);

        % See if the file exists (ie: successful conversion)
        loaderFile = fullfile(pwd, resultOutput);
        if ~exist(loaderFile, 'file')
            disp('Conversion was not successful');
            continue;
        end;

        % Move the converted files to destDir
        [dbdPath, dbdFile] = fileparts(loaderFile);
        [success, msg] = movefile(fullfile(dbdPath, [dbdFile '*']), destDir);
        if isequal(success, 0)
            disp(['Error moving file (', loaderFile, '): ', msg]);
            continue;
        end;

        % Add the converted mfilename to the return value cell array
        asciis{end + 1} = fullfile(destDir, dbdFile); %#ok<AGROW>
    end;

    % Change back to working directory
    cd(currentDir);

    % Remove the temporary directory and all files before exiting
    fprintf('Removing temporary directory...');
    [success, msg] = rmdir(temporalDir, 's');
    if isequal(success, 0)
        disp(['Error removing temporary directory: ', msg]);
    end;

    disp([num2str(length(asciis)), '/ ', num2str(totalCount), ...
        ' files SUCCESSFULLY converted.']);

    asciis = asciis';

    
    function absPath = relPathToAbsPath(relPath)
        currentWorkDir = pwd;
        cd(relPath);
        absPath = pwd;
        cd(currentWorkDir);     
    end

end