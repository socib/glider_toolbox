function dba_file_full = xbd2dba(dbd_files, dba_file, varargin)
%XBD2DBA  Slocum xbd to ascii file conversion using external program provided by WRC.
%
%  Syntax:
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE)
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE, OPTIONS)
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE, OPT1, VAL1, ...)
%
%  Description:
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE) converts the binary file(s) 
%    named by string or string cell array DBD_FILES (xxx.[smdtne]bd files) 
%    to the corresponding text representation in the ascii file named by string
%    DBA_FILE, and returns the absolute path of the generated file in string
%    DBA_FILE_FULL. The conversion is done invocating the system program 
%    'dbd2asc' provided by the Webb Research Company with the contents of 
%    DBD_FILES as argument, and capturing its output to DBA_FILE.
%    The call is done in the current directory through the function SYSTEM 
%    (this may be relevant for the cache directory involved in the conversion).
%
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE, OPTIONS) and
%    DBA_FILE_FULL = XBD2DBA(DBD_FILES, DBA_FILE, OPT1, VAL1, ...) accept
%    the following options given in key-value pairs OPT1, VAL1... or in struct 
%    OPTIONS with field names as option keys and field values as option values:
%      CMDNAME: conversion program executable.
%        String with the conversion program command name, including the path
%        if needed. This is useful if the 'dbd2asc' program has been renamed
%        or it is not in your system path.
%        Default value: 'dbd2asc'.
%      CMDOPTS:
%        String with extra options to use in the program call.
%        It is placed into the command line just before the input file names.
%        This is useful for passing options like '-k' or '-o'. 
%        Default value: '' (no command options)
%      CACHE: cache directory.
%        String with the cache directory to use.
%        It is passed as the -c option value in the conversion command call.
%        If empty the -c option will not be used.
%        Default value: '' (do not use -c command option)
%
%  Notes:
%    This function is intended to allow Slocum binary file conversion from
%    MATLAB/Octave without having to fall back to a system terminal.
%
%    Input file strings are passed to the command line as they are, 
%    so they may contain glob patterns to be expanded by the underlying shell.
%
%  Examples:
%    % Convert a single file.
%    dbd_file = 'happyglider-1970-000-0-0.sbd'
%    dba_file = 'happyglider-1970-000-0-0-sbd.dba'
%    dba_file_full = xbd2dba(dbd_file, dba_file)
%    % Convert all navigation files of the same mission in current directory,
%    % using it as cache directory and setting the path of the dbd2asc program.
%    dbd_files = 'happyglider-1970-000-0-*.[smd]bd'
%    dba_file = 'happyglider-1970-000-0-x-xbd.dba'
%    dba_file_full = xbd2dba(dbd_file, dba_file, 'cache', pwd(), ...
%                            'cmdname', '~/bin/dbd2asc')
%
%  See also:
%    DBACAT
%    DBAMERGE
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

  error(nargchk(2, 8, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.cmdname = 'dbd2asc';
  options.cmdopts = '';
  options.cache = [];
  
  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:xbd2dba:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:xbd2dba:InvalidOption', ...
            'Invalid option: %s.', opt);
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
  cmd_name = options.cmdname;
  cmd_opts = options.cmdopts;
  cac_path = options.cache;
  if isempty(cac_path)
    cmd_str = [cmd_name ' ' cmd_opts ' ' input_str];
  else
    cmd_str = [cmd_name ' -c ' cac_path ' ' cmd_opts ' ' input_str];
  end
  [status, cmd_out] = system(cmd_str);
  if status ~= 0
    error('glider_toolbox:xbd2dba:SystemCallError', ...
          'Error executing call: %s\n%s.', cmd_str, cmd_out);
  end
  
  
  %% Create directory of target file if needed.
  % This seems to be the better way to check if a relative path points to
  % an existing directory (EXIST checks for existance in the whole load path).
  [dba_dir, ~, ~] = fileparts(dba_file);
  [status, attrout] = fileattrib(dba_dir);
  if ~status
    [success, message] = mkdir(dba_dir);
    if ~success
      error('glider_toolbox:xbd2dba:AsciiDirectoryError', ...
            'Could not create directory %s: %s.', dba_dir, message);
    end
  elseif ~attrout.directory
    error('glider_toolbox:xbd2dba:AsciiDirectoryError', ...
          'Not a directory: %s.', attrout.Name);
  end

  
  %% Write output of conversion command to the file.
  [fid, fid_msg] = fopen(dba_file, 'w');
  if fid < 0
    error('glider_toolbox:xbd2dba:WriteFileError', ...
          'Could not create file %s: %s.', dba_file, fid_msg);
  end
  fprintf(fid, '%s', cmd_out);
  fclose(fid);
  
   
  %% Return the absolute name of the produced file.
  [status, attrout, ~] = fileattrib(dba_file);
  if status==0
    % We should never get here (if conversion succeed, ascii file must exist).
    error('glider_toolbox:xbd2dba:AsciiFileError', ...
          'Conversion call succeed but problems with output file %s: %s.', ...
          dba_file, attrout);
  end
  dba_file_full = attrout.Name;  
  
end
