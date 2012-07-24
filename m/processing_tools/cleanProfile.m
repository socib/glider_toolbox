function [cleanedProfile, varargout] = cleanProfile(profileData)
%CLEANPROFILE - Remove records from a profile that contain nans
% This function Remove records from a profile that contain nans
%
% Syntax: cleanedProfile = cleanProfile(profileData)
%         [cleanedProfile, idxStayed] = cleanProfile(profileData)
%
% Inputs:
%    profileData - Structure where each field is a column vector, all of
%                  them of the same size
%
% Outputs:
%    cleanedProfile - Structure with same fields as the input one, but
%                     with no nans in it
%    stayedIdx - Indices of the values that stayed
%
% Example:
%    [cleanedProfile, idxStayed] = cleanProfile(profileData);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIELDNAMES, FIND, ISNAN
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 22-Feb-2011
%

    varsSet = fieldnames(profileData);
    dataMatrix = []; % start with an empty matrix
    for varIdx = 1:length(varsSet)
        column = profileData.(varsSet{varIdx});
        dataMatrix = [dataMatrix, column(:)];
    end;

    goodRows = find( sum(isnan(dataMatrix), 2) == 0 );
    dataMatrix = dataMatrix(goodRows, :);

    for varIdx = 1:length(varsSet)
        cleanedProfile.(varsSet{varIdx}) = dataMatrix(:, varIdx);
    end;

    if nargout > 1
        varargout{1} = goodRows;
    end;

end
