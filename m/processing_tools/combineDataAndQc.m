function combined_struct = combineDataAndQc(data_struct, qc_struct, applied_qc_LuT)
%COMBINEDATAANDQC  Combines the data struct with QC outputs.
%
%  Syntax:
%    COMBINED_STRUCT = COMBINEDATAANDQC(DATA_STRUCT, QC_STRUCT, APPLIED_QC_LUT)
%
%  Description:
%    Returns one structure consisting the data and QC flagged output, as
%    well as the QC identifiers. To add data to the COMBINED_STRUCT, the
%    QC_STRUCT fieldnames should be the same as those in the DATA_STRUCT. 
%    Adds only qcFlaggedOutput and appliedQcIdentifiers to data fields that
%    have the same fieldname than those in DATA_STRUCT.
%
%  Notes:
%    Currently, the applied QC identifier is put into a seperate variable.
%
%  Examples:
%    config = configBasicQualityControl();
%    applied_qc_LuT = config.applied_QC_LuT;
%    test_struct.time = [1 2 3 4 5];
%    test_qc_struct.time.qcFlaggedOutput = [1 1 1 4 1];
%    test_qc_struct.time.appliedQcIdentifiers = ['' '' '' 'impossibleDateCheck' ''];
%    combineDataAndQc(test_struct, test_qc_struct, applied_qc_LuT)
%
%  See also:
%    ADDQCTONETCDFVARIABLES
%    PERFORMQC
%    PERFORMGRIDDEDQC
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

%% Check inputs.
narginchk(3,3)
validateattributes(data_struct, {'struct'}, {'nonempty'})
validateattributes(qc_struct, {'struct'}, {'nonempty'})
validateattributes(applied_qc_LuT, {'struct'}, {'nonempty'})

%% Start assembling.
names_data = fieldnames(data_struct);
combined_struct = struct();

for i=1:numel(names_data)
    combined_struct.(names_data{i}) = data_struct.(names_data{i});
    if isfield(qc_struct, (names_data{i}))
        new_name = strcat('QC_', names_data{i});
        combined_struct.(new_name) = qc_struct.(names_data{i}).qcFlaggedOutput;
        new_name = strcat('QC_ID_', names_data{i});

        %% Format qc LuT for processing format.
        idx = strfind(applied_qc_LuT.QC_method_names, ' ');
        pointer = 1;
        splitted_method_names = cell(1,length(idx)+1);
        splitted_method_ids = zeros(1, length(idx)+1);
        for j=1:length(idx)
            splitted_method_names{j} = applied_qc_LuT.QC_method_names(pointer:idx(j)-1);
            splitted_method_ids(j) = applied_qc_LuT.QC_method_IDs(j);
            pointer = idx(j);
        end
        splitted_method_names{end} = applied_qc_LuT.QC_method_names(pointer+1:end);
        splitted_method_ids(end) =  applied_qc_LuT.QC_method_IDs(end);
        
        %% Replace String representation of QC flag identifiers.
        IDs = zeros(size(qc_struct.(names_data{i}).qcFlaggedOutput));
        for j=1:length(splitted_method_names)
            idx = strcmp(splitted_method_names{j}, qc_struct.(names_data{i}).appliedQcIdentifiers);
            IDs(idx) = splitted_method_ids(j);
        end
        combined_struct.(new_name) = IDs;
    else
        disp('QC variable name not found')
    end
end
end
