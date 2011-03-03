%TESTPHPSERVICES - Test script to query php services
% This script tests the connection and retrieval of glider services
% through JSON strings 
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2Âºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%
%% Script start: clean workspace and set path defaults
clear all;
close all;
clc;
%restoredefaultpath;

%% Basic path setup
% Set the path for accessing the glider PHP JSON service
baseURL             = 'http://dataserver.imedea.uib-csic.es/gapp/lib/request/';
getDeploymentURL    = [baseURL, 'gapp.getDeploymentList.php'];
getConfigurationURL = [baseURL, 'gapp.getConfiguration.php'];

%% Get Deployments
jsonStr = urlread(getDeploymentURL);
data = parseJson(jsonStr);
clear jsonStr;
data = data{1};
for k = 1:length(data)
    disp(data{k});
end;

%% Get Configuration
jsonStr = urlread(getConfigurationURL);
data = parseJson(jsonStr);
clear jsonStr;
data = data{1};

fn = fieldnames(data);
for k = 1:length(fn)
    disp(data.(fn{k}));
end;
