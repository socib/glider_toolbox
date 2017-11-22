function [ glider_type, processing_config ] = extractDeploymentConfig( glider_model, config )
% EXTRACTDEPLOYMENTCONFIGURATION  Selects the configuration values for the
%                                   specific glider model
%
%  Syntax:
%    [GLIDER_TYPE, PROCESSING_CONFIG] = ...
%            EXTRACTDEPLOYMENTCONFIGURATION(GLIDER_MODEL, CONFIG)
%
%  Description:
%    EXTRACTDEPLOYMENTCONFIGURATION selects the file definition and
%    processing configurations for a specific glider model given a
%    configuration structure that contains the configuration for all
%    "possible" glider models. It returns the glider type that is based on
%    the name conventions as follow:
%            glider_model          glider_type 
%            .*slocum.*g1.*  ==>    slocum_g1
%            .*slocum.*g2.*  ==>    slocum_g2
%            .*seaglider.*   ==>    seaglider
%            .*seaexplorer.* ==>    seaexplorer
%
%  Input:
%    GLIDER_MODEL defines the name of the glider model. 
%
%    CONFIG is the structure containing the configuration of the processing
%    as defined by SETUPCONFIGURATION. 
%
%  Output:
%    GLIDER_TYPE is the glider type as explained in the description above.
%
%    PROCESSING_CONFIG is the structure containing the configuration for
%    the specified glider model. It contains the following fields with
%    structures for each type of configuration: 
%      - file_options          
%      - preprocessing_options 
%      - processing_options 
%      - netcdf_l0_options 
%      - gridding_options    
%      - netcdf_l1_options    
%      - netcdf_egol1_options 
%      - netcdf_l2_options    
%      - figproc_options      
%      - figgrid_options      
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


  narginchk(2, 2);
    
  glider_type = '';
  if ~isempty(regexpi(glider_model, '.*slocum.*g1.*', 'match', 'once'))
      glider_type = 'slocum_g1';
  elseif ~isempty(regexpi(glider_model, '.*slocum.*g2.*', 'match', 'once'))
      glider_type = 'slocum_g2';
  elseif ~isempty(regexpi(glider_model, '.*seaglider.*', 'match', 'once'))
      glider_type = 'seaglider';
  elseif ~isempty(regexpi(glider_model, '.*seaexplorer.*', 'match', 'once'))
      glider_type = 'seaexplorer';
  end

  % Options depending on the type of glider:
  switch glider_type
    case 'slocum_g1'
      processing_config.file_options          = config.file_options_slocum;
      processing_config.preprocessing_options = config.preprocessing_options_slocum;
      processing_config.processing_options    = config.processing_options_slocum_g1;
      processing_config.netcdf_l0_options     = config.output_netcdf_l0_slocum;
      processing_config.netcdf_eng_options     = config.output_netcdf_eng_slocum;
    case 'slocum_g2'
      processing_config.file_options          = config.file_options_slocum;
      processing_config.preprocessing_options = config.preprocessing_options_slocum;
      processing_config.processing_options    = config.processing_options_slocum_g2;
      processing_config.netcdf_l0_options     = config.output_netcdf_l0_slocum;
      processing_config.netcdf_eng_options     = config.output_netcdf_eng_slocum;
    case 'seaglider'
      processing_config.file_options          = config.file_options_seaglider;
      processing_config.preprocessing_options = config.preprocessing_options_seaglider;
      processing_config.processing_options    = config.processing_options_seaglider;
      processing_config.netcdf_eng_options     = config.output_netcdf_eng_seaglider;
    case 'seaexplorer' 
      processing_config.file_options          = config.file_options_seaexplorer;
      processing_config.preprocessing_options = config.preprocessing_options_seaexplorer;
      processing_config.processing_options    = config.processing_options_seaexplorer;
      processing_config.netcdf_l0_options     = config.output_netcdf_l0_seaexplorer;
      processing_config.netcdf_eng_options     = config.output_netcdf_eng_seaexplorer;
  end
  
  processing_config.gridding_options     = config.gridding_options;
  processing_config.netcdf_l1_options    = config.output_netcdf_l1;
  processing_config.netcdf_egol1_options = config.output_netcdf_egol1;
  processing_config.netcdf_l2_options    = config.output_netcdf_l2;
  processing_config.figproc_options      = config.figures_processed.options;
  processing_config.figgrid_options      = config.figures_gridded.options;

end

