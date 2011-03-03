function fileList = listLoaders(folder, varargin)
%LISTLOADERS - One line description of what the function or script performs (H1 line)
% Returns a cell array of fully qualified and sorted (ascending) slocum glider
% .m data files from the directory specified by folder.
%
%
% Syntax: fileList = listLoaders(folder, varargin)
%
% Inputs:
%    folder - the directory to be explored
%    suffix (optional) - File type. Valid filetypes are:
%      'sbd', 'mbd', 'dbd', 'sf_dbd'...
%
% Outputs:
%    fileList - list of .m files
%
% Example:
%    fileList = listLoaders(folder);
%    fileList = listLoaders(folder, 'sbd');
%
% Other m-files required: dirToCell, sortLoaders
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

    % Initialize output
    fileList = {};

    % Validate directory
    if isequal(nargin, 0)
        disp('Please specify a directory!');
        return;
    elseif ~isdir(folder)
        disp(['Invalid directory specified: ', folder]);
        return;
    end;

    % Try to get the absolute path to the specified directory
    % ./ascii ? Check this
    [success, msg] = fileattrib('./ascii');
    if isequal(success, 1)
        folder = msg.Name;
    end;

    % Get a listing of the *bd.m files
    if nargin > 1
        glob = varargin{1};
        dbds = dir(fullfile(folder, ['*' glob '.m']));
    else
        dbds = dir(fullfile(folder, '*bd.m'));
    end;

    if isempty(dbds)
        return;
    end;

    % Sort the files
    dbds = sortLoaders(dbds);

    % Prepend the directory to each file and place in a cell array
    fileList = dirToCell(dbds, folder);

end