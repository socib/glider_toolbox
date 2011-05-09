function periodsList = getTransects(navTime, wptLon, wptLat)
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

    % Get the list of waypoints and deNan it
    waypointList = [wptLon(:), wptLat(:)];
    goodRows = find( sum(isnan(waypointList), 2) == 0 );
    wptMat = waypointList(goodRows, :);
    
    % Search in which record (row) the waypoint changed.
    % *Note1: Copy the first waypoint at the beginning on the list so
    % 'diff' will have the same size as wptMat (and idx will be right)
    % *Note2: It does not matter if just changes lat or lon, only the row
    extMat = [wptMat(1,:); wptMat];
    idxChange = find(diff(extMat, 1, 1) ~= 0);
    [idxRow, ~] = ind2sub(size(wptMat), idxChange);
    
    recordsIdx = goodRows(unique(idxRow));
    periodsList = navTime([1; recordsIdx(:); length(navTime)]);

%     plot(wptMat(:,1), wptMat(:,2), 'ko-');
%     h = [];
%     for k = 1:size(wptMat, 1)
%         if ~isempty(h)
%             delete(h);
%         end;
%         plot(wptMat(:,1), wptMat(:,2), 'ko-');
%         h = text(wptMat(k, 1) + 0.01, wptMat(k, 2) - 0.01, num2str(k));
%         pause(1.5);
%     end;
%     
    plot(wptLon(recordsIdx), wptLat(recordsIdx), 'ko-');
    h = [];
    for k = 1:length(recordsIdx)
        if ~isempty(h)
            delete(h);
        end;
        h = text(wptLon(recordsIdx(k))+0.01, wptLat(recordsIdx(k))-0.01, num2str(k));
        pause(1.5);
    end;    
    
end