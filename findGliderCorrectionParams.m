function [bestGuessCorrectionParams, paramsMeaning] = findGliderCorrectionParams(timeserie, options)

    paramsMeaning = {};
    
    bestGuessCorrectionParams = innerFindGliderCorrectionParams(timeserie, ...
        {'temperature', 'conductivity'}, options);
    %paramsMeaning{end + 1} = 'TH';
    paramsMeaning{end + 1} = {'temperature', 'conductivity'};

    if isfield(timeserie, 'Tcor')
        bestGuessCorrectionParams = [bestGuessCorrectionParams;
            innerFindGliderCorrectionParams(timeserie, ...
                {'Tcor', 'conductivity'}, options)];
        paramsMeaning{end + 1} = 'T_TH';
    end;
    
    if isfield(timeserie, 'Ccor')
        bestGuessCorrectionParams = [bestGuessCorrectionParams;
            innerFindGliderCorrectionParams(timeserie, ...
                {'Tcor', 'Ccor'}, options)];
        paramsMeaning{end + 1} = 'T_C_TH';
    end;

    function bestGuessCorrectionParams = innerFindGliderCorrectionParams(timeserie, varsSet, options)
        
        innerVarsSet = ['sciTime', 'depth', varsSet];
        newFieldNames = {'ptime', 'depth', 'temp', 'cond'};
        if isfield(timeserie, 'pitch')
            innerVarsSet = [innerVarsSet, 'pitch'];
            newFieldNames = [newFieldNames, 'pitch'];
        end;
        
        maxCasts = max(timeserie.profile_index);
        totalCorrectionParams = [];

        % Loop through the list of profiles
        for prfIdx = 1:(maxCasts - 1)

            % Get the range indexes for these profiles
            profile1IdxRange = find(timeserie.profile_index == prfIdx);
            profile2IdxRange = find(timeserie.profile_index == prfIdx + 1);

            basicProfile1Data = buildCombinedProfile(timeserie, profile1IdxRange, innerVarsSet, newFieldNames);
            basicProfile2Data = buildCombinedProfile(timeserie, profile2IdxRange, innerVarsSet, newFieldNames);


            if ~isempty(basicProfile1Data) && ...
               ~isempty(basicProfile1Data.ptime) && ...
               ~isempty(basicProfile2Data) && ...
               ~isempty(basicProfile2Data.ptime) 
               
                % Check if both profiles go in different directions
                prf1Down = basicProfile1Data.depth(end) > basicProfile1Data.depth(1);
                prf2Down = basicProfile2Data.depth(end) > basicProfile2Data.depth(1);
                if xor(prf1Down, prf2Down)
                    disp(['Finding correction params (profile ', num2str(prfIdx), ' of ', num2str(maxCasts),')...']);
                    % THERMAL LAG CORRECTION PARAMETERS ESTIMATION %
                    % Mission an estimation on how good this correction is:
                    % correction quality
                    correctionParams = adjustThermalLagParams(...
                        basicProfile1Data, basicProfile2Data);

%                 if options.debugPlot
%                     basicProfile1Data = correctThermalLag(basicProfile1Data, correctionParams);
%                     basicProfile2Data = correctThermalLag(basicProfile2Data, correctionParams);
% 
%                     cndr = 10* basicProfile1Data.cond / sw_c3515;
%                     basicProfile1Data.salt           = sw_salt(cndr, basicProfile1Data.temp      , basicProfile1Data.depth);
%                     basicProfile1Data.salt_corrected = sw_salt(cndr, basicProfile1Data.tempInCell, basicProfile1Data.depth);
% 
%                     cndr = 10* basicProfile2Data.cond / sw_c3515;
%                     basicProfile2Data.salt           = sw_salt(cndr, basicProfile2Data.temp      , basicProfile2Data.depth);
%                     basicProfile2Data.salt_corrected = sw_salt(cndr, basicProfile2Data.tempInCell, basicProfile2Data.depth);

%                     depthThreshold = 200;
%                     prf1Range = find(basicProfile1Data.depth < depthThreshold);
%                     prf2Range = find(basicProfile2Data.depth < depthThreshold);
% 
%                     figure(33); clf;
% 
%                     subplot(1,2,1);
%                     plot(basicProfile1Data.temp(prf1Range), basicProfile1Data.depth(prf1Range), 'b-',...
%                          basicProfile2Data.temp(prf2Range), basicProfile2Data.depth(prf2Range), 'r-');
%                     set(gca, 'YDir', 'reverse');
% 
%                     subplot(1,2,2);
%                     plot(basicProfile1Data.salt(prf1Range), basicProfile1Data.depth(prf1Range), 'b-',...
%                          basicProfile2Data.salt(prf2Range), basicProfile2Data.depth(prf2Range), 'r-',...
%                          basicProfile1Data.salt_corrected(prf1Range), basicProfile1Data.depth(prf1Range), 'b--',...
%                          basicProfile2Data.salt_corrected(prf2Range), basicProfile2Data.depth(prf2Range), 'r--');
%                     set(gca, 'YDir', 'reverse');
% 
%                     filename = fullfile(options.debugPlotPath, ['profiles', num2str(prfIdx), '.png']);
%                     print('-dpng', filename);
%                     pause(0.5);
%                 end;

                    totalCorrectionParams = [totalCorrectionParams; correctionParams]; %#ok<AGROW>
                else
                    disp(['Dismissing pair ', num2str(prfIdx), '(same direction)']);
                end;
            else
                disp(['Dismissing pair ', num2str(prfIdx)]);
            end;
        end;

        % Find statistically the best guess for the correction parameters set
        if isempty(totalCorrectionParams)
            disp('Warning: could not find any suitable correction params');
            bestGuessCorrectionParams = nan;
            return;
        else
            bestGuessCorrectionParams = median(totalCorrectionParams);
        end;

        if options.debugPlot
            titleList = {'\alpha offset', '\alpha slope', '\tau offset', '\tau slope'};
            figure; clf;
            for k = 1:4
               subplot(2,2,k);
               hist(totalCorrectionParams(:,k), sqrt(size(totalCorrectionParams, 1)) / 2 );
               title([titleList{k}, ':', num2str(bestGuessCorrectionParams(k))]);
            end;
            filename = fullfile(options.debugPlotPath, 'correctionParamsHistogram.png');
            print('-dpng', filename);
        end;
    end 
    
end