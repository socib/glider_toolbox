function [partialProcessedData, partialGriddedData] = trimGliderData(processedData, griddedData, timePeriod)

    % Initialize output
    partialProcessedData = processedData;
    partialGriddedData = griddedData;

    % Trim timeseries
    goodIdx = find(processedData.navTime >= min(timePeriod) & ...
        processedData.navTime <= max(timePeriod));
    fields = processedData.timeseries;
    for k = 1:length(fields)
        currentFieldName = fields{k};
        partialProcessedData.(currentFieldName) = ...
            partialProcessedData.(currentFieldName)(goodIdx);
    end;

    goodIdx = find(processedData.waterInfo.time >= min(timePeriod) & ...
        processedData.waterInfo.time <= max(timePeriod));
    fields = fieldnames(processedData.waterInfo);
    for k = 1:length(fields)
        currentFieldName = fields{k};
        partialProcessedData.waterInfo.(currentFieldName) = ...
            partialProcessedData.waterInfo.(currentFieldName)(goodIdx);
    end;


    % Trim grids
    goodIdx = find(griddedData.gridCoords.timeRange >= min(timePeriod) & ...
        griddedData.gridCoords.timeRange <= max(timePeriod));
    fields = fieldnames(griddedData.grids);
    for k = 1:length(fields)
        currentFieldName = fields{k};
        partialGriddedData.grids.(currentFieldName) = ...
            partialGriddedData.grids.(currentFieldName)(:, goodIdx);
    end;

end