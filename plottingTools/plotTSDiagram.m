function varargout = plotTSDiagram(figProperties, temperature, salinity, texts)

    prepareFigure(figProperties);
    colormap('gray');
    set(gca, 'color', [1 1 1]);
    hold on;
    
    % Prepare density matrix
    temperature = real(temperature);
    salinity = real(salinity);
    mu = nanmedian(temperature);
    sigma = nanstd(temperature);
    safeTempRange = mu + 2 * sigma * [-1, 1];
    mu = nanmedian(salinity);
    sigma = nanstd(salinity);
    safeSaltRange = mu + 2 * sigma * [-1, 1];
    goodRows = find(temperature > min(safeTempRange) & ...
    temperature < max(safeTempRange) & ...
    salinity > min(safeSaltRange) & ...
    salinity < max(safeSaltRange));
    temperature = temperature(goodRows);
    salinity = salinity(goodRows);
    
    
    ytRange = linspace(min(safeTempRange), max(safeTempRange), 30);
    xsRange = linspace(min(safeSaltRange), max(safeSaltRange), 30);
    [xsMat, ytMat] = meshgrid(xsRange, ytRange);
    zdMat = sw_dens0(xsMat(:), ytMat(:));
    zdMat = reshape(zdMat, size(xsMat)) - 1000;
    
    % Compute density levels
    zdMin = round(min(zdMat(:))*100)/100;
    zdMax = round(max(zdMat(:))*100)/100;
    contourLevels = zdMin:0.2:zdMax;
    
    % Plot measured points
    %density = sw_dens0(salinity, temperature);
    %pointArea = selectPointArea(figProperties);
    %scatter(salinity, temperature, pointArea, density, 'filled');
    plot(salinity, temperature, '.', 'color',[0.6 0.6 0.6]);
    %plot(salinity, temperature, 'ko', 'MarkerFaceColor', 'k');

    % Plot density isolines
    [C,h] = contour(xsMat, ytMat, zdMat, contourLevels, 'k-');
    clabel(C,h, 'FontName', figProperties.textFont, 'fontweight', 'bold');
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2);
    axis([min(xsRange), max(xsRange), min(ytRange), max(ytRange)]);
    axis('square'), axis('tight');
    set(gca, 'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textAxisSize);
    xlabel('Salinity (psu)', 'FontName', figProperties.textFont, 'fontsize', figProperties.textLabelSize);
    ylabel('Temperature (^{o}C)', 'FontName', figProperties.textFont, 'fontsize', figProperties.textLabelSize);
    title('T-S diagram (on \sigma_t contours)', ...
        'FontName', figProperties.textFont, ...
        'fontsize', figProperties.textTitleSize, ...
        'fontweight', 'bold');
    
    if nargout > 0
        varargout{1} = printImage(figProperties, texts);
    else
        printImage(figProperties, texts);
    end
    hold off;

    return;
    
