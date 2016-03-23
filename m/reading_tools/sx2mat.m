function [meta, data] = sx2mat(filename, varargin)
%SX2MAT  Load data and metadata from a seaExplorer ascii file.
%
%  Syntax:
%    [META, DATA] = SX2MAT(FILENAME)
%    [META, DATA] = SX2MAT(FILENAME, OPTIONS)
%    [META, DATA] = SX2MAT(FILENAME, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SX2MAT(FILENAME) reads the sx file named by string 
%    FILENAME, loading its metadata in struct META and its data in array DATA.
%
%    [META, DATA] = SX2MAT(FILENAME, OPTIONS) and 
%    [META, DATA] = SX2MAT(FILENAME, OPT1, VAL1, ...) accept the following 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS with 
%    field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with sensor readings as columns ordered
%            as in the 'variables' metadata field.
%          'struct': DATA is a struct with sensor names as field names and
%            column vectors of sensor readings as field values.
%        Default value: 'array'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the sensors of interest. If given,
%        only the sensors present in both the input data file and this list
%        will be present in output. The string 'all' may also be given,
%        in which case sensor filtering is not performed and all sensors
%        in the input data file will be present in output.
%        Default value: 'all' (do not perform sensor filtering).
%
%    META has the following fields based on the tags of the ascii header:
%      HEADERS: a struct with the ascii tags present in sx header with fields:
%        VARIABLES_PER_CYCLE: ascii tag in sx header.
%        FILENAME: string cell array with the full path of the
%        ascii original files (same as SOURCES below) .
%      VARIABLES: string cell array with the names of the variables present
%        in the returned data array (in the same column order as the data).
%      UNITS: string cell array with the units of the sensors present
%        in the returned data array (EMPTY FOR NOW).
%      BYTES: array with the number of bytes of each sensor present
%        in the returned data array (EMPTY FOR NOW).
%      SOURCES: string cell array containing FILENAME.
%
%
%  Examples:
%    % Retrieve data from all sensors as array:
%    [meta, data] = sx2mat('test.dat.0001')
%    % Retrieve data from all sensors as struct:
%    [meta, data] = sx2mat('test.gli.0001', 'format', 'struct')
%    % Retrieve data from time sensors as struct (NOT TESTED!):
%    time_sensors = {'Posixtime' 'Posixtime'}
%    [meta, data] = sx2mat('test.gli.0001', 'variables', 'TimeStamp')
%
%  See also:
%    SXCAT
%    SXMERGE
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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
%  along with this program.  If not, see  <http://www.gnu.org/licenses/>.


  error(nargchk(1, 7, nargin, 'struct'));


  %% Set options and default values.
  options.format = 'array';
  options.variables = 'all';

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
      error('glider_toolbox:sx2mat:InvalidOptions', ...
            'Invalid optional arguments (neither key-value pairs nor struct).');
  end

  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
      opt = lower(opt_key_list{opt_idx});
      val = opt_val_list{opt_idx};
      if isfield(options, opt)
          options.(opt) = val;
      else
          error('glider_toolbox:sx2mat:InvalidOption', ...
                'Invalid option: %s.', opt);
      end
  end


  %% Set option flags and values.
  output_format = lower(options.format);
  sensor_filtering = true;
  if ischar(options.variables) && strcmp(options.variables, 'all')
      sensor_filtering = false;
  end
  sensor_list = cellstr(options.variables);


  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'rt');
  if fid < 0
      error('glider_toolbox:sx2mat:FileError', fid_msg);
  end

  %% Process the file.
  try
      % read header and fill variables
      header=fgetl(fid);
      sensor_values = strread(header,'%s','delimiter',';');
      [~, name, ext] = fileparts(filename);
      meta.sources = {[name ext]};
      meta.headers = {};
      meta.variables = sensor_values;
      meta.headers.variables_per_cycle = numel(sensor_values);
      meta.headers.filename = {filename};
      meta.units = repmat({'N/A'}, meta.headers.variables_per_cycle, 1);  % <------- should be fixed
      meta.bytes = repmat({'N/A'}, meta.headers.variables_per_cycle, 1);  % <------- should be fixed
      
      % fill 'data'
      % Read sensor data filtering selected variables if needed.
      sensor_format = repmat({'%f'}, meta.headers.variables_per_cycle, 1);
      if sensor_filtering
          selected_variables = ismember(meta.variables, sensor_list);
          meta.variables = meta.variables(selected_variables);
          meta.units = meta.units(selected_variables);
          meta.bytes = meta.bytes(selected_variables);
          sensor_format(~selected_variables) = {'%*f'};
      end

      fmt_str = [sprintf('%s ', sensor_format{1:end-1}) sensor_format{end} '\n'];
      fmt_str(1:2) = '%s';
      data_values = textscan(fid, fmt_str, 'ReturnOnError', false, 'headerlines', 1, 'delimiter', ';');

      % transform time stamp in posix vector
      Timestamp = data_values{1};
      if length(Timestamp{1}) == 19 % Nav files
          data_values{1} = (datenum(Timestamp, 'dd/mm/yyyy HH:MM:SS') ...
                            - datenum(1970,1,1))*86400;
      elseif length(Timestamp{1}) == 23 % Nav files
          data_values{1} = (datenum(Timestamp, 'dd/mm/yyyy HH:MM:SS.FFF') ...
                            - datenum(1970,1,1))*86400;
      else
          error('Timestamp format unknown!');        
      end
      
      meta.variables{1} = 'Posixtime';
      data = [data_values{:}];
      
      switch output_format
        case 'array'
          % nothing to do, done just above
        case 'struct' % <============================== to be tested!
          data = cell2struct(data_values, meta.variables, 2);
        otherwise
          error('glider_toolbox:sx2mat:InvalidFormat', ...
                'Invalid output format: %s.', format)
      end

  catch exception
      % Close the file after a reading error.
      fclose(fid);
      rethrow(exception);
  end

end
