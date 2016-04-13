function [meta, data] = sx2mat(filename, varargin)
%SX2MAT  Load data and metadata from a SeaExplorer data file.
%
%  Syntax:
%    [META, DATA] = SX2MAT(FILENAME)
%    [META, DATA] = SX2MAT(FILENAME, OPTIONS)
%    [META, DATA] = SX2MAT(FILENAME, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SX2MAT(FILENAME) reads the SeaExplorer file named by string
%    FILENAME, loading its metadata in struct META and its data in array DATA.
%
%    [META, DATA] = SX2MAT(FILENAME, OPTIONS) and 
%    [META, DATA] = SX2MAT(FILENAME, OPT1, VAL1, ...) accept the following 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS with 
%    field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a matrix with variable readings in the column order
%            specified by the VARIABLES metadata field.
%          'struct': DATA is a struct with variable names as field names
%            and column vectors of variable readings as field values.
%        Default value: 'array'
%      VARIABLES: variable filtering list.
%        String cell array with the names of the variables of interest.
%        If given, only variables present in both the input file and this list
%        will be present in output. The string 'all' may also be given,
%        in which case variable filtering is not performed and all variables
%        in the input file will be present in output.
%        Default value: 'all' (do not perform variable filtering).
%      TIME: timestamp variable list.
%        String cell array with the names of the time variables.
%        Variables in this list and also present in the data file are assumed
%        to be UTC timestamps in the format 'DD/MM/YYYY HH:MM:SS' or
%        'DD/MM/YYYY HH:MM:SS.FFF', and are converted to numeric values
%        (seconds since 1970-01-01 00:00:00 UTC) with DATENUM
%        and UTC2POSIXTIME.
%        Default value: {'Timestamp' 'PLD_REALTIMECLOCK'}
%
%    META has the following fields based on the tags of the ascii header:
%      VARIABLES: string cell array with the names of the variables present
%        in the returned data array (in the same column order as the data).
%      SOURCES: string cell array containing FILENAME.
%
%  Examples:
%    % Retrieve data from all variables as array:
%    [meta, data] = sx2mat('test.dat.0001')
%    % Retrieve data from all variables as struct:
%    [meta, data] = sx2mat('test.gli.0001', 'format', 'struct')
%    % Retrieve attitude data as struct:
%    [meta, data] = sx2mat('test.gli.0001', 'format', 'struct', ...
%                          'variables', {'Heading' 'Pitch' 'Roll'});
%
%  See also:
%    SXCAT
%    SXMERGE
%    DATENUM
%    UTC2POSIXTIME
%
%  Authors:
%    Frederic Cyr  <Frederic.Cyr@mio.osupytheas.fr>
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2016
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

  error(nargchk(1, 7, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.format = 'array';
  options.variables = 'all';
  options.time = {'Timestamp' 'PLD_REALTIMECLOCK'};
  
  
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
  variable_filtering = true;
  if ischar(options.variables) && strcmp(options.variables, 'all')
    variable_filtering = false;
  end
  variable_list = cellstr(options.variables);
  time_variable_list = cellstr(options.time);
  
  
  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'r');
  if fid < 0
    error('glider_toolbox:sx2mat:FileError', fid_msg);
  end
  
  
  %% Process the file.
  try
    % Read variable names in header line.
    header = fgetl(fid);
    variable_values = ...
      textscan(header, '%s', 'Delimiter', ';', 'ReturnOnError', false);
    
    % Build metadata structure.
    [~, name, ext] = fileparts(filename);
    meta.sources = {[name ext]};
    meta.variables = variable_values{1};
    
    % Read variable data filtering selected variables if needed.
    variable_format = repmat({'%f'}, length(meta.variables), 1);
    time_variable_select = ismember(meta.variables, time_variable_list);
    variable_format(time_variable_select) = {'%s'};
    if variable_filtering
      variable_select = ismember(meta.variables, variable_list);
      variable_format( time_variable_select & ~variable_select) = {'%*f'};
      variable_format(~time_variable_select & ~variable_select) = {'%*s'};
      meta.variables = variables(variable_select);
      time_variable_select = time_variable_select(variable_select);
    end
    data_values = textscan(fid, [variable_format{:} '%*s'], ...
                           'Delimiter', ';', 'ReturnOnError', false);
    
    % Convert timestamp variables to numeric format.
    for time_variable_idx = find(time_variable_select)
      data_timestamp = data_values{time_variable_idx};
      switch size(char(data_timestamp), 2)
        case 19
          timestamp_format = 'dd/mm/yyyy HH:MM:SS';
        case 23
          timestamp_format = 'dd/mm/yyyy HH:MM:SS.FFF';
        otherwise
          error('glider_toolbox:sx2mat:TimestampError', ...
                'Unknown timestamp format');
      end
      data_datenum = datenum(data_timestamp, timestamp_format);
      data_values{time_variable_idx} = utc2posixtime(data_datenum);
    end
    
    % Convert data to desired output format:
    switch output_format
      case 'array'
        data = [data_values{:}];
      case 'struct'
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
  
  
  %% Close the file after successful reading.
  fclose(fid); 

end
