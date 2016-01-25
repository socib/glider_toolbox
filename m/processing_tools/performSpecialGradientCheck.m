function qcFlaggedOutput = performSpecialGradientCheck(data, depth, profile_index, gradient_threshold, diff_threshold, depth_threshold, qc_flag)
%PERFORMSPECIALGRADIENTCHECK  One-line description here, please.
%
%  Syntax:
%    QCFLAGGEDOUTPUT = PERFORMSPECIALGRADIENTCHECK(DATA, DEPTH, PROFILE_INDEX, GRADIENT_THRESHOLD, DIFF_THRESHOLD, DEPTH_THRESHOLD, QC_FLAG)
%
%  Description:
%    QCFLAGGEDOUTPUT = PERFORMSPECIALGRADIENTCHECK(DATA, DEPTH, PROFILE_INDEX, GRADIENT_THRESHOLD, DIFF_THRESHOLD, DEPTH_THRESHOLD, QC_FLAG) Detailed description here, please.
%
%  Notes:
%
%  Examples:
%    qcFlaggedOutput = performSpecialGradientCheck(data, depth, profile_index, gradient_threshold, diff_threshold, depth_threshold, qc_flag)
%
%  See also:
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

qcFlaggedOutput=ones(length(data),1);

for o=1:floor(profile_index(end))
    idx = profile_index == o;
    temp_data = data(idx);
    temp_depth = depth(idx);
    qcFlaggedOutput(idx) = specialGradientCheck(temp_data', temp_depth', gradient_threshold, diff_threshold, depth_threshold, qc_flag);
end

end
