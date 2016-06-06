function [meta, data] = sglog2mat(filename, varargin)
%SGLOG2MAT  Load data and metadata from a Seaglider log file.
%
%  Syntax:
%    [META, DATA] = SGLOG2MAT(FILENAME)
%    [META, DATA] = SGLOG2MAT(FILENAME, OPTIONS)
%    [META, DATA] = SGLOG2MAT(FILENAME, OPT1, VAL1, ...)
%
%  Description:
%    [META, DATA] = SGLOG2MAT(FILENAME, VARARGIN) reads the Seaglider log file 
%    named by string FILENAME, loading its metadata in struct META and its data 
%    in struct DATA.
%
%    [META, DATA] = SGLOG2MAT(FILENAME, OPTIONS) and 
%    [META, DATA] = SGLOG2MAT(FILENAME, OPT1, VAL1, ...) accept the following 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS
%    with field names as option keys and field values as option values:
%      FORMAT: data output format.
%        String setting the format of the output DATA. Valid values are:
%          'array': DATA is a struct with a scalar field for each scalar 
%            parameter and an array or cell array field for each non-scalar
%            parameter. Values of non-scalar parameters are in the column order
%            given by the corresponding field of the PARAMS metadata field.
%          'merged': DATA is a struct with a scalar or column vector field for
%            each scalar parameter or entry of a non-scalar parameter.
%            For scalar parameters, the field is named after the parameter,
%            while for non-scalar parameters the field names are the parameter
%            name and its field names, separated by underscore.
%          'struct': DATA is a struct with a scalar field for each scalar 
%            parameter and a struct array for each non-scalar parameter.
%            The fields of the non-scalar parameters are given by the 
%            corresponding field of the PARAMS metadata field.
%        Default value: 'array'
%      PARAMS: parameter filtering list.
%        String cell array with the names of the parameters of interest.
%        If given, only parameters present in both the input file and this list
%        will be present in output. For non-scalar parameters, the name 
%        of the identifier as it appears in the log line specifies including
%        all of its fields. Individual parameter fields are selected 
%        with the identifier and the name of the field separated by underscore
%        (e.g. 'GC_st_secs'). The string 'all' may also be given, in which case
%        parameter filtering is not performed and all parameters in input file
%        will be present in output.
%        Default value: 'all' (do not perform parameter filtering).
%
%    META has the following fields based on the tags of the header and the
%    content of some metaparameters:
%      HEADERS: a struct with the initial tags in the log file:
%        VERSION: string with the version tag in log header.
%        GLIDER : string with the glider id tag in log header.
%        MISSION: mission number tag in log header.
%        DIVE   : dive number tag in log header.
%        START  : start date and time tag in log header (month, day of month, 
%          year after 1900, hour, minute and second).
%      START_SECS: dive start time from header tag in POSIX time 
%        (seconds since 1970 Janyuay 01 00:00:00 UTC).
%      PARAMS: struct with the names of the fields of non-scalar parameters.
%        There is one field named after each parameter in data output, whose
%        value is a string cell array with the names for the parameter fields,
%        empty for scalar parameters. See note below for some exceptions.
%      GCHEAD: string cell array with the names of the fields for the GC lines
%        (in the same column order as in the output data).
%      DEVICES: string cell array with the names of the device fields 
%        for device lines (in the same column order as in the output data).
%      SENSORS: string cell array with the names of the sensor fields 
%        for sensor lines (in the same column order as in the output data).
%      SOURCES: string cell array containing FILENAME.
%
%  Notes:
%    This parsing is based on the information about the log files provided by
%    the Seaglider User's Guide, the Seaglider File Formats Manual and the
%    Parameter Reference Manual. The information there is not complete, so the
%    final result might be suboptimal.
%
%    The parsing is done according to the following general rules:
%      - The log data is preceded by a header identifying the dive.
%      - Each data line provides a parameter and is of the form:
%          $PARAM,VAL1,VAL2,...\n
%      - Some parameter names are not valid as identifiers.
%      - GPS parameters GPS1, GPS2 and GPS are gathered together.
%      - Some parameters are scalar (single valued).
%        Others are multi-valued and each value is treated as a parameter field.
%      - Field names has been chosen to reflect their meaning according to
%        the documentation cited above.
%      - If field names are not known, they are generated as sequentially as 
%        'fieldXX' where XX is the positional index of the correpsonding value.
%      - If field names are known, any missing values are treated as empty
%        strings ('') or invalid number (NaN).
%      - All parameter values are numeric except STATE, TGT_NAME, and the GPS
%        date and time fields, which are strings.
%      - There are some metaparameters that set the fields of other parameters: 
%        DEVICES line sets the fields of DEVICE_SECS and DEVICE_MAMPS.
%        SENSORS line sets the fields of SENSOR_SECS and SENSOR_MAMPS.
%        GCHEAD  line sets the fields of GC.
%
%  Examples:
%    [meta, data] = sglog2mat(filename)
%    [meta, data] = sglog2mat(filename, 'format', 'struct')
%    options = struct( ...
%      'params', {{'GPS_date' 'GPS_time' 'GPS_latf' 'GPS_lonf' 'CURRENT'}}, ...
%      'format', {'merged'});
%    [meta, data] = sglog2mat(filename, options)
%
%  See also:
%    SGENG2MAT
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
  options.params = 'all';
  
  
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
    error('glider_toolbox:sglog2mat:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:sglog2mat:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Set option flags and values.
  output_format = lower(options.format);
  all_params = false;
  if ischar(options.params) && strcmp(options.params, 'all')
    all_params = true;
  end
  param_list = cellstr(options.params);
  
  
  %% Open the file.
  [fid, fid_msg] = fopen(filename, 'r');
  if fid < 0
    error('glider_toolbox:sglog2mat:FileError', fid_msg);
  end
  
  
  %% Parse the file.
  try
    % Read header tags:
    header_map = { ...
      'version' 'version: %s\n'
      'glider'  'glider: %s\n'
      'mission' 'mission: %d\n'
      'dive'    'dive: %d\n'
      'start'   'start: %s\n' };
    header_fields = header_map(:,1);
    header_fmtstr = [header_map{:,2}];
    header_values = ...
      textscan(fid, header_fmtstr, 1, 'ReturnOnError', false, 'Delimiter', '');
    header_struct = {header_fields{:}; header_values{:}};
    header_struct = struct(header_struct{:});
    header_struct.start = sscanf(header_struct.start, '%d')';
    
    % Build metadata structure:
    %   - The filename (without base directory).
    %   - The log file header lines.
    %   - The dive start time as POSIX time.
    %   - Field names for composite parameters.
    %   - Non-constant metaparameters affecting other parameters.
    [~, name, ext] = fileparts(filename);
    meta.sources = {[name ext]};
    meta.headers = header_struct;
    meta.start_secs = ...
      utc2posixtime(datenum([header_struct.start(:, 3) + 1900 ...
                             header_struct.start(:, [1 2 4 5 6])]));
    meta.params = struct();
    meta.GCHEAD = cell(1,0);
    meta.DEVICES = cell(1,0);
    meta.SENSORS = cell(1,0);
    
    % Read log parameter data:
    % GPS parameters to store together and decompose:
    gps_field = 'GPSFIX';
    gps_param_list = {'GPS1' 'GPS2' 'GPS'};
    gps_member_list = {'ddmmyy' 'hhmmss' 'fixlat'  'fixlon' 'ttffix' 'hordop' 'ttafix' 'magvar'};
    
    % Parameters to rename (valid identifiers begin with a letter):
    rename_param_map = [ {
      '_CALLS'        'CALLS'
      '_XMS_NAKs'     'XMS_NAKs'  
      '_XMS_TOUTs'    'XMS_TOUTs'
      '_SM_DEPTHo'    'SM_DEPTHo'
      '_SM_ANGLEo'    'SM_ANGLEo'
      '24V_AH'        'x24V_AH'
      '10V_AH'        'x10V_AH' };
      gps_param_list' repmat({gps_field}, size(gps_param_list))'
    ];
    rename_param_list = rename_param_map(:,1);
    rename_field_list = rename_param_map(:,2);
        
    % Multi-valued parameters to decompose:
    mulval_param_map = [ {
      'SPEED_LIMITS'        {'min_spd' 'max_spd'}
      'TGT_LATLONG'         {'tgt_lat' 'tgt_lon'}
      'KALMAN_CONTROL'      {'spd_east' 'spd_nrth'}
      'KALMAN_X'            {'cur_mean_east' 'cur_diur_east' 'cur_semi_east' 'gld_wspd_east' 'delta_x'}
      'KALMAN_Y'            {'cur_mean_nrth' 'cur_diur_nrth' 'cur_semi_nrth' 'gld_wspd_nrth' 'delta_y'}
      'MHEAD_RNG_PITCHd_Wd' {'mag_head' 'tgt_rnge' 'ptch_ang' 'vert_vel'}
      'GC'                  {} % from $GCHEAD log line.
      'FINISH'              {'dpth' 'dens'}
      'STATE'               {'st_secs' 'status' 'result'}
      'SM_CCo'              {'st_secs' 'pmp_secs' 'pmp_amps' 'pmp_rets' 'pmp_errs' 'pmp_cnts' 'pmp_ccss'}
      'ALTIM_BOTTOM_PING'   {'dpth' 'rnge'}
      '24V_AH'              {'volts_min' 'ampsh_tot'}
      '10V_AH'              {'volts_min' 'ampsh_tot'}
      'DEVICE_SECS'         {} % from $DEVICES log line.
      'DEVICE_MAMPS'        {} % from $DEVICES log line.
      'SENSOR_SECS'         {} % from $SENSORS line.
      'SENSOR_MAMPS'        {} % from $SENSORS line.
      'DATA_FILE_SIZE'      {'bytes' 'samples'}
      'CFSIZE'              {'bytes_total' 'bytes_free'}
      'ERRORS'              {'bufoverrun' 'interrupts' ...
                             'fopen_errs' 'fwrit_errs' 'fclos_errs' 'fopen_rets' 'fwrit_rets' 'fclos_rets' ...
                             'ptch_errs' 'roll_errs' 'vbd_errs' 'ptch_rets' 'roll_rets' 'vbd_rets' ...
                             'gps_mis' 'gps_pps'}
      'CURRENT'             {'cur_spd' 'cur_dir' 'cur_val'} }
      gps_param_list'       repmat({gps_member_list}, size(gps_param_list))'
    ];
    mulval_param_list = mulval_param_map(:,1);
    mulval_member_list = mulval_param_map(:,2);
  
    % Non-numeric parameters:
    nonum_param_map = {
      'TGT_NAME'     @cellstr
      'GPS1'         @(v)([{''} v(1) num2cell(str2double(v(2:end)))])
      'GPS2'         @(v)([{''} v(1) num2cell(str2double(v(2:end)))])
      'GPS'          @(v)([v(1) v(2) num2cell(str2double(v(3:end)))])
      'STATE'        @(v)({str2double(v{1}) v{2:end}})
      'GCHEAD'       @cellstr
      'DEVICES'      @(v)(v(~strcmp(v, 'nil')))
      'SENSORS'      @(v)(v(~strcmp(v, 'nil')))
      'RECOV_CODE'   @cellstr
      'RESTART_TIME' @cellstr
    };
    nonum_param_list = nonum_param_map(:,1);
    nonum_funct_list = nonum_param_map(:,2);
    
    % Metadata parameters.
    meta_params_map = {
      'GCHEAD'  {'GC'}
      'DEVICES' {'DEVICE_SECS' 'DEVICE_MAMPS'}
      'SENSORS' {'SENSOR_SECS' 'SENSOR_MAMPS'}
    };
    meta_param_list = meta_params_map(:,1);
    meta_which_list = meta_params_map(:,2);
    
    % Read each line and parse its contents.
    textscan(fid, 'data:\n',  1, 'ReturnOnError', false);
    data = struct();
    while ~feof(fid)
      logline = fgetl(fid);
      parts = regexp(logline, ',', 'split');
      head = parts{1};
      rest = parts(2:end);
      if head(1) ~= '$'
        error('glider_toolbox:sglog2mat:BadDataLine', ...
              'Bad data line: %s.', logline);
      end
      param = head(2:end);
      % Do not use ISMEMBER, it is too slow (it is not designed for this use).
      i = find(strcmp(param, rename_param_list), 1);
      if i
        field = rename_field_list{i};
      else
        field = param;  
      end
      i = find(strcmp(param, nonum_param_list), 1);
      if i
        value_list = nonum_funct_list{i}(rest);
      else
        % This is 2.5x faster than STR2DOUBLE provided that numbers are real.
        value_list = sscanf(sprintf(' %s', rest{:}), '%f')';
      end
      i = find(strcmp(param, mulval_param_list), 1);
      if i
        member_list = mulval_member_list{i};
      else
        member_list = cell(0,1);
      end
      i = find(strcmp(param, meta_param_list), 1);
      if i
        which_param_list = meta_which_list{i};
        [~, mulval_map_index] = ...
          intersect(mulval_param_list, which_param_list);
        mulval_member_list(mulval_map_index) = {genvarname(value_list)};
        meta.(field) = value_list;
      else
        num_mems = numel(member_list);
        num_vals = numel(value_list);
        if num_vals < num_mems
          if isnumeric(value_list)
            value_list(num_vals+1:num_mems) = nan;
          else
            value_list(num_vals+1:num_mems) = {''};
          end
        elseif num_vals > 1 
          member_list(num_mems+1:num_vals) = ...
            cellstr(num2str((num_mems+1:num_vals)', 'field%02d'));
        end
        if all_params || any(strcmp(field, param_list))
          member_select = true;
        else
          % Avoid ISMEMBER and STRCAT, they decrease performance dramatically.
          % The alternative with CELLFUN is less efficient that the loop, too.
          %member_select = ismember(strcat(param, '_', member_list), param_list);
          member_select = false(size(member_list));
          for member_idx = 1:numel(member_list)
            member_select(member_idx) = ...
              any(strcmp([field '_' member_list{member_idx}], param_list));
          end
          member_list = member_list(member_select);
          value_list = value_list(member_select);
        end
        if any(member_select)
          if isfield(data, field)
            data.(field)(end+1, :) = value_list;
          else
            meta.params.(field) = member_list(:);
            data.(field) = value_list;
          end
        end
      end
    end
  catch exception
    % Close the file after a reading error.
    fclose(fid);
    rethrow(exception);
  end
  
  
  %% Close the file after successful reading.
  fclose(fid); 
  
  
  %% Convert data to desired format:
  switch output_format
    case 'array'
    case 'merged'
      field_list = fieldnames(data);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = data.(field);
        if ~isempty(member_list)
          for member_idx = 1:numel(member_list)
            member = member_list{member_idx};
            field_member = [field '_' member];
            value = value_list(:, member_idx);
            if iscell(value) && ~iscellstr(value)
              value = vertcat(value{:});
            end
            data.(field_member) = value;
          end
          data = rmfield(data, field);
        end
      end
    case 'struct'
      field_list = fieldnames(data);
      for field_idx = 1:numel(field_list)
        field = field_list{field_idx};
        member_list = meta.params.(field);
        value_list = data.(field);
        if ~isempty(member_list)
          if isnumeric(value_list)
            value_list = num2cell(value_list);
          end
          data.(field) = cell2struct(value_list, member_list, 2);
        end
      end
    otherwise
      error('glider_toolbox:sglog2mat:InvalidFormat', ...
            'Invalid output format: %s.', output_format)
  end

end
