function varargout = plotCurrentsMap(figProperties, waterInfo, texts)
%PLOTCURRENTSMAP - Plot a map with glider trajectory and inferred currents
% This function plots a map with the glider trajectory and over imposes
% a set of vectors indicating the inferred vertically averaged currents
% estimated at each surfacing point.
%
% Syntax: imageFilename = plotCurrentsMap(figProperties, waterInfo, texts)
%
% Inputs:
%    figProperties - Structure containing desired figure properties
%    waterInfo - water currents information
%    texts -  Texts to be displayed on the figure
%
% Outputs:
%    imageFilename - name of the generated image file
%
% Example:
%    imageFilename = plotCurrentsMap(figProperties, waterInfo, texts);
%
% Other m-files required: prepareFigure, printImage, m_map toolbox
% Subfunctions: selectScaleFactor
% MAT-files required: none
%
% See also: PREPAREFIGURE, PRINTIMAGE, 
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 04-Mar-2011
%

    prepareFigure(figProperties); hold on;
    
    % Based on WRC documentation, x_dr_state possible values are
    % mission_start    = 0
    % underwater       = 1
    % awaiting_fix     = 2
    % awaiting_postfix = 3
    % awaiting_dive    = 4
    goodRows = find(waterInfo.x_dr_state == 4);

    % Prepare map limits
    lats = waterInfo.lat(goodRows)';
    lons = waterInfo.lon(goodRows)';
    
    margin = 0.5;
    latMin = min(lats) - margin;
    latMax = max(lats) + margin;
    lonMin = min(lons) - margin;
    lonMax = max(lons) + margin;
    
    LatLim = [latMin, latMax];
    LonLim = [lonMin, lonMax];

    imgHeight = figProperties.paperHeight * str2double(figProperties.imResolution);
    imgWidth  = figProperties.paperWidth * str2double(figProperties.imResolution);

    lon = linspace(lonMin, lonMax, imgWidth);
    lat = fliplr(linspace(latMin, latMax, imgHeight));

    layers = [];
    for wmsIdx = 1:1
        switch wmsIdx
            case 1
                serverURL = 'http://labs.metacarta.com/wms/vmap0';
                layerName = 'basic';
            case 2
                serverURL = 'http://scb-gisserver:8080/geoserver/wms';
                layerName = 'gn:wmed_mcb200v40';
        end;
        server = WebMapServer(serverURL);
        try
            capabilities = server.getCapabilities();
            [membership, position] = ismember(layerName, capabilities.LayerNames);
            if membership
                layer = capabilities.Layer(position);
                layers = [layers; layer];
            end;
        catch ME
            disp('getCapabilities did not work as expected');
            disp(getReport(ME, 'extended'));
        end;
        
    end;    
    try
        [rasterMap, geoReference, webMapRequest] = wmsread(layers, ...
                    'LatLim', LatLim, ...
                    'LonLim', LonLim, ...
                    'ImageFormat', 'image/png', ...
                    'ImageHeight', imgHeight, ...
                    'ImageWidth', imgWidth, ...
                    'Transparent', false, ...
                    'TimeoutInSeconds', 10);
    catch ME
        disp('WMS did not work as expected');
        disp(getReport(ME, 'extended'));
    end;

    image(lon(:)', lat(:), rasterMap);
    axis xy equal tight;

    plot(lons(:), lats(:), 'k-');
    
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
    
    arrowColor = [0.9 0.8, 0.1];
    
    quivers(waterInfo.lon(goodRows), ...
            waterInfo.lat(goodRows), ...
            waterInfo.m_final_water_vx(goodRows), ...
            waterInfo.m_final_water_vy(goodRows),...
            scaleFactor, 1, 'm s^{-1}', ...
            {'Color', arrowColor, 'LineWidth', 2}, ...
            {'Color', [0 0 0], ...
            'FontName', figProperties.textFont, ...
            'FontSize', figProperties.textAxisSize});

    set(gca, 'xlim', [lonMin lonMax], ... 
        'ylim', [latMin latMax], ... 
        'xgrid', 'on', ... 
        'ygrid', 'on', ... 
        'gridlinestyle', ':', ... 
        'xcolor', 'k', ... 
        'ycolor', 'k', ...
        'layer', 'top');

    box on;
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
