function qcFlaggedOutput = performSpecialGradientCheck(data, depth, profile_index, gradient_threshold, diff_threshold, depth_threshold, qc_flag)
%PERFORMSPECIALGRADIENTCHECK  Calls the specialGradientCheck.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = PERFORMSPECIALGRADIENTCHECK(DATA, DEPTH, PROFILE_INDEX, GRADIENT_THRESHOLD, DIFF_THRESHOLD, DEPTH_THRESHOLD, QC_FLAG)
%
%  Description:
%    Calls the specialGradientCheck for the specified profiles and returns
%    the merged QC outputs.
%
%  Notes:
%    Make sure that (especially) the gradient_threshold is wisely chosen,
%    if you are using this test. 
%
%  Examples:
%    qcFlaggedOutput = performSpecialGradientCheck(data, depth, profile_index, gradient_threshold, diff_threshold, depth_threshold, qc_flag)
%
%  See also:
%    PERFORMQC
%    PERFORMGRIDDEDQC
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

%% Check input.
validateattributes(data, {'numeric'}, {'nonempty'})
validateattributes(depth, {'numeric'}, {'nonempty'})
validateattributes(profile_index, {'numeric'}, {'nonempty'})
validateattributes(gradient_threshold, {'numeric'}, {'nonempty'})
validateattributes(depth_threshold, {'numeric'}, {'nonempty'})
validateattributes(qc_flag, {'numeric'}, {'nonempty'})

%% Begin processing.
qcFlaggedOutput=ones(length(data),1);

for o=1:floor(profile_index(end))
    idx = profile_index == o;
    temp_data = data(idx);
    temp_depth = depth(idx);
    qcFlaggedOutput(idx) = specialGradientCheck(temp_data', temp_depth', gradient_threshold, diff_threshold, depth_threshold, qc_flag);
end

end
