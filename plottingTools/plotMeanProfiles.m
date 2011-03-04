function varargout = plotMeanProfiles(figProperties, profileData, depthRange, texts)
%PLOTMEANPROFILES - Generates profiles plots of given variables
% This function plots a set of mean profiles with their respective 
% standard deviation from the mean. It plots the variables one beside the other
%
% Syntax: imageFilename = plotMeanProfiles(figProperties, profileData, depthRange, texts)
%
% Inputs:
%    figProperties - Structure containing desired figure properties
%    profileData - Structure containing the data
%    depthRange - Vector containing the common depth range vector
%    texts - Texts to be displayed on the figure
%
% Outputs:
%    imagefilename - name of the printed image filename
%
% Example:
%    imageFilename = plotMeanProfiles(figProperties, profileData, depthRange, texts)
%
% Other m-files required: prepareFigure, printImage
% Subfunctions: plotVarProfile
% MAT-files required: none
%
% See also: PLOT, PREPAREFIGURE, PRINTIMAGE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 03-Mar-2011
%

    prepareFigure(figProperties);
    
    for prfIdx = 1:length(profileData),
        labelStr = [profileData(prfIdx).varName, ' (',...
            profileData(prfIdx).varUnits, ')'];
        titleStr = [profileData(prfIdx).varName, ' profiles'];
        subplot(1, length(profileData), prfIdx);
        plotVarProfile(profileData(prfIdx).meanVarProfile, ...
            profileData(prfIdx).stdVarProfile, depthRange, figProperties);
        xlabel(labelStr, ...
            'FontName', figProperties.textFont, ...
            'FontSize', figProperties.textLabelSize);
        ylabel('Depth (m)', ...
            'FontName', figProperties.textFont, ...
            'FontSize', figProperties.textLabelSize);
        title(titleStr, ...
            'FontName', figProperties.textFont, ...
            'FontSize', figProperties.textTitleSize, ...
            'FontWeight', 'bold');
    end;

    if nargout > 0
        varargout{1} = printImage(figProperties, texts);
    else
        printImage(figProperties, texts);
    end
    hold off;

return;

    function plotVarProfile(meanVarProfile, stdVarProfile, depthRange, figProperties)

        meanVarProfile = real(meanVarProfile);
        varLowerBound = meanVarProfile - stdVarProfile;
        varUpperBound = meanVarProfile + stdVarProfile;

        varLimits  = [min(varLowerBound), max(varUpperBound)];
        varMargin  = 0.1 * diff(varLimits, 1);
        varLimits  = varLimits + [-varMargin, varMargin];

        depthLimits = [min(depthRange), max(depthRange)];
        hold on;
        plot(meanVarProfile, depthRange, 'k',  'LineWidth', 2);
        plot(varLowerBound,  depthRange ,'k:', 'LineWidth', 2);
        plot(varUpperBound,  depthRange ,'k:', 'LineWidth', 2);

        set(gca,'XMinorTick','on','ydir','reverse', 'box','on');
        grid on;
        axis([varLimits, depthLimits]);
        set(gca, 'FontName', figProperties.textFont, ...
                 'FontSize', figProperties.textAxisSize);
        goodRows = find(~isnan(meanVarProfile));
        
        [~, surfIdx] = min(depthRange(goodRows));
        [~, deepIdx] = max(depthRange(goodRows));
        surfIdx = goodRows(surfIdx);
        deepIdx = goodRows(deepIdx);

        if meanVarProfile(surfIdx) > meanVarProfile(deepIdx), % Value decreases with depth
            legendLocation2 = 'SouthEast';
        else % Values increase with depth
            legendLocation2 = 'SouthWest';
        end;
        %[legend_h,object_h,plot_h,text_strings] = legend('mean', 'std', ...
        %    'Location', legendLocation2);
        legend('mean', 'std', 'Location', legendLocation2);

    end

end
