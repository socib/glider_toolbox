function processing_options = configDataProcessingSeaExplorer()
%CONFIGDATAPROCESSINGSEAEXPLORER  Configure SeaExplorer glider data processing.
%
%  Syntax:
%    PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSEAEXPLORER()
%
%  Description:
%    PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSEAEXPLORER() should return a struct 
%    setting the options for SeaExplorer glider data processing as needed by the 
%    function PROCESSGLIDERDATA.
%
%  Examples:
%    processing_options = configDataProcessingSeaExplorer()
%
%  See also:
%    PROCESSGLIDERDATA
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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

  processing_options = struct();

  processing_options.time_filling = true;
  processing_options.position_filling = true;
  processing_options.depth_filling = true;
  processing_options.attitude_filling = true;
  processing_options.heading_filling = true;
  processing_options.waypoint_filling = false;

  processing_options.pressure_filtering = true;
  processing_options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  processing_options.depth_ctd_derivation = true;

  processing_options.profiling_list(1).depth = 'depth_ctd';
  processing_options.profiling_list(1).time = 'time';
  processing_options.profiling_list(2).depth = 'depth';
  processing_options.profiling_list(2).time = 'time';

  processing_options.profile_min_range = 10;
  processing_options.profile_max_gap_ratio = 0.6;

  processing_options.sensor_lag_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});

  processing_options.thermal_lag_list = ...
    struct('conductivity_corrected', {}, 'temperature_corrected', {}, ...
           'conductivity_original', {}, 'temperature_original', {}, ...
           'pressure_original', {}, 'parameters', {});

  processing_options.salinity_list(1).salinity     = 'salinity';
  processing_options.salinity_list(1).conductivity = 'conductivity';
  processing_options.salinity_list(1).temperature  = 'temperature';
  processing_options.salinity_list(1).pressure     = 'pressure';

  processing_options.density_list(1).density     = 'density';
  processing_options.density_list(1).salinity    = 'salinity';
  processing_options.density_list(1).temperature = 'temperature';
  processing_options.density_list(1).pressure    = 'pressure';

end
