function [basicProfileData, varargout] = buildCombinedProfile(timeserie, indexRange, varsSet, varargin)

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
