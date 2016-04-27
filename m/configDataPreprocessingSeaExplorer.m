function preprocessing_options = configDataPreprocessingSeaExplorer()
%CONFIGDATAPREPROCESSINGSEAEXPLORER  Configure SeaExplorer glider data preprocessing.
%
%  Syntax:
%    PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSINGSEAEXPLORER()
%
%  Description:
%    PREPROCESSING_OPTIONS = CONFIGDATAPREPROCESSINGSEAEXPLORER() should return
%    a struct setting the options for SeaExplorer glider data preprocessing 
%    as needed by the function PREPROCESSGLIDERDATA.
%
%  Examples:
%    preprocessing_options = configDataPreprocessingSeaExplorer()
%
%  See also:
%    PREPROCESSGLIDERDATA
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

  preprocessing_options = struct();

  preprocessing_options.time_list(1).time = 'Timestamp';
  preprocessing_options.time_list(2).time = 'PLD_REALTIMECLOCK';  

  preprocessing_options.position_list(1).longitude = 'NAV_LONGITUDE';
  preprocessing_options.position_list(1).latitude  = 'NAV_LATITUDE';
  preprocessing_options.position_list(1).conversion = @sxnmea2deg;
  preprocessing_options.position_list(2).longitude = 'Lon';
  preprocessing_options.position_list(2).latitude  = 'Lat';
  preprocessing_options.position_list(2).conversion = @sxnmea2deg;

  preprocessing_options.depth_list(1).depth = 'NAV_DEPTH';
  preprocessing_options.depth_list(2).depth = 'Depth';

  preprocessing_options.depth_list(1).depth_ctd = 'GPCTD_PRESSURE';
  preprocessing_options.depth_list(2).depth_ctd = 'SBD_PRESSURE';  

  preprocessing_options.attitude_list(1).roll = 'Roll';
  preprocessing_options.attitude_list(1).pitch = 'Pitch';
  preprocessing_options.attitude_list(1).conversion = @deg2rad;

  preprocessing_options.heading_list(1).heading = 'Heading';
  preprocessing_options.heading_list(1).conversion = @deg2rad;

  preprocessing_options.ctd_list(1).conductivity = 'GPCTD_CONDUCTIVITY';
  preprocessing_options.ctd_list(1).temperature  = 'GPCTD_TEMPERATURE';
  preprocessing_options.ctd_list(1).pressure     = 'GPCTD_PRESSURE';
  preprocessing_options.ctd_list(1).oxygen       = 'GPCTD_DOF';

  preprocessing_options.ctd_list(2).conductivity = 'SBD_CONDUCTIVITY';
  preprocessing_options.ctd_list(2).temperature  = 'SBD_TEMPERATURE';
  preprocessing_options.ctd_list(2).pressure     = 'SBD_PRESSURE';
  preprocessing_options.ctd_list(2).oxygen       = 'SBD_DOF';

  preprocessing_options.ctd_list(3).conductivity = 'GPCTD_CONDUCTIVITY';
  preprocessing_options.ctd_list(3).temperature  = 'GPCTD_TEMPERATURE';
  preprocessing_options.ctd_list(3).pressure     = 'GPCTD_PRESSURE';

  preprocessing_options.optics_list(1).chlorophyll = 'FLBBCD_CHL_SCALED';
  preprocessing_options.optics_list(1).cdom        = 'FLBBCD_CDOM_SCALED';
  preprocessing_options.optics_list(1).backscatter_700 = 'FLBBCD_BB_700_SCALED';

  preprocessing_options.optics_list(2).chlorophyll = 'TRI_CHL_SCALED';
  preprocessing_options.optics_list(2).cdom        = 'TRI_CDOM_SCALED';
  preprocessing_options.optics_list(2).backscatter_700 = 'TRI_BB_700_SCALED';

  preprocessing_options.optics_list(3).chlorophyll = 'FLNTU_CHL_SCALED';
  preprocessing_options.optics_list(3).turbidity = 'FLNTU_NTU_SCALED';  

  %% Extra sensors
  % Minifluo1-UV1 choices:
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_270_340 = 'M1FL_PHD1';
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_255_360 = 'M1FL_PHD2';
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_monitoring_270_340 = 'M1FL_MON1';
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_monitoring_255_360 = 'M1FL_MON2';
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_emission_temperature = 'M1FL_TMPE';
  preprocessing_options.extra_sensor_list.minifluo1(1).fluorescence_detection_temperature = 'M1FL_TMPD'; 
  
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_270_340 = 'MFL_V1';
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_255_360 = 'MFL_V2';
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_monitoring_270_340 = 'MFL_V3';
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_monitoring_255_360 = 'MFL_V4';
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_emission_temperature = 'MFL_TMPE';
  preprocessing_options.extra_sensor_list.minifluo1(2).fluorescence_detection_temperature = 'MFL_TMPD';  

  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_270_340 = 'UV1_V1';
  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_255_360 = 'UV1_V2';
  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_monitoring_270_340 = 'UV1_V3';
  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_monitoring_255_360 = 'UV1_V4';  
  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_emission_temperature = 'UV1_TMP1';
  preprocessing_options.extra_sensor_list.minifluo1(3).fluorescence_detection_temperature = 'UV1_TMP2';  

  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_270_340 = 'UV1_PHE';
  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_255_360 = 'UV1_TRY';
  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_monitoring_270_340 = 'UV1_LD1';
  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_monitoring_255_360 = 'UV1_LD2';
  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_emission_temperature = 'UV1_TMP1';
  preprocessing_options.extra_sensor_list.minifluo1(4).fluorescence_detection_temperature = 'UV1_TMP2';  

  % Minifluo-UV2
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_260_315 = 'M2FL_PHD1';
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_270_376 = 'M2FL_PHD2';
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_monitoring_260_315 = 'M2FL_MON1';
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_monitoring_270_376 = 'M2FL_MON2';
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_emission_temperature = 'M2FL_TMPE';
  preprocessing_options.extra_sensor_list.minifluo2(1).fluorescence_detection_temperature = 'M2FL_TMPD';   
  
  
  % Methane sensor choices:
  preprocessing_options.extra_sensor_list.methane(1).methane_volt = 'METS_METHANE_VOLT';
  preprocessing_options.extra_sensor_list.methane(1).methane_concentration = 'METS_METHANE_SCALED';
  preprocessing_options.extra_sensor_list.methane(1).mets_circuit_temperature_volt = 'METS_TEMP_VOLT';
  preprocessing_options.extra_sensor_list.methane(1).mets_circuit_temperature = 'METS_TEMP_SCALED';

end

