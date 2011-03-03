function periodsList = getTransects(timeserie)
%GETTRANSECTS - Finds time periods at which the glider started each transect
% this function uses the c_wpt_lon and c_wpt_lat to look for differences
% and discover where the glider changed its goal. From that information
% it generates a list of time instants that can be used as time ranges
% for each transect (considered as the travelling between two waypoints)
%
% Syntax: periodsList = getTransects(timeserie)
%
% Inputs:
%    timeserie - structure returned by processGliderData
%
% Outputs:
%    periodsList - vector of time instants, extracted from the field navTime
%
% Example:
%    periodsList = getTransects(timeserie)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIND, SUM, ISNAN, UNIQUE, IND2SUB
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 25-Feb-2011
%

    % Check we have the necessary fields in the input structure
    if ~isfield(timeserie, 'wptLon') || ~isfield(timeserie, 'wptLat')
        disp('No waypoints information in the input');
        periodsList = [timeserie.navTime(1), timeserie.navTime(end)];
        return;
    end;
    
    % Get the list of waypoints and deNan it
    waypointList = [timeserie.wptLon(:), timeserie.wptLat(:)];
    goodRows = find( sum(isnan(waypointList), 2) == 0 );
    wptMat = waypointList(goodRows);
    
    % Search in which record (row) the waypoint changed.
    % *Note1: Copy the first waypoint at the beginning on the list so
    % 'diff' will have the same size as wptMat (and idx will be right)
    % *Note2: It does not matter if just changes lat or lon, only the row
    idxChange = find(diff([wptMat(1,:); wptMat]) ~= 0);
    [idxRow, ~] = ind2sub(size(wptMat), idxChange);
    
    recordsIdx = goodRows(unique(idxRow));
    periodsList = timeserie.navTime([1, recordsIdx, length(timeserie.navTime)]);

end