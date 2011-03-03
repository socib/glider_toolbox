function sortedFiles = sortLoaders(inFiles)
%SORTLOADERS - Sorts slocum glider data loaders files in ascending order
% Sorts the slocum raw data files contained in the directory structure listing
% (returned from dir *.m) in ascending order.
%
% glidername_yyyy_ddd_[mm]m_[ss]s_[s|d|m]bd
%
% The files are sorted in this order:
%
%   yyyy        - year
%   ddd         - julian day
%   mmm         - mission number
%   sss         - segment number
%
% The sorted files are returned as a data structure identical to the input
% argument.
%
% Syntax: sortedFiles = sortLoaders(inFiles)
%
% Inputs:
%    inFiles - Input list of loaders files
%
% Outputs:
%    sortedFiles - Output ordered list of loaders files
%
% Example:
%    sortedFiles = sortLoaders(inFiles)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: SORTROWS DEAL, REGEXPREP
%
% Authors: John Kerfoot & Bartolome Garau
% Work address: 
% Author e-mail: kerfoot@imcs.rutgers.edu & tgarau@socib.es
% Website: http://rucool.marine.rutgers.edu & http://www.socib.es
% Creation: 18-Feb-2011
%

    % Initialize output
    sortedFiles = [];

    % Check input arguments
    if isempty(inFiles)
        disp('Empty directory listing!');    
        return;
    elseif ~isstruct(inFiles)
        disp('Directory listing must be a data structure!');
        return;
    end

    % Get a cell array list of file names
    [filenames{1:length(inFiles)}] = deal(inFiles.name);

    % Replace underscores and hyphens with spaces
    filenames = regexprep(filenames, '[-_]', ' ');

    % Intialize the sorting matrix
    sortMatrix = NaN(length(filenames), 4);
    for fileIdx = 1:length(filenames)
        % Search for the required number of whitespaces
        ind = find(filenames{fileIdx} == ' ');
        if length(ind) < 5
            continue;
        end
        sortMatrix(fileIdx, :) = ...
            str2num(filenames{fileIdx}(ind(1)+1:ind(5)-1)); %#ok<ST2NM>
    end

    % Sort the resulting matrix
    [~, rightOrderIdx] = sortrows(sortMatrix);
    sortedFiles = inFiles(rightOrderIdx);

end
