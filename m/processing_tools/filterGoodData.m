function data_struct_filtered = filterGoodData(qc_struct, data_struct)
%FILTERGOODDATA  Replaces bad flagged values with NaNs.
%
%  Syntax:
%    DATA_STRUCT_FILTERED = FILTERGOODDATA(QC_STRUCT, DATA_STRUCT)
%
%  Description:
%    Returns the data struct with bad values (QC flags 4, 6) replaced by
%    NaNs.
%    Runs through all fieldnames of the struct and cross-checks with the QC
%    struct data.
%
%  Notes:
%    Requires the QC output and the stored data struct from the QC and
%    processing outputs.
%
%  Examples:
%    qc_struct.temperature.qcFlaggedOutput = [1 1 4 4 1 1];
%    data_struct.temperature = [15 16 99 99 16 16];
%    data_filtered_preprocessed = filterGoodData(qc_struct, data_struct)
%
%  See also:
%    PERFORMQC
%    PERFORMGRIDDEDQC
%    PREPROCESSGLIDERDATA
%    PROCESSGLIDERDATA
%    FILLINVALIDVALUES
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

data_struct_filtered = data_struct;
badIdx = struct();
fields = fieldnames(data_struct);
for i=1:numel(fields)
    badIdx.(fields{i}) = (qc_struct.(fields{i}).qcFlaggedOutput==4 | qc_struct.(fields{i}).qcFlaggedOutput==6);
    data_struct_filtered.(fields{i})(badIdx.(fields{i})) = NaN;
end

end
