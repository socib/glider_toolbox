function basic_qc_configuration = configBasicQualityControl()
%CONFIGBASICQUALITYCONTROL  Returns the basic QC configurations.
%
%  Syntax:
%    BASIC_QC_CONFIGURATION = CONFIGBASICQUALITYCONTROL()
%
%  Description:
%    Configures the basic QC behaviour. The performQC identifier indicates,
%    if the configured QC methods should be applied to the pre-/processed
%    or gridded data. The useNanReplacement switch is used to determine, if
%    bad flagged data should be given as NaNs to the next processing step.
%    The summary fileName is used for the logging of QC flags during the
%    processing steps.
%    Use the plotSuspiciousProfiles flag to plot profiles with bad flagged
%    data.
%
%  Notes:
%
%  Examples:
%    basic_qc_configuration = configBasicQualityControl()
%
%  See also:
%    CONFIGDATAPREPROCESSINGQC
%    CONFIGDATAPROCESSINGQC
%    CONFIGDATAGRIDDINGQC
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

basic_qc_configuration.preprocessing.performQC = true;
basic_qc_configuration.preprocessing.summaryFileName = 'qc_preprocessing.log';

basic_qc_configuration.processing.performQC = true;
basic_qc_configuration.processing.summaryFileName = 'qc_processing.log';

basic_qc_configuration.gridding.performQC = false;

% Experimental use only.
basic_qc_configuration.processing.plotSuspiciousProfiles = false;

basic_qc_configuration.applied_QC_LuT.QC_method_names = 'impossibleDateCheck impossibleLocationCheck validRangeCheck spikeCheck specialGradientCheck nanCheck';
basic_qc_configuration.applied_QC_LuT.QC_method_IDs = [1, 2, 3, 4, 5, 9];

end
