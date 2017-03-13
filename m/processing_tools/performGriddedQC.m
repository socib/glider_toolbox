function output_data_struct = performGriddedQC(gridded_data, grid_qc_config)
%PERFORMGRIDDEDQC  Performs the specified QC handles.
%
%  Syntax:
%    OUTPUT_DATA_STRUCT = PERFORMGRIDDEDQC(GRIDDED_DATA, GRID_QC_CONFIG)
%
%  Description:
%    In the end, it behaves finally like the performQC function. 
%    Performs the defined QC methods with the specified configurations.
%    In general, this function gives each available (and specified) profile
%    to the determined QC method and merges the output to conform with the
%    designated processOn variables.
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
%       - Special handling for the two dimensional processing implemented.
%         This includes especially the treatment of 1D data that can affect
%         2D arrays (e.g. a wrong time measurement [really really unlikely
%         to happen], will affect one row within the temperature, ...
%         grid).
%       - See also the the qc tests (validRange etc.) for the test
%         implementation.
%
%  Notes:
%    Take care to pass only the output of the configDataGriddingQC as
%    grid_qc_config to this function, since the inserting of data is
%    performed within this function (unlike the preprocessing and
%    processing configurations). Most steps executed in this function are
%    to correctly handle the argument passing and the effection of 1D QC
%    output to 2D data and vice versa.
%
%  Examples:
%    output_data_struct = performGriddedQC(gridded_data, grid_qc_config)
%
%  See also:
%    CONFIGDATAGRIDDINGQC
%    PERFORMQC
%    VALIDRANGECHECK
%    SPIKECHECK
%    IMPOSSIBLEDATECHECK
%    IMPOSSIBLELOCATIONCHECK
%    NANCHECK
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

%% Check input.
validateattributes(gridded_data, {'struct'}, {'nonempty'})
validateattributes(grid_qc_config, {'struct'}, {'nonempty'})

%% Process NaN Check.
dataNames = fieldnames(gridded_data);
if grid_qc_config.checkAllForNan.switch
    for i=1:numel(dataNames)
        dimensions = size(gridded_data.(dataNames{i}));
        output_data_struct.(dataNames{i}).qcFlaggedOutput = ones(dimensions);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers = cell(dimensions);
        
        if dimensions(2)==1
            qcOut = nanCheck(gridded_data.(dataNames{i}), 9);
        elseif dimensions(2)>=2
            qcOut = ones(dimensions);
            for k=1:dimensions(1)
                qcOut(k,:) = nanCheck(gridded_data.(dataNames{i})(k,:),9);
            end
        else
            error('Unknown dimension...')
        end
        idx = output_data_struct.(dataNames{i}).qcFlaggedOutput < qcOut;
        output_data_struct.(dataNames{i}).qcFlaggedOutput(idx) = qcOut(idx);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers(idx) = {char(grid_qc_config.checkAllForNan.functionHandle)};
    end
else 
    for i=1:numel(dataNames)
        output_data_struct.(dataNames{i}).qcFlaggedOutput = ones(dimensions);
        output_data_struct.(dataNames{i}).appliedQcIdentifiers = cell(dimensions);
    end
end

removeNames = {'checkAllForNan'};
grid_qc_config = removeVariablesFromStruct(grid_qc_config, removeNames, '');

