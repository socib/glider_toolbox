function [hfig, haxs, hlgs, hlns] = plotProfileStatistics(varargin)
%PLOTPROFILESTATISTICS  Plot vertical section of scatter data from a glider transect.
%
%  Syntax:
%    PLOTPROFILESTATISTICS(OPTIONS)
%    PLOTPROFILESTATISTICS(OPT1, VAL1, ...)
%    PLOTPROFILESTATISTICS(H, OPTIONS)
%    PLOTPROFILESTATISTICS(H, OPT1, VAL1, ...)
%    [HFIG, HAXS, HLGS, HLNS] = PLOTPROFILESTATISTICS(...)
%
%  Description:
%    PLOTPROFILESTATISTICS(OPTIONS) and 
%    PLOTPROFILESTATISTICS(OPT1, VAL1, ...) generate a new figure with
%    line plots of statistical profiles of gridded glider data according
%    to options in  key-value pairs OPT1, VAL1... or in struct OPTIONS
%    with field names as option keys and field values as option values.
%    A profile statistic subplot is produced for each given variable,
%    showing the mean value and the standard deviation of each given measured
%    variable along the horizontal dimension over the given vertical coordinate
%    for that subplot. The statistics are computed with the functions MEAN 
%    and STD. The line plots are generated with the function PLOT.
%    Recognized options are:
%      MDATA: measurement data.
%        Cell array of matrices with variable data from which the profile
%        statistics will be computed. One subplot will be produced for each
%        matrix. The subplot layout is given by the size of the cell array.
%        The first dimension of each matrix should be the profile instance.
%        The second dimension of each matrix should be the depth level.
%        Default value: {[]}
%      YDATA: vertical coordinate data.
%        Cell array of vectors with the vertical coordinate data for each 
%        subplot. The number of vectors in the cell array should match the 
%        number of matrices in MDATA, and their lengths should match the second
%        dimension of the corresponding matrix.
%        Default value: {[]}
%      XLABEL: horizontal axis label data.
%        Struct array defining x label properties for each subplot.
%        Label's text is in property 'String'.
%        Default value: repmat(struct(), size(MDATA))
%      YLABEL: vertical axis label data.
%        Struct array defining y label properties for each subplot.
%        Label's text is in property 'String'.
%        Default value: repmat(struct(), size(MDATA))
%      TITLE: axes title data.
%        Struct array defining axes title properties for each subplot.
%        Title's text is in property 'String'.
%        Default value: repmat(struct(), size(MDATA))
%      AXSPROPS: extra axis properties.
%        Struct array of axis properties to be set for each subplot axes with 
%        function SET.
%        Default value: repmat(struct(), size(MDATA))
%      FIGPROPS: extra figure properties.
%        Struct of figure properties to be set for the figure with function SET.
%        Default value: struct()
%
%    PLOTPROFILESTATISTICS(H, ...) does not create a new figure,
%    but plots to figure given by figure handle H.
%
%    [HFIG, HAXS, HLGS, HLNS] = PLOTPROFILESTATISTICS(...) returns
%    handles for the figure, subplot axes, subplot legends, and lineseries,
%    in HFIG, HAXS, HLGS,  and HLNS, respectively. The dimesnions of HFIG, HAXS, 
%    and HLGS match the number of suplots in the figure, MxN, and HLNS is 2xMxN,
%    where M and N are the number of rows and columns in cell array MDATA.
%
%  Examples:
%    [hfig, haxs, hlgs, hlns] = ...
%      plotProfileStatistics(gcf, ...
%        'mdata', {rand(30,100) randn(30,100) 10.^rand(30,100)}, ...
%        'ydata', {(1:30)' (1:30)' (1:30)'} , ...
%        'xlabel', struct('String', {'x' 'x' 'x'}), ...
%        'ylabel', struct('String', {'y' 'y' 'y'}), ...
%        'title', struct('String', {'uniform profile' 'normal profile' 'exponential profile'}), ...
%        'axsprops', struct('XGrid', {'on' 'on' 'on'}, ...
%                           'YGrid', {'on' 'on' 'on'}, ...
%                           'XScale',{'linear' 'linear' 'log'}), ...
%        'figprops', struct('Name', 'Profile statistics example') )
%
%  See also:
%    MEAN
%    STD
%    PLOT
%    SET
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2016
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

  % No argument number checking since any number of arguments is allowed.

  %% Set plot options and default values.
  options = struct();
  options.mdata = {[]};
  options.ydata = {[]};
  options.xlabel = [];
  options.ylabel = [];
  options.title = [];
  options.axsprops = [];
  options.figprops = struct();
  
  
  %% Get optional figure handle and option arguments.
  if (nargin > 0) && isscalar(varargin{1}) && ishghandle(varargin{1})
    args = varargin(2:end);
    hfig = figure(varargin{1});
  else
    args = varargin;
    hfig = figure();
  end
  
  
  %% Get options from extra arguments.
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(args) && isstruct(args{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    option_key_list = fieldnames(args{1});
    option_val_list = struct2cell(args{1});
  elseif mod(numel(args), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = args(1:2:end);
    option_val_list = args(2:2:end);
  else
    error('glider_toolbox:plotProfileStatistics:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:plotProfileStatistics:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Update subplot options not already set to match number or subplots.
  subplot_option_name_list = {'xlabel' 'ylabel' 'title' 'axsprops'};
  for subplot_option_name_idx = 1:numel(subplot_option_name_list)
    subplot_option_name = subplot_option_name_list{subplot_option_name_idx};
    if isempty(options.(subplot_option_name))
      options.(subplot_option_name) = repmat(struct(), size(options.mdata));
    end
  end
  
  
  %% Set figure properties.
  set(hfig, options.figprops);
  
  
  %% Initialize and set properties of all plot elements.
  haxs = nan(size(options.mdata));
  hlgs = nan(size(haxs));
  hlns = nan([2 size(haxs)]);
  [m, n] = size(options.mdata);
  for s = 1:(m*n)
    ydata = options.ydata{s};
    mdata = options.mdata{s};
    % mrange = quantile(options.mdata{s}, [0.01 0.99]);
    % mdata(mdata < mrange(1) | mdata > mrange(2)) = nan;
    mmean = nanmean(mdata, 1);
    mstd = nanstd(mdata, 1, 1); % 1 to compute the second moment biased estimator.
    haxs(s) = subplot(m, n, s);
    % Use 0 because plot does not return lineseries handles if empty inputs.
    hlns(:,s) = plot(haxs(s), 0, 0, '-', 0, 0, ':'); 
    hlgs(s) = legend(hlns(:,s));
    haxstit = title(haxs(s), []);
    haxsxlb = xlabel(haxs(s), []);
    haxsylb = ylabel(haxs(s), []);
    axis([min(mmean-mstd) max(mmean+mstd) min(ydata) max(ydata)] * ...
         [1.1 -0.1 0 0; -0.1 1.1 0 0; 0 0 1 0; 0 0 0 1]);
    set(haxs(s), options.axsprops(s));
    color_order = get(haxs(s), 'ColorOrder');
    set(hlns(1,s), ...
        'LineWidth', 2 * get(haxs(s), 'LineWidth'), ...
        'Color', color_order(1, :), ...
        'YData', ydata(:), 'XData', mmean(:));
    set(hlns(2,s), ...
        'LineWidth', 2 * get(haxs(s), 'LineWidth'), ...
        'Color', color_order( 1 + rem(1,size(color_order,1)) , : ), ...
        'YData', [ydata(:); nan; ydata(:)], ...
        'XData', [(mmean(:) - mstd(:)); nan; (mmean(:) + mstd(:))]);
    reverse_x = strcmp(get(haxs(s), 'XDir'), 'reverse');
    reverse_y = strcmp(get(haxs(s), 'YDir'), 'reverse');
    increasing = [1 0] * nancov(mmean(:), ydata(:), 1) * [0 1]' > 0;
    legend_location_list = {'NorthWest' 'NorthEast'; 'SouthWest' 'SouthEast'};
    legend_location = ...
      legend_location_list{1 + reverse_y, ...
                           2 - xor(increasing, reverse_x)};
    set(hlgs(s), 'String', {'mean', 'std'}, 'Location', legend_location);
    set(haxstit, options.title(s));
    set(haxsxlb, options.xlabel(s));
    set(haxsylb, options.ylabel(s));
    
  end

end
