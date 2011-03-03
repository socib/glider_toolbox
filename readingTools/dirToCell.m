function filenames = dirToCell(dirStruct, fileBaseDir)
%DIRTOCELL - Converts the output of a dir command to a cell array of files
% Converts the entries contained in dirStruct (as returned by
% the dir command) to a cell array.  The string contained in fileBaseDir is
% appended to each entry to create the absolute path to the each file.
%
% Syntax: filenames = dirToCell(dirStruct, fileBaseDir)
%
% Inputs:
%    dirStruct - the outuput structure of a 'dir' command
%    fileBaseDir - the base path to be appended to the files names
%
% Outputs:
%    filenames - fully qualified path files names
%
% Example:
%    filenames = dirToCell(dirStruct, fileBaseDir)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: DEAL
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

    % Initialize output
    filenames = {};

    % Validate arguments
    if ~isequal(nargin, 2)
        disp([mfilename ': 2 arguments required.']);
        return;
    elseif ~isstruct(dirStruct)
        disp([mfilename ':First argument must be a directory structure.']);
        return;
    elseif ~isdir(fileBaseDir)
        disp([mfilename ':Invalid directory specified.']);
        return;
    end;

    [filenames{1:length(dirStruct)}] = deal(dirStruct.name);
    filenames = filenames';

    for fileIdx = 1:length(filenames)
        filenames{fileIdx} = fullfile(fileBaseDir, filenames{fileIdx});
    end;

end