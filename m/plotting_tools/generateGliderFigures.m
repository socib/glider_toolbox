function figure_info = generateGliderFigures(data, figure_list, varargin)
%GENERATEFIGURES  Generate figures from glider data.
%
%  Syntax:
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST)
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, OPTIONS)
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, OPT1, VAL1, ...)
%
%  Description:
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST) generate figures 
%    specified in struct FIGURE_LIST from glider data in struct DATA, and
%    returns information about generated image files in struct FIGURE_INFO.
%    FIGURE_LIST is a struct where each field specifies a figure to generate.
%    Field names are figure keys identifying each particular figure, and field 
%    values are structs with the following fields:
%      PLOTFUNC: plotting function.
%        String or function handle specifying which function should be used to
%        generate the figure plot.
%      DATAOPTS: data options.
%        Struct array with the mapping between data plot options (field names) 
%        and variables in struct DATA (field values). Each field value may be
%        either a string or a string cell array with a list of variable name 
%        choices in order of preference. The first variable present in DATA 
%        containing some valid value will be added to the plot options given in 
%        option PLOTOPTS, using the same field name given in DATAOPTS.
%      PLOTOPTS: plot style options.
%        Struct array with extra plot options to pass to plotting function given
%        in PLOTFUNC. It can also serve to specify default data option values.
%        These values will be used when none of the choices specified in
%         DATAOPTSis present in DATA.
%      PRNTOPTS: print options.
%        Struct array with print options to pass to function PRINTFIGURE.
%    FIGURE_INFO is a struct containing information about the generated figures.
%    Fields are named after corresponding figure keys, and their value is the
%    output of the call to PRINTFIGURE. Only figures whose data is available in 
%    struct DATA are generated, other figures are silently omitted.
%
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, OPT1, VAL1, ...) and
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, OPTIONS) allows
%    passing the following options of PRINTFIGURE in key-value pairs OPT1, 
%    VAL1... or in a struct OPTIONS with field names as option names and 
%    field values as option values:
%      DIRNAME: image file directory.
%        Default value: '' (empty, use current directory)
%      FORMAT: image file format (extension)
%        Default value: 'eps'
%      RESOLUTION: image resolution in dots per inch.
%        Default value: 72
%      DRIVER: driver to print intermediate vector image file.
%        Default value: 'epsc2'
%      RENDER: renderer to use when printing intermediate vector file.
%        Default value: [] (renderer automatically selected)
%      LOOSE: uncrop image when printing intermediate vector file.
%        Default value: 'loose' (produce uncropped images).
%      CONVERT: program to convert intermediate vector file to final format.
%        Default value: 'convert'
%      KEEPEPS: preserve intermediate vector file after conversion.
%        Default value: false
%      DATE: image generation timestamp.
%        Default value: datestr(now(), 31)
%
%  Examples:
%    % Assuming data is a processed glider data structure, 
%    % plot CTD trajectory data:
%    % Plot a transect vertical section of temperature.  
%    figure_list.temperature = struct();
%    figure_list.temperature.plotfunc = @plotTransectVerticalSection;
%    % Using covered planar distance as horizontal coordinate, and using
%    % depth from CTD pressure if available, otherwise use navigation depth.
%    figure_list.temperature.dataopts.xdata = 'distance_over_ground';
%    figure_list.temperature.dataopts.ydata = {'depth_ctd' 'depth'}; 
%    figure_list.temperature.dataopts.cdata = 'temperature';
%    % Add labels, title and some extra options.
%    figure_list.temperature.plotopts.sdata = 4;
%    figure_list.temperature.plotopts.xlabel = struct('String', 'distance (km)');
%    figure_list.temperature.plotopts.ylabel = struct('String', 'depth (m)');
%    figure_list.temperature.plotopts.clabel = struct('String', 'temperature (deg C)');
%    figure_list.temperature.plotopts.title = struct('String', 'In situ temperature');
%    figure_list.temperature.plotopts.axsprops = struct('Ydir', 'reverse');
%    % Set printing options.
%    figure_list.temperature.prntopts = struct('filename', 'ctd_temp', ...
%                                             'title',  'Temperature section', ...
%                                             'comment', 'Cross section of in situ measured temperature.');
%    % Make similar figures for salinity and density:
%    figure_list.salinity = struct();
%    figure_list.salinity.plotfunc = @plotTransectVerticalSection;
%    figure_list.salinity.dataopts.xdata = 'distance_over_ground';
%    figure_list.salinity.dataopts.ydata = {'depth_ctd' 'depth'}; 
%    figure_list.salinity.dataopts.cdata = 'salinity';
%    figure_list.salinity.plotopts.sdata = 4;
%    figure_list.salinity.plotopts.xlabel = struct('String', 'distance (km)');
%    figure_list.salinity.plotopts.ylabel = struct('String', 'depth (m)');
%    figure_list.salinity.plotopts.clabel = struct('String', 'salinity (PSU)');
%    figure_list.salinity.plotopts.title = struct('String', 'In situ salinity');
%    figure_list.salinity.plotopts.axsprops = struct('Ydir', 'reverse');
%    figure_list.salinity.prntopts = struct('filename', 'ctd_salt', ...
%                                           'title',  'Temperature section', ...
%                                           'comment', 'Cross section of in situ derived salinity.');
%    figure_list.density = struct();
%    figure_list.density.plotfunc = @plotTransectVerticalSection;
%    figure_list.density.dataopts.xdata = 'distance_over_ground';
%    figure_list.density.dataopts.ydata = {'depth_ctd' 'depth'}; 
%    figure_list.density.dataopts.cdata = 'density';
%    figure_list.density.plotopts.sdata = 4;
%    figure_list.density.plotopts.xlabel = struct('String', 'distance (km)');
%    figure_list.density.plotopts.ylabel = struct('String', 'depth (m)');
%    figure_list.density.plotopts.clabel = struct('String', 'density (PSU)');
%    figure_list.density.plotopts.title = struct('String', 'In situ density');
%    figure_list.density.plotopts.axsprops = struct('Ydir', 'reverse');
%    figure_list.density.prntopts = struct('filename', 'ctd_dens', ...
%                                          'title',  'Temperature section', ...
%                                          'comment', 'Cross section of in situ derived density.');
%    % Plot them at once to current directory, using default format.
%    figure_info = generateGliderFigures(data, figure_list)
%    % Plot them to desired image directory, selecting format and resolution.
%    figure_info = generateGliderFigures(data, figure_list, ...
%                                        'dirname', 'figures', ...
%                                        'format', 'png', ...
%                                        'resolution', 150)
%
%  See also:
%    PRINTFIGURE
%    PLOTTRANSECTVERTICALSECTION
%    PLOTTSDIAGRAM
%    PLOTPROFILESTATISTICS
%    CONFIGFIGURES
%    DATESTR
%    NOW
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

  error(nargchk(2, 20, nargin, 'struct'));
  
  
  %% Set plot options and default values.
  options.dirname = '';
  options.format = 'eps';
  options.resolution = 72;
  options.driver = 'epsc2';
  options.render = [];
  options.loose = 'loose';
  options.convert = 'convert';
  options.keepeps = false;
  options.date = datestr(now(), 31);
  
  
  %% Get options from extra arguments.
  % Parse option key-value pairs in any accepted call signature.
  if isscalar(varargin) && isstruct(varargin{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    option_key_list = fieldnames(varargin{1});
    option_val_list = struct2cell(varargin{1});
  elseif mod(numel(varargin), 2) == 0
    % Options passed as key-value argument pairs.
    option_key_list = varargin(1:2:end);
    option_val_list = varargin(2:2:end);
  else
    error('glider_toolbox:generateFigures:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:generateFigures:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Initialize output.
  figure_info = struct();
  
  
  %% Generate figures given in figure list, if data is available.
  figure_key_list = fieldnames(figure_list);
  for figure_key_idx = 1:numel(figure_key_list);
    % Get current figure key and settings.
    figure_key = figure_key_list{figure_key_idx};
    figure_plot = figure_list.(figure_key);
    % Set print options (figure options override global options).
    if isfield(figure_plot, 'prntopts')
      print_options = figure_plot.prntopts;
    else
      print_options = struct();  
    end
    print_option_field_list = fieldnames(options);
    for print_option_field_idx = 1:numel(print_option_field_list)
      print_option_field = print_option_field_list{print_option_field_idx};
      if ~isfield(print_options, print_option_field)
        print_options.(print_option_field) = options.(print_option_field);
      end
    end
    % Get plot function as function handle.
    plot_function = figure_plot.plotfunc;
    if ischar(figure_plot.plotfunc)
      plot_function = str2func(figure_plot.plotfunc);
    end
    % Get plot extra options.
    if isfield(figure_plot, 'plotopts')
      plot_options = figure_plot.plotopts;
    else
      plot_options = struct();
    end
    % Get plot data options.
    data_option_field_list = fieldnames(figure_plot.dataopts);
    data_options = repmat(struct(), size(figure_plot.dataopts));
    for data_option_idx = 1:numel(figure_plot.dataopts)
      dataopt = figure_plot.dataopts(data_option_idx);
      for data_option_field_idx = 1:numel(data_option_field_list)
        data_option_field = data_option_field_list{data_option_field_idx};
        data_options(data_option_idx).(data_option_field) = '';
        if ischar(dataopt.(data_option_field))
          data_option_value_list = {dataopt.(data_option_field)};
        else
          data_option_value_list = dataopt.(data_option_field);
        end
        for data_option_value_idx = 1:numel(data_option_value_list)
          data_option_value = data_option_value_list{data_option_value_idx};
          if isfield(data, data_option_value) ...
              && ~all(isnan(data.(data_option_value)(:)))
            data_options(data_option_idx).(data_option_field) = data_option_value;
            break
          end
        end
      end
    end
    % Generate figure if all data is there.
    % Data specified in dataopts should be in data options,
    % data_available = all(isfield(data_options, data_option_field_list)) ...
    %                  && ~any(any(cellfun(@isempty, struct2cell(data_options))));
    data_option_field_missing = ...
      any(cellfun(@isempty, struct2cell(data_options(:))), 2);               
    data_available = ...
      ~any(data_option_field_missing) || ...
       all(isfield(plot_options, data_option_field_list(data_option_field_missing)));
    if data_available
      fprintf('Generating figure %s with settings:\n', figure_key);
      fprintf('  plot function    : %s\n', func2str(plot_function));
      for data_option_field_idx = 1:numel(data_option_field_list)
        data_option_field = data_option_field_list{data_option_field_idx};
        data_option_value_str = cell(size(data_options));
        if isscalar(data_options)
            data_option_value = data_options.(data_option_field);
            if isempty(data_option_value)
              data_option_value_str{1} = ...
                sprintf('[%dx%d %s]', ...
                        size(plot_options.(data_option_field)), ...
                        class(plot_options.(data_option_field)));
            else
              data_option_value_str{1} = data_option_value;
              plot_options.(data_option_field) = data.(data_option_value);
            end
        else
          for data_option_idx = 1:numel(data_options)
            data_option_value = data_options(data_option_idx).(data_option_field);
            if isempty(data_option_value)
              data_option_value_str{data_option_idx} = ...
                sprintf('[%dx%d %s]', ...
                        size(plot_options.(data_option_field){data_option_idx}), ...
                        class(plot_options.(data_option_field){data_option_idx}));
            else
              data_option_value_str{data_option_idx} = data_option_value;
              plot_options.(data_option_field){data_option_idx} = ...
                data.(data_option_value);
            end
          end
        end
        fprintf('  %-16s :%s\n', ...
                data_option_field, sprintf(' %-16s', data_option_value_str{:}));
      end
      figure_handle = figure();
      try
        plot_function(figure_handle, plot_options);
        figure_info.(figure_key) = printfigure(figure_handle, print_options);
      catch exception
        fprintf('Figure generation failed:\n');
        disp(getReport(exception, 'extended'));
      end
      close(figure_handle);
    end
    
  end

end
