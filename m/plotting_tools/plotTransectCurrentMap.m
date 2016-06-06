function [hfig, haxs, hlgn, hcba, htrj, hbeg, hend, hwpt, hcur] = plotTransectCurrentMap(varargin)
%PLOTTRANSECTCURRENTMAP  Plot map of glider trajectory with waypoints and current estimates.
%
%  Syntax:
%    PLOTTRANSECTCURRENTMAP(OPTIONS)
%    PLOTTRANSECTCURRENTMAP(OPT1, VAL1, ...)
%    PLOTTRANSECTCURRENTMAP(H, OPTIONS)
%    PLOTTRANSECTCURRENTMAP(H, OPT1, VAL1, ...)
%    [HFIG, HAXS, HLGN, HCBA, HTRJ, HBEG, HEND, HWPT, HCUR] = PLOTTRANSECTCURRENTMAP(...)
%
%  Description:
%    PLOTTRANSECTCURRENTMAP(OPTIONS) and 
%    PLOTTRANSECTCURRENTMAP(OPT1, VAL1, ...) generate a new figure with a line
%    plot of the trajectory described in glider data over a map, with an 
%    optional line plot of the waypoint path and a vector plot of the estimated
%    average currents, according to options in key-value pairs OPT1, VAL1...
%    or in struct OPTIONS with field names as option keys and field values as
%    option values. The map is generated with M_PROJ, M_PATCH and M_GSHHS_H or
%    M_USERCOAST. The line plots are generated with M_PLOT, and the vector plot
%    with M_VEC. Recognized options are:
%      LATDATA: trajectory latitude coordinate data.
%        Vector to use as latitude coordinate of the glider trajectory.
%        Default value: []
%      LONDATA: trajectory longitude coordinate data.
%        Vector to use as longitude coordindate of the glider trajectory.
%        Default value: []
%      WPTLATDATA: waypoint path latitude data.
%        Vector to use as latitude coordinates of the waypoint path.
%        Default value: []
%      WPTLONDATA: waypoint path longitude data.
%        Vector to use as longitude coordinates of the waypoint path.
%        Default value: []
%      CURNORDATA: northward current data.
%        Vector to use as northward component of water velocity estimates.
%        Default value: []
%      CUREASDATA: eastward current data.
%        Vector to use as eastward component of water velocity estimates.
%        Default value: []
%      CURSCALE: current unit scale.
%        Scalar specifying the length of current vectors in inches.
%        Default value: 1
%      COASTFILE: precomputed coast line data file.
%        String with the path to the coast file to be passed to function 
%        M_USERCOAST to generate the land patch. If empty, M_GSHHS_H is called
%        instead.
%        Default value: [] (call M_GSHHS_H)
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
%      AXSPROPS: extra axis properties.
%        Struct of axis properties to set for the plot axes with function SET.
%        Default value: struct()
%      FIGPROPS: extra figure properties.
%        Struct of figure properties to set for the figure with function SET.
%        Default value: struct()
%
%    PLOTTRANSECTCURRENTMAP(H, ...) does not create a new figure, but plots 
%    to figure given by figure handle H.
%
%    [HFIG, HAXS, HLGN, HCBA, HTRJ, HBEG, HEND, HWPT, HCUR] = PLOTTRANSECTCURRENTMAP(...) 
%    returns handles for the figure, axes, legend, color bar, lines and patch 
%    objects in HFIG, HAXS, HLGN, HCBA, HTRJ, HBEG, HEND, HWPT, and HCUR 
%    respectively.
%
%  Notes:
%    This function requires the files from the Global Self-consistant 
%    Hierarchical High-resolution Shorelines data suite (GSHHS) to be available 
%    in the path when no user defined coast file is provided. Please see
%    installation details in M_Map official site:
%      <http://www.eos.ubc.ca/~rich/private/mapug.html#p9.5>
%
%    The map is plotted in the geographic coordinate system (longitude-latitude,
%    no projection) and the map boundaries are selected such that the resulting
%    map fills the given plot box with a data aspect ratio of 1.
%
%    Water velocity estimates are represented as colored normalized vectors with
%    the magitude value (absolute water speed) as color coordinate. The vectors
%    are scaled so that they length matches the desired length given in inches.
%
%  Examples:
%    [hfig, haxs, hlgn, hcba, htrj, hwpt, hcur] = ...
%      plotTransectCurrentMap(gcf, ...
%        'latdata', linspace(39, 40, 30) - [0 5.0/60*rand(1,29)], ...
%        'londata', linspace( 0,  2, 30) - [0 2.5/60*rand(1,29)], ...
%        'wptlatdata', [39 40], 'wptlondata', [0 2], ...
%        'curnordata', -10 + 5 * rand(1, 30), ...
%        'cureasdata', -5 + 5 * rand(1, 30), ...
%        'curscale', 0.25, ...
%        'title', struct('String', 'Random trajectory and current plot'), ...
%        'xlabel', struct('String', 'longitude'), ...
%        'ylabel', struct('String', 'latitude'), ...
%        'clabel', struct('String', 'depth-averaged current (m s-1)'), ...
%        'axsprops', struct('Layer', 'top', 'XGrid', 'on', 'Ygrid', 'on'), ...
%        'figprops', struct('Name', 'Trajectory and current map', ...
%                           'PaperPosition', [0 0 8.3 6.6], ...
%                           'PaperUnits', 'inches'))
%
%  See also:
%    M_PROJ
%    M_GSHHS_H
%    M_USERCOAST
%    M_VEC
%    M_PLOT
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
  options.latdata = [];
  options.londata = [];
  options.wptlatdata = [];
  options.wptlondata = [];
  options.curnordata = [];
  options.cureasdata = [];
  options.curscale = 1;
  options.coastfile = [];
  options.xlabel = struct();
  options.ylabel = struct();
  options.clabel = struct();
  options.title = struct();
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
    error('glider_toolbox:plotTransectCurrentMap:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:plotTransectCurrentMap:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set figure properties.
  set(hfig, options.figprops);
  
  
  %% Initialize axis plot elements.
  haxs = gca();
  haxs_hold = ishold(haxs);
  if ~haxs_hold
    newplot(haxs);
    hold(haxs, 'on');
  end
  haxstit = title(haxs, []);
  haxsxlb = xlabel(haxs, []);
  haxsylb = ylabel(haxs, []);
  hlgn = [];
  hcba = colorbar('SouthOutside');
  hcbatit = get(hcba, 'XLabel');
  set(haxs, options.axsprops);
  set(haxstit, options.title);
  set(haxsxlb, options.xlabel);
  set(haxsylb, options.ylabel);
  set(hcbatit, options.clabel);
  
  
  %% Plot the map.
  % Compute axis limits such that data aspect ratio is 1 with axes' current
  % position, and glider trajectory is centered in the plot.
  lat_bounds = [min(options.latdata) max(options.latdata)];
  lon_bounds = [min(options.londata) max(options.londata)];
  if (numel(lat_bounds) ~= 2) || (max(abs(lat_bounds)) > 90)
    lat_bounds = [-90 90]; % arbitrary value when bad latitude data.
  end
  if (numel(lon_bounds) ~= 2) || (max(abs(lat_bounds)) > 180)
    lon_bounds = [-180  180]; % arbitrary value when bad longitude data.  
  end
  max_range = 1.1 * max(diff(lat_bounds), diff(lon_bounds));
  if strcmpi(get(haxs, 'Units'), 'normalized')
    set(haxs, 'Units', 'inches');
    haxs_position = get(haxs, 'Position');
    set(haxs, 'Units', 'normalized');
  else
    haxs_position = get(haxs, 'Position');
  end
  axs_ratio = haxs_position(4) / haxs_position(3);
  if axs_ratio < 1
    lat_range = max_range;
    lon_range = max_range / axs_ratio;
  else
    lat_range = max_range * axs_ratio;
    lon_range = max_range;
  end
  lat_lims = mean(lat_bounds) + [-0.5 0.5] * lat_range;
  lon_lims = mean(lon_bounds) + [-0.5 0.5] * lon_range;
  % Set no projection (map coordinates are longitude and latitude).
  m_proj('Equidistant Cylindrical', 'lat', lat_lims, 'lon', lon_lims);
  % Plot ocean and land as patches without coast lines.
  land_color = [1 1 1];
  ocean_color = [0.4141 0.6328 0.7852];
  m_patch(lon_lims([1 1 2 2]), lat_lims([1 2 2 1]), ocean_color, ...
          'EdgeColor', 'none');
  if isempty(options.coastfile)
     m_gshhs_h('patch', land_color, 'EdgeColor', 'none');
  else
     m_usercoast(options.coastfile, 'patch', land_color, 'EdgeColor', 'none')
  end
  % Remove extra axis limit space and set latitude and longitude ticks.
  % This is usually done by calling M_GRID, but it may shrink the axes too much.
  % Use the following code as an alternative.
  % m_grid('box', 'on', 'backcolor', ocean_color);
  [haxs_xlims, haxs_ylims] = m_ll2xy(lon_lims, lat_lims, 'clip', 'off');
  set(haxs, 'XLim', haxs_xlims, 'YLim', haxs_ylims);
  
  lat_tick_step = (10/2) ...
                * (floor((2/10) * 10 .^ mod(log10(diff(lat_lims)), 1)) + 1) ...
                * 10 .^ (floor(log10(diff(lat_lims))) - 1);
  lon_tick_step = (10/2) ...
                * (floor((2/10) * 10 .^ mod(log10(diff(lon_lims)), 1)) + 1) ...
                * 10 .^ (floor(log10(diff(lon_lims))) - 1);
  lat_ticks = (-200 : lat_tick_step : 200);
  lon_ticks = (-100 : lon_tick_step : 100);
  lat_ticks = lat_ticks(lat_lims(1) <= lat_ticks & lat_ticks <= lat_lims(2));
  lon_ticks = lon_ticks(lon_lims(1) <= lon_ticks & lon_ticks <= lon_lims(2));
  haxs_xticks = ...
    haxs_xlims(1) + (lon_ticks - lon_lims(1)) * diff(haxs_xlims) / diff(lon_lims);
  haxs_yticks = ...
    haxs_ylims(1) + (lat_ticks - lat_lims(1)) * diff(haxs_ylims) / diff(lat_lims);
  set(haxs, 'XTick', haxs_xticks, 'XTickLabel', cellstr(num2str(lon_ticks(:))));
  set(haxs, 'YTick', haxs_yticks, 'YTickLabel', cellstr(num2str(lat_ticks(:))));
  
  
  %% Plot glider data elements.
  % Plot sea water velocity vector estimates.
  % Plot normalized vectors with magnitude information in color coordinate.
  % The inverse of the scale factor is the size of a unary vector.
  if isempty(options.curnordata) || isempty(options.cureasdata)
    hcur = [];
  else
    curabsdata = sqrt(options.curnordata .^ 2 + options.cureasdata .^ 2);
    hcur = m_vec(1/options.curscale, options.londata, options.latdata, ...
                 options.cureasdata ./ curabsdata, ...               
                 options.curnordata ./ curabsdata, ...
                 curabsdata, ...
                 'shaftwidth', 2 * get(haxs, 'LineWidth'), ...
                 'headwidth', 0.25 * get(haxs, 'FontSize'), ...
                 'headlength', 0.25 * get(haxs, 'FontSize'), ...
                 'clip', 'on');
  end
  % Plot planned waypoint path.
  hwpt = m_plot(options.wptlondata, options.wptlatdata, ...
                'LineStyle', ':', 'LineWidth', 1.5 * get(haxs, 'LineWidth'), ...
                'Marker', 'x', 'MarkerSize', 0.5 * get(haxs, 'FontSize'), ...
                'Color', 'black');
  % Plot glider trajectory.
  htrj = m_plot(options.londata, options.latdata, ...
                'LineStyle', '-', 'LineWidth', 1.5 * get(haxs, 'LineWidth'), ...
                'Marker', 'none', ...
                'Color', 'black');
  % Plot initial and final trajectory points.
  trj_frst = ...
    find(~(isnan(options.londata(:)) | isnan(options.latdata(:))), 1, 'first');
  trj_last = ...
    find(~(isnan(options.londata(:)) | isnan(options.latdata(:))), 1, 'last');
  hbeg = m_plot(options.londata(trj_frst), options.latdata(trj_frst), ...
                'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerSize', 1/3 * get(haxs, 'FontSize'), ...
                'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black');
  hend = m_plot(options.londata(trj_last), options.latdata(trj_last), ...
                'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerSize', 1/3 * get(haxs, 'FontSize'), ...
                'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'white');
  
  
  %% Add legends for glider trajectory and planned waypoint path.
  set(htrj, 'DisplayName', 'glider trajectory');
  set(hbeg, 'DisplayName', 'first position');
  set(hend, 'DisplayName', 'last position');
  set(hwpt, 'DisplayName', 'planned waypoint path');
  if any(ishghandle([htrj hbeg hend hwpt]))
    hlgn = legend([htrj hbeg hend hwpt]);
  end
  
  
  %% Restore figure and axes properties, if needed.
  if ~haxs_hold
    hold(haxs, 'off');
  end

end