%% Process other QC Methods (retrieved from config).
dimensions = 0;
tests = fieldnames(grid_qc_config);
for i=1:numel(tests)
    for j=1:numel(grid_qc_config.(tests{i}).processOn)
        handle = grid_qc_config.(tests{i}).functionHandle;
        % check dimension of passingParameters
        replacementIdx = [];
        for k=1:length(grid_qc_config.(tests{i}).passingParameters{j})
            if isa(grid_qc_config.(tests{i}).passingParameters{j}{k}, 'char')
                replacementIdx = [replacementIdx; k];
                grid_qc_config.(tests{i}).passingParameters{j}{k} = gridded_data.(grid_qc_config.(tests{i}).passingParameters{j}{k});
            end
        end
        % all data has been inserted to the struct
        % Check now for 2D or 1D input data
        dimensions = size(grid_qc_config.(tests{i}).passingParameters{j}{1});
        qcOut = ones(dimensions);
        % build arguments to pass into functions as cell array
        if dimensions(2)==1
            arguments = {};
            for n=1:length(grid_qc_config.(tests{i}).passingParameters{j})
                % find replacementIdx, dann Q{end+1} = [] oder Q(end+1) = {[]}
                if find(replacementIdx==n)
                    tempDimension = size(grid_qc_config.(tests{i}).passingParameters{j}{n});
                    if tempDimension(2)==1
                        arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n};
                    elseif tempDimension(2)>=2    
                        arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n}(o,:);
                    end
                else
                    arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n};
                end
            end
            qcOut = handle(arguments{:});
        elseif dimensions(2)>=2
            for o=1:dimensions(1)
                arguments = {};
                for n=1:length(grid_qc_config.(tests{i}).passingParameters{j})
                    % find replacementIdx, dann Q{end+1} = [] oder Q(end+1) = {[]}
                    if find(replacementIdx==n)
                        tempDimension = size(grid_qc_config.(tests{i}).passingParameters{j}{n});
                        if tempDimension(2)==1
                            arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n};
                        elseif tempDimension(2)>=2    
                            arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n}(o,:);
                        end
                    else
                        arguments{end+1} = grid_qc_config.(tests{i}).passingParameters{j}{n};
                    end
                end
                if dimensions(2)==1
                    qcOut = handle(arguments{:});
                elseif dimensions(2)>=2
                    qcOut(o,:) = handle(arguments{:});
                end
            end
        else
            error('Error in gridding QC. Unknown dimension...')
        end
        isCellFlag = false;
        if iscell(grid_qc_config.(tests{i}).processOn{j})
            isCellFlag = true;
            var_name = grid_qc_config.(tests{i}).processOn{j}{1};
        else
            var_name = grid_qc_config.(tests{i}).processOn{j};
        end
        % qcOut = handle(grid_qc_config.(tests{i}).passingParameters{j}{:});
        if ~isfield(output_data_struct, var_name)
            fprintf('QC variable name %s not found. Will skip this test. Please remove or rename the variable.\n', var_name)
            continue;
        end
        idx = output_data_struct.(var_name).qcFlaggedOutput < qcOut;
        if isCellFlag
            for k=1:length(grid_qc_config.(tests{i}).processOn{j})
                var_name = grid_qc_config.(tests{i}).processOn{j}{k};
                if ~isfield(gridded_data, var_name)
                    fprintf('QC variable name %s not found. Will skip this variable.\n', var_name)
                    continue;
                end
                if checkForTwoDimensionalData(gridded_data.(var_name)) && ~checkForTwoDimensionalData(idx)
                    %to process on is 2D data and the idx is only 1D
                    tempidx = find(idx);
                    for p=1:length(tempidx)
                        output_data_struct.(var_name).qcFlaggedOutput(tempidx(p),:) = qcOut(tempidx(p));
                        output_data_struct.(var_name).appliedQcIdentifiers(tempidx(p),:) = {char(grid_qc_config.(tests{i}).functionHandle)};
                    end
                else
                    %is uniformed 1D or 2D
                    output_data_struct.(var_name).qcFlaggedOutput(idx) = qcOut(idx);
                    output_data_struct.(var_name).appliedQcIdentifiers(idx) = {char(grid_qc_config.(tests{i}).functionHandle)};
                end
            end
        else
            if checkForTwoDimensionalData(gridded_data.(var_name)) && ~checkForTwoDimensionalData(idx)
                %to process on is 2D data and the idx is only 1D
                tempidx = find(idx);
                for p=1:length(tempidx)
                    output_data_struct.(var_name).qcFlaggedOutput(tempidx(p),:) = qcOut(tempidx);
                    output_data_struct.(var_name).appliedQcIdentifiers(tempidx(p),:) = {char(grid_qc_config.(tests{i}).functionHandle)};
                end
            else
                %is uniformed 1D or 2D
                output_data_struct.(var_name).qcFlaggedOutput(idx) = qcOut(idx);
                output_data_struct.(var_name).appliedQcIdentifiers(idx) = {char(grid_qc_config.(tests{i}).functionHandle)};
            end
        end
    end
end

end
