function logQC(qc_data, data, log_file_name)
%LOGQC  Writes summary of applied QC to the file.
%
%  Syntax:
%    LOGQC(QC_DATA, DATA, LOG_FILE_NAME)
%
%  Description:
%    Writes a summary of the applied QC to the specified log file by
%    finding the amount of good, bad and NaNs within the QC dataset.
%
%  Notes:
%    Only interesting for debugging / logging purposes of the QC outputs.
%    Data struct generally not needed - in this case just added for
%    debugging purposes. 
%
%  Examples:
%    logQC(qc_data, data, log_file_name)
%
%  See also:
%    CONFIGDATAPREPROCESSINGQC
%    PERFORMQC
%    FILTERGOODDATA
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2017
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

%% Check input.
narginchk(3,3)
validateattributes(qc_data, {'struct'}, {'nonempty'})
validateattributes(data, {'struct'}, {'nonempty'})
validateattributes(log_file_name, {'char'}, {'nonempty'})

%% Begin processing.
dataLengthBeforeQc = length(data.time);
fprintf('Starting log file QC output...\r\n')

fileID = fopen(log_file_name, 'w');
fprintf(fileID, '%d entries per variable before QC filtering.\r\n', dataLengthBeforeQc);

dataNames = fieldnames(data);
for i=1:numel(dataNames)
    idx = (qc_data.(dataNames{i}).qcFlaggedOutput==1);
    lenIdx = length(find(idx==1));
    fprintf(fileID, 'QC of %s :\r\n', (dataNames{i}));
    fprintf(fileID, '%d good (QC flag 1) measurements\r\n', lenIdx);
    tempLen = length(find(qc_data.(dataNames{i}).qcFlaggedOutput==9));
    fprintf(fileID, '%d NaN (QC flag 9) values\r\n', tempLen);
    tempLen = length(find(qc_data.(dataNames{i}).qcFlaggedOutput>2 & qc_data.(dataNames{i}).qcFlaggedOutput<9));
    fprintf(fileID, '%d (probably) Bad (QC flag (3), 4, 6) values\r\n', tempLen);
     tempCell = qc_data.(dataNames{i}).appliedQcIdentifiers;
     tempCell(any(cellfun(@isempty,tempCell),2),:) = [];
     appliedQcNames = unique(tempCell);
     fprintf(fileID, 'Detailed list of applied QC:\r\n');
     for j=1:numel(appliedQcNames)
         idx = find(strcmp(appliedQcNames{j}, tempCell));
         lenIdx = length(idx);
         fprintf(fileID, '%d entries marked with %s\r\n', lenIdx, appliedQcNames{j});
     end
    fprintf(fileID, '\r\n');
end
fclose(fileID);


end
