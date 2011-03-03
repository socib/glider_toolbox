function griddedData = gridGliderData(processedData)


    % Interpolate profiles in vertical at 1 meter resolution
    maxCasts = max(processedData.profile_index);
    depthResol = 1;
    minDepth   = depthResol * floor(min(processedData.depth) / depthResol);
    maxDepth   = depthResol *  ceil(max(processedData.depth) / depthResol);

    depthRange  = (minDepth:depthResol:maxDepth)';
    depthLevels = length(depthRange);

    % Prepare a structure for gridded data
    nonGriddingVars = {'latitude', 'longitude', 'distanceOverGround', ...
        'navTime', 'sciTime', 'profile_index', ...
        'depth', 'continousDepth', 'pressure'};
    gridCoords.latitudeRange  = zeros(1, maxCasts);
    gridCoords.longitudeRange = zeros(1, maxCasts);
    gridCoords.distanceRange  = zeros(1, maxCasts);
    gridCoords.timeRange      = zeros(1, maxCasts);
    gridCoords.depthRange     = depthRange;

    strucContent = processedData.timeseries;
    griddingVars = setdiff(strucContent, nonGriddingVars);
    for fieldIdx = 1:length(griddingVars)
        currentFieldName = griddingVars{fieldIdx};
        grids.(currentFieldName) = nan(depthLevels, maxCasts);
    end;
    
    for prfIdx = 1:maxCasts
    
        indexRange = find(processedData.profile_index == prfIdx);
        
        gridCoords.latitudeRange(prfIdx)  = nanmean(processedData.latitude(indexRange));
        gridCoords.longitudeRange(prfIdx) = nanmean(processedData.longitude(indexRange));
        gridCoords.timeRange(prfIdx)      = nanmean(processedData.navTime(indexRange));

        % Interpolate data at desired depths for the profile
        interpMethod = 'pchip';
        for fieldIdx = 1:length(griddingVars)
            currentFieldName = griddingVars{fieldIdx};
            currentFieldContent = processedData.(currentFieldName);
            currentFieldContent = currentFieldContent(indexRange);
            currentDepthContent = processedData.depth(indexRange);
            goodRows = find( sum(isnan([currentDepthContent(:), currentFieldContent(:)]), 2) == 0 );

            [knownDepth, idxForward, ~] = unique(currentDepthContent(goodRows));
            knownVal = currentFieldContent(goodRows);
            knownVal = knownVal(idxForward);
            
            if length(knownDepth) >= 2
                currentFieldProfile = interp1(knownDepth, knownVal, depthRange, interpMethod, NaN)';
            else
                currentFieldProfile = nan(size(depthRange));
            end;
            grids.(currentFieldName)(:, prfIdx) = currentFieldProfile(:);
            %griddedField = gridded.(currentFieldName);
            %griddedField(:, prfIdx) = currentFieldProfile(:);
            %gridded.(currentFieldName) = double(griddedField);
        end;
    end;
    
    for fieldIdx = 1:length(griddingVars)
        currentFieldName = griddingVars{fieldIdx};
        meanProfiles.(currentFieldName) = nanmean(grids.(currentFieldName), 2);
        %stdProfiles.(currentFieldName) = nanstd(grids.(currentFieldName), 2);
    end;
    
    gridCoords.distanceRange = [0, m_lldist(gridCoords.longitudeRange, gridCoords.latitudeRange)'];
    
    griddedData.gridCoords = gridCoords;
    griddedData.grids = grids;
    griddedData.meanProfiles = meanProfiles;
    %griddedData.stdProfiles = stdProfiles;
    if isfield(processedData, 'source')
        griddedData.source = processedData.source;
    end;


end