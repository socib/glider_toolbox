function [meta, data] = dba2mat(filename, varargin)
%DBA2MAT  Load data and metadata from a dba file.
%
%  Syntax:
%    [META, DATA] = DBA2MAT(FILENAME)
%    [META, DATA] = DBA2MAT(FILENAME, OPTIONS)
%    [META, DATA] = DBA2MAT(FILENAME, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = DBA2MAT(FILENAME) reads the dba file named by string
%    FILENAME, loading its metadata in struct META and its data in array DATA.
%
%    [META, DATA] = DBA2MAT(FILENAME, OPTIONS) and 
%    [META, DATA] = DBA2MAT(FILENAME, OPT1, VAL1, ...) accept the following 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS with 
%    field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with sensor readings in the column order
%            specified by the SENSORS metadata field.
%          'struct': DATA is a struct with sensor names as field names
%            and column vectors of sensor readings as field values.
%        Default value: 'array'
%      SENSORS: sensor filtering list.
%        String cell array with the names of the sensors of interest.
%        If given, only the sensors present in both the input data file and this
%        list will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all sensors
%        in the input data file will be present in output.
%        Default value: 'all' (do not perform sensor filtering).
%
%    META has the following fields based on the tags of the ascii header:
%      HEADERS: a struct with the ascii tags present in dba header with fields:
%        DBD_LABEL: ascii tag in dba header.
%        ENCODING_VER: ascii tag in dba header.
%        NUM_ASCII_TAGS: ascii tag in dba header.
%        ALL_SENSORS: ascii tag in dba header.
%        FILENAME: ascii tag in dba header.
%        THE8X3_FILENAME: ascii tag in dba header.
%        FILENAME_EXTENSION: ascii tag in dba header.
%        FILENAME_LABEL: ascii tag in dba header.
%        MISSION_NAME: ascii tag in dba header.
%        FILEOPEN_TIME: ascii tag in dba header.
%        SENSORS_PER_CYCLE: ascii tag in dba header.
%        NUM_LABEL_LINES: ascii tag in dba header.
%        NUM_SEGMENTS: ascii tag in dba header.
%        SEGMENT_FILENAMES: string cell array with the contents of
%           the ascii tags SEGMENT_FILENAME_0, ... , SEGMENT_FILENAME_N-1.
%      SENSORS: string cell array with the names of the sensors present
%        in the returned data array (in the same column order as the data).
%      UNITS: string cell array with the units of the sensors present
%        in the returned data array.
%      BYTES: array with the number of bytes of each sensor present
%        in the returned data array.
%      SOURCES: string cell array containing FILENAME.
%
%  Notes:
%    A description of the dba format may be found here:
%      <http://marine.rutgers.edu/~kerfoot/slocum/data/readme/wrc_doco/dbd_file_format.txt>
%
%  Examples:
%    % Retrieve data from all sensors as array:
%    [meta, data] = dba2mat('test.dba')
%    % Retrieve data from all sensors as struct:
%    [meta, data] = dba2mat('test.dba', 'format', 'struct')
%    % Retrieve data from time sensors as struct:
%    [meta, data] = dba2mat('test.dba', 'format', 'struct', ...
%                           'sensors', {'m_present_time' 'sci_m_present_time'})
%
%  See also:
%    XBD2DBA
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

  error(nargchk(1, 5, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.sensors = 'all';
  
  
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
    error('glider_toolbox:dba2mat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:dba2mat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  sensor_filtering = true;
  if ischar(options.sensors) && strcmp(options.sensors, 'all')
    sensor_filtering = false;
  end
  sensor_list = cellstr(options.sensors);
  
  
  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'r');
  if fid < 0
    error('glider_toolbox:dba2mat:FileError', fid_msg);
  end
  
  
  %% Process the file.
  try
    % Read mandatory header tags.
    num_mandatory_ascii_tags = 12;
    header_map = { ...
      'dbd_label'          'dbd_label: %s\n'
      'encoding_ver'       'encoding_ver: %s\n'
      'num_ascii_tags'     'num_ascii_tags: %d\n'
      'all_sensors'        'all_sensors: %d\n'
      'filename'           'filename: %s\n'
      'the8x3_filename'    'the8x3_filename: %s\n'
      'filename_extension' 'filename_extension: %s\n'
      'filename_label'     'filename_label: %s\n'
      'mission_name'       'mission_name: %s\n'
      'fileopen_time'      'fileopen_time: %s\n'
      'sensors_per_cycle'  'sensors_per_cycle: %d\n'
      'num_label_lines'    'num_label_lines: %d\n' };
    header_fields = header_map(:,1);
    header_fmtstr = [header_map{:,2}];
    header_values = textscan(fid, header_fmtstr, 1, 'ReturnOnError', false);
    header_struct = {header_fields{:}; header_values{:}};
    header_struct = struct(header_struct{:});
    
    % Read optional tags (number of segment files and segment file names).
    num_ascii_tags = header_values{3};
    if num_ascii_tags == num_mandatory_ascii_tags
      header_struct.num_segments = [];
      header_struct.segment_filenames = {};
    else
      num_segments_values = ...
        textscan(fid, 'num_segments: %d\n', 1, 'ReturnOnError', false);
      segment_format = repmat(sprintf('segment_filename_%%*u: %%s\n'), ...
                              1, num_segments_values{1});
      segment_values = textscan(fid, segment_format, 1, 'ReturnOnError', false);
      header_struct.num_segments = num_segments_values{1};
      header_struct.segment_filenames = vertcat(segment_values{:});
    end
    
    % Read label lines (sensor names, sensor units and bytes per sensor).
    num_sensors = header_struct.sensors_per_cycle;
    sensor_values = textscan(fid, '%s', num_sensors, 'ReturnOnError', false);
    unit_values   = textscan(fid, '%s', num_sensors, 'ReturnOnError', false);
    byte_values   = textscan(fid, '%d', num_sensors, 'ReturnOnError', false);
    
    % Build metadata structure.
    [~, name, ext] = fileparts(filename);
    meta.sources = {[name ext]};
    meta.headers = header_struct;
    meta.sensors = sensor_values{1};
    meta.units = unit_values{1};
    meta.bytes = byte_values{1};
    
    % Read sensor data filtering selected sensors if needed.
    sensor_format = repmat({'%f'}, meta.headers.sensors_per_cycle, 1);
    if sensor_filtering
      selected_sensors = ismember(meta.sensors, sensor_list);
      meta.sensors = meta.sensors(selected_sensors);
      meta.units = meta.units(selected_sensors);
      meta.bytes = meta.bytes(selected_sensors);
      sensor_format(~selected_sensors) = {'%*f'};
    end
    fmt_str = [sprintf('%s ', sensor_format{1:end-1}) sensor_format{end} '\n'];
    data_values = textscan(fid, fmt_str, 'ReturnOnError', false);
    
    % Convert data to desired output format.
    switch output_format
      case 'array'
        data = [data_values{:}];
      case 'struct'
        data = cell2struct(data_values, meta.sensors, 2);
      otherwise
        error('glider_toolbox:dba2mat:InvalidFormat', ...
              'Invalid output format: %s.', format)
    end
  catch exception
    % Close the file after a reading error.
    fclose(fid);
    rethrow(exception);
  end
  
  
  %% Close the file after successful reading.
  fclose(fid); 

end
