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
%    path_formats contains the following fields:
%       - base_dir: Root directory. All other paths will be relative to it.
%       - binary_path: Path to binary files
%       - ascii_path: Path to ascii files 
%       - cache_path: Path to cache files used to convert binary data files
%             from Slocum to ascii. Cache files are created because only the
%             first binary files of a set contains the complete hearder
%       - log_path: Path to log files 
%       - processing_log: Name of the log file
%       - figure_path: Path where figure files will be created
%       - netcdf_l0, netcdf_l1, netcdf_l2: File names of L0, L1 and L2
%             NetCDF products 
%       - netcdf_egol1: File names of L1 EGO formatted products
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
%       information of the paths built from the input path_formats.
%           - binary_dir
%           - cache_dir
%           - log_dir
%           - ascii_dir
%           - figure_dir (optional)
%           - netcdf_l0_file (optional)
%           - netcdf_l1_file (optional)
%           - netcdf_l2_file (optional)
%           - netcdf_egol1_file (optional)
%           
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

    data_paths.processing_log = fullfile(path_formats.base_dir, strfstruct(path_formats.processing_log, deployment));
    data_paths.binary_dir     = fullfile(path_formats.base_dir, strfstruct(path_formats.binary_path, deployment));
    data_paths.cache_dir      = fullfile(path_formats.base_dir, strfstruct(path_formats.cache_path, deployment));
    data_paths.log_dir        = fullfile(path_formats.base_dir, strfstruct(path_formats.log_path, deployment));
    data_paths.ascii_dir      = fullfile(path_formats.base_dir, strfstruct(path_formats.ascii_path, deployment));
    
    data_paths.figure_dir = '';
    if ~isempty(path_formats.figure_path)
      data_paths.figure_dir     = fullfile(path_formats.base_dir, strfstruct(path_formats.figure_path, deployment));
    end

    %% Check and make netCDF file names
    data_paths.netcdf_l0_file = '';
    if ~isempty(path_formats.netcdf_l0)
      data_paths.netcdf_l0_file = fullfile(path_formats.base_dir, strfstruct(path_formats.netcdf_l0, deployment));
    end

    data_paths.netcdf_l1_file = '';
    if ~isempty(path_formats.netcdf_l1)      
      data_paths.netcdf_l1_file = fullfile(path_formats.base_dir, strfstruct(path_formats.netcdf_l1, deployment));
    end
    
    data_paths.netcdf_l2_file = '';
    if ~isempty(path_formats.netcdf_l2)
      data_paths.netcdf_l2_file = fullfile(path_formats.base_dir, strfstruct(path_formats.netcdf_l2, deployment));
    end

    %% Check and make special data file names (e.g. EGO)
    data_paths.netcdf_egol1_file = '';
    if ~isempty(path_formats.netcdf_egol1)
      data_paths.netcdf_egol1_file = fullfile(path_formats.base_dir, strfstruct(path_formats.netcdf_egol1, deployment));
    end
end

