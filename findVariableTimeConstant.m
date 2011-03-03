function bestGuessCorrectionParam = findVariableTimeConstant(timeserie, varName, options)

    maxCasts = max(timeserie.profile_index);

    totalCorrectionParams = [];
    
    % Loop through the list of profiles
    for prfIdx = 1:(maxCasts - 1)

        % Get the range indexes for these profiles
        profile1IdxRange = find(timeserie.profile_index == prfIdx);
        profile2IdxRange = find(timeserie.profile_index == prfIdx + 1);

        basicProfile1Data.time  = timeserie.sciTime(profile1IdxRange);
        basicProfile1Data.depth = timeserie.depth  (profile1IdxRange);
        %ts = timeserie.(varName);
        %basicProfile1Data.data  = ts(profile1IdxRange);
        basicProfile1Data.data  = timeserie.(varName)(profile1IdxRange);
        basicProfile1Data       = cleanProfile(basicProfile1Data);
        
        basicProfile2Data.time  = timeserie.sciTime(profile2IdxRange);
        basicProfile2Data.depth = timeserie.depth  (profile2IdxRange);
        %ts = timeserie.(varName);
        %basicProfile2Data.data  = ts(profile2IdxRange);
        basicProfile2Data.data  = timeserie.(varName)(profile2IdxRange);
        basicProfile2Data       = cleanProfile(basicProfile2Data);
        
        prf1Down = basicProfile1Data.depth(end) > basicProfile1Data.depth(1);
        prf2Down = basicProfile2Data.depth(end) > basicProfile2Data.depth(1);
        
        %% Check the amount of data in both profiles and oposite directions
        if ~isempty(basicProfile1Data) && ~isempty(basicProfile2Data) ...
            && xor(prf1Down, prf2Down)
            disp(['Finding ', varName, ' time constant params (profile ', num2str(prfIdx), ' of ', num2str(maxCasts),')...']);
            
            timeConstant = adjustTimeConstant(basicProfile1Data, basicProfile2Data);
            totalCorrectionParams = [totalCorrectionParams; timeConstant]; %#ok<AGROW>
        else
            if ~xor(prf1Down, prf2Down)
                disp(['Dismissing pair ', num2str(prfIdx)]);
            else
                disp(['Dismissing pair ', num2str(prfIdx), '(same direction)']);
            end;
        end;
    end;
   
    % Find statistically the best guess for the correction parameters set
    if isempty(totalCorrectionParams)
        disp('Warning: could not find any suitable correction param');
        bestGuessCorrectionParam = nan;
    else
        bestGuessCorrectionParam = median(totalCorrectionParams);
    end;

    if options.debugPlot
        titleStr = [varName, ' TC'];
        figure; clf;
        hist(totalCorrectionParams(:), sqrt(length(totalCorrectionParams)) / 2 );
        title([titleStr, ':', num2str(bestGuessCorrectionParam)]);
        filename = fullfile(options.debugPlotPath, [varName, 'timeResponsecorrectionParamsHistogram.png']);
        try
            print('-dpng', filename);
        catch ME
            disp(ME.message);
        end;
    end;
end