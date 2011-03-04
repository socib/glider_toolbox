function [basicProfileData, varargout] = buildCombinedProfile(timeserie, indexRange, varsSet, varargin)
%BUILDCOMBINEDPROFILE - Combines a set of variables into a clean profile
% This function selects a subset of the fields in timeserie, specified by
% the variables set, and outputs them into a clean profile.
% Optionally, the fields can be renamed.
%
% Syntax: basicProfileData = buildCombinedProfile(timeserie, indexRange, varsSet)
%       basicProfileData = buildCombinedProfile(timeserie, indexRange, varsSet, newFieldsNames)
%       [basicProfileData, goodIdx] = buildCombinedProfile(timeserie, indexRange, varsSet)
%       [basicProfileData, goodIdx] = buildCombinedProfile(timeserie, indexRange, varsSet, newFieldsNames)
%
% Inputs:
%    timeserie - A structure containing the different timeseries as fields
%    indexRange - A subrange of the timeseries that delimits a profile
%    varsSet - A subset of the fields in timeseries that should appear on
%           output
%    newFieldsNames - Optional, the name of the fields in the output
%           profile
%
% Outputs:
%    basicProfileData - A structure containing the desired timeseries
%    goodIdx - Indexes that remained after the profile cleaning
%
% Example:
%       basicProfileData = buildCombinedProfile(timeserie, indexRange, varsSet);
%       basicProfileData = buildCombinedProfile(timeserie, indexRange, varsSet, newFieldsNames);
%       [basicProfileData, goodIdx] = buildCombinedProfile(timeserie, indexRange, varsSet);
%       [basicProfileData, goodIdx] = buildCombinedProfile(timeserie, indexRange, varsSet, newFieldsNames);
%
% Other m-files required: cleanProfile
% Subfunctions: none
% MAT-files required: none
%
% See also: CLEANPROFILE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 04-Mar-2011
%

    % Check input set
    totalVarsSet = fieldnames(timeserie);
    if ~isempty(setdiff(varsSet, totalVarsSet))
        disp('The set of vars required are not in the input timeserie');
        return;
    end;
    
    if nargin > 3
        newFieldNames = varargin{1};
    else
        newFieldNames = varsSet;
    end;

    for varIdx = 1:length(varsSet)
        basicProfile.(newFieldNames{varIdx}) = timeserie.(varsSet{varIdx})(indexRange);
    end;
    [basicProfileData, goodRows] = cleanProfile(basicProfile);
    
    if nargout > 1
        varargout{1} = goodRows;
    end;
end
