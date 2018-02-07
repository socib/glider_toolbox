function local_paths = configPathsLocal(glider_toolbox_dir)
%CONFIGDTPATHSLOCAL  Config local paths for glider deployment delayed time data and figures.
%
%  Syntax:
%    LOCAL_PATHS = CONFIGDTPATHSLOCAL()
%
%  Description:
%    LOCAL_PATHS = CONFIGDTPATHSLOCAL() should return a struct with the path 
%    patterns for the deployment files involved in the glider processing chain
%    in delayed time mode. It should have the following fields:
%      BINARY_PATH: path pattern of directory of Slocum binary files (.Xbd).
%      CACHE_PATH: path pattern of directory of Slocum cache files (.cac).
%      LOG_PATH: path pattern of directory of Slocum surface log files (.log).
%      ASCII_PATH: path pattern of directory of converted Slocum text files
%        (.dba) or Seglider text files (.log and .eng).
%      FIGURE_PATH: path pattern of directory for deployment figures.
%      NETCDF_L0: path pattern of NetCDF file for raw data
%        (data provided by the glider without any meaningful modification).
%      NETCDF_L1: path pattern of NetCDF file for processed trajectory data
%        (well referenced data with conversions, corrections and derivations).
%      NETCDF_L2: path pattern of NetCDF file for processed grid data
%        (processed data interpolated on vertical instantaneous profiles).
%      PROCESSING_LOG: path pattern of processing log file.
%    These path patterns are converted to true paths through the function
%    STRFSTRUCT.
%
%  Notes:
%    Edit this file filling in the paths to reflect your desired file layout.
%
%  Examples:
%    local_paths = configDTPathsLocal()
%
%  See also:
%    MAIN_GLIDER_DATA_PROCESSING_DT
%    STRFSTRUCT
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  narginchk(1, 1);
  
  local_paths.base_dir       = fullfile(glider_toolbox_dir, 'glider_data', '${GLIDER_NAME}', '${DEPLOYMENT_START,Tyyyymmdd}');
  local_paths.binary_path    = fullfile('binary');
  local_paths.cache_path     = fullfile('binary');
  local_paths.log_path       = fullfile('log');
  local_paths.ascii_path     = fullfile('ascii');
  local_paths.figure_path    = fullfile('figures');
  local_paths.netcdf_l0      = fullfile('netcdf', 'dep${GLIDER_DEPLOYMENT_CODE,l}_${GLIDER_NAME,l}_${GLIDER_INSTRUMENT_NAME,l}_L0_${DEPLOYMENT_START,Tyyyy-mm-dd}_data_rt.nc');
  local_paths.netcdf_l1      = fullfile('netcdf', 'dep${GLIDER_DEPLOYMENT_CODE,l}_${GLIDER_NAME,l}_${GLIDER_INSTRUMENT_NAME,l}_L1_${DEPLOYMENT_START,Tyyyy-mm-dd}_data_rt.nc');
  local_paths.netcdf_l2      = fullfile('netcdf', 'dep${GLIDER_DEPLOYMENT_CODE,l}_${GLIDER_NAME,l}_${GLIDER_INSTRUMENT_NAME,l}_L2_${DEPLOYMENT_START,Tyyyy-mm-dd}_data_rt.nc');
  local_paths.processing_log = fullfile('dep${GLIDER_DEPLOYMENT_CODE,l}_${GLIDER_NAME,l}_${GLIDER_INSTRUMENT_NAME,l}_${DEPLOYMENT_START,Tyyyy-mm-dd}_data_rt.log');
  local_paths.config_record  = fullfile('dep${GLIDER_DEPLOYMENT_CODE,l}_${GLIDER_NAME,l}_${GLIDER_INSTRUMENT_NAME,l}_${DEPLOYMENT_START,Tyyyy-mm-dd}_data_rt.config');
   
end
