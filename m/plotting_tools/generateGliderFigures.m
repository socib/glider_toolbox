function figure_info = generateGliderFigures(data, figure_list, varargin)
%GENERATEFIGURES  One-line description here, please.
%
%  Syntax:
%    FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, VARARGIN)
%
%  FIGURE_INFO = GENERATEGLIDERFIGURES(DATA, FIGURE_LIST, VARARGIN) Detailed description here, please.
%
%  following fields:
%    PLOTFUNC: plotting function.
%      String or function handle specifying which function should be used to
%      generate the figure plot. 
%  Notes:
%
%  Examples:
%    figure_info = generateGliderFigures(data, figure_list, varargin)
%
%  See also:
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 12, nargin, 'struct'));
  
  
  %% Set plot options and default values.
  options.dirname = '';
  options.format = 'eps';
  options.resolution = 72;
  options.driver = 'epsc2';
  options.render = [];
  
  
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
    if ~isfield(print_options, 'dirname')
      print_options.dirname = options.dirname;
    end
    if ~isfield(print_options, 'format')
      print_options.format = options.format;
    end
    if ~isfield(print_options, 'resolution')
      print_options.resolution = options.resolution;
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
    for data_option_field_idx = 1:numel(data_option_field_list)
      data_option_field = data_option_field_list{data_option_field_idx};
      if ischar(figure_plot.dataopts.(data_option_field))
        data_option_value_list = {figure_plot.dataopts.(data_option_field)};
      else
        data_option_value_list = figure_plot.dataopts.(data_option_field);
      end
      for data_option_value_idx = 1:numel(data_option_value_list)
        data_option_value = data_option_value_list{data_option_value_idx};
        if isfield(data, data_option_value) ...
            && ~all(isnan(data.(data_option_value)))
          data_options.(data_option_field) = data_option_value;
          break;
        end
      end
    end
    data_available = all(isfield(data_options, data_option_field_list));
    % Generate figure if all data is there.
    if data_available
      fprintf('Generating figure %s with settings:\n', figure_key);
      fprintf('  plot function    : %s\n', func2str(plot_function));
      for data_option_field_idx = 1:numel(data_option_field_list)
        data_option_field = data_option_field_list{data_option_field_idx};
        data_option_value = data_options.(data_option_field);
        fprintf('  %-16s : %s\n', data_option_field, data_option_value);
        plot_options.(data_option_field) = data.(data_option_value);
      end
      figure_handle = figure();
      plot_function(figure_handle, plot_options);
      figure_info.(figure_key) = printFigure(figure_handle, print_options);
      close(figure_handle);
    end
    
  end

end
