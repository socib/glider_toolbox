function newScienceTime = fillScienceTime(scienceTime)
%FILLSCIENCETIME - Makes science time continous (no nans)
% This function fills in NaN values in science time assuming it was
% regularly sampled
%
% Syntax: newScienceTime = fillScienceTime(scienceTime)
%
% Inputs:
%    scienceTime - vector with the original science time values
%
% Outputs:
%    newScienceTime - vector with the filled science time values
%
% Example:
%    newScienceTime = fillScienceTime(scienceTime)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIND, ISNAN, INTERP1
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 24-Feb-2011
%

    origSize       = size(scienceTime);
    scienceTime    = scienceTime(:);
    aRange         = (1:length(scienceTime))';
    goodRows       = find(~isnan(scienceTime));
    newScienceTime = interp1(goodRows, scienceTime(goodRows), aRange);
    newScienceTime = reshape(newScienceTime, origSize);

end
