function varargout = plotCurrentsMap(figProperties, waterInfo, texts)

    prepareFigure(figProperties);
    
    goodRows = find(waterInfo.x_dr_state == 4);

    % Prepare map
    lats = [waterInfo.lat(goodRows)'];
    lons = [waterInfo.lon(goodRows)'];
    
    margin = 0.5;
    latMin = min(lats) - margin;
    latMax = max(lats) + margin;
    lonMin = min(lons) - margin;
    lonMax = max(lons) + margin;
    
    m_proj('mercator','lat',[latMin latMax],'lon',[lonMin lonMax]);
    
    backgroundColor = [.9 .99 1];
    set(gca, 'Color', backgroundColor);
    hold on;

%     addpath('F:\Datos\mapas\bathymetries\');
%     [latgrat, longrat, bathymetry] = satbath(1,[latMin latMax],[lonMin lonMax]);
%     rmpath('F:\Datos\mapas\bathymetries\');
%     bathyLevels = [-20, -50, -100, -200, -500, -1000];
%     batCm = [...
%         165,154,248;
%         146,165,255;
%         142,209,235;
%         157,253,190;
%         187,213,168;
%         253,249,201;
%     ] / 255;
%     batCm = flipud(batCm);
%     %colormap(batCm);
%     m_contour(longrat, latgrat, bathymetry, bathyLevels);
    
    %coastFile = 'coastPlot';
    %m_gshhs_f('save', coastFile);
    landColor = [.7 1 .7];
    %m_usercoast(coastFile, 'patch', landColor);
    %warning off MATLAB:finite;
    m_gshhs_i('patch', landColor);

    m_plot(lons(:), lats(:), 'k.');
    
    scaleFactor = selectScaleFactor(figProperties);
    if ~isempty(goodRows)
        m_vec(scaleFactor, waterInfo.lon(goodRows), waterInfo.lat(goodRows), ...
            waterInfo.m_final_water_vx(goodRows), waterInfo.m_final_water_vy(goodRows), 'b'); 
        m_vec(scaleFactor, lonMin + margin / 2, latMin + margin / 2, 0.20, 0, 'b', ...
            'key', '20 cm s^{-1}');
    end;
    m_grid('box','fancy','linestyle',':');
    set(gca, 'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textAxisSize);
    xlabel('Longitude (degrees)', ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textLabelSize);
    ylabel('Latitude (degrees)', ...
        'FontName', figProperties.textFont, ...
        'FontSize', figProperties.textLabelSize);
    title('Glider trajectory and column integrated water currents estimations', ...
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

function scaleFactor = selectScaleFactor(figProperties)

    % Get figure and axis size
    OrigAxUnits = get(gca,'Units');
    if strcmp(OrigAxUnits(1:3), 'nor')
        axposNor = get(gca, 'position');
        axWidLenInches = axposNor(3:4) .* [figProperties.paperWidth, figProperties.paperHeight];
    else
        set(gca, 'units', 'inches');
        axposInches = get(gca, 'position');
        set(gca, 'units', OrigAxUnits);
        axWidLenInches = axposInches(3:4);
    end;

    scx = diff(get(gca, 'XLim')) / axWidLenInches(1);
    scy = diff(get(gca, 'YLim')) / axWidLenInches(2);
    sc  = max(scx, scy);
    
    % Compute the desired scale factor
    characteristicLength = 0.01;
    scaleFactor = sc / characteristicLength;
    
return;
