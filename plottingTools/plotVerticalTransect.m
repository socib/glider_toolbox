function varargout = plotVerticalTransect(figProperties, cMap, un_xAxis, un_depth, un_var, texts)

    dx = max(un_xAxis) - min(un_xAxis);
    dy = max(un_depth) - min(un_depth);
    aspectRatioAdjustment = dx / (2 * dy);

    prepareFigure(figProperties);
    if aspectRatioAdjustment ~= 0
        set(gca, 'dataaspectratio', [aspectRatioAdjustment 1 1]);
    end
    colormap(cMap);
    hold on;
    %plot(un_xAxis, un_depth, 'k-'); 
    %pointArea = selectPointArea(figProperties);
    %scatter(un_xAxis, un_depth, pointArea, un_var, 'filled');
    
    mu      = nanmedian(un_var);
    sigma   = nanstd(un_var);
    climVec = mu + 1.75 * sigma * [-1, 1];
    [~, hc] = fast_scatter(un_xAxis, un_depth, un_var, ...
        'colorbar', 'horiz', 'clim', climVec);
%     [h, hc] = fast_scatter(un_xAxis, un_depth, un_var, ...
%         'colorbar', 'horiz');
    axis('tight'), axis('ij'), axis('on');
    set(gca, 'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textAxisSize);

    xlabel(texts.xLabelStr, ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textLabelSize);
    if strmatch('time', lower(texts.xLabelStr))
        if dx > 2
            dateFormat = 'dd/mm';
        else
            dateFormat = 'HH:MM';
        end
        datetick('x', dateFormat);
    end
    ylabel('Depth (m)', ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textLabelSize);
    grid on;
    % hc = colorbar('EastOutside');
    decimals = 1e3;
    if figProperties.linearColorScale == 0,
        iniScale = (linspace(min(un_var(:)), max(un_var(:)), 5));
        modScale = round( 10.^iniScale .* decimals) ./ decimals;
        set(hc, 'xtick', iniScale, 'xticklabel', modScale, 'tickdir', 'out');
    end;
    set(get(hc, 'XLabel'), 'String', texts.colorbarTitle, ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textColorbarSize);
    title(texts.figureTitle, ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textTitleSize, ...
        'FontWeight', 'bold');
    
    if nargout > 0
        varargout{1} = printImage(figProperties, texts);
    else
        printImage(figProperties, texts);
    end
    hold off;

return;
