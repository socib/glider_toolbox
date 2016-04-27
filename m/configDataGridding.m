function gridding_options = configDataGridding()
%CONFIGDATAGRIDDING  Configure glider data gridding.
%
%  Syntax:
%    GRIDDING_OPTIONS = CONFIGDATAGRIDDING()
%
%  Description:
%    GRIDDING_OPTIONS = CONFIGDATAGRIDDING() should return a struct setting the 
%    options for glider data gridding as needed by the function GRIDGLIDERDATA.
%
%  Examples:
%    gridding_options = configDataGridding()
%
%  See also:
%    GRIDGLIDERDATA
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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

  error(nargchk(0, 0, nargin, 'struct'));

  gridding_options = struct();

  gridding_options.profile_list = {'profile_index'};
  
  gridding_options.time_list = {'time'};

  gridding_options.position_list(1).latitude = 'latitude';
  gridding_options.position_list(1).longitude = 'longitude';

  gridding_options.depth_list = {'depth' 'depth_ctd'};

  gridding_options.depth_step = 1;

  gridding_options.variable_list = {
    'conductivity'
    'temperature'
    'pressure'
    'chlorophyll'
    'turbidity'
    'cdom'
    'oxygen_concentration'
    'oxygen_saturation'
    'conductivity_corrected_thermal'
    'temperature_corrected_thermal'
    'salinity'
    'density'
    'salinity_corrected_thermal'
    'density_corrected_thermal'
    'fluorescence_255_360'
    'fluorescence_260_315'
    'fluorescence_270_340'
    'fluorescence_270_376'
    'fluorescence_monitoring_255_360'
    'fluorescence_monitoring_260_315'
    'fluorescence_monitoring_270_340'
    'fluorescence_monitoring_270_376'
    'methane_concentration'
    'backscatter_700'
    'oxygen_frequency'                  
  };

end
