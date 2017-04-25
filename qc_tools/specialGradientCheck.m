function qc_out = specialGradientCheck(input_data, input_depth, gradient_threshold, diff_threshold, depth_threshold, qc_flag)
%GRADIENTCHECK  Performs gradient check upon profile data.
%
%  Syntax:
%    QC_OUT = GRADIENTCHECK(PROFILE, THRESHOLD, DEPTH_THRESHOLD)
%
%  Description:
%    Calculates the gradient, as specified in the socib QC_procedure
%    document. Requires a 2 row PROFILE array as input. The first row
%    must be the data array. The second row is the associated depth data.
%    THRESHOLD is the amount of change that is possible beginning from the
%    specified DEPTH_THRESHOLD. The test does not consider the differences
%    in depth, but assumes a sampling that adequately reproduces the
%    changes with depth.
%    If a gradient according to the specified gradient_threshold is
%    identified, all measurements after this gradient will be flagged,
%    until the diff_threshold is reached. The diff_threshold is the valid
%    range from the point where the gradient appeared. This is particularly
%    useful for CTD conductivity data, where we assume, that the data from
%    a specific depth (depth_threshold), behaves almost like a flat line.
%
%  Notes:
%    This function performs a gradient with including flat line test.
%    We also assume fixed depth steps.
%
%  Examples:
%    qc_out = gradientCheck(profile, threshold, depth_threshold)
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

%% Check input.
validateattributes(input_data, {'numeric'}, {'nonempty'})
validateattributes(input_depth, {'numeric'}, {'nonempty'})
validateattributes(gradient_threshold, {'numeric'}, {'nonempty'})
validateattributes(diff_threshold, {'numeric'}, {'nonempty'})
validateattributes(depth_threshold, {'numeric'}, {'nonempty'})
validateattributes(qc_flag, {'numeric'}, {'nonempty'})

%% Begin processing.
qc_out = ones(length(input_data),1);

[temp, I] = sort(input_depth);
input_depth = temp;
input_data = input_data(I);

depth_idx = find(input_depth>=depth_threshold,1);
if depth_idx >1
    depth_idx = depth_idx-1;
end

all_data = input_data;
all_depth = input_depth;

data = input_data(depth_idx:end);
non_nan_idx = find(~isnan(data));
depth_segment = input_depth(depth_idx:end);
%data = data(~isnan(data));

% Using non nan may cause problems with the positioning of the later
% indices.

myDiffs = 0;
gradChecker = false;
falsePos = [];
falseX = [];
falseIndex = [];
fig_created = false;

for i=2:length(non_nan_idx)
    if i==length(non_nan_idx)
        break;
    end
    V1 = data(non_nan_idx(i-1));
    V2 = data(non_nan_idx(i));
    V3 = data(non_nan_idx(i+1));
    grad = V2 - (V3 + V1)/2;
    if abs(grad)>gradient_threshold
        disp('possible gradient found')
        % plot(i,V2, '*r')
        gradChecker = true;
    end
    if gradChecker
        myDiffs = myDiffs + ( V2-V3 );
        falsePos = [falsePos; V2];
        falseX = [falseX; depth_segment(non_nan_idx(i))];
        falseIndex = [falseIndex; non_nan_idx(i)-1+depth_idx];
        if myDiffs <= diff_threshold
            gradChecker=false;
            if ~fig_created
                h = figure;
                set(h, 'Visible', 'off');
                fig_created=true;
            end
            plot(all_depth(~isnan(all_data)), all_data(~isnan(all_data)), '-k')
            hold on
            plot([all_depth(depth_idx), all_depth(depth_idx)], [nanmin(all_data), nanmax(all_data)], '--r');
            plot(falseX, falsePos, '-sr');
            legend('data', 'depth threshold', 'flagged points')
        end
    end
end

if ~isempty(depth_idx) && ~isempty(falseX)
    title('Outliers detected based on gradient - flat line approach.')
    xlabel('Depth')
    ylabel('Unit')    
    whitebg('white')
    set(h, 'Visible', 'on');
    qc_out(falseIndex) = qc_flag;
end


end
