function data_filtered_preprocessed = filterGoodData(qc_preprocessed, data_preprocessed)
%FILTERGOODDATA  Replaces bad values with NaNs.
%
%  Syntax:
%    DATA_FILTERED_PREPROCESSED = FILTERGOODDATA(QC_PREPROCESSED, DATA_PREPROCESSED)
%
%  Description:
%    Returns the data struct with bad values (QC flags 4, 6) replaced by
%    NaNs.
%
%    Runs through all fieldnames of the struct and cross-checks with the QC
%    struct data.
%
%  Notes:
%    Requires the QC output and the stored data struct.
%
%  Examples:
%    data_filtered_preprocessed = filterGoodData(qc_preprocessed, data_preprocessed)
%
%  See also:
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

data_filtered_preprocessed = data_preprocessed;
badIdx = struct();
fields = fieldnames(data_preprocessed);
for i=1:numel(fields)
    badIdx.(fields{i}) = (qc_preprocessed.(fields{i}).qcFlaggedOutput==4 | qc_preprocessed.(fields{i}).qcFlaggedOutput==6);
    data_filtered_preprocessed.(fields{i})(badIdx.(fields{i})) = NaN;
    %% Test case
    test_case = false;
    if strcmp(fields{i},'salinity') && test_case
        disp('insert simple test case data')
        nonNanIdx = find(~isnan(data_filtered_preprocessed.temperature));
        % change first 20 items
        data_filtered_preprocessed.temperature(nonNanIdx(1:20)) = 0;
    end
end

end
