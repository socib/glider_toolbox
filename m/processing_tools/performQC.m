function output_data_struct = performQC(input_data_struct, performQC_config)
%PERFORMQC  Executes the specified QC handles.
%
%  Syntax:
%    OUTPUT_DATA_STRUCT = PERFORMQC(INPUT_DATA_STRUCT, PERFORMQC_CONFIG)
%
%  Description:
%    Performs the defined QC methods with the specified configurations.
%    Returns a struct consisting of the entries qcFlaggedOutput and
%    appliedQcIdentifiers. The first entry is the flagged QC output of the
%    defined QC functions. The second one tells, if a data point has been
%    flagged as bad, which QC method has been applied.
%    In particular, the following actions are executed:
%       - If the NaN switch is true:
%         Create an output struct for all data variables consisting of the
%         QC output (9s for all NaNs, remainder is 1) and another entry
%         which marks the applied method with the name of the applied
%         function.
%         Run through all data variables and mark existing NaNs with 9 and
%         also mark the entry as being flagged with the NaN check.
%       - Else, only the raw struct entries qcFlaggedOutput and
%         appliedQcIdentifiers will be created.
%       - For each defined QC method (validRange, impossibleLocation etc),
%         check, if the processOn contains more than one variable. If yes,
%         use the defined passingParameters for the QC output and apply it 
%         to all the processOn variables. Else, just perform the QC to the
%         single defined variable.
%       - See also the the qc tests (validRange etc.) for the test
%         implementation.
%         
%
%  Notes: In general, it only calls the QC methods, assigns the output to
%  the data and return a newly structured output.
%
%  Examples:
%    output_data_struct = performQC(input_data_struct, performQC_config)
%    
%
%  See also:
%       CONFIGDATAPREPROCESSINGQC
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

qcInputLength=length(input_data_struct.time);
output_data_struct = struct();

dataNames = fieldnames(input_data_struct);
if performQC_config.checkAllForNan.switch
    for i=1:numel(dataNames)
        output_data_struct.(dataNames{i}).qcFlaggedOutput = ones(qcInputLength,1);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers = cell(qcInputLength,1);
        qcOut = nanCheck(input_data_struct.(dataNames{i}), 9);
        idx = output_data_struct.(dataNames{i}).qcFlaggedOutput < qcOut;
        output_data_struct.(dataNames{i}).qcFlaggedOutput(idx) = qcOut(idx);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers(idx) = {char(performQC_config.checkAllForNan.functionHandle)};
    end
else 
    for i=1:numel(dataNames)
        output_data_struct.(dataNames{i}).qcFlaggedOutput = ones(qcInputLength,1);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers = cell(qcInputLength,1);
    end
end

removeNames = {'checkAllForNan', 'summaryFileName', 'replaceWithNans'};
removeFields = isfield(performQC_config, removeNames);
removeNames = removeNames(removeFields);
performQC_config = rmfield(performQC_config, removeNames);


fields = fieldnames(performQC_config);
for i=1:numel(fields)
    for j=1:numel(performQC_config.(fields{i}).processOn)
        handle = performQC_config.(fields{i}).functionHandle;
        qcOut = handle(performQC_config.(fields{i}).passingParameters{j}{:});
        isCellFlag = false;
        if iscell(performQC_config.(fields{i}).processOn{j})
            isCellFlag = true;
            var_name = performQC_config.(fields{i}).processOn{j}{1};
        else
            var_name = performQC_config.(fields{i}).processOn{j};
        end
        idx = output_data_struct.(var_name).qcFlaggedOutput < qcOut;
        if isCellFlag
            for k=1:length(performQC_config.(fields{i}).processOn{j})
                var_name = performQC_config.(fields{i}).processOn{j}{k};
                output_data_struct.(var_name).qcFlaggedOutput(idx) = qcOut(idx);
                output_data_struct.(var_name).appliedQcIdentifiers(idx) = {char(performQC_config.(fields{i}).functionHandle)};
            end
        else
            output_data_struct.(var_name).qcFlaggedOutput(idx) = qcOut(idx);
            output_data_struct.(var_name).appliedQcIdentifiers(idx) = {char(performQC_config.(fields{i}).functionHandle)};
        end
    end
end

end
