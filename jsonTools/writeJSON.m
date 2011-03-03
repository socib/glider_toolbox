function writeJSON(treeStruct, fileName)
%WRITEJSON - Outputs the given structure into a file as a JSON string
% This function 
%
% Syntax: writeJSON(treeStruct, fileName)
%
% Inputs:
%    treeStruct - matlab structure to be converted to a JSON string
%    fileName - fully qualified name of the output file
%
% Outputs: none
%
% Example:
%    writeJSON(treeStruct, fileName)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIELDNAMES, FPRINTF
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 03-Mar-2011
%

    fid = fopen(fileName, 'wt');
    if fid < 3
        disp(['Error creating ' fileName]);
        return;
    end;
    if numel(treeStruct) > 1
        writeArray(fid, treeStruct)
    else
        writeObject(fid, treeStruct);
    end;
    fclose(fid);
    return;

    function writeObject(fid, object)
        fprintf(fid, '{\n');
        members = fieldnames(object);
        if ~isempty(members)
            for memberIdx = 1:length(members)
                memberName = members{memberIdx};
                fprintf(fid, '"%s" :', memberName);
                writeValue(fid, object.(memberName));
                if memberIdx < length(members)
                    fprintf(fid, ',\n');
                else
                    fprintf(fid, '\n');
                end;
            end;
        end;
        fprintf(fid, '}\n');
    end

    function writeArray(fid, object)
        fprintf(fid, '[\n');
        
        for valueIdx = 1:length(object)
            writeValue(fid, object(valueIdx));
            if valueIdx < length(object)
                fprintf(fid, ', ');
            end;
        end;
        fprintf(fid, ']');
    end

    function writeValue(fid, object)
        if ischar(object)
            fprintf(fid, '"%s"', object);
        elseif length(object) > 1
            writeArray(fid, object);
        elseif isnumeric(object) && ~isnan(object)
            fprintf(fid, '%f', object);
        elseif isnumeric(object) && isnan(object)
            fprintf(fid, '"NaN"');
        else
            writeObject(fid, object);
        end;
    end

end
