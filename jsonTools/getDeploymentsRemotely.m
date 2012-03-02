function currentDeploymentsList = getDeploymentsRemotely
%GETDEPLOYMENTSREMOTELY - Gets the list of active deployments via RESTful services
% This function gets the list of active deployments via RESTful services
% through JSON strings 
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2Âºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

%% Basic path setup
    % Set the path for accessing the glider PHP JSON service
    baseURL              = 'http://dataserver.imedea.uib-csic.es/gapp/lib/request/';
    getDeploymentListURL = [baseURL, 'gapp.getDeploymentList.php'];
    getDeploymentInfoURL = [baseURL, 'gapp.getDeployment.php'];

    currentDeploymentsList = [];

%% Get active deployments' list
    % Get remote list of deployments
    data = parseJson(urlread(getDeploymentListURL));
    deploymentList = data{1}';
    if isempty(deploymentList)
        disp('No deployments found');
        return;
    end;

    % Filter just active deployments and get detailed information from them
    for depIdx = 1:length(deploymentList)
        if deploymentList{depIdx}.is_active
            deploymentQuery = [getDeploymentInfoURL, ...
                '?glider=', deploymentList{depIdx}.glider, ...
                '&mission=', deploymentList{depIdx}.mission_name];
            data = parseJson(urlread(deploymentQuery));
            deploymentInfo = data{1}';
            % As number of active deployments cannot be known in advance
            % there is no way of preallocating space for them
            currentDeploymentsList{end+1} = deploymentInfo; %#ok<AGROW>
        end;
    end;

%% Parse each deployment info
    % Preallocate space for known number of deployments
    currentDeploymentsList = cell(length(currentDeploymentsList), 1);
    % Loop through the deployments and parse their information
    for depIdx = 1:length(currentDeploymentsList)
        currentDeployment = currentDeploymentsList{depIdx};
        parsedDeployment  = parseDeploymentInfo(currentDeployment);
        currentDeploymentsList{depIdx} = parsedDeployment;
    end; % for depIdx = 1:length(currentDeploymentsList)

    return;
    
%% Auxiliar function to parse deployment information along the path
    function parsedDeployment = parseDeploymentInfo(currentDeployment)
        % Initialize output variable
        parsedDeployment   = currentDeployment;
        
%% Create surface sensor time series
        parsedDeployment.surfaceTimeseries = [];
        parsedDeployment.surfaceTimeseries.time = [];
        desiredSensorsList = fieldnames(currentDeployment.path{1}.sensors);
        for senIdx = 1:length(desiredSensorsList)
            currentSensor = desiredSensorsList{senIdx};
            parsedDeployment.surfaceTimeseries.(currentSensor) = [];
        end;
        
        for surfIdx = 1:length(currentDeployment.path)
            % Append time instant
            parsedDeployment.surfaceTimeseries.time = [
                parsedDeployment.surfaceTimeseries.time;
                currentDeployment.path{surfIdx}.initial_date];
            
            for senIdx = 1:length(desiredSensorsList)
                currentSensor      = desiredSensorsList{senIdx};
                currentSensorValue = nan;
                availableSensorsList = fieldnames(currentDeployment.path{surfIdx}.sensors);
                if ismember(currentSensor, availableSensorsList)
                    currentSensorValue = str2double(currentDeployment.path{surfIdx}.sensors.(currentSensor).value);
                end;
                parsedDeployment.surfaceTimeseries.(currentSensor) = [
                    parsedDeployment.surfaceTimeseries.(currentSensor);
                    currentSensorValue];
            end; % for senIdx = 1:length(sensorsList)
        end; % for surfIdx = 1:length(currentDeployment.path)
        
%% Create array of waypoints lat and lon
        wpArray = [currentDeployment.waypoints];
        wpArray = [wpArray{:}];
        parsedDeployment.waypointsLat = [wpArray.lat];
        parsedDeployment.waypointsLon = [wpArray.lon];
    end

end
