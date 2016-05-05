function [meta, data] = sgeng2mat(filename, varargin)
%sgeng2mat  Load data and metadata from a Seaglider eng file.
%
%  Syntax:
%    [META, DATA] = sgeng2mat(FILENAME)
%    [META, DATA] = sgeng2mat(FILENAME, OPTIONS)
%    [META, DATA] = sgeng2mat(FILENAME, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = sgeng2mat(FILENAME, VARARGIN) reads the Seaglider eng file 
%    named by string FILENAME, loading its metadata in struct META and its data 
%    in struct DATA.
%
%    [META, DATA] = sgeng2mat(FILENAME, OPTIONS) and 
%    [META, DATA] = sgeng2mat(FILENAME, OPT1, VAL1, ...) accept the following 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS
%    with field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with data readings as columns ordered
%            as in the COLUMNS metadata field.
%          'struct': DATA is a struct with column names as field names
%            and column vectors of data columns as field values.
%        Default value: 'array'
%      COLUMNS: data column filtering list.
%        String cell array with the names of the data columns of interest
%        as reported in the COLUMNS metadata field (see note on column 
%        renaming). If given, only parameters present in both the input
%        file and this list will be present in output. The string 'all'
%        may also be given, in which case column filtering is not performed
%        and all columns in the input list will be present in output.
%        Default value: 'all' (do not perform column filtering).
%
%    META has the following fields based on the tags of the header and the
%    content of some metaparameters:
%      HEADERS: a struct with the initial tags in the eng file:
%        VERSION: string with the version tag in eng header.
%        GLIDER : string with the glider id tag in eng header.
%        MISSION: mission number tag in eng header.
%        DIVE   : dive number tag in eng header.
%        BASESTATION_VERSION: string with the basestation tag in eng header.
%        START  : start date and time tag in eng header (month, day of month, 
%          year after 1900, hour, minute and second).
%      START_SECS: dive start time from header tag in POSIX time 
%        (seconds since 1970 Janyuay 01 00:00:00 UTC).
%      COLUMNS: string cell array with the names of the columns in the returned 
%        data array (in the same column order as the data). See note on column
%        renaming.
%      SOURCES: string cell array containing FILENAME.
%
%  Notes:
%    This parsing is based on the information about the eng files provided by
%    the Seaglider User's Guide and the Seaglider File Formats Manual and the
%    Parameter Reference Manual. The information there is not complete, so the
%    final result might be suboptimal.
%
%    Some column names reported in the COLUMNS field of the eng file header
%    are not valid identifiers because they contain a dot character 
%    ('sbect.tempFreq'). They are renamed in the COLUMNS metadata field by 
%    replacing the dot character '.' by an underscore '_' ('sbect.tempFreq').
%    The columns header line is still available untouched in the COLUMNS field
%    of the HEADERS metadata field.
%
%  Examples:
%    [meta, data] = sgeng2mat(filename)
%    [meta, data] = sgeng2mat(filename, 'format', 'struct')
%    options = struct( ...
%      'columns', {{'elaps_t' 'depth' 'head' 'pitchAng' 'rollAng'}}, ...
%      'format', {'merged'});
%    [meta, data] = sgeng2mat(filename, options)
%
%  See also:
%    SGLOG2MAT
%    SGLOGCAT
%    SGENGCAT
%    SGENGLOGMERGE
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

  error(nargchk(1, 5, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.columns = 'all';
  
  
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
    error('glider_toolbox:sgeng2mat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sgeng2mat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  column_filter = true;
  if ischar(options.columns) && strcmp(options.columns, 'all')
    column_filter = false;
  end
  column_list = cellstr(options.columns);
  
  
  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'r');
  if fid < 0
    error('glider_toolbox:sgeng2mat:FileError', fid_msg);
  end
  
  
  %% Parse the file.
  try
    % Read header tags:
    header_map = { ...
      'version'             '%%version: %s\n'              1
      'glider'              '%%glider: %s\n'               1
      'mission'             '%%mission: %d\n'              1
      'dive'                '%%dive: %d\n'                 1
      'basestation_version' '%%basestation_version: %s\n'  1
      'start'               '%%start: %d %d %d %d %d %d\n' 6
      'columns'             '%%columns: %s\n'              1};
    header_fields = header_map(:,1);
    header_fmtstr = header_map(:,2);
    header_length = vertcat(header_map{:,3});
    % TEXTSCAN whould be useful here, but it fails on escaped '%' sign.
    % header_values = ...
    %  textscan([header_fmt_str{:}], 1, 'ReturnOnError', false, 'Delimiter', '');
    header_values = cell(size(header_fields));
    for header_field_idx = 1:numel(header_fields)
      [header_values{header_field_idx}, header_field_count] = ...
        fscanf(fid, header_fmtstr{header_field_idx}, ...
               [1, header_length(header_field_idx)]);
      if header_field_count < 1
        error('glider_toolbox:sgeng2mat:BadFileFormat', ...
              'Mismatch between file and header format (field %d).', ...
              header_field_index);
      end
    end
    header_struct = {header_fields{:}; header_values{:}};
    header_struct = struct(header_struct{:});
  
    % Build metadata structure:
    %   - The filename (without base directory).
    %   - The log file header lines.
    %   - The dive start time as POSIX time.
    %   - The list of names of data columns.
    [~, name, ext] = fileparts(filename);
    meta.sources = {[name ext]};
    meta.headers = header_struct;
    meta.start_secs = ...
      utc2posixtime(datenum([header_struct.start(:, 3) + 1900 ...
                             header_struct.start(:, [1 2 4 5 6])]));
    meta.columns = ...
      strrep(regexp(header_struct.columns, ',', 'split'), '.', '_')';
    
    % Read eng data columns filtering selected columns if needed:
    fscanf(fid, '%%data:\n');
    dataline_format = repmat({'%f'}, numel(meta.columns), 1);
    if column_filter
      column_filtering = ismember(meta.columns, column_list);
      meta.columns = meta.columns(column_filtering);
      dataline_format(~column_filtering) = {'%*f'};
    end
    format_str = ...
      [sprintf('%s ', dataline_format{1:end-1}) dataline_format{end} '\n'];
    data_values = textscan(fid, format_str, 'ReturnOnError', false);
    switch lower(output_format)
      case 'array'
        data = [data_values{:}];
      case 'struct'
        data = cell2struct(data_values, meta.columns, 2);
      otherwise
        error('glider_toolbox:sgeng2mat:InvalidFormat', ...
              'Invalid output format: %s.', output_format)
    end
  catch exception
    % Close the file after a reading error.
    fclose(fid);
    rethrow(exception);
  end
  
  
  %% Close the file after successful reading.
  fclose(fid); 

end
