function [ config ] = setupConfiguration( glider_toolbox_dir, varargin)
% SETUPCONFIGURATION  Read configuration for processing glider data
%
%  Syntax:
%    [CONFIG] = SETUPCONFIGURATION(GLIDER_TOOLBOX_DIR, FCONFIG)
%    [CONFIG] = SETUPCONFIGURATION(GLIDER_TOOLBOX_DIR, FCONFIG, OPT1, VAL1, ...)
%
%  Description:
%    SETUPCONFIGURATION creates a configuration structure that can be used
%    for processing  glider data using DEPLOYMENTDATAPROCESSING. The
%    configuration structure contains information for the following:
%          - External libraries
%          - Dockserver
%          - Databases
%          - Input and output local and public directory tree
%          - Binary to Ascii conversion
%          - Figures and netCDF creation
%          - L0, L1 and L2 variables
%          - L0, L1 and L2 processing
%          - Quality control
%
%    The configuration is created in two steps. Firstly, for each type of
%    configurtion the appropriate function is called that returns the default
%    configuration. These function are described below and can be edited by
%    the user if different default parameters are required. The second step
%    consists of reading specific parameter values to overwrite the default
%    ones. These values are read from a configuration file that should follow
%    the format define by the template config/configTemplate.txt. The
%    configuration file may contain only a subset of the parameters. Only
%    those parameters contained in the configuration file will be overwriten.
%    The values of the other parameters remain the default values. As
%    specified in the template, the input template may refer to other
%    templates containing the values for the specific subset of variables.
%
%  Input:
%    GLIDER_TOOLBOX_DIR is the path of the glider toolbox installation.
%    This path must contain the m folder with the matlab code. 
%
%  Output:
%    CONFIG is the configuration struture. It contains the following
%    fields:
%       - STATUS: Name of the configuration file if any.
%       - PROCESSING_MODE: Must be rt or dt for real time mode or delayed
%           mode. If set, the value will overwrite the input option.
%       - WRCPROGS: External libraries (configWRCPrograms)
%           -- wrcprogs.status: File name or configuration function 
%           -- wrcprogs.base_dir: Location of binary files relative to base_dir           
%           -- wrcprogs.dbd2asc: File name of binary to ascii script relative to base_dir
%           -- wrcprogs.dba_merge: File name of dba merge scrip relative to base_dir 
%           -- wrcprogs.dba_sensor_filter: File name of sensor filter script relative to base_dir
%           -- wrcprogs.dba_time_filter: File name of time filter script relative to base_dir 
%           -- wrcprogs.dba2_orig_matlab: File name of orig matlab script relative to base_dir
%           -- wrcprogs.rename_dbd_files: File name of CF2 Persistor
%                        file rename script relative to base_dir
%       - LOCAL_PATHS: Definition of data folder structure (configPathsLocal)
%           -- local_paths.status: File name or configuration function 
%           -- local_paths.base_dir: Base directory containing the other folders
%           -- local_paths.binary_path: Directory for binary files under relative to base_dir
%           -- local_paths.cache_path: Directory for cache of db2asc files relative to base_dir
%           -- local_paths.log_path: Directory for log files relative to base_dir
%           -- local_paths.ascii_path: Directory for ascii files relative to base_dir
%           -- local_paths.figure_path: Directory for figure files relative to base_dir
%           -- local_paths.netcdf_l0: File name for L0 products relative to base_dir
%           -- local_paths.netcdf_l1: File name for L1 products relative to base_dir
%           -- local_paths.netcdf_l2: File name for L2 products relative to base_dir
%           -- local_paths.processing_log: File name for log file relative to base_dir
%       - PUBLIC_PATHS: Definition of public paths and urls (configPathsPublic)
%           -- public_paths.status: File name or configuration function 
%           -- public_paths.base_dir: Base directory containing the other folders
%           -- public_paths.netcdf_l0: File name for L0 products relative to base_dir
%           -- public_paths.netcdf_l1: File name for L1 products relative to base_dir
%           -- public_paths.netcdf_l2: File name for L2 products relative to base_dir
%           -- public_paths.base_html_dir: Directory for public figures
%           -- public_paths.base_url: URL of public access for json creation
%           -- public_paths.figure_url: URL for public figures for json creation
%           -- public_paths.figure_info: json name format
%       - DB_ACCESS: Definition of database access (configDBAccess)
%           -- db_access.status: File name or configuration function 
%           -- db_access.active: Indicates the use of database  
%           -- db_access.server: DB server name/ip
%           -- db_access.name: DB name
%           -- db_access.user: DB user name for access
%           -- db_access.pass: DB password for access
%           -- db_access.driver: DB drivers
%       - DOCKSERVERS: Definition of dockserver access (configDockservers)
%           -- dockservers.status: File name or configuration function 
%           -- dockservers.active: Indicates the use of dockserver
%           -- dockservers.remote_base_dir: Directory in remote server
%           -- dockservers.remote_xbd_dir: Directory of xdb files relative to base_dir 
%           -- dockservers.remote_log_dir: Directory of log files relative to base_dir
%           -- dockservers.server(1).url: Dockserver url
%           -- dockservers.server(1).host: Dockserver host name
%           -- dockservers.server(1).user: User for dockserver access
%           -- dockservers.server(1).pass: Password for dockserver access
%           -- dockservers.server(1).conn: Communication protocol to access
%       - FILE_OPTIONS_SLOCUM: Options for creating files from Slocum data (configDTFileOptionsSlocum)
%           -- file_options_slocum.status: File name or configuration function 
%           -- file_options_slocum.format_conversion: Indicates the use of
%                        binary to ascii conversion
%           -- file_options_slocum.xbd_name_pattern: Pattern to indentify
%                        valid binary files
%           -- file_options_slocum.dba_name_replace: Pattern for creating
%                        ascii file names
%           -- file_options_slocum.dba_name_pattern_nav: Navigation file pattern
%           -- file_options_slocum.dba_name_pattern_sci: Science file pattern
%           -- file_options_slocum.dba_time_sensor_nav: Navigation files
%                         time parameter
%           -- file_options_slocum.dba_time_sensor_sci: Science files
%                         time parameter
%           -- file_options_slocum.dba_sensors: Name of parameters to
%                         consider from binary files (array)
%       - FIGURES_PROCESSED and FIGURES_GRIDDED: Definitions for figure
%                 creation (configFigures). The default parameters are
%                 explained in configFigures but potentially it allows any
%                 figure in the configuration file
%
%    The following configuration parameters do not allow configuration file
%    overwrite. Check function for details. Some of them allow for delayed
%    or real time mode configuration according to the input processing_mode
%    option.
%       - OUTPUT_NETCDF_L0_SLOCUM: Definition for L0 netCDF file creation
%                 for Slocum data (configXTOutputNetCDFL0Slocum). 
%       - OUTPUT_NETCDF_L0_SEAGLIDER: Definition for L0 netCDF file creation
%                 for Seaglider data (configXTOutputNetCDFL0Seaglider). 
%       - OUTPUT_NETCDF_L0_SEAEXPLORER: Definition for L0 netCDF file creation
%                 for SeaExplorer data (configXTOutputNetCDFL0SeaExplorer). 
%       - OUTPUT_NETCDF_L1: Definition for L1 netCDF file creation (configXTOutputNetCDFL1). 
%       - OUTPUT_NETCDF_L1: Definition for L1 netCDF-EGO file creation (configOutputNetCDFEGOL1). 
%       - OUTPUT_NETCDF_L2: Definition for L2 netCDF file creation (configXTOutputNetCDFL2). 
%       - PREPROCESSING_OPTIONS_SLOCUM: Definition of pre-processing data
%                from Slocum (configDataPreprocessingSlocum)
%       - PREPROCESSING_OPTIONS_SEAGLIDER: Definition of pre-processing data
%                from Seaglider (configDataPreprocessingSeaglider)
%       - PREPROCESSING_OPTIONS_SEAEXPLORER: Definition of pre-processing data
%                from SeaExplorer (configDataPreprocessingSeaExplorer)
%       - PROCESSING_OPTIONS_SLOCUM: Definition of processing data
%                from Slocum G1 (configDataProcessingSlocumG1)
%       - PROCESSING_OPTIONS_SLOCUM: Definition of processing data
%                from Slocum G2 (configDataProcessingSlocumG2)
%       - PROCESSING_OPTIONS_SEAGLIDER: Definition of processing data
%                from Seaglider (configDataProcessingSeaglider)
%       - PROCESSING_OPTIONS_SEAEXPLORER: Definition of processing data
%                from SeaExplorer (configDataProcessingSeaExplorer)
%       - GRIDDING_OPTIONS: Definition for gridding (L2) process (configDataGridding)
%       - FILE_OPTIONS_SEAGLIDER: Options for creating files from Seaglider
%                data (configXTFileOptionsSeaglider)
%       - FILE_OPTIONS_SEAEXPLORER: Options for creating files from Seaexplorer
%                data (configXTFileOptionsSeaExplorer)
% 
%  Options:
%    FCONFIG is the name of the configuration file to use if necessary. The
%      options for the configuration will be read from this file if it
%      follows a specific format defined in the configuration template
%      (config/configTemplate.txt). The values extracted from the file
%      overwrites the default values.
%
%    PROCESSING_MODE indicates if the processing is for real time data or
%      delayed mode data. The difference happens in the configuration since
%      the data is gathered differently and has different formats and
%      content. The processing mode value is overwritten if it is also set
%      in the input configuration file.
%
%  Default Values:
%      Default values result from the call of the 
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


    narginchk(1, 5);
    options.processing_mode = 'rt';  
    options.fconfig = '';
    options.array_delimiter = '|';
    
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
        error('glider_toolbox:setupConfiguration:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:setupConfiguration:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
  
    %% Read configuration file
    readconfig = struct([]);
    if ~strcmp(options.fconfig, '')
        readconfig = readConfigFile(options.fconfig,'array_delimiter', options.array_delimiter);
        config.status = options.fconfig;
        disp(['Configuration file ' options.fconfig]);
    else 
        disp('No configuration file was input');
        config.status = '';
    end
    
    %% Set processing mode for default configuration values
    if ~isempty(readconfig) && isfield(readconfig, 'processing_mode')
        options.processing_mode = readconfig.processing_mode;
    end
    config.processing_mode = lower(options.processing_mode);
    
    
    %% Configure external tools.
    config.wrcprogs = configWRCPrograms(glider_toolbox_dir);
    config.wrcprogs.status = 'configWRCPrograms';
    
    if ~isempty(readconfig) && isfield(readconfig, 'wrcprogs')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.wrcprogs.status = options.fconfig;
        config_wrcprogs = readconfig.wrcprogs;
        fields = fieldnames(config_wrcprogs);
        for i = 1:numel(fields)
            config.wrcprogs.(fields{i}) = config_wrcprogs.(fields{i});
        end
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.wrcprogs, 'fconfig') 
          array_delimiter = '';
          if isfield(config.wrcprogs, 'array_delimiter')
            array_delimiter = config.wrcprogs.array_delimiter;
          end
          config_read_fconfig = readConfigFile(readconfig.wrcprogs.fconfig, 'array_delimiter', array_delimiter);
          config_wrcprogs = config_read_fconfig.wrcprogs;
        
          fields = fieldnames(config_wrcprogs);
          for i = 1:numel(fields)
              config.wrcprogs.(fields{i}) = config_wrcprogs.(fields{i});
          end
        end
    end
  
  
    %% Configure data path.
    config.local_paths = configPathsLocal(glider_toolbox_dir);
    config.local_paths.status = 'configPathsLocal';
  
    if ~isempty(readconfig) && isfield(readconfig, 'local_paths')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.local_paths.status = options.fconfig;
        config_local_paths = readconfig.local_paths;
        fields = fieldnames(config_local_paths);
        for i = 1:numel(fields)
            config.local_paths.(fields{i}) = config_local_paths.(fields{i});
        end
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.local_paths, 'fconfig') 
            array_delimiter = '';
            if isfield(config.local_paths, 'array_delimiter')
              array_delimiter = config.local_paths.array_delimiter;
            end
            config_read_fconfig = readConfigFile(readconfig.local_paths.fconfig, 'array_delimiter', array_delimiter);
            config_localpaths = config_read_fconfig.local_paths;
            for i = 1:numel(fields)
                config.local_paths.(fields{i}) = config_localpaths.(fields{i});
            end
        end
    end
     
    %% Configure public path.
    config.public_paths = configPathsPublic(glider_toolbox_dir, struct());
    config.public_paths.status = 'configPathsPublic';
  
    if ~isempty(readconfig) && isfield(readconfig, 'public_paths')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.public_paths.status = options.fconfig;
        config_public_paths = readconfig.public_paths;
        fields = fieldnames(config_public_paths);
        for i = 1:numel(fields)
            config.public_paths.(fields{i}) = config_public_paths.(fields{i});
        end
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.public_paths, 'fconfig') 
            array_delimiter = '';
            if isfield(config.public_paths, 'array_delimiter')
              array_delimiter = config.public_paths.array_delimiter;
            end
            config_read_fconfig = readConfigFile(readconfig.public_paths.fconfig, 'array_delimiter', array_delimiter);
            config_publicpaths = config_read_fconfig.public_paths;

            fields = fieldnames(config_publicpaths);
            for i = 1:numel(fields)
                config.public_paths.(fields{i}) = config_publicpaths.(fields{i});
            end
        end
    end

    %% Configure data base deployment information source.
    config.db_access = configDBAccess();
    config.db_access.status = 'configDBAccess';
    
    if ~isempty(readconfig) && isfield(readconfig, 'db_access')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.db_access.status = options.fconfig;
        config_db_access = readconfig.db_access;
        fields = fieldnames(config_db_access);
        for i = 1:numel(fields)
            if strcmp(fields{i},'active') == 0
                config.db_access.(fields{i}) = config_db_access.(fields{i});
            else
                config.db_access.(fields{i}) = strcmp(config_db_access.(fields{i}),'1') + strcmp(config_db_access.(fields{i}),'true');
            end
        end        
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.db_access, 'fconfig') 
            array_delimiter = '';
            if isfield(config.db_access, 'array_delimiter')
                array_delimiter = config.db_access.array_delimiter;
            end
            config_read_fconfig = readConfigFile(readconfig.db_access.fconfig, 'array_delimiter', array_delimiter);
            config_db_access = config_read_fconfig.db_access;
            fields = fieldnames(config_db_access);
            for i = 1:numel(fields)
                if strcmp(fields{i},'active') == 0
                    config.db_access.(fields{i}) = config_db_access.(fields{i});
                else
                    config.db_access.(fields{i}) = strcmp(config_db_access.(fields{i}),'1') + strcmp(config_db_access.(fields{i}),'true');
                end
            end
        end
    end

    %% Configure Dockserver
    config.dockservers = configDockservers();
    config.dockservers.status = 'configDockservers';
    
    if ~isempty(readconfig) && isfield(readconfig, 'dockservers')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.dockservers.status = options.fconfig;
        config_dockservers = readconfig.dockservers;
        fields = fieldnames(config_dockservers);
        for i = 1:numel(fields)
            if strcmp(fields{i},'active') == 0
                config.dockservers.(fields{i}) = config_dockservers.(fields{i});
            else
                config.dockservers.(fields{i}) = strcmp(config_dockservers.(fields{i}),'1') + strcmp(config_dockservers.(fields{i}),'true');
            end
        end

        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.dockservers, 'fconfig') 
            array_delimiter = '';
            if isfield(config.dockservers, 'array_delimiter')
                array_delimiter = config.dockservers.array_delimiter;
            end
            config_read_fconfig = readConfigFile(readconfig.dockservers.fconfig, 'array_delimiter', array_delimiter);
            config_dockservers = config_read_fconfig.dockservers;
            fields = fieldnames(config_dockservers);
            for i = 1:numel(fields)
                if strcmp(fields{i},'active') == 0
                    config.dockservers.(fields{i}) = config_dockservers.(fields{i});
                else
                    config.dockservers.(fields{i}) = strcmp(config_dockservers.(fields{i}),'1') + strcmp(config_dockservers.(fields{i}),'true');
                end
            end
        end
    end
    
    %% Configure figure outputs.
    [figures_processed_options, figures_gridded_options] = configFigures();
    config.figures_processed.options = figures_processed_options;
    config.figures_gridded.options   = figures_gridded_options;
    config.figures_processed.status  = 'configFigures';
    config.figures_gridded.status    = 'configFigures';
    
    % Overwrite figures_processed
    % TODO: This only handles specific parameters and it won't work for all
    %       the fields of the structure since some of them are structures
    if ~isempty(readconfig) && isfield(readconfig, 'figures_processed')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.figures_processed.status = options.fconfig;
        config_figures_processed = readconfig.figures_processed;
        fields = fieldnames(config_figures_processed);
        for i = 1:numel(fields)
            if strcmp(fields{i},'active') == 0
                config.figures_processed.(fields{i}) = config_figures_processed.(fields{i});
            else
                config.figures_processed.(fields{i}) = strcmp(config_figures_processed.(fields{i}),'1') + strcmp(config_figures_processed.(fields{i}),'true');
            end
        end
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.figures_processed, 'fconfig') 
          array_delimiter = '';
          if isfield(config.figures_processed, 'array_delimiter')
            array_delimiter = config.figures_processed.array_delimiter;
          end
          config_read_fconfig = readConfigFile(readconfig.figures_processed.fconfig, 'array_delimiter', array_delimiter);
          config_figures_processed = config_read_fconfig.figures_processed;
        
          fields = fieldnames(config_figures_processed);
          for i = 1:numel(fields)
            if strcmp(fields{i},'active') == 0
                config.figures_processed.(fields{i}) = config_figures_processed.(fields{i});
            else
                config.figures_processed.(fields{i}) = strcmp(config_figures_processed.(fields{i}),'1') + strcmp(config_figures_processed.(fields{i}),'true');
            end
          end
        end
    end
    
    % Overwrite figures_gridded
    if ~isempty(readconfig) && isfield(readconfig, 'figures_gridded')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.figures_gridded.status = options.fconfig;
        config_figures_gridded = readconfig.figures_gridded;
        fields = fieldnames(config_figures_gridded);
        for i = 1:numel(fields)
            if strcmp(fields{i},'active') == 0
                config.figures_gridded.(fields{i}) = config_figures_gridded.(fields{i});
            else
                config.figures_gridded.(fields{i}) = strcmp(config_figures_gridded.(fields{i}),'1') + strcmp(config_figures_gridded.(fields{i}),'true');
            end
        end
          
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        if isfield(readconfig.figures_gridded, 'fconfig') 
          array_delimiter = '';
          if isfield(config.figures_gridded, 'array_delimiter')
            array_delimiter = config.figures_gridded.array_delimiter;
          end
          config_read_fconfig = readConfigFile(readconfig.figures_gridded.fconfig, 'array_delimiter', array_delimiter);
          config_figures_gridded = config_read_fconfig.config_figures_gridded;
          
          fields = fieldnames(config_figures_gridded);
          for i = 1:numel(fields)
              if strcmp(fields{i},'active') == 0
                  config.figures_gridded.(fields{i}) = config_figures_gridded.(fields{i});
              else
                  config.figures_gridded.(fields{i}) = strcmp(config_figures_gridded.(fields{i}),'1') + strcmp(config_figures_gridded.(fields{i}),'true');
              end
          end
        end
    end


    %% Configure NetCDF outputs.
    if strcmp(config.processing_mode, 'dt')
        config.output_netcdf_l0_slocum      = configDTOutputNetCDFL0Slocum();
        config.output_netcdf_l0_seaglider   = configDTOutputNetCDFL0Seaglider();
        config.output_netcdf_l0_seaexplorer = configDTOutputNetCDFL0SeaExplorer();
        config.output_netcdf_eng_slocum      = configDTOutputNetCDFEngSlocum();
        config.output_netcdf_eng_seaglider   = configDTOutputNetCDFEngSeaglider();
        config.output_netcdf_eng_seaexplorer = configDTOutputNetCDFEngSeaExplorer();
        config.output_netcdf_l1             = configDTOutputNetCDFL1();
        config.output_netcdf_egol1          = configDTOutputNetCDFEGOL1();    
        config.output_netcdf_l2             = configDTOutputNetCDFL2();
    elseif strcmp(config.processing_mode, 'rt')
        config.output_netcdf_l0_slocum      = configRTOutputNetCDFL0Slocum();
        config.output_netcdf_l0_seaglider   = configRTOutputNetCDFL0Seaglider();
        config.output_netcdf_l0_seaexplorer = configRTOutputNetCDFL0SeaExplorer();
        config.output_netcdf_eng_slocum      = configRTOutputNetCDFEngSlocum();
        config.output_netcdf_eng_seaglider   = configRTOutputNetCDFEngSeaglider();
        config.output_netcdf_eng_seaexplorer = configRTOutputNetCDFEngSeaExplorer();
        config.output_netcdf_l1             = configRTOutputNetCDFL1();
        config.output_netcdf_egol1          = configRTOutputNetCDFEGOL1();    
        config.output_netcdf_l2             = configRTOutputNetCDFL2();
    else
        error('glider_toolbox:setupConfiguration:InvalidOption', ...
                'Invalid processing mode: %s.', config.processing_mode);
    end

    %% Configure processing options.
    config.preprocessing_options_slocum = configDataPreprocessingSlocum();
    config.preprocessing_options_seaglider = configDataPreprocessingSeaglider();
    config.preprocessing_options_seaexplorer = configDataPreprocessingSeaExplorer();
    config.processing_options_slocum_g1 = configDataProcessingSlocumG1();
    config.processing_options_slocum_g2 = configDataProcessingSlocumG2();
    config.processing_options_seaglider = configDataProcessingSeaglider();
    config.processing_options_seaexplorer = configDataProcessingSeaExplorer();
    config.gridding_options = configDataGridding();

    %% Configure Slocum file options
    if strcmp(config.processing_mode, 'dt')
        config.file_options_slocum = configDTFileOptionsSlocum();
    elseif strcmp(config.processing_mode, 'rt')
        config.file_options_slocum = configRTFileOptionsSlocum();
    else
        error('glider_toolbox:setupConfiguration:InvalidOption', ...
                'Invalid processing mode: %s.', config.processing_mode);
    end
    config.file_options_slocum.status = 'configRTFileOptionsSlocum';
    
    if ~isempty(readconfig) && isfield(readconfig, 'file_options_slocum')
        % Read values from configuration file and overwrite default values
        % with the one found in the file
        config.file_options_slocum.status = options.fconfig;
        config_file_options_slocum = readconfig.file_options_slocum;
        fields = fieldnames(config_file_options_slocum);
        add2dba_sensors = {};
        for i = 1:numel(fields)
            if strcmp(fields{i},'format_conversion') == 1
                config.file_options_slocum.(fields{i}) = strcmp(config_file_options_slocum.(fields{i}),'1') + strcmp(config_file_options_slocum.(fields{i}),'true');
            elseif strcmp(fields{i},'add2dba_sensors') == 0
                config.file_options_slocum.(fields{i}) = config_file_options_slocum.(fields{i});
            else 
                add2dba_sensors = [add2dba_sensors, config_file_options_slocum.(fields{i})];
            end
        end
        
        % When another configuration file is referred, it is read and
        % values are overwritten with the one in the referred file
        % add2dba_sensors is overwritten the previous array
        if isfield(readconfig.file_options_slocum, 'fconfig') 
            array_delimiter = '';
            if isfield(config.file_options_slocum, 'array_delimiter')
              array_delimiter = config.file_options_slocum.array_delimiter;
            end
            config_read_fconfig = readConfigFile(readconfig.file_options_slocum.fconfig, 'array_delimiter', array_delimiter);
            config_file_options_slocum = config_read_fconfig.file_options_slocum;
          
            fields = fieldnames(config_file_options_slocum);
            add2dba_sensors = {};
            for i = 1:numel(fields)
                if strcmp(fields{i},'format_conversion') == 1
                    config.file_options_slocum.(fields{i}) = strcmp(config_file_options_slocum.(fields{i}),'1') + strcmp(config_file_options_slocum.(fields{i}),'true');
                elseif strcmp(fields{i},'add2dba_sensors') == 0
                    config.file_options_slocum.(fields{i}) = config_file_options_slocum.(fields{i});
                else 
                    add2dba_sensors = [add2dba_sensors, config_file_options_slocum.(fields{i})];
                end
            end
            if ~isempty(add2dba_sensors)
                config.file_options_slocum.dba_sensors = union(config.file_options_slocum.dba_sensors, add2dba_sensors);
            end
        end
    end
    
    %% Configure file download and conversion and data loading.
    if strcmp(config.processing_mode, 'dt')
        config.file_options_seaglider = configDTFileOptionsSeaglider();
        config.file_options_seaexplorer = configDTFileOptionsSeaExplorer();
    elseif strcmp(config.processing_mode, 'rt')
        config.file_options_seaglider = configRTFileOptionsSeaglider();
        config.file_options_seaexplorer = configRTFileOptionsSeaExplorer();
    else
        error('glider_toolbox:setupConfiguration:InvalidOption', ...
                'Invalid processing mode: %s.', config.processing_mode);
    end


end

