function [meta, data] = dba2mat(filename, varargin)
%DBA2MAT  Load data and metadata from a dba file.
%
%  [META, DATA] = DBA2MAT(FILENAME) reads the dba file named by string FILENAME,
%  loading its metadata in struct META and its data in array DATA.
%
%  [META, DATA] = DBA2MAT(FILENAME, OPT1, VAL1, ...) accepts the following
%  options:
%    'format': a string setting the format of the output DATA. Valid values are:
%      'array' (default): DATA is a matrix whith sensor readings as columns 
%         ordered as in the SENSORS metadata field.
%      'struct': DATA is a struct with sensor names as field names and column 
%         vectors of sensor readings as field values.
%    'sensors': a string cell array with the names of the sensors of interest.
%      If given, only sensors present in both the file and this list will be 
%      present in output.
%
%  META has the following fields based on the tags of the ascii header:
%    DBD_LABEL: ascii tag in dba header.
%    ENCODING_VER: ascii tag in dba header.
%    NUM_ASCII_TAGS: ascii tag in dba header.
%    ALL_SENSORS: ascii tag in dba header.
%    FILENAME: ascii tag in dba header.
%    THE8X3_FILENAME: ascii tag in dba header.
%    FILENAME_EXTENSION: ascii tag in dba header.
%    FILENAME_LABEL: ascii tag in dba header.
%    MISSION_NAME: ascii tag in dba header.
%    FILEOPEN_TIME: ascii tag in dba header.
%    SENSORS_PER_CYCLE: ascii tag in dba header.
%    NUM_LABEL_LINES: ascii tag in dba header.
%    NUM_SEGMENTS: ascii tag in dba header.
%    SEGMENT_FILENAMES: string cell array with the contents of the ascii tags
%      SEGMENT_FILENAME_0, ..., SEGMENT_FILENAME_N-1.
%    SENSORS: cell array of strings with the names of the sensors present in the
%      returned data array (in the same column order as the data).
%    UNITS: cell array of strings with the units of the sensors present in the
%      returned data array.
%    BYTES: array with the number of bytes of each sensor present in the 
%      returned data array.
%    SOURCES: cell array of strings containing FILENAME.
%
%  Notes:
%    A description of the dba format may be found here:
%      http://marine.rutgers.edu/~kerfoot/slocum/data/readme/wrc_doco/dbd_file_format.txt
%
%  Examples:
%    % Retrieve data from all sensors as array:
%    [meta, data] = dba2mat('test.dba')
%    % Retrieve data from all sensors as struct:
%    [meta, data] = dba2mat('test.dba', 'format', 'struct')
%    % Retrieve data from time sensors as struct:
%    time_sensors = {'m_present_time' 'sci_m_present_time'}
%    [meta, data] = dba2mat('test.dba', 'sensors', time_sensors)
%
%  See also:
%    DBACAT
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 5, nargin, 'struct'));
  
  %% Set option values.
  sensor_filtering = false;
  sensor_list = [];
  output_format = 'array';
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'format'
        output_format = val;
      case 'sensors'
        sensor_filtering = true;
        sensor_list = val;
      otherwise
        error('glider_toolbox:dba2mat:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end
  
  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'r');
  if fid < 0
    error('glider_toolbox:dba2mat:FileError', fid_msg)
  end
  
  %% Process the file.
  try
    % Read mandatory tags.
    num_mandatory_ascii_tags = 12;
    field_header_line_map = { ...
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
    header_fields = field_header_line_map(:,1);
    header_format_str = [field_header_line_map{:,2}];
    header_values = textscan(fid, header_format_str, 1, 'ReturnOnError', false);
    header_field_value_map = {header_fields{:}; header_values{:}};
    % Read optional tags (number of segment files and segment file names).
    num_ascii_tags = header_values{3};
    if num_ascii_tags == num_mandatory_ascii_tags
      segment_field_value_map = cell(0,2);
    else
      num_segments_values = ...
        textscan(fid, 'num_segments: %d\n', 1, 'ReturnOnError', false);
      segment_format = ...
        sprintf('segment_filename_%d: %%s\n', 0:num_segments_values{1}-1);
      segment_values = textscan(fid, segment_format, 1, 'ReturnOnError', false);
      segment_field_value_map =  {
        'num_segments'       [num_segments_values{:}]
        'segment_file_names' {vertcat(segment_values{:})} }';
    end
    % Read label lines (sensor names, sensor units and bytes per sensor).
    num_sensors = header_values{11};
    sensor_values = textscan(fid, '%s', num_sensors, 'ReturnOnError', false);
    unit_values   = textscan(fid, '%s', num_sensors, 'ReturnOnError', false);
    byte_values   = textscan(fid, '%d', num_sensors, 'ReturnOnError', false);
    label_field_value_map = {
      'sensors'  sensor_values'
      'units'    unit_values'
      'bytes'    byte_values' }';
    % Add extra fields not in dba header.
    [~, name, ext] = fileparts(filename);
    extra_field_value_map = {
      'sources'  {{[name ext]}}
    }';
    % Build metadata structure;
    meta_fill_value_map = [
      header_field_value_map ...
      segment_field_value_map ...
      label_field_value_map ...
      extra_field_value_map ...
    ];
    meta = struct(meta_fill_value_map{:});
    % Read sensor data filtering selected sensors if needed.
    if sensor_filtering
      selected_sensors = ismember(meta.sensors, sensor_list);
      meta.sensors = meta.sensors(selected_sensors);
      meta.units = meta.units(selected_sensors);
      meta.bytes = meta.bytes(selected_sensors);
      meta.num_sensors = numel(meta.sensors);
      sensor_format = cell(meta.num_sensors, 1);
      sensor_format(selected_sensors) = {'%f'};
      sensor_format(~selected_sensors) = {'%*f'};
    else
      meta.num_sensors = meta.sensors_per_cycle;
      sensor_format = cell(meta.num_sensors, 1);
      sensor_format(:) = {'%f'};
    end
    fmt_str = [sprintf('%s ', sensor_format{1:end-1}) sensor_format{end} '\n'];
    data_values = textscan(fid, fmt_str, 'ReturnOnError', false);
    switch lower(output_format)
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
