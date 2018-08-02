function [] = gliderDataProcessing(varargin)
%GLIDER_DATA_PROCESSING_DT  Run glider processing chain 
%
%  Syntax:
%    GLIDERDATAPROCESSING(OPT1, VAL1, ...)
%
%  Description:
%    GLIDERDATAPROCESSING processes a list of deployments by calling
%    DEPLOYMENTDATAPROCESSING. It wraps the processing and allow to
%    retrieve the information of deployments from a database, setup the
%    configuration of the processing, organize the input and output data
%    file locations and log the results of the processing. For detailed
%    information of the processing refer to DEPLOYMENTDATAPROCESSING. This
%    functions performs the following steps:
%        - Setup configuration by calling SETUPCONFIGURATION if the
%           configuration is not input as an option.
%        - Read active deployments in database or used a deployment list if
%           is input as an option
%        - Data management and processing for each deployment as follow:
%             -- Create directory name structure of local and public paths
%             -- Start processing log
%             -- Call DEPLOYMENTDATAPROCESSING for processing deployment
%             -- Organize public data (TBD)
%
%  Input: No required input (see options)
%
%  Output: None
%
%  Options:
%
%    GLIDERDATAPROCESSING(OPT1, VAL1, ...) accept the 
%    following options given in key-value pairs OPT1, VAL1... or in struct
%    OPTIONS with field names as option keys and field values as option values:
%      GLIDER_TOOLBOX_DIR: Glider toolbox installation directory.
%        String with the name of the directory where the glider toolbox
%        lives. 
%        Default value: When the option is not input the configGliderToolboxPath
%        routine will be call and thus, the function must be in the path.
%      CONFIG: Configuration structure that is used if no configuration
%        file is input. Optionally, the name of a file can be input
%        defining the configuration for the current processing. The function 
%        is load using SETUPCONFIGURATION if a configuration file name is
%        input or the input structure is empty. 
%      DEPLOYMENT_LIST: Array of deployment structures containing the
%        information of the deployments to be processed. By default the list
%        is built using the database when defined. However, the database
%        query is skipped when the deployment list is input. The structure of
%        the deployment list must contai: deployment_id, deployment_name,
%        deployment_start, deployment_end, glider_name, glider_serial and
%        glider_model
%      PROCESSING_MODE: Defines the processing mode, either real time (rt or RT)
%        or delayed time (dt or DT).
%      PUBLIC_NETCDFS_EXCEPTIONS: Describes the netCDF files that must not
%        be copied to the public location. By default all products will be
%        copied. Values can be: netcdf_l0, netcdf_eng, netcdf_l1,
%        netcdf_egol1 or netcdf_l2.
%      PUBLIC_FIGURES_EXCEPTIONS: Describes the figues that must not
%        be copied to the public location. By default all figures will be
%        copied. Values depend on the configuration file definitions.
%
%  See also:
%    DEPLOYMENTDATAPROCESSING
%    CONFIGGLIDERTOOLBXPATH
%    SETUPCONFIGURATION
%    GETDEPLOYMENTINFODB
%    CREATEFSTRUCT
%    STARTLOGGING
%    ORGANIZEPUBLICDATA
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
 
    %% Initialization
    narginchk(0, 10);

    % required parameters of deployment structure
    required_deployment_strparam = {'deployment_name', 'glider_name', ...
                       'glider_serial', 'glider_model'};
    required_deployment_numparam = {'deployment_id', ...
                       'deployment_start', 'deployment_end'};
                   
    
    options.glider_toolbox_dir = '';
    options.processing_mode = 'rt';  
    %TODO: Remove the default path and set it to empty. I am using this for testing
    options.config            = '/home/mcharcos/gtb_versions/glider_toolbox_scbd077_db01_ego/config/configMain.txt';
    options.deployment_list    = [];
    options.public_netcdfs_exceptions  = [];
    options.public_figures_exceptions  = [];
    
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
        error('glider_toolbox:gliderDataProcessing:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:gliderDataProcessing:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end
  
    %% Configure toolbox and configuration file path 
    if isempty(options.glider_toolbox_dir)
        options.glider_toolbox_dir = configGliderToolboxPath();
        options.glider_toolbox_ver = configGliderToolboxVersion();
    else
        options.glider_toolbox_ver = 'unknown';
    end
    
    %% Read configuration values from configuration file
    if ~isempty(options.config) && ischar(options.config)
        config = setupConfiguration(options.glider_toolbox_dir, ...
                                    'processing_mode', options.processing_mode, ...
                                    'fconfig', options.config);
    elseif isstruct(options.config)
        config = options.config;
    end
    
    if isempty(config) || ~isstruct(config)  
        error('glider_toolbox:gliderDataProcessing:MissingConfiguration',...
              'Empty configuration file');
    end
    
    %% Get list of deployments to process from database.
    user_db_access = 0;
    if ~isempty(config.db_access) && isfield(config.db_access, 'active')
        user_db_access = config.db_access.active;
    end
    if user_db_access && isempty(options.deployment_list)
        if ~isfield(config,'processing_mode')
            error('glider_toolbox:gliderDataProcessing:InvalidConfiguration',...
              'Configuration file is missing processing mode');
        end
        if strcmp(config.processing_mode, 'rt')
            [config.db_query, config.db_fields] = configRTDeploymentInfoQueryDB();
        elseif strcmp(config.processing_mode, 'dt')
            if ~isfield(config.db_access, 'deployment_ids')
                error('glider_toolbox:gliderDataProcessing:MissingConfiguration',...
                          'Delayed mode requires deployment ids');
            end
            [config.db_query, config.db_fields] = configDTDeploymentInfoQueryDB('deployment_ids', config.db_access.deployment_ids);
        else
            error('glider_toolbox:gliderDataProcessing:InvalidConfiguration',...
              'Configuration file has wrong processing mode');
        end
        
        disp('Querying information of glider deployments...');
        options.deployment_list = getDeploymentInfoDB( ...
          config.db_query, config.db_access.name, ...
          'user', config.db_access.user, 'pass', config.db_access.pass, ...
          'server', config.db_access.server, 'driver', config.db_access.driver, ...
          'fields', config.db_fields);
        if isempty(options.deployment_list)
          disp('Selected glider deployments are not available.');
          return
        else
          disp(['Selected deployments found: ' num2str(numel(options.deployment_list)) '.']);
        end
    else
        if isempty(options.deployment_list)
          error('glider_toolbox:gliderDataProcessing:InvalidOptions',...
              'Missing database and deployment list');
        elseif ischar(options.deployment_list)
            try
                read_deployment = readConfigFile(options.deployment_list);
                options.deployment_list = read_deployment.deployment_list;
            catch exception
                error('glider_toolbox:gliderDataProcessing:InvalidConfiguration',...
                  'Could not read deployment definition file');
            end            
        end
        
        %Check/modify format of deployment_list 
        for i=1:numel(required_deployment_strparam)
           fieldname = required_deployment_strparam(i);
           if ~isfield( options.deployment_list, fieldname{1})
               disp(['ERROR: Deployment definition does not contain ' fieldname{1}]);
               return;
           end
        end
        for i=1:numel(required_deployment_numparam)
           fieldname = required_deployment_numparam(i);
           if ~isfield( options.deployment_list, fieldname{1})
               disp(['ERROR: Deployment definition does not contain ' fieldname{1}]);
               return;
           else
               for j=1:numel(options.deployment_list)  
                   options.deployment_list(j).(fieldname{1}) = str2num(options.deployment_list(j).(fieldname{1}));
               end
           end
        end        
    end
    
    %% Validate deployment list
    if isempty(options.deployment_list)
        disp('No deployments to be processed');
        return;
    end
    
    %% Process active deployments.
    for deployment_idx = 1:numel(options.deployment_list)
      disp(['Processing deployment ' num2str(deployment_idx) '...']);
      deployment = options.deployment_list(deployment_idx);
      
      %% Define paths for processing
      data_paths = createFStruct(config.local_paths, deployment);
      
      %% Start deployment processing logging.
      startLogging(fullfile(data_paths.base_dir,data_paths.processing_log), options.glider_toolbox_ver, deployment);
      
      %% Copy configuration file to data folder
      if ~isempty(options.config) && ischar(options.config)
          config_record = fullfile(data_paths.base_dir,data_paths.config_record);
          config_record_dir = fileparts(config_record);
          [status, attrout] = fileattrib(config_record_dir);
          if ~status
            [status, message] = mkdir(config_record_dir);
          elseif ~attrout.directory
            status = false;
            message = 'not a directory';
          end
          if status
            [success, message] = copyfile(options.config, config_record);
            if success
              disp(['Configuration file succesfully copied: ' config_record '.']);
            else
              disp(['Error copying configuration file to local data ' ...
                    config_record ': ' options.config '.']);
              disp(message);
            end
          else
            disp(['Error creating output directory ' config_record_dir ':']);
            disp(message);
          end
      end
    
      
      
      %% Process data
      try
        [netcdf_products, figure_products, ~, ~] = ...
            deploymentDataProcessing(data_paths, deployment, config, ...
                                        'data_result', 'postprocessed');
      catch exception
        disp(['Error processing deployment ' deployment.deployment_name ':']);
        disp(getReport(exception, 'extended'));
        continue;
      end
      
      %% Define public paths and copy data to public
      if ~isempty(fieldnames(netcdf_products)) || ~isempty(fieldnames(figure_products))
          % remove netcdf exceptions
          if ~isempty(fieldnames(netcdf_products)) && ~isempty(options.public_netcdfs_exceptions)
              except_list = options.public_netcdfs_exceptions;
              for count_except=1:numel(except_list)
                  if isfield(netcdf_products,except_list{count_except})
                      netcdf_products = rmfield(netcdf_products,except_list{count_except});
                  end
              end
          end
          
          % remove figure exceptions
          if ~isempty(fieldnames(figure_products)) && ~isempty(options.public_figures_exceptions)
              except_list = options.public_figures_exceptions;
              for count_except=1:numel(except_list)
                  if isfield(figure_products,except_list{count_except})
                      figure_products = rmfield(figure_products,except_list{count_except});
                  end
              end
          end
          
          public_paths = createFStruct(config.public_paths, deployment);
          
          organizePublicData(public_paths, netcdf_products, figure_products);
   
      end
      
      %% Stop deployment processing logging.
      disp(['Deployment processing end time: ' ...
            datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);
      diary('off');
    end
    
end
