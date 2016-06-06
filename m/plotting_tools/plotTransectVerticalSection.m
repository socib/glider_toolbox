function [hfig, haxs, hcba, hsct] = plotTransectVerticalSection(varargin)
%PLOTTRANSECTVERTICALSECTION  Plot vertical section of scatter data from a glider transect.
%
%  Syntax:
%    PLOTTRANSECTVERTICALSECTION(OPTIONS)
%    PLOTTRANSECTVERTICALSECTION(OPT1, VAL1, ...)
%    PLOTTRANSECTVERTICALSECTION(H, OPTIONS)
%    PLOTTRANSECTVERTICALSECTION(H, OPT1, VAL1, ...)
%    [HFIG, HAXS, HCBA, HSCT] = PLOTTRANSECTVERTICALSECTION(...)
%
%  Description:
%    PLOTTRANSECTVERTICALSECTION(OPTIONS) and 
%    PLOTTRANSECTVERTICALSECTION(OPT1, VAL1, ...) generate a new figure with a
%    scatter plot of scalar data collected during a glider transect according to
%    options in string key-value pairs OPT1, VAL1... or in struct OPTIONS with
%    field names as option keys and field values as option values.
%    The scatter plot is generated with the function SCATTER.
%    See note on performance and invalid values.
%    Recognized options are:
%      XDATA: horizontal coordinate data.
%        Vector of data to be passed as x coordindate to function SCATTER, 
%        usually distance or time.
%        Default value: []
%      YDATA: vertical coordinate data.
%        Vector of data to be passed as y coordindate to function SCATTER,
%        usually pressure or depth.
%        Default value: []
%      CDATA: measured variable data.
%        Vector of data to be passed as color coordindate to function SCATTER.
%        Default value: []
%      SDATA: data marker size.
%        Vector or scalar to be passed as size coordindate to function SCATTER.
%        Default value: []
%      XLABEL: horizontal axis label data.
%        Struct defining x label properties.
%        The text of the label is in property 'String'.
%        Default value: struct()
%      YLABEL: vertical axis label data.
%        Struct defining y label properties.
%        The text of the label is in property 'String'.
%        Default value: struct()
%      CLABEL: color bar label data.
%        Struct defining color bar label properties.
%        The text of the label is in property 'String'.
%        Actually this will be the colorbar's child object 'Title'.
%        Default value: struct()
%      TITLE: axes title data.
%        Struct defining axes title properties.
%        The text of the label is in property 'String'.
%        Default value: struct()
%      LOGSCALE: use logarithmic color scale instead of linear scale.
%        Boolean specifying whether color scale should be logarithmic instead of
%        linear. See note on logarithmic color scaling.
%        Default value: false
%      DATETICKS: use date formatted tick labels for selected axes.
%        Substring of 'xyz' specifying which axes should be labeled with date
%        formatted ticks using function DATETICKS.
%        Default value: ''
%      AXSPROPS: extra axis properties.
%        Struct of axis properties to set for the plot axes with function SET.
%        Default value: struct()
%      FIGPROPS: extra figure properties.
%        Struct of figure properties to set for the figure with function SET.
%        Default value: struct()
%  
%    PLOTTRANSECTVERTICALSECTION(H, ...) does not create a new figure,
%    but plots  to figure given by figure handle H.
%
%    [HFIG, HAXS, HCBA, HSCT] = PLOTTRANSECTVERTICALSECTION(...) returns
%    handles for the figure, axes, color bar, and scatter group in
%    HFIG, HAXS, HSCT, and HCBA, respectively.
%
%  Notes:
%    Invalid values (NaN) introduce a signficant performance penalty in the 
%    plotting functions. They are discarded without modifying the final
%    appearance of the plot.
%
%    There is no built-in support for logarithmic color scaling. 
%    The effect is emulated hacking the color data and the color bar ticks.
%
%  Examples:
%    [hfig, haxs, hcba, hsct] = ...
%      plotTransectVerticalSection(gcf, ...
%        'xdata', now+30*rand(100,1), 'xlabel', struct('String', 'x'), ...
%        'ydata', rand(100,1), 'ylabel', struct('String', 'y'), ...
%        'cdata', 10.^(3*rand(100,1)), 'clabel', struct('String', 'c'), ...
%        'sdata', 25, 'logscale', true, 'dateticks', 'x', ...
%        'title', struct('String', 'Random scatter plot'), ...
%        'axsprops', struct('XGrid', 'on', 'YGrid', 'on', 'PlotBoxAspectRatio', [2 1 1]), ...
%        'figprops', struct('Name', 'Vertical section example') )
%
%  See also:
%    SCATTER
%    COLORBAR
%    DATETICK
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
  options.xdata = [];
  options.ydata = [];
  options.cdata = [];
  options.sdata = [];
  options.xlabel = struct();
  options.ylabel = struct();
  options.clabel = struct();
  options.title = struct();
  options.logscale = false;
  options.dateticks = '';
  options.axsprops = struct();
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
    error('glider_toolbox:plotTransectVerticalSection:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:plotTransectVerticalSection:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set figure properties.
  set(hfig, options.figprops);
  
  
  %% Initialize all plot elements.
  haxs = gca();
  hsct = scatter(haxs, [], [], [], [], 'fill');
  hcba = colorbar('SouthOutside');
  haxstit = title(haxs, []);
  haxsxlb = xlabel(haxs, []);
  haxsylb = ylabel(haxs, []);
  hcbatit = get(hcba, 'XLabel');
  
  
  %% Compute mask to discard invalid values to speedup plotting.
  % Size data might be empty to use default marker size in SCATTER.
  valid = ~(isnan(options.xdata) | isnan(options.ydata) | isnan(options.cdata));
  if (~isempty(options.sdata))
    valid = valid & ~isnan(options.sdata);
  end
  
  
  %% Set properties of plot elements.
  % Use an equivalent way to compute quantile without using QUANTILE function
  % in statistical toolbox. See documentation there for algorithm details.
  % crange = quantile(options.cdata(valid), crange_quantiles);
  crange_quantiles = [0.01 0.99];
  cdata_sorted = sort(options.cdata(valid));
  if isempty(cdata_sorted)
    crange = [0.5 1.5]; % some arbitrary value to let the rest of code work.
  else
    crange = interp1(cdata_sorted([1 1:end end]),...
                     crange_quantiles * numel(cdata_sorted) + 1.5);
  end
  xrange = [min(options.xdata(:)) max(options.xdata(:))];
  yrange = [min(options.ydata(:)) max(options.ydata(:))];
  if options.logscale
    % Hack to plot a color bar with logarithmic scale and linear ticks.
    % This code should go after colormap call, otherwise colormap resets ticks.
    if isscalar(options.sdata)
      set(hsct, ...
          'XData', options.xdata(valid), ...
          'YData', options.ydata(valid), ...
          'CData', log10(options.cdata(valid)), ...
          'SizeData', options.sdata);
    elseif ~isempty(options.sdata)
      set(hsct, ...
          'XData', options.xdata(valid), ...
          'YData', options.ydata(valid), ...
          'CData', log10(options.cdata(valid)), ...
          'SizeData', options.sdata(valid));
    end
    % Force range to prevent error due to wrong non-positive values.
    % These values should not be there for logarithmic scale magnitudes
    % (e.g. chlorophyll concentration).
    if crange(2) <= 0
      crange = log10(realmin('double')*[1 10]);
    elseif crange(1) <= 0 
      crange = log10(sort([min(options.cdata(options.cdata(:)>0)) crange(2)]));
    else
      crange = log10(crange);
    end
    if diff(crange) == 0
      crange = crange + 0.5 * [-1 1];
    end
    ctick = bsxfun(@plus, log10(1:9)', floor(crange(1)) : floor(crange(2)));
    ctick = ctick(crange(1) <= ctick & ctick <= crange(2));
    ctick_label = cell(size(ctick));
    switch floor(diff(crange))
      case 0
        ctick_show = true(size(ctick));
      case 1
        ctick_show = [true ; rem(ctick(2:end-1), 1) == 0 ; true];
      otherwise
        ctick_show = (rem(ctick, 1) == 0);
    end
    ctick_label(ctick_show) = strtrim(cellstr(num2str(10.^ctick(ctick_show))));
    drawnow(); % Hack to force plot update before setting color axis properties.
    set(haxs, 'CLim', crange, 'XLim', xrange, 'YLim', yrange);
    set(hcba, 'XTick', ctick, 'XTickLabel', ctick_label);
  else
    if isscalar(options.sdata)
      set(hsct, ...
          'XData', options.xdata(valid), ...
          'YData', options.ydata(valid), ...
          'CData', options.cdata(valid), ...
          'SizeData', options.sdata);
    elseif ~isempty(options.sdata)
      set(hsct, ...
          'XData', options.xdata(valid), ...
          'YData', options.ydata(valid), ...
          'CData', options.cdata(valid), ...
          'SizeData', options.sdata(valid));
    end
    % Prevent range error when color range contains one single value.
    if diff(crange) == 0
      crange = crange + 0.5 * [-1 1];
    end
    set(haxs, 'CLim', crange, 'XLim', xrange, 'YLim', yrange);
  end
  for a = 'xyz'
    if ismember(a, options.dateticks)
      arange = diff(get(haxs, [a 'lim']));
      if arange > 365
        datetick_format = 'yyyy mmm';
      elseif arange > 2
        datetick_format = 'mmm dd';
      else
        datetick_format = 'HH:mm:ss';
      end
      datetick(a, datetick_format, 'keeplimits');
    end
  end
  set(haxs, options.axsprops);
  set(haxstit, options.title);
  set(haxsxlb, options.xlabel);
  set(haxsylb, options.ylabel);
  set(hcbatit, options.clabel);

end
