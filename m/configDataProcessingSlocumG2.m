function options = configDataProcessingSlocumG2()
%CONFIGDATAPROCESSINGSLOCUMG1  Configure Slocum G1 glider data processing.
%
%  Syntax:
%    PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSLOCUMG2()
%
%  PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSLOCUMG2() should return a struct 
%  setting the options for Slocum G2 glider data processing as needed by the 
%  function PROCESSGLIDERDATA.
%
%  Examples:
%    options = configDataProcessingSlocumG2()
%
%  See also:
%    PROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013-2014
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  options = struct();

  options.time_filling = true;
  options.position_filling = true;
  options.depth_filling = true;
  options.attitude_filling = true;
  options.heading_filling = true;
  options.waypoint_filling = true;

  options.pressure_filtering = true;
  options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  options.depth_ctd_derivation = true;

  options.profiling_list(1).depth = 'depth';
  options.profiling_list(1).time = 'time';
  options.profiling_list(2).depth = 'depth_ctd';
  options.profiling_list(2).time = 'time_ctd';
  options.profiling_list(3).depth = 'depth_ctd';
  options.profiling_list(3).time = 'time';
  % Use default values for profile identification parameters:
  % stall (3), inversion (3), and length (10), and
  % shake (20), interrupt (180), and period (0).

  options.profile_min_range = 10;
  options.profile_max_gap_ratio = 0.6;

  options.sensor_lag_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});

  options.thermal_lag_list = ...
    struct('conductivity_corrected', {}, 'temperature_corrected', {}, ...
           'conductivity_original', {}, 'temperature_original', {}, ...
           'pressure_original', {}, 'parameters', {});

  options.salinity_list(1).salinity     = 'salinity';
  options.salinity_list(1).conductivity = 'conductivity';
  options.salinity_list(1).temperature  = 'temperature';
  options.salinity_list(1).pressure     = 'pressure';

  options.density_list(1).density     = 'density';
  options.density_list(1).salinity    = 'salinity';
  options.density_list(1).temperature = 'temperature';
  options.density_list(1).pressure    = 'pressure';

end
