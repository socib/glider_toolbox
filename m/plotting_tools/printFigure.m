function imginfo = printFigure(varargin)
%PRINTFIGURE  Print figure to image file with metadata.
%
%  Syntax:
%    IMGINFO = PRINTFIGURE(OPTIONS)
%    IMGINFO = PRINTFIGURE(OPT1, VAL1, ...)
%    IMGINFO = PRINTFIGURE(H, OPTIONS)
%    IMGINFO = PRINTFIGURE(H, OPT1, VAL1, ...)
%
%  IMGINFO = PRINTFIGURE(OPTIONS) and IMGINFO = PRINTFIGURE(OPT1, VAL1, ...)
%  print current figure to image file according to given options and return a
%  struct IMGINFO with information about the generated image file.
%  Options may be given either as key-value pairs OPT1, VAL1 ... or in a struct
%  OPTIONS with field names as option keys and field values as option values.
%  Recognized options are:
%    DIRNAME: image file directory.
%      String with the path of the directory of the resulting image file.
%      It may be absolute or relative to the current directory reported by PWD.
%      Default value: '' (empty, use current directory)
%    FILENAME: image file name without extension.
%      String with name of the resulting image file without path prefix nor
%      extension.
%      Default value: sprintf('figure%03d', h) where h is the figure handle
%    FORMAT: image file format (extension)
%      String with the extension of the resulting image file (no leading dot).
%      It also specifies the image format. Any format recognized by the program 
%      'convert' in the ImageMagick suite may be used. See note on format below.
%      Default value: 'eps'
%    RESOLUTION: image resolution in dots per inch.
%      Positive integer with the resolution of the resulting image file in dpi.
%      See note on image size below.
%      Default value: 72
%    DATE: image time stamp.
%      String with the value of the 'date' property of the resulting image file.
%      Some image formats might not support it. Usually it is the creation date.
%      Default value: datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')
%    TITLE: image title label.
%      String with the value of the 'title' property of the resulting image
%      file. Some image formats might not support it.
%      Default value: ''
%    COMMENT: image description comment.
%      String with the value of the 'comment' property of the resulting image
%      file. Some image formats might not support it. It should describe the
%      figure contents.
%      Default value: ''
%    DRIVER: driver to print intermediate vector image file.
%      String setting whether the intermediate vector image file should be 
%      printed using a mono or color driver. It should be one of:
%        'eps'  : mono
%        'eps2' : mono
%        'epsc' : color
%        'epsc2': color
%      See note on format below.
%      Default value: 'epsc2'
%    RENDER: renderer to use when printing intermediate vector file.
%      String setting which renderer should be used when printing the
%      intermediate vector image file. Any renderer supported by function PRINT
%      is allowed. If empty, no renderer option is set when calling PRINT, and
%      the renderer is automatically selected either from figure properties or
%      depending on figure contents.
%      Default value: '' (renderer automatically selected)
%  Returned struct IMGINFO contains information about the figure and the 
%  generated image. It has the following fields:
%    TITLE: string with the image label (taken from options).
%    COMMENT: string with the image comment (taken from options).
%    DATE: string with the image timestamp (taken from options).
%    FULLFILE: string with the absolute path of the generated image file.
%    FILENAME: string with the image base file name (taken from options).
%    DIRNAME: string with the image directory name (taken from options).
%    FORMAT: string with the format extension (taken from options).
%    RESOLUTION: scalar with the image resolution in dots per inch (taken from options).
%    WIDTH: scalar with the image width (taken from the figure handle).
%    HEIGHT: scalar with the image height (taken from the figure handle).
%    UNITS: string with the image size units (taken from the figure handle).
%
%  IMGINFO = PRINTFIGURE(H, ...) prints figure given by figure handle H instead
%  of current figure.
%
%  Notes:
%    This function is inspired by function PRINTIMAGE by Tomeu Garau. He is the
%    true glider man. Main changes are:
%      - Changed input syntax to support output parameter setting.
%      - Changed output to return image information.
%      - Added metadata to generated image file.
%      - Removed thumbnail generation.
%
%    Due to quality limitations when printing to some output formats in MATLAB
%    (like png), the image file is generated first printing the corresponding 
%    figure to eps format with PRINT, and then calling the program 'convert' 
%    from ImageMagick suite through SYSTEM to convert it to the final format 
%    and add metadata tags. If the final format is eps, no conversion is
%    performed. Since eps does not seem to support metadata tags, the program is
%    not invoked at all.
%
%    The resulting image size, either in pixel or metric units, is governed by 
%    the resolution option and the figure position properties 'PaperPosition'
%    and 'PaperUnits'.
%
%    The resulting image file path is build calling the function FULLFILE with 
%    the value of the options DIRNAME, FILENAME and FORMAT.
%
%  Examples:
%    hfig = figure('PaperUnits', 'inches', 'PaperPosition', [0 0 6.83 5.12])
%    x = -pi:.1:pi;
%    y = sin(x);
%    plot(x,y)
%    options = struct()
%    options.dirname = 'images'
%    options.filename = 'example_figure'
%    options.format = 'png'
%    options.resolution = 150
%    options.date = datestr(now(), 31)
%    options.title = 'Example plot'
%    options.comment = 'Example 6.83x5.12 inch figure printed to png at 150 dpi (approx. 1024x768 pixels)'
%    imginfo = printFigure(hfig, options)
%
%  See also:
%    SYSTEM
%    PRINT
%    GCF
%    FULLFILE
%    POSIXTIME
%    
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  % No argument number checking since any number of arguments is allowed.

  %% Get optional figure handle and option arguments.
  if (nargin > 0) && isscalar(varargin{1}) && ishghandle(varargin{1})
    args = varargin(2:end);
    hfig = figure(varargin{1});
  else
    args = varargin;
    hfig = gcf();
  end
  
  
  %% Set plot options and default values.
  options = struct();
  options.dirname = pwd();
  options.filename = sprintf('figure%03d', hfig);
  options.format = 'eps';
  options.resolution = 72;
  options.date = datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00');
  options.title = '';
  options.comment = '';
  options.driver = 'epsc2';
  options.render = 'painters'; 
  
  
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
    error('glider_toolbox:printFigure:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(option_key_list)
    opt = lower(option_key_list{opt_idx});
    val = option_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:printFigure:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end

  
  %% Create image directory if needed.
  % MATLAB does not provide a proper way to check if a relative path points to
  % an existing directory (EXIST checks for existance in the whole load path).
  [status, attrout] = fileattrib(options.dirname);
  if ~status
    [success, message] = mkdir(options.dirname);
    if ~success
      error('glider_toolbox:printFigure:ImageDirectoryError', ...
            'Could not create directory %s: %s.', options.dirname, message);
    end
  elseif ~attrout.directory
    error('glider_toolbox:printFigure:ImageDirectoryError', ...
          'Not a directory: %s.', options.dirname);
  end
  
  
  %% Print figure to intermediate vector image file and convert it to final format.
  fullfile_eps = fullfile(options.dirname, [options.filename '.eps']);
  fullfile_ext = fullfile(options.dirname, [options.filename '.' options.format]);
  resdpiopt = ['-r' num2str(options.resolution)];
  driveropt = ['-d' options.driver];
  renderopt = '';
  if ~isempty(options.render)
    renderopt = ['-' options.render];
  end
  looseopt = '-loose'; % needed to create an uncropped image (eps bounding box better matches figure position)
  print(hfig, resdpiopt, renderopt, driveropt, looseopt, fullfile_eps);
  if ~strcmpi(options.format, 'eps')
    [failure, output] = system( ...
        ['convert' ...
         ' -density ' num2str(options.resolution) ... 
         ' ' fullfile_eps ...
         ' -set date ''' options.date '''' ...
         ' -set label ''' options.title '''' ...
         ' -set comment ''' options.comment ''''  ...
         ' ' fullfile_ext ';'] );
     if failure
       error('glider_toolbox:printFigure:ConvertError', ...
             'Command convert failed (eps file preserved): %s.', output);
     else
       delete(fullfile_eps);
     end
  end
  
  
  %% Report image information with absolute name of the generated file.
  [status, attrout, ~] = fileattrib(fullfile_ext);
  if status == 0
    % We should never get here (if image creation succeed, file must exist).
    error('glider_toolbox:printFigure:ImageFileError', ...
          'Image generation succeed but problems with image file %s: %s.', ...
          fullfile_ext, attrout);
  end
  hfigpaperpos = get(hfig, 'PaperPosition');
  hfigpaperuts = get(hfig, 'PaperUnits');
  imginfo.width = hfigpaperpos(3);
  imginfo.height = hfigpaperpos(4);
  imginfo.units = hfigpaperuts;
  imginfo.resolution = options.resolution;
  imginfo.title = options.title;
  imginfo.comment = options.comment;
  imginfo.date = options.date;
  imginfo.format = options.format;
  imginfo.filename = options.filename;
  imginfo.dirname = options.dirname;
  imginfo.fullfile = attrout.Name;

end
