function [data, varargout] = removeDuplicatedRecords(oldData, column, keepFirst)
%REMOVEDUPLICATEDRECORDS - Removes records with same value at specified column
% This function removes or combines the records with the same value at
% the specified column (usually time).
%
% Syntax: data = removeDuplicatedRecords(oldData, column, keepFirst)
%  [data, idxRemoved] = removeDuplicatedRecords(oldData, column, keepFirst)
%  [data, idxRemoved, idxStayed] = removeDuplicatedRecords(oldData, column, keepFirst)
%
% Inputs:
%    oldData - Data matrix
%    column - Column we want to be unique in the output
%    keepFirst - Flag to determine if records are removed or combined
%
% Outputs:
%    data - Data matrix without repeated records
%    idxRemoved - Indices in the original matrix of the removed records
%    idxStayed - Indices in the original matrix of the records that stayed
%
% Example:
%    data = removeDuplicatedRecords(oldData, column, keepFirst)
%    [data, idxRemoved] = removeDuplicatedRecords(oldData, column, keepFirst)
%    [data, idxRemoved, idxStayed] = removeDuplicatedRecords(oldData, column, keepFirst)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIND, SETDIFF, NANMEAN
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 18-Feb-2011
%

    data = oldData;
    recordsRemoved = 0;
    idxRemoved = [];
    duplicates = true;
    while duplicates

        deltaTime = diff(data(:, column));

        startsAt = find(deltaTime == 0, 1, 'first');
        if isempty(startsAt)
            duplicates = false;
            break;
        end;

        endsAt = find(deltaTime(startsAt:end) ~= 0, 1, 'first');
        if isempty(endsAt)
            endsAt = length(deltaTime);
        else
            endsAt = startsAt + endsAt - 1;
        end;

        if keepFirst
            data(startsAt, :) = nanmean(data(startsAt:endsAt, :));
            data(startsAt+1:endsAt, :) = [];
            idxRemoved = [idxRemoved; (recordsRemoved + (startsAt+1:endsAt))'];
            recordsRemoved = recordsRemoved + (endsAt - startsAt);
        else
            data(startsAt:endsAt, :) = [];
            idxRemoved = [idxRemoved; (recordsRemoved + (startsAt:endsAt))'];
            recordsRemoved = recordsRemoved + (endsAt - startsAt + 1);
        end;
    end;

    if nargout > 1
        varargout{1} = idxRemoved;
    end;
    if nargout > 2
        difference = setdiff(1:size(oldData, 1), idxRemoved);
        varargout{2} = difference(:);
    end;
end