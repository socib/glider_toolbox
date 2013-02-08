function dba_file_full = xbd2dba(dbd_files, dba_file, varargin)
%XBD2DBA  Slocum xbd to ascii file conversion using external program provided by WRC.
%
%  DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE) converts the binary file(s) 
%  named by string or string cell array DBD_FILES (xxx.[smdtne]bd files) to the 
%  corresponding text representation in the ascii file named by string DBA_FILE,
%  and returns the absolute path of the generated file in string DBA_FILE_FULL.
%  The conversion is done invocating the system program 'dbd2asc' provided
%  by the Webb Research Company with the contents of DBD_FILES as argument,
%  and capturing its output to DBA_FILE. The call is done in the current 
%  directory through the function SYSTEM (this may be relevant for the cache 
%  directory involved in the conversion).
%
%  DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE, OPT1, VAL1, ...) accepts the
%  following set of options to modify the default behaviour:
%    'program': string with the conversion program command name, including the
%      path if needed. This is useful if the 'dbd2asc' program has been renamed
%      or it is not in your system path. Default value is 'dbd2asc'.
%    'cache': string with the cache directory to use. It will be passed as the -c
%      option value in the conversion command call. By default the -c option
%      will not be used.
%    'options': string to with extra to the program call. It will be placed into 
%      the command just before the input file names (useful for passing options
%      like '-k' or '-o'). Default value is empty.
%
%  Notes:
%    This function is intended to allow Slocum binary file conversion from
%    MATLAB/Octave without having to fall back to a system terminal.
%
%    Input file strings are passed to the command line as they are, 
%    so they may contain glob patterns to be expanded by the underlying shell.
%
%  Examples:
%    % Convert a simple file.
%    dbd_file = 'happyglider-1970-000-0-0.sbd'
%    dba_file = 'happyglider-1970-000-0-0-sbd.dba'
%    dba_file_full = xbd2dba(dbd_file, dba_file)
%    % Convert all navigation files of the same mission in current directory,
%    % using it as cache directory and setting the path of the dbd2asc program.
%    dbd_files = 'happyglider-1970-000-0-*.[smd]bd'
%    dba_file = 'happyglider-1970-000-0-x-xbd.dba'
%    dba_file_full = xbd2dba(dbd_file, dba_file, 'cache', pwd(), ...
%                            'program', '~/bin/dbd2asc')
%
%  See also:
%    DBACAT
%    DBAMERGE
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 6, nargin, 'struct'));
  
  %% Set option values.
  program_dbd2asc = 'dbd2asc';
  use_cache_dir = false;
  extra_options = '';
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'program'
        program_dbd2asc = val;
      case 'cache'
        use_cache_dir = true;
        cache_dir = val;
      case 'options'
        extra_options = val;
      otherwise
        error('glider_toolbox:xbd2ascii:InvalidOption', 'Invalid option: %s.', opt);
    end
  end
  
  
  %% Check for a single input file.
  if ischar(dbd_files)
    input_file_list = cellstr(dbd_files);
  else
    input_file_list = dbd_files;
  end
  input_str = [sprintf('%s ', input_file_list{1:end-1}) input_file_list{end}];
 
  
  %% Build command and execute it.
  % Note that shell redirection could be used here to produce the file inplace 
  % from the command line. However, on errors (e.g. missing .cac files) this 
  % would produce an empty file that should be removed afterwards. To prevent
  % this, capture the output of the dbd2asc in a string and write it to a file
  % only when conversion succeeds.
  if use_cache_dir
    cmd_str = [program_dbd2asc ' -c ' cache_dir ' ' extra_options ' ' input_str];
  else
    cmd_str = [program_dbd2asc ' ' extra_options ' ' input_str];
  end
  [status, cmd_output] = system(cmd_str);
  if status~=0
    error('glider_toolbox:xbd2ascii:SystemCallError', ...
          'Error executing call: %s\n%s', cmd_str, cmd_output);
  end
  
  
  %% Create base directory of target file if needed.
  [dba_dir, ~, ~] = fileparts(dba_file);
  if ~exist(dba_dir, 'dir')
    [success, message] = mkdir(dba_dir);
    if ~success
      error('glider_toolbox:xbd2ascii:AsciiDirectoryError', ...
            'Error creating target directory: %s.', message);
    end
  end
  
  %% Write output of conversion command to the file.
  [fid, fid_msg] = fopen(dba_file, 'w');
  if fid < 0
    error('glider_toolbox:xbd2ascii:WriteFileError', ...
          'Error creating target file: %s.', fid_msg);
  end
  fprintf(fid, '%s', cmd_output);
  fclose(fid);
  
   
  %% Return the absolute name of the produced file.
  [status, att_output, ~] = fileattrib(dba_file);
  if status==0
    % We should never get here (if conversion succeed, ascii file must exist).
    error('glider_toolbox:xbd2ascii:AsciiFileError', ...
          'Conversion call succeed but problems with output file %s:\n%s.', ...
          dba_file, att_output);
  end
  dba_file_full = att_output.Name;  
  
end
