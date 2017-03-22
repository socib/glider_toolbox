function plot_suspicious_profiles(qc_lookup, data_lookup)
%PLOT_SUSPICIOUS_PROFILES  Will plot all profiles with bad flagged data.
%
%  Syntax:
%    PLOT_SUSPICIOUS_PROFILES(QC_LOOKUP, DATA_LOOKUP)
%
%  Description:
%    PLOT_SUSPICIOUS_PROFILES(QC_LOOKUP, DATA_LOOKUP) Detailed description coming.
%
%  Notes:
%    Experimental for showing bad flagged data.
%    TODO: insert description
%
%  Examples:
%    plot_suspicious_profiles(qc_lookup, data_lookup)
%
%  See also:
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

var_names = fieldnames(data_lookup);
for i=1:numel(var_names)
    
    bad_qc_idx = (qc_lookup.(var_names{i}).qcFlaggedOutput == 4) | (qc_lookup.(var_names{i}).qcFlaggedOutput == 6);
    if ~any(bad_qc_idx)
        continue;
    end
    bad_profiles = data_lookup.profile_index(bad_qc_idx);
    bad_profiles = unique(bad_profiles);
    
    for j=1:length(bad_profiles)
        cur_profile_idx = bad_profiles(j);
        whole_profile_idx = data_lookup.profile_index == cur_profile_idx;
        cur_depth = data_lookup.depth(whole_profile_idx);
        cur_values = data_lookup.(var_names{i});
        cur_values = cur_values(whole_profile_idx);
        non_nan_depth = cur_depth(~isnan(cur_values));
        non_nan_values = cur_values(~isnan(cur_values));
        lookup_for_current_bad_values = qc_lookup.(var_names{i}).qcFlaggedOutput(whole_profile_idx);
        current_bad_values_idx = (lookup_for_current_bad_values == 4) | (lookup_for_current_bad_values == 6);
        current_bad_values = cur_values(current_bad_values_idx);
        current_bad_depths = cur_depth(current_bad_values_idx);
        if all(isnan(current_bad_depths)) || all(isnan(current_bad_values))
            continue;
        end
        f = gcf();
        title(strcat(strcat(strcat('Variable: ', var_names{i}),' Profile index: '), num2str(cur_profile_idx)));
        hold on
        plot(non_nan_depth, non_nan_values, '-xb');
        plot(current_bad_depths, current_bad_values, 'or');
        xlabel('depth')
        ylabel('value')
        disp('Press space for the next profile.')
        hold off
        pause
        clf(f);        
    end

end
close(f)
end
