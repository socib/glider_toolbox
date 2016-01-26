function preprocessing_qc_options = configDataPreprocessingQC(data_preprocessed)
%CONFIGDATAPREPROCESSINGQC  Defines QC methods to be applied on
%preprocessed data.
%
%  Syntax:
%    PREPROCESSING_QC_OPTIONS = CONFIGDATAPREPROCESSINGQC(DATA_PREPROCESSED)
%
%  Description:
%    Returns a struct setting the options for the quality controls applied
%    to the preprocessed data.
%    
%    Each check must be defined as preprocessing_qc_options.PROCESSNAME and
%    has to contain the struct entries functionHandle, processOn and
%    passingParameters. Only exception is the NaN-Check, which only
%    requires the functionHandle and a switch, if it should be applied
%    (true) or not (false).
%
%    The functionHandle defines the function that is applied to the
%    specified data (string).
%    
%    The struct entry passingParameters are the parameters given to the
%    functions. It must be a cell for each processOn entry. If there are
%    more than one variable, the test should be applied to (e.g. bad 
%    longitude means also a bad latitude and vice versa), the processOn
%    cell must contain another cell entry with the variable names.
%    
%    Example for defining a validRangeCheck:
%    preprocessing_qc_options.validRangeCheck.functionHandle =
%    str2func('validRangeCheck');
%    preprocessing_qc_options.validRangeCheck.processOn = { 'temperature';
%    {'latitude'; 'longitude'};};
%    preprocessing_qc_options.validRangeCheck.passingParameters = { [{data_preprocessed.temperature}; -2; 42; 4];
%    [{data_preprocessed.latitude}; 30; 46; 4];};
%    This means, if the passing temperature measurements exceed the
%    threshold (between -2 and 42 degrees Celsius), the variable
%    temperature (defined in processOn) will be flagged with the outcome of
%    the validRangeCheck. Also, if the latitude exceed the thresholds 30
%    and 46 degrees, the latitude and longitude (defined in processOn) will
%    be flagged.
%
%  Notes:
%       Requires the preprocessed data as input.
%
%  Examples:
%    preprocessing_qc_options = configDataPreprocessingQC(data_preprocessed)
%
%  See also:
%    PERFORMQC
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2016
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

preprocessing_qc_options.checkAllForNan.switch = true;
preprocessing_qc_options.checkAllForNan.functionHandle = str2func('nanCheck');

preprocessing_qc_options.impossibleDateCheck.functionHandle = str2func('impossibleDateCheck');
preprocessing_qc_options.impossibleDateCheck.processOn = {
    'time';
    {'time_ctd'; 'temperature'; 'conductivity'; 'oxygen_concentration'; 'oxygen_saturation'; 'pressure'; 'chlorophyll'; 'turbidity'}
    };
preprocessing_qc_options.impossibleDateCheck.passingParameters = {
        [{data_preprocessed.time}; 4];
        [{data_preprocessed.time_ctd}; 4]
    };

preprocessing_qc_options.impossibleLocationCheck.functionHandle = str2func('impossibleLocationCheck');
preprocessing_qc_options.impossibleLocationCheck.processOn = {{'longitude'; 'latitude'}};
preprocessing_qc_options.impossibleLocationCheck.passingParameters = {
        [{data_preprocessed.latitude}; {data_preprocessed.longitude}; 4]
    };

preprocessing_qc_options.validRangeCheck.functionHandle = str2func('validRangeCheck');
preprocessing_qc_options.validRangeCheck.processOn = {
    'temperature';
    'chlorophyll';
    'turbidity';
    {'oxygen_concentration'; 'oxygen_saturation'};
    {'oxygen_saturation'; 'oxygen_concentration'};
    {'longitude'; 'latitude'};
    {'latitude'; 'longitude'};
    {'waypoint_longitude'; 'waypoint_latitude'};
    {'waypoint_latitude'; 'waypoint_longitude'};
    'temperature'
    };

preprocessing_qc_options.validRangeCheck.passingParameters = {
        [{data_preprocessed.temperature}; -2; 42; 4];
        [{data_preprocessed.chlorophyll}; 0; 50; 4];
        [{data_preprocessed.turbidity}; 0; 50; 4];
        [{data_preprocessed.oxygen_concentration}; 0; 500; 4];
        [{data_preprocessed.oxygen_saturation}; 0; 200; 4];
        [{data_preprocessed.longitude}; -6; 37; 4];
        [{data_preprocessed.latitude}; 30; 46; 4];
        [{data_preprocessed.waypoint_longitude}; -6; 37; 3];
        [{data_preprocessed.waypoint_latitude}; 30; 46; 3];
        [{data_preprocessed.temperature}; {[0; 3; 3; 3; 3; 3]}; {[34; 30; 28; 26; 22; 20]}; 4; {data_preprocessed.depth}; {[0, 20; 20, 50; 50, 75; 75, 150; 150, 300; 300, 1100]}]
    };

preprocessing_qc_options.spikeCheck.functionHandle = str2func('spikeCheck');
preprocessing_qc_options.spikeCheck.processOn = {'temperature';
    'turbidity'
    };
preprocessing_qc_options.spikeCheck.passingParameters = {
        [{data_preprocessed.temperature}; 6; {data_preprocessed.pressure}; 500; 6; 2];
        [{data_preprocessed.turbidity}; 6; 5]
    };

end
