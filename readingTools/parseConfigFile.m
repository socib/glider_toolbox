function configParams = parseConfigFile(filename)
%PARSECONFIGFILE - Parses glider config file and returns a structure
% This function returns a structured array containing
% glider deployment configuration parameters read from FILENAME.
% Parameter format is:
% PARAMETER1=VALUE1
% PARAMETER2=VALUE2
% ...
% Comments (%) are ignored.
%
% Syntax: configParams = parseConfigFile(filename)
%
% Inputs:
%    filename - fully qualified glider configuration file name
%
% Outputs:
%    configParams - structure with parameters and their values
%
% Example:
%    configParams = parseConfigFile('./glider.cfg');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: REGEXP
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

%% Initialize output structure as an empty set
    configParams = struct([]);

    if isequal(nargin, 0)
        disp([datestr(now, 30) 'E: Input file name not specified']);
        return;
    end

%% Try to open input file
    if ~exist(filename, 'file')
        disp([datestr(now, 30) 'E: Input file name does not exist']);
    end;

    [fileDescriptor, msg] = fopen(filename, 'r');
    % MATLAB reserves file identifiers 0, 1, and 2 for 
    % standard input, standard output, and standard error, respectively. 
    % When fopen successfully opens a file, 
    % it returns a file identifier greater than or equal to 3.
    if fileDescriptor < 3
        disp([datestr(now, 30) 'E: I/O Error: ' msg]);
        return;
    end;

%% Define required regular expressions to parse the config file
    skipRegExp       = '^\W';     % Skip lines if don't begin with letter or digit
    configPairRegExp = '\w+=';    % Valid NAME=VALUE pairing
    commentRegExp    = '[%#].*$'; % Comment after the NAME=VALUE pairing

%% Parse the file contents, line by line
    while ~feof(fileDescriptor)

        currentLine = fgetl(fileDescriptor);

        % Skip blank lines and comments
        if isempty(currentLine) || ~isempty(regexp(currentLine, skipRegExp, 'once'))
            continue;
        end;

        % Skip non-valid configuration pairings
        if isempty(regexp(currentLine, configPairRegExp, 'once'))
            continue;
        end;

        % Break up the valid configuration pairing
        [paramName,paramValue] = strtok(currentLine, '=');
        
        % Get rid of the equals sign
        paramValue(1) = [];
        
        % Strip out an comments
        paramValue = regexprep(paramValue, commentRegExp, '');
        
        % Add the parameter to the configParams data structure
        if isempty(paramValue)
            configParams(1).(paramName) = [];
        else
            % Deal with dates as a string: yyyy ONLY!
            if ~isempty(regexp(paramValue, '^\d{4}[/|-]\d{1,2}[/|-]\d{2}', 'once'))
                configParams(1).(paramName) = datenum(paramValue, 'yyyy-mm-dd');
                continue;
            end;

            % If the value contains only stringified numbers, convert them to
            % doubles and add them to the configuration, otherwise add the value
            % as the string.
            if ~isempty(regexp(paramValue, '^\-?(\s*\.*\d{1,}\.*\d*)+$', 'once'))
                % Add numeric values
                numVal = str2double(paramValue);
                if ~isnan(numVal)
                    configParams(1).(paramName) = numVal;
                else
                    configParams(1).(paramName) = strtrim(paramValue);
                end;
            else
                % Add the string
                configParams(1).(paramName) = strtrim(paramValue);
            end;
        end; % if isempty(paramValue)
    end; % while ~feof(fileDescriptor)

    fclose(fileDescriptor);
    
end