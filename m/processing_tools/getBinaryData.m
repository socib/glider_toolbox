function [ ] = getBinaryData( output_path, log_dir, glider_type, file_options, dockservers, varargin)
% GETBINARYDATA  Retrieves the raw data of a glider from the dockserver or path
%
%  Syntax:
%    GETBINARYDATA(OUTPUT_PATH, LOG_DIR, GLIDER_TYPE, ...
%                       FILE_OPTIONS, DOCKSERVERS)
%
%    GETBINARYDATA(OUTPUT_PATH, LOG_DIR, GLIDER_TYPE, ...
%                       START_UTC, FILE_OPTIONS, DOCKSERVERS, OPT1, VAL1, ...)
%
%  Description:
%    GETBINARYDATA wraps the GETDOCKSERVERFILES function to retrieve data
%    according to the glider time.  
%
%  Input:
%    OUTPUT_PATH: Location where the raw xdb files are downloaded in the local drive.
%    LOG_DIR: Location where the log files are downloaded in the local drive.
%    GLIDER_TYPE: Glider type may be slocum_g1, slocum_g2 or seaglider. It
%      is used to select the dockserver retrieval method.
%    FILE_OPTIONS: struct with the parameters that control the files to
%      retrieve, how they will  be converted, and which files and data should
%      be used in real time mode. 
%    DOCKSERVER is a struct with the fields needed by functions FTP or SFTP:
%      HOST: url as either fully qualified name or IP with optional port (string).
%      USER: user to access the dockserver if needed (string).
%      PASS: password of the dockserver if needed (string).
%      CONN: name or handle of connection type function, @FTP (default) or @SFTP.
%
%  Output: Binary files are downloaded from dockserver and copied in the output_path.
%
%  Options:
%    START_UTC: initial date of the period of interest.
%      If given, do not download files before the given date.
%      It may be any valid input compatible with XBD2DATE and LOG2DATE
%      options below, usually a serial date number.
%      Default value: -Inf
%    END_UTC: final date of the period of interest.
%      If given, do not download files after the the given date.
%      It may be any valid input compatible with XBD2DATE and LOG2DATE
%      options below, usually a serial date number.
%      Default value: +Inf
%    REMOTE_BASE_DIR: Root directory where the data live in the dockserver.
%    REMOTE_XBD_DIR: Path relative to REMOTE_BASE_DIR to the xbd files.
%    REMOTE_LOG_DIR: Path relative to REMOTE_BASE_DIR to the log files.
%    GLIDER: Name of the glider. It is used to build the directory path in
%      the remote server relative to REMOTE_BASE_DIR. If Glider is defined,
%      data path will be REMOTE_BASE_DIR/GLIDER/REMOTE_XBD_DIR or
%      REMOTE_BASE_DIR/GLIDER/REMOTE_LOG_DIR. Otherwise, XBD and LOG paths
%      are directly under REMOTE_BASE_DIR.
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


    narginchk(6, 20);

    options.start_utc        = -Inf;
    options.end_utc          = +Inf;
    options.glider           = '';
    options.remote_base_dir = '/var/opt/gmc/gliders';
    options.remote_xbd_dir  = 'from-glider';
    options.remote_log_dir  = 'logs';
    
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
        error('glider_toolbox:getBinaryData:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:getBinaryData:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
    
  %% Download deployment glider files from station(s).
  % Check for new or updated deployment files in every dockserver.
  % Deployment start time must be truncated to days because the date of 
  % a binary file is deduced from its name only up to day precission.
  % Deployment end time may be undefined.
  disp('Download deployment new data...');
  download_start = datenum(datestr(options.start_utc,'yyyy-mm-dd'),'yyyy-mm-dd');
  if isnan(options.end_utc)
    download_final = posixtime2utc(posixtime());
  else
    download_final = end_utc;
  end
  
  if isstruct(dockservers)
      switch glider_type
        case {'slocum_g1' 'slocum_g2'}
          new_xbds = cell(size(dockservers));
          new_logs = cell(size(dockservers));
          for dockserver_idx = 1:numel(dockservers)
            dockserver = dockservers(dockserver_idx);
            try
              [new_xbds{dockserver_idx}, new_logs{dockserver_idx}] = ...
                getDockserverFiles(dockserver, output_path, log_dir, ...
                                   'glider', options.glider, ...
                                   'remote_base_dir', options.remote_base_dir, ...
                                   'remote_xbd_dir', options.remote_xbd_dir, ...
                                   'remote_log_dir', options.remote_log_dir, ...
                                   'xbd', file_options.xbd_name_pattern, ...                     
                                   'log', file_options.log_name_pattern, ...
                                   'start', download_start, ...
                                   'final', download_final);
            catch exception
                error('glider_toolbox:getBinaryData:CallFailed', ...
                      'Error getting dockserver files from %s:%s', dockserver.host, getReport(exception, 'extended'));
            end
          end  
          new_xbds = [new_xbds{:}];
          new_logs = [new_logs{:}];
          disp(['Destination folder of Slocum files: ' output_path]);
          disp(['      - Binary data files downloaded: '  num2str(numel(new_xbds)) '.']);
          disp(['      - Surface log files downloaded: '  num2str(numel(new_logs)) '.']);
        case {'seaglider'}
          new_engs = cell(size(basestations));
          new_logs = cell(size(basestations));
          for basestation_idx = 1:numel(basestations)
            basestation = dockservers(basestation_idx);  
            try
              [new_engs{basestation_idx}, new_logs{basestation_idx}] = ...
                getDockserverFiles(basestation, output_path, output_path, ...
                                   'glider', options.glider, ...
                                   'remote_base_dir', options.remote_base_dir, ...
                                   'remote_xbd_dir', options.remote_xbd_dir, ...
                                   'remote_log_dir', options.remote_log_dir, ...
                                   'eng', file_options.eng_name_pattern, ...                     
                                   'log', file_options.log_name_pattern, ...
                                   'start', download_start, ...
                                   'final', download_final);
            catch exception
                error('glider_toolbox:getBinaryData:CallFailed', ...
                      'Error getting basestation files from %s:%s', basestation.host, getReport(exception, 'extended'));
            end
          end  
          new_engs = [new_engs{:}];
          new_logs = [new_logs{:}];
          disp(['Destination folder of Seaglider files: ' output_path]);
          disp(['       - Engineering data files downloaded: '  num2str(numel(new_engs)) '.']);
          disp(['       - Dive log data files downloaded: '  num2str(numel(new_logs)) '.']);
        case {'seaexplorer'}
          error('glider_toolbox:getBinaryData:NotImplemented', ...
                  'Real time file retrieval not implemented for SeaExplorer')
        otherwise
      end
  elseif ischar(dockservers)
      %TODO: For delayed mode, implement retrieval/softlinks and rename of binary
      %files
  else
      error('glider_toolbox:getBinaryData:NotImplemented', ...
            'Dockserver type is not allowed');
  end
end

