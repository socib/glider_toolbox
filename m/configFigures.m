function [figures_proc, figures_grid] = configFigures()
%CONFIGFIGURES  Configure generation of figures from glider data.
%
%  Syntax:
%    [FIGURES_PROC, FIGURES_GRID] = CONFIGFIGURES()
%
%  Description:
%    [FIGURES_PROC, FIGURES_GRID] = CONFIGFIGURES() should return structs
%    FIGURES_PROC and FIGURES_GRID defining the figures to be generated from
%    processed glider data and gridded glider data respectively in the format
%    accepted by function GENERATEGLIDERFIGURES.
%
%    Additionally, default values of axis, figure and plot object properties
%    for glider figure plots might be set. This is usually done calling the
%    function SET with the root object (0) and prepending figure property names
%    with 'DefaultFigure...' and axis property names with 'DefaultAxes...'.
%
%  Notes:
%    Edit this file defining the desired figures for processed and gridded data
%    outpus, and setting up the figure and axes and plot object properties 
%    according to the desired appearance.
%
%  Examples:
%    configFigures()
%
%  See also:
%    GENERATEGLIDERFIGURES
%    PLOTTRANSECTVERTICALSECTION
%    PLOTTRANSECTCURRENTMAP
%    PLOTTSDIAGRAM
%    PLOTPROFILESTATISTICS
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

  error(nargchk(0, 0, nargin, 'struct'));
  
  
  %% Get handle to current figure or create one.
  % A new figure will be created anyway when calling SET,
  % so make this explicit in source code.
  hfig = gcf();
  
  
  %% Set built-in default values for some figure and axes properties.
  % Figure properties.
  set(0,'DefaultFigurePaperUnits', 'inches');
  set(0,'DefaultFigurePaperSize', [6.40 3.84]);
  set(0,'DefaultFigurePaperPosition', [0 0 6.40 3.84]);
  set(0,'DefaultFigurePaperPositionMode','manual');
  set(0,'DefaultFigureColor', 'white');
  set(0,'DefaultFigureColormap', colormap('jet'));
  set(0,'DefaultFigureInvertHardcopy','off');
  % Axes properties.
  set(0, 'DefaultAxesColor', 0.8 * ones(1,3));
  set(0, 'DefaultAxesBox', 'on');
  set(0, 'DefaultAxesXGrid', 'on');
  set(0, 'DefaultAxesYGrid', 'on');
  set(0, 'DefaultAxesFontName',  'Helvetica');
  set(0, 'DefaultAxesFontUnits', 'points');
  set(0, 'DefaultAxesFontSize',  8);
  set(0, 'DefaultAxesLineWidth', 0.25);
  % Text properties.
  set(0, 'DefaultTextFontSize',  8);
  
  
  %% Set printing options.
  default_prntopts = struct();
  default_prntopts.resolution = 200;
  default_prntopts.format = 'png';
  default_prntopts.render = 'painters';
  
  
  %% Set default figure and axes properties.
  default_figure = struct();
  default_figure.PaperUnits = 'inches';
  default_figure.PaperSize = [6.40 3.84];
  default_figure.PaperPosition = [0 0 6.40 3.84];
  default_figure.PaperPositionMode = 'manual';
  default_figure.Color = 'white';
  default_figure.Colormap = colormap('jet');
  default_figure.InvertHardcopy = 'off';
  
  default_axes = struct();
  default_axes.FontName = 'Helvetica';
  default_axes.FontUnits ='points';
  default_axes.FontSize = 8;
  default_axes.FontWeight = 'normal';
  default_axes.Color = 0.8 * ones(1,3);
  default_axes.Box = 'on';
  default_axes.XGrid = 'on';
  default_axes.YGrid = 'on';
  default_axes.LineWidth = 0.25;
    
  default_label = struct();
  default_label.FontName = 'Helvetica';
  default_label.FontUnits = 'points';
  default_label.FontSize = 8;
  default_label.FontWeight = 'normal';
  
  default_title = struct();
  default_title.FontName = 'Helvetica';
  default_title.FontUnits = 'points';
  default_title.FontSize = 10;
  default_title.FontWeight = 'bold';
  
  
  %% Configure processed data figures.
  figures_proc = struct();

  % Vertical section plots.
  figures_proc.temperature = struct();
  figures_proc.temperature.plotfunc = @plotTransectVerticalSection;
  figures_proc.temperature.dataopts.xdata = 'distance_over_ground';
  figures_proc.temperature.dataopts.ydata = {'depth_ctd' 'depth'};
  figures_proc.temperature.dataopts.cdata = 'temperature';
  figures_proc.temperature.plotopts.sdata = 2;
  figures_proc.temperature.plotopts.logscale = false;
  figures_proc.temperature.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.temperature.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.temperature.plotopts.clabel = setfield(default_label, 'String', 'temperature (deg C)');
  figures_proc.temperature.plotopts.title = setfield(default_title, 'String', 'In situ temperature');
  figures_proc.temperature.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.temperature.plotopts.figprops = default_figure;
  figures_proc.temperature.prntopts = default_prntopts;
  figures_proc.temperature.prntopts.filename = 'temperature';
  figures_proc.temperature.prntopts.title = 'Temperature section';
  figures_proc.temperature.prntopts.comment = 'Cross section of in situ measured temperature.';
  
  figures_proc.salinity = struct();
  figures_proc.salinity.plotfunc = @plotTransectVerticalSection;
  figures_proc.salinity.dataopts.xdata = 'distance_over_ground';
  figures_proc.salinity.dataopts.ydata = {'depth_ctd' 'depth'};
  figures_proc.salinity.dataopts.cdata = 'salinity';
  figures_proc.salinity.plotopts.sdata = 2;
  figures_proc.salinity.plotopts.logscale = false;
  figures_proc.salinity.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.salinity.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.salinity.plotopts.clabel = setfield(default_label, 'String', 'salinity (PSU)');
  figures_proc.salinity.plotopts.title = setfield(default_title, 'String', 'In situ salinity (raw)');
  figures_proc.salinity.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.salinity.plotopts.figprops = default_figure;
  figures_proc.salinity.prntopts = default_prntopts;
  figures_proc.salinity.prntopts.filename = 'salinity';
  figures_proc.salinity.prntopts.title = 'Salinity section';
  figures_proc.salinity.prntopts.comment = 'Cross section of in situ derived salinity without corrections.';

  figures_proc.salinity_corrected_thermal = struct();
  figures_proc.salinity_corrected_thermal.plotfunc = @plotTransectVerticalSection;
  figures_proc.salinity_corrected_thermal.dataopts.xdata = 'distance_over_ground';
  figures_proc.salinity_corrected_thermal.dataopts.ydata = {'depth_ctd' 'depth'};
  figures_proc.salinity_corrected_thermal.dataopts.cdata = 'salinity_corrected_thermal';
  figures_proc.salinity_corrected_thermal.plotopts.sdata = 2;
  figures_proc.salinity_corrected_thermal.plotopts.logscale = false;
  figures_proc.salinity_corrected_thermal.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.salinity_corrected_thermal.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.salinity_corrected_thermal.plotopts.clabel = setfield(default_label, 'String', 'salinity (PSU)');
  figures_proc.salinity_corrected_thermal.plotopts.title = setfield(default_title, 'String', 'In situ salinity (thermal lag corrected)');
  figures_proc.salinity_corrected_thermal.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.salinity_corrected_thermal.plotopts.figprops = default_figure;
  figures_proc.salinity_corrected_thermal.prntopts = default_prntopts;
  figures_proc.salinity_corrected_thermal.prntopts.filename = 'salinity_corrected_thermal';
  figures_proc.salinity_corrected_thermal.prntopts.title = 'Salinity section';
  figures_proc.salinity_corrected_thermal.prntopts.comment = 'Cross section of in situ derived salinity with thermal lag corrections.';

  figures_proc.density = struct();
  figures_proc.density.plotfunc = @plotTransectVerticalSection;
  figures_proc.density.dataopts.xdata = 'distance_over_ground';
  figures_proc.density.dataopts.ydata = {'depth_ctd' 'depth'};
  figures_proc.density.dataopts.cdata = 'density';
  figures_proc.density.plotopts.sdata = 2;
  figures_proc.density.plotopts.logscale = false;
  figures_proc.density.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.density.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.density.plotopts.clabel = setfield(default_label, 'String', 'density (kg m-3)');
  figures_proc.density.plotopts.title = setfield(default_title, 'String', 'In situ density (from raw salinity)');
  figures_proc.density.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.density.plotopts.figprops = default_figure;
  figures_proc.density.prntopts = default_prntopts;
  figures_proc.density.prntopts.filename = 'density';
  figures_proc.density.prntopts.title = 'Density section';
  figures_proc.density.prntopts.comment = 'Cross section of in situ derived density from salinity without corrections.';

  figures_proc.density_corrected_thermal = struct();
  figures_proc.density_corrected_thermal.plotfunc = @plotTransectVerticalSection;
  figures_proc.density_corrected_thermal.dataopts.xdata = 'distance_over_ground';
  figures_proc.density_corrected_thermal.dataopts.ydata = {'depth_ctd' 'depth'};
  figures_proc.density_corrected_thermal.dataopts.cdata = 'density_corrected_thermal';
  figures_proc.density_corrected_thermal.plotopts.sdata = 2;
  figures_proc.density_corrected_thermal.plotopts.logscale = false;
  figures_proc.density_corrected_thermal.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.density_corrected_thermal.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.density_corrected_thermal.plotopts.clabel = setfield(default_label, 'String', 'salinity (PSU)');
  figures_proc.density_corrected_thermal.plotopts.title = setfield(default_title, 'String', 'In situ density (from thermal lag corrected salinity)');
  figures_proc.density_corrected_thermal.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.density_corrected_thermal.plotopts.figprops = default_figure;
  figures_proc.density_corrected_thermal.prntopts = default_prntopts;
  figures_proc.density_corrected_thermal.prntopts.filename = 'density_corrected_thermal';
  figures_proc.density_corrected_thermal.prntopts.title = 'Density section';
  figures_proc.density_corrected_thermal.prntopts.comment = 'Cross section of in situ derived density from salinity with thermal lag corrections.';

  figures_proc.chlorophyll = struct();
  figures_proc.chlorophyll.plotfunc = @plotTransectVerticalSection;
  figures_proc.chlorophyll.dataopts.xdata = 'distance_over_ground';
  figures_proc.chlorophyll.dataopts.ydata = {'depth' 'depth_ctd'};
  figures_proc.chlorophyll.dataopts.cdata = 'chlorophyll';
  figures_proc.chlorophyll.plotopts.sdata = 2;
  figures_proc.chlorophyll.plotopts.logscale = true;
  figures_proc.chlorophyll.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.chlorophyll.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.chlorophyll.plotopts.clabel = setfield(default_label, 'String', 'chlorophyll (ug l-1)');
  figures_proc.chlorophyll.plotopts.title = setfield(default_title, 'String', 'In situ chlorophyll');
  figures_proc.chlorophyll.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.chlorophyll.plotopts.figprops = default_figure;
  figures_proc.chlorophyll.prntopts = default_prntopts;
  figures_proc.chlorophyll.prntopts.filename = 'chlorophyll';
  figures_proc.chlorophyll.prntopts.title = 'Chlorophyll section';
  figures_proc.chlorophyll.prntopts.comment = 'Cross section of in situ measured chlorophyll.';

  figures_proc.turbidity = struct();
  figures_proc.turbidity.plotfunc = @plotTransectVerticalSection;
  figures_proc.turbidity.dataopts.xdata = 'distance_over_ground';
  figures_proc.turbidity.dataopts.ydata = {'depth' 'depth_ctd'};
  figures_proc.turbidity.dataopts.cdata = 'turbidity';
  figures_proc.turbidity.plotopts.sdata = 2;
  figures_proc.turbidity.plotopts.logscale = true;
  figures_proc.turbidity.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.turbidity.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.turbidity.plotopts.clabel = setfield(default_label, 'String', 'turbidity (NTU)');
  figures_proc.turbidity.plotopts.title = setfield(default_title, 'String', 'In situ turbidity');
  figures_proc.turbidity.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.turbidity.plotopts.figprops = default_figure;
  figures_proc.turbidity.prntopts = default_prntopts;
  figures_proc.turbidity.prntopts.filename = 'turbidity';
  figures_proc.turbidity.prntopts.title = 'Turbidity section';
  figures_proc.turbidity.prntopts.comment = 'Cross section of in situ measured turbidity.';

  figures_proc.cdom = struct();
  figures_proc.cdom.plotfunc = @plotTransectVerticalSection;
  figures_proc.cdom.dataopts.xdata = 'distance_over_ground';
  figures_proc.cdom.dataopts.ydata = {'depth' 'depth_ctd'};
  figures_proc.cdom.dataopts.cdata = 'cdom';
  figures_proc.cdom.plotopts.sdata = 2;
  figures_proc.cdom.plotopts.logscale = false;
  figures_proc.cdom.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.cdom.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.cdom.plotopts.clabel = setfield(default_label, 'String', 'CDOM (ppb)');
  figures_proc.cdom.plotopts.title = setfield(default_title, 'String', 'In situ CDOM');
  figures_proc.cdom.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.cdom.plotopts.figprops = default_figure;
  figures_proc.cdom.prntopts = default_prntopts;
  figures_proc.cdom.prntopts.filename = 'cdom';
  figures_proc.cdom.prntopts.title = 'CDOM section';
  figures_proc.cdom.prntopts.comment = 'Cross section of in situ measured CDOM.';  

  figures_proc.oxygen_concentration = struct();
  figures_proc.oxygen_concentration.plotfunc = @plotTransectVerticalSection;
  figures_proc.oxygen_concentration.dataopts.xdata = 'distance_over_ground';
  figures_proc.oxygen_concentration.dataopts.ydata = {'depth' 'depth_ctd'};
  figures_proc.oxygen_concentration.dataopts.cdata = 'oxygen_concentration';
  figures_proc.oxygen_concentration.plotopts.sdata = 2;
  figures_proc.oxygen_concentration.plotopts.logscale = false;
  figures_proc.oxygen_concentration.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.oxygen_concentration.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.oxygen_concentration.plotopts.clabel = setfield(default_label, 'String', 'oxygen concentration (umol l-1)');
  figures_proc.oxygen_concentration.plotopts.title = setfield(default_title, 'String', 'In situ oxygen concentration');
  figures_proc.oxygen_concentration.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.oxygen_concentration.figprops = default_figure;
  figures_proc.oxygen_concentration.prntopts = default_prntopts;
  figures_proc.oxygen_concentration.prntopts.filename = 'oxygen_concentration';
  figures_proc.oxygen_concentration.prntopts.title = 'Oxygen concentration section';
  figures_proc.oxygen_concentration.prntopts.comment = 'Cross section of in situ measured oxygen saturation.';

  figures_proc.oxygen_saturation = struct();
  figures_proc.oxygen_saturation.plotfunc = @plotTransectVerticalSection;
  figures_proc.oxygen_saturation.dataopts.xdata = 'distance_over_ground';
  figures_proc.oxygen_saturation.dataopts.ydata = {'depth' 'depth_ctd'};
  figures_proc.oxygen_saturation.dataopts.cdata = 'oxygen_saturation';
  figures_proc.oxygen_saturation.plotopts.sdata = 2;
  figures_proc.oxygen_saturation.plotopts.logscale = false;
  figures_proc.oxygen_saturation.plotopts.xlabel = setfield(default_label, 'String', 'distance (km)');
  figures_proc.oxygen_saturation.plotopts.ylabel = setfield(default_label, 'String', 'depth (m)');
  figures_proc.oxygen_saturation.plotopts.clabel = setfield(default_label, 'String', 'oxygen saturation (%)');
  figures_proc.oxygen_saturation.plotopts.title = setfield(default_title, 'String', 'In situ oxygen saturation');
  figures_proc.oxygen_saturation.plotopts.axsprops = setfield(default_axes, 'Ydir', 'reverse');
  figures_proc.oxygen_saturation.plotopts.figprops = default_figure;
  figures_proc.oxygen_saturation.prntopts = default_prntopts;
  figures_proc.oxygen_saturation.prntopts.filename = 'oxygen_saturation';
  figures_proc.oxygen_saturation.prntopts.title = 'Oxygen saturation section';
  figures_proc.oxygen_saturation.prntopts.comment = 'Cross section of in situ measured oxygen saturation.';

  % Temperature - salinity diagrams.
  figures_proc.temperature_salinity = struct();
  figures_proc.temperature_salinity.plotfunc = @plotTSDiagram;
  figures_proc.temperature_salinity.dataopts.sdata = 'salinity';
  figures_proc.temperature_salinity.dataopts.tdata = 'temperature';
  figures_proc.temperature_salinity.plotopts.xlabel = setfield(default_label, 'String', 'salinity (PSU)');
  figures_proc.temperature_salinity.plotopts.ylabel = setfield(default_label, 'String', 'temperature (deg C)');
  figures_proc.temperature_salinity.plotopts.title = setfield(default_title, 'String', {''; 'Temperature-Salinity diagram on sigma-t contours'});
  figures_proc.temperature_salinity.plotopts.axsprops = setfield(setfield(setfield(default_axes, ...
                                                          'PlotBoxAspectRatio', [1 1 1]), ...
                                                          'XGrid', 'off'), 'YGrid', 'off');
  figures_proc.temperature_salinity.plotopts.figprops = setfield(setfield(default_figure, ...
                                                          'PaperSize', [4.80 3.84]), ...
                                                          'PaperPosition', [0 0 4.80 3.84]);
  figures_proc.temperature_salinity.prntopts = default_prntopts;
  figures_proc.temperature_salinity.prntopts.filename = 'temperature_salinity';
  figures_proc.temperature_salinity.prntopts.title = 'Temperature - Salinity diagram';
  figures_proc.temperature_salinity.prntopts.comment = 'Diagram of temperature versus salinity without corrections over constant sigma-t contour levels.';
  
  figures_proc.temperature_salinity_corrected_thermal = struct();
  figures_proc.temperature_salinity_corrected_thermal.plotfunc = @plotTSDiagram;
  figures_proc.temperature_salinity_corrected_thermal.dataopts.sdata = 'salinity_corrected_thermal';
  figures_proc.temperature_salinity_corrected_thermal.dataopts.tdata = 'temperature';
  figures_proc.temperature_salinity_corrected_thermal.plotopts.xlabel = setfield(default_label, 'String', 'salinity (PSU)');
  figures_proc.temperature_salinity_corrected_thermal.plotopts.ylabel = setfield(default_label, 'String', 'temperature (deg C)');
  figures_proc.temperature_salinity_corrected_thermal.plotopts.title = setfield(default_title, 'String', {'Temperature-Salinity diagram on sigma-t contours'; '(corrected thermal lag)'});
  figures_proc.temperature_salinity_corrected_thermal.plotopts.axsprops = setfield(setfield(setfield(default_axes, ...
                                                                            'PlotBoxAspectRatio', [1 1 1]), ...
                                                                            'XGrid', 'off'), 'YGrid', 'off');
  figures_proc.temperature_salinity_corrected_thermal.plotopts.figprops = setfield(setfield(default_figure, ...
                                                                            'PaperSize', [4.80 3.84]), ...
                                                                            'PaperPosition', [0 0 4.80 3.84]);
  figures_proc.temperature_salinity_corrected_thermal.prntopts = default_prntopts;
  figures_proc.temperature_salinity_corrected_thermal.prntopts.filename = 'temperature_salinity_corrected_thermal';
  figures_proc.temperature_salinity_corrected_thermal.prntopts.title = 'Temperature - Salinity diagram';
  figures_proc.temperature_salinity_corrected_thermal.prntopts.comment = 'Diagram of temperature versus salinity with thermal lag corrections over constant sigma-t contour levels.';

  % Trajectory and currents maps:
  figures_proc.current_map = struct();
  figures_proc.current_map.plotfunc = @plotTransectCurrentMap;
  figures_proc.current_map.dataopts.latdata = 'latitude';
  figures_proc.current_map.dataopts.londata = 'longitude';
  figures_proc.current_map.dataopts.wptlatdata = 'waypoint_latitude';
  figures_proc.current_map.dataopts.wptlondata = 'waypoint_longitude';
  figures_proc.current_map.dataopts.curnordata = 'water_velocity_northward';
  figures_proc.current_map.dataopts.cureasdata = 'water_velocity_eastward';
  figures_proc.current_map.plotopts.wptlatdata = [];
  figures_proc.current_map.plotopts.wptlondata = [];
  figures_proc.current_map.plotopts.curnordata = [];
  figures_proc.current_map.plotopts.cureasdata = [];
  figures_proc.current_map.plotopts.curscale = 0.2;
  figures_proc.current_map.plotopts.xlabel = setfield(default_label, 'String', 'longitude');
  figures_proc.current_map.plotopts.ylabel = setfield(default_label, 'String', 'latitude');
  figures_proc.current_map.plotopts.clabel = setfield(default_label, 'String', 'column-averaged sea water speed (m s-1)');
  figures_proc.current_map.plotopts.title = setfield(default_title, 'String', 'Trajectory and column integrated water current estimates');
  figures_proc.current_map.plotopts.axsprops = setfield(setfield(default_axes, 'Layer', 'top'), 'GridLineStyle', ':');
  figures_proc.current_map.plotopts.figprops = setfield(setfield(default_figure, ...
                                                                 'PaperSize', [4.80 3.84]), ...
                                                                 'PaperPosition', [0 0 4.80 3.84]);
  figures_proc.current_map.prntopts = default_prntopts;
  figures_proc.current_map.prntopts.filename = 'current_map';
  figures_proc.current_map.prntopts.title = 'Current map';
  figures_proc.current_map.prntopts.comment = 'Map of glider planned waypoint path, actual track and column integrated water current estimates.';
  
  
  %% Configure gridded data figures.
  default_axes.Ydir = 'reverse';
  default_axes.ColorOrder = [0 0 0];
  default_axes.XMinorTick = 'on';

  figures_grid = struct();

  % Profile statistics plots.
  figures_grid.profiles_ctd.plotfunc = @plotProfileStatistics;
  figures_grid.profiles_ctd.dataopts(1).mdata = 'temperature';
  figures_grid.profiles_ctd.dataopts(1).ydata = 'depth';
  figures_grid.profiles_ctd.plotopts.xlabel(1) = setfield(default_label, 'String', 'temperature (deg C)');
  figures_grid.profiles_ctd.plotopts.ylabel(1) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd.plotopts.title(1) = setfield(default_title, 'String', 'Temperature profiles');
  figures_grid.profiles_ctd.dataopts(2).mdata = 'salinity';
  figures_grid.profiles_ctd.dataopts(2).ydata = 'depth';
  figures_grid.profiles_ctd.plotopts.xlabel(2) = setfield(default_label, 'String', 'salinity (PSU)');
  figures_grid.profiles_ctd.plotopts.ylabel(2) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd.plotopts.title(2) = setfield(default_title, 'String', 'Salinity profiles');
  figures_grid.profiles_ctd.dataopts(3).mdata = 'density';
  figures_grid.profiles_ctd.dataopts(3).ydata = 'depth';
  figures_grid.profiles_ctd.plotopts.xlabel(3) = setfield(default_label, 'String', 'density (kg m-1)');
  figures_grid.profiles_ctd.plotopts.ylabel(3) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd.plotopts.title(3) = setfield(default_title, 'String', 'Density profiles');
  figures_grid.profiles_ctd.plotopts.axsprops(1:3) = default_axes;
  figures_grid.profiles_ctd.prntopts = default_prntopts;
  figures_grid.profiles_ctd.prntopts.filename = 'ctd_profiles';
  figures_grid.profiles_ctd.prntopts.title = 'CTD profiles';
  figures_grid.profiles_ctd.prntopts.comment = 'Profile statistics of temperature, salinity and density, derived from raw CTD measurements.';

  figures_grid.profiles_ctd_corrected_thermal.plotfunc = @plotProfileStatistics;
  figures_grid.profiles_ctd_corrected_thermal.dataopts(1).mdata = 'temperature';
  figures_grid.profiles_ctd_corrected_thermal.dataopts(1).ydata = 'depth';
  figures_grid.profiles_ctd_corrected_thermal.plotopts.xlabel(1) = setfield(default_label, 'String', 'temperature (deg C)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.ylabel(1) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.title(1) = setfield(default_title, 'String', {'Temperature profiles'; ''});
  figures_grid.profiles_ctd_corrected_thermal.dataopts(2).mdata = 'salinity_corrected_thermal';
  figures_grid.profiles_ctd_corrected_thermal.dataopts(2).ydata = 'depth';
  figures_grid.profiles_ctd_corrected_thermal.plotopts.xlabel(2) = setfield(default_label, 'String', 'salinity (PSU)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.ylabel(2) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.title(2) = setfield(default_title, 'String', {'Salinity profiles'; '(corrected thermal lag)'});
  figures_grid.profiles_ctd_corrected_thermal.dataopts(3).mdata = 'density_corrected_thermal';
  figures_grid.profiles_ctd_corrected_thermal.dataopts(3).ydata = 'depth';
  figures_grid.profiles_ctd_corrected_thermal.plotopts.xlabel(3) = setfield(default_label, 'String', 'density (kg m-1)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.ylabel(3) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_ctd_corrected_thermal.plotopts.title(3) = setfield(default_title, 'String', {'Density profiles'; '(corrected thermal lag)'});
  figures_grid.profiles_ctd_corrected_thermal.plotopts.axsprops(1:3) = default_axes;
  figures_grid.profiles_ctd_corrected_thermal.prntopts = default_prntopts;
  figures_grid.profiles_ctd_corrected_thermal.prntopts.filename = 'ctd_profiles_corrected_thermal';
  figures_grid.profiles_ctd_corrected_thermal.prntopts.title = 'CTD profiles';
  figures_grid.profiles_ctd_corrected_thermal.prntopts.comment = 'Profile statistics of temperature, salinity and density, derived from CTD measurements with thermal lag corrections.';

  figures_grid.profiles_flntu.plotfunc = @plotProfileStatistics;
  figures_grid.profiles_flntu.dataopts(1).mdata = 'chlorophyll';
  figures_grid.profiles_flntu.dataopts(1).ydata = 'depth';
  figures_grid.profiles_flntu.plotopts.xlabel(1) = setfield(default_label, 'String', 'chlorophyll (ug l-1)');
  figures_grid.profiles_flntu.plotopts.ylabel(1) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_flntu.plotopts.title(1) = setfield(default_title, 'String', 'Chlorophyll profiles');
  figures_grid.profiles_flntu.dataopts(2).mdata = 'turbidity';
  figures_grid.profiles_flntu.dataopts(2).ydata = 'depth';
  figures_grid.profiles_flntu.plotopts.xlabel(2) = setfield(default_label, 'String', 'turbidity (NTU)');
  figures_grid.profiles_flntu.plotopts.ylabel(2) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_flntu.plotopts.title(2) = setfield(default_title, 'String', 'Turbidity profiles');
  figures_grid.profiles_flntu.plotopts.axsprops(1:2) = default_axes;
  figures_grid.profiles_flntu.prntopts = default_prntopts;
  figures_grid.profiles_flntu.prntopts.filename = 'flntu_profiles';
  figures_grid.profiles_flntu.prntopts.title = 'Chlorohpyll and turbidity profiles';
  figures_grid.profiles_flntu.prntopts.comment = 'Profile statistics of chlorophyll and turbidity.';

  figures_grid.profiles_bbfl2.plotfunc = @plotProfileStatistics;
  figures_grid.profiles_bbfl2.dataopts(1).mdata = 'chlorophyll';
  figures_grid.profiles_bbfl2.dataopts(1).ydata = 'depth';
  figures_grid.profiles_bbfl2.plotopts.xlabel(1) = setfield(default_label, 'String', 'chlorophyll (ug l-1)');
  figures_grid.profiles_bbfl2.plotopts.ylabel(1) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_bbfl2.plotopts.title(1) = setfield(default_title, 'String', 'Chlorophyll profiles');
  figures_grid.profiles_bbfl2.dataopts(2).mdata = 'cdom';
  figures_grid.profiles_bbfl2.dataopts(2).ydata = 'depth';
  figures_grid.profiles_bbfl2.plotopts.xlabel(2) = setfield(default_label, 'String', 'CDOM (ppb)');
  figures_grid.profiles_bbfl2.plotopts.ylabel(2) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_bbfl2.plotopts.title(2) = setfield(default_title, 'String', 'CDOM profiles');
  figures_grid.profiles_bbfl2.plotopts.axsprops(1:2) = default_axes;
  figures_grid.profiles_bbfl2.prntopts = default_prntopts;
  figures_grid.profiles_bbfl2.prntopts.filename = 'bbfl2_profiles';
  figures_grid.profiles_bbfl2.prntopts.title = 'Chlorohpyll and CDOM profiles';
  figures_grid.profiles_bbfl2.prntopts.comment = 'Profile statistics of chlorophyll and CDOM.';

  figures_grid.profiles_oxygen.plotfunc = @plotProfileStatistics;
  figures_grid.profiles_oxygen.dataopts(1).mdata = 'oxygen_concentration';
  figures_grid.profiles_oxygen.dataopts(1).ydata = 'depth';
  figures_grid.profiles_oxygen.plotopts.xlabel(1) = setfield(default_label, 'String', 'O2 concentration (umol l-1)');
  figures_grid.profiles_oxygen.plotopts.ylabel(1) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_oxygen.plotopts.title(1) = setfield(default_title, 'String', 'O2 concentration profiles');
  figures_grid.profiles_oxygen.dataopts(2).mdata = 'oxygen_saturation';
  figures_grid.profiles_oxygen.dataopts(2).ydata = 'depth';
  figures_grid.profiles_oxygen.plotopts.xlabel(2) = setfield(default_label, 'String', 'O2 saturation (%)');
  figures_grid.profiles_oxygen.plotopts.ylabel(2) = setfield(default_label, 'String', 'depth (m)');
  figures_grid.profiles_oxygen.plotopts.title(2) = setfield(default_title, 'String', 'O2 saturation profiles');
  figures_grid.profiles_oxygen.plotopts.axsprops(1:2) = default_axes;
  figures_grid.profiles_oxygen.prntopts = default_prntopts;
  figures_grid.profiles_oxygen.prntopts.filename = 'oxygen_profiles';
  figures_grid.profiles_oxygen.prntopts.title = 'Oxygen profiles';
  figures_grid.profiles_oxygen.prntopts.comment = 'Profile statistics of oxygen concentration and saturation.';

  close(hfig);
  
end
