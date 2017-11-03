function [ ] = getBinaryData( output_path, log_dir, glider_type, start_utc, file_options, dockservers, varargin)
% GETBINARYDATA  Retrieves the raw data of a glider from the dockserver or path
%
%  Syntax:
%    GETBINARYDATA(OUTPUT_PATH, LOG_DIR, GLIDER_TYPE, ...
%                       START_UTC, FILE_OPTIONS, DOCKSERVERS)
%
%    GETBINARYDATA(OUTPUT_PATH, LOG_DIR, GLIDER_TYPE, ...
%                       START_UTC, FILE_OPTIONS, DOCKSERVERS, OPT1, VAL1, ...)
%
%  Description:
%    TODO: Description for GETBINARYDATA
%
%  Input:
%    TODO: Inputs for GETBINARYDATA
%
%  Output:
%    TODO: Outputs for GETBINARYDATA
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

    options.end_utc          = NaN;
    options.basestation      = [];
    options.ascii_dir        = '';
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
  download_start = datenum(datestr(start_utc,'yyyy-mm-dd'),'yyyy-mm-dd');
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
              disp(['Error getting dockserver files from ' dockserver.host ':']);
              disp(getReport(exception, 'extended'));
            end
          end  
          new_xbds = [new_xbds{:}];
          new_logs = [new_logs{:}];
          disp(['Binary data files downloaded: '  num2str(numel(new_xbds)) '.']);
          disp(['Surface log files downloaded: '  num2str(numel(new_logs)) '.']);
        case {'seaglider'}
          new_engs = cell(size(basestations));
          new_logs = cell(size(basestations));
          for basestation_idx = 1:numel(basestations)
            basestation = dockservers(basestation_idx);  %TODO: are we really using basestations or just dockservers
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
              disp(['Error getting basestation files from ' basestation.host ':']);
              disp(getReport(exception, 'extended'));
            end
          end  
          new_engs = [new_engs{:}];
          new_logs = [new_logs{:}];
          disp(['Engineering data files downloaded: '  num2str(numel(new_engs)) '.']);
          disp(['Dive log data files downloaded: '  num2str(numel(new_logs)) '.']);
        case {'seaexplorer'}
          warning('glider_toolbox:getBinaryData:NotImplemented', ...
                  'Real time file retrieval not implemented for SeaExplorer')
        otherwise
      end
  elseif ischar(dockservers)
      %TODO: For delayed mode, implement retrieval/softlinks and rename of binary
      %files
  else
      error('glider_toolbox:main_glider_data_processing_dt:NotImplemented', ...
            'Dockserver type is not allows');
  end
end

