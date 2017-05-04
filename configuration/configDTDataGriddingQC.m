function gridding_qc_config = configDataGriddingQC()
%CONFIGDATAGRIDDINGQC  Configures the QC methods applied to the gridded data.
%
%  Syntax:
%    GRIDDING_QC_CONFIG = CONFIGDATAGRIDDINGQC()
%
%  Description:
%    In general, same structure as configDataPreprocessingQC or
%    configDataProcessingQC. It differs in respect to the passingParamters
%    (will only pass the names of passing parameters).
%    See PreprocessingQC and ProcessingQC config files for further
%    information.
%    First passing parameter in a passingParameter instance requires the
%    name of a variable (will result in the inserted data, as required for
%    the specific tests).
%    
%    Here, an example usage for a valid range check is shown. It shall be
%    processed on the oxygen saturation and the oxygen concentration. This
%    means, if it fails, both variable indices will be flagged:
%    gridding_qc_config.validRangeCheck.functionHandle = str2func('validRangeCheck');
%    gridding_qc_config.validRangeCheck.processOn = {
%        {'oxygen_concentration'; 'oxygen_saturation'};
%        {'oxygen_saturation'; 'oxygen_concentration'}
%        };
%    gridding_qc_config.validRangeCheck.passingParameters = {
%            [{'oxygen_concentration'}; 0; 500; 4];
%            [{'oxygen_saturation'}; 0; 200; 4]
%        };
%
%    As described in the valid range check QC function, further parameters
%    can be described (e.g. depth ranges that apply for specific depths).
%
%  Notes:
%    No arguments required. Uses the names of variables for processing.
%
%  Examples:
%    gridding_qc_config = configDataGriddingQC()
%
%  See also:
%    CONFIGDATAPREPROCESSINGQC
%    CONFIGDATAPROCESSINGQC
%    PERFORMGRIDDINGQC
%    VALIDRANGECHECK
%    SPIKECHECK
%    NANCHECK
%    IMPOSSIBLEDATECHECK
%    IMPOSSIBLELOCATIONCHECK
%    
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2017
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

gridding_qc_config.checkAllForNan.switch = true;
gridding_qc_config.checkAllForNan.functionHandle = str2func('nanCheck');

gridding_qc_config.impossibleDateCheck.functionHandle = str2func('impossibleDateCheck');
gridding_qc_config.impossibleDateCheck.processOn = {
    {'time'; 'profile_index'; 'longitude'; 'latitude'; 'chlorophyll'; 'conductivity'; 'density'; 'oxygen_concentration'; 'oxygen_saturation'; 'pressure'; 'salinity'; 'temperature'; 'turbidity'}
    };
gridding_qc_config.impossibleDateCheck.passingParameters = {
        [{'time'}; 4];
    };

gridding_qc_config.impossibleLocationCheck.functionHandle = str2func('impossibleLocationCheck');
gridding_qc_config.impossibleLocationCheck.processOn = {{'longitude'; 'latitude'}};
gridding_qc_config.impossibleLocationCheck.passingParameters = {
        [{'latitude'}; {'longitude'}; 4]
    };

gridding_qc_config.validRangeCheck.functionHandle = str2func('validRangeCheck');
gridding_qc_config.validRangeCheck.processOn = {
    'temperature';
    'chlorophyll';
    'turbidity';
    {'oxygen_concentration'; 'oxygen_saturation'};
    {'oxygen_saturation'; 'oxygen_concentration'};
    {'longitude'; 'latitude'};
    {'latitude'; 'longitude'};
    'temperature';
    'salinity'
    };
gridding_qc_config.validRangeCheck.passingParameters = {
        [{'temperature'}; -2; 42; 4];
        [{'chlorophyll'}; 0; 50; 4];
        [{'turbidity'}; 0; 50; 4];
        [{'oxygen_concentration'}; 0; 500; 4];
        [{'oxygen_saturation'}; 0; 200; 4];
        [{'longitude'}; -6; 37; 4];
        [{'latitude'}; 30; 46; 4];
        [{'temperature'}; {[0; 3; 3; 3; 3; 3]}; {[34; 30; 28; 26; 22; 20]}; 4; {'depth'}; {[0, 20; 20, 50; 50, 75; 75, 150; 150, 300; 300, 1100]}];
        [{'salinity'}; {[36; 36; 36; 36]}; {[40; 40; 40; 40]}; 4; {'depth'}; {[0, 30; 30, 75; 75, 600; 600, 1100]}]
    };

gridding_qc_config.spikeCheck.functionHandle = str2func('spikeCheck');
gridding_qc_config.spikeCheck.processOn = {
    'temperature';
    'turbidity';
    'oxygen_concentration';
    'oxygen_saturation'
    };
gridding_qc_config.spikeCheck.passingParameters = {
        [{'temperature'}; 6; {'pressure'}; 500; 6; 2];
        [{'turbidity'}; 6; 5];
        [{'oxygen_concentration'}; 6; 20];
        [{'oxygen_saturation'}; 6; 20]
    };

gridding_qc_config.specialGradientCheck.functionHandle = str2func('specialGradientCheck');
gridding_qc_config.specialGradientCheck.processOn = {
    {'conductivity', 'density', 'salinity'}
    };
gridding_qc_config.specialGradientCheck.passingParameters = {
        [{'conductivity'}; {'depth'}; 0.05; 0.05; 200; 4]
    };

end
