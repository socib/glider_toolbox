function profileIndex = findProfiles(depthTimeserie, inflectionInd)
%FINDPROFILES - Identifies profiles from a depth time serie and inflection points
% This function identifies profiles from a depth time serie and inflection points
% and removes profiles with gaps larger than 50% of the profile coverage.
% This is specially useful to remove sparse profiles, like the ones
% obtained between inflections when sampling only on downcast or upcast
% i.e. with one reading after inflection at depth and
% few before inflection as CTD turns on ahead of surface inflection
%
% Syntax: profileIndex = findProfiles(depthTimeserie, inflectionInd)
%
% Inputs:
%    depthTimeserie - a column vector with depth time serie
%    inflectionInd - a column vector with indices where inflections occur
%
% Outputs:
%    profileIndex - a column vector, same size than depthTimeserie, with
%                   indices of which profile this sample belongs to
%
% Example:
%    profileIndex = findProfiles(depthTimeserie, inflectionInd)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: MAX, MIN DIFF
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 24-Feb-2011
%

    % Initialize output
    profileIndex = nan(length(depthTimeserie) , 1);

    % Loop through profiles
    profileCounter = 0;
    dismissedCounter = 0;
    for idx = 1:length(inflectionInd) - 1

        profileRange  = inflectionInd(idx):inflectionInd(idx + 1);
        profileDepth  = depthTimeserie(profileRange);
        profileDepth  = profileDepth(~isnan(profileDepth));
        maxDepthRange = max(profileDepth) - min(profileDepth);
        maxGap        = max(abs(diff(profileDepth)));
        emptyRatio    = maxGap / maxDepthRange;
        % Profile longer than 10 meters and gaps smaller than 80%
        if and(maxDepthRange > 10, emptyRatio < 0.8)
            profileCounter = profileCounter + 1;
            profileIndex(profileRange) = profileCounter;
        else
            dismissedCounter = dismissedCounter + 1;
        end;
    end;

    disp([num2str(length(inflectionInd)), ' inflection points']);
    disp([num2str(profileCounter), ' profiles found']);
    disp([num2str(dismissedCounter), ' profiles dismissed']);
    disp([num2str(profileCounter + dismissedCounter), ' total profiles analyzed']);

end