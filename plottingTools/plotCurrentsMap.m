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

    prepareFigure(figProperties);
    
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
    
    m_proj('mercator','lat',[latMin latMax],'lon',[lonMin lonMax]);
    
    backgroundColor = [.9 .99 1];
    set(gca, 'Color', backgroundColor);
    hold on;

%     bathyLevels = [-20, -50, -100, -200, -500, -1000];
%     m_contour(longrat, latgrat, bathymetry, bathyLevels);
    
    warning off MATLAB:finite;
    landColor = [.7 1 .7];
    coastOption = 10;
    switch coastOption
        case 0
            coastFile = '/home/glider/matlabDevelopment/coastfiles/coast.dat';
            coastData = load(coastFile);
            [cx, cy] = m_ll2xy(coastData(:, 1), coastData(:, 2));
            patch(cx, cy, landColor);
        case 1
            m_coast('patch', landColor);
            %m_gshhs_f(landColor);
        otherwise
            coastFile = '/home/glider/matlabDevelopment/coastfiles/coast2.mat';
            m_gshhs_f('save', coastFile);
            m_usercoast(coastFile, 'patch', landColor);
    end;

    m_plot(lons(:), lats(:), 'k-');
    
    scaleFactor = selectScaleFactor(figProperties);
    if ~isempty(goodRows)
        m_vec(scaleFactor, waterInfo.lon(goodRows), waterInfo.lat(goodRows), ...
            waterInfo.m_final_water_vx(goodRows), waterInfo.m_final_water_vy(goodRows), 'b'); 
        m_vec(scaleFactor, lonMin + margin / 2, latMin + margin / 2, 0.20, 0, 'b', ...
            'key', '20 cm s^{-1}');
    end;
    m_grid('box','fancy','linestyle',':');
    set(gca, 'Color', backgroundColor, ...
        'FontName', figProperties.textFont, ...
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
