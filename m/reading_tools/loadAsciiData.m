function [meta_raw, data_raw, source_files] = loadAsciiData( input_path, glider_type, start_utc, file_options, varargin )
% LOADASCIIDATA 
%
%  Syntax: 
%       [META_RAW, DATA_RAW, SOURCE_FILES] = ...
%            LOADASCIIDATA( INPUT_PATH, GLIDER_TYPE, START_UTC, FILE_OPTIONS)
%       [META_RAW, DATA_RAW, SOURCE_FILES] = ...
%            LOADASCIIDATA( INPUT_PATH, GLIDER_TYPE, START_UTC, FILE_OPTIONS, 'END_UTC', END_UTC)
%
%  Description:
%    LOADASCIIDATA reads ascii files with glider data from Slocum,
%    Seaglider or SeaExplorer and creates two arrays containing the
%    metadata and data from the files. It also creates a list of the files
%    that were read during the process.
%
%  Input:
%    INPUT_PATH: Location where the raw xdb files are in the local drive.
%    GLIDER_TYPE: Glider type may be slocum_g1, slocum_g2 or seaglider. It
%      is used to select the dockserver retrieval method.
%    START_UTC: initial date of the period of interest.
%    FILE_OPTIONS: struct with the parameters that control the files to
%      load and which files and data should. These struc shoudl contain the
%      parameters needed by LOADSLOCUMDATA, LOADSEAGLIDERDATA or
%      LOADSEAEXPLORER accordingly. 
%
%  Options:
%    START_UTC: End date of the period of interest. Default is current date.
%
%  Ouput:
%    
%    DATA_RAW should be a struct in the format returned by where each field
%      is a vector sequence from the sensor or variable with the same name.
%    META_RAW should be the struct with the metadata required for the preprocessing. 
%
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
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

    narginchk(4, 6);
    
    options.end_utc          = NaN;
    
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
        error('glider_toolbox:loadAsciiData:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:loadAsciiData:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
    
    %% Load data from ascii deployment glider files.
    disp('Loading raw deployment data from text files...');
    load_start = utc2posixtime(start_utc);
    load_final = posixtime();
    if ~isnan(options.end_utc)
        load_final = utc2posixtime(options.end_utc);
    end
    try
        switch glider_type
          case {'slocum_g1' 'slocum_g2'}
            [meta_raw, data_raw] = ...
              loadSlocumData(input_path, ...
                             file_options.dba_name_pattern_nav, ...
                             file_options.dba_name_pattern_sci, ...
                             'timenav', file_options.dba_time_sensor_nav, ...
                             'timesci', file_options.dba_time_sensor_sci, ...
                             'sensors', file_options.dba_sensors, ...
                             'period', [load_start load_final], ...
                             'format', 'struct');
            source_files = {meta_raw.headers.filename_label};
          case 'seaglider'
            [meta_raw, data_raw] = ...
              loadSeagliderData(input_path, ...
                                file_options.log_name_pattern, ...
                                file_options.eng_name_pattern, ...
                                'columns', file_options.eng_columns, ...
                                'params' , file_options.log_params, ...
                                'period', [load_start load_final], ...
                                'format', 'merged');
            source_files = meta_raw.sources;
          case {'seaexplorer'}
            [meta_raw, data_raw] = ...
              loadSeaExplorerData(input_path, ...
                                  file_options.gli_name_pattern, ...
                                  file_options.pld_name_pattern, ...
                                  'timegli', file_options.gli_time, ...
                                  'timepld', file_options.pld_time, ...
                                  'format', 'struct');
            source_files = meta_raw.sources;
          otherwise
            warning('glider_toolbox:loadAsciiData:InvalidGliderType', ...
                    'Unknown glider type: %s.', glider_type);
        end
    catch exception
        disp('Error loading raw data:');
        disp(getReport(exception, 'extended'));
    end

end

