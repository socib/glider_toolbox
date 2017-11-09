function [ data_paths ] = createFStruct( path_formats, deployment )
% CREATEFSTRUCT  Produces a structure with the path tree for glider
%                data processing for the specific deployment
%
%  Syntax:
%    [DATA_PATHS] = CREATEFSTRUCT(PATH_FORMATS, DEPLOYMENT)
%
%  Description:
%    CREATEFSTRUCT creates the directory names for glider data for a given
%    format specified in path_formats and the information of the deployment.
%    path_formats may contain any field.
%       - 
%    This function calls STRFSTRUCT to complete the name of the files and
%    directories using the format defined by the function. For example,
%    ${GLIDER_NAME} may be used to complete the string with the glider name
%    or ${DEPLOYMENT_START,Tyyyymmdd} to use start date of the deployment
%    in the path name. Refer to STRFSTRUCT for more details of the name
%    formats.
%
%  Input:
%    PATH_FORMATS is a structure that contains the fields described above.
%       The required fields are base_dir, binary_path, ascii_path,
%       cache_path and log_path. The reference to figure_path and netCDF
%       file names is optional and the names in the output to these
%       products will be omitted if the input does not contain them.
%
%  Output:
%    DATA_PATHS is a structure of directory and names containing the
%       information of the paths built from the input path_formats.%           
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
%  Copyright (C) 2013-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
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
%

    narginchk(2, 2);
    
    path_list = fieldnames(path_formats);
    data_paths = struct();
    
    for i=1:numel(path_list)
        current_path_name = path_list(i);
        data_paths.(current_path_name{1}) = ...
            fullfile(strfstruct(path_formats.(current_path_name{1}), deployment));
    end
end

