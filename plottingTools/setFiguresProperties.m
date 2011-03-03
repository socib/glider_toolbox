function [figProperties, cmJet] = setFiguresProperties(desiredImgSize)

    % General Plot figures properties: colormaps, formats, resolutions...
    cmJet        = colormap('jet'); % Colormap for temperature plots
    bgColor      = 0.8 * ones(1,3); % Background color for axis
    imFormat     = 'png';
    imDevice     = imFormat;

    paperUnits = 'inches';
    

    % Figures in real-time: web-destinated
    % - Ghostscript restriction: only 72dpi
    % - Desired size in pixels: ex. [1024, 768]
    imResolution = '72';
    paperWidth  = max(desiredImgSize(:)) / str2double(imResolution);
    paperHeight = min(desiredImgSize(:)) / str2double(imResolution);

    % % Figures in delayed-mode: high quality for papers and reports
%     imResolution = '150';
%     % % A5 size: 148 x 210 mm
%     cm2inches = 1 / 2.54;
%     paperWidth  = 21.0 * cm2inches;
%     paperHeight = 14.8 * cm2inches;

    set(0,'DefaultFigurePaperPositionMode','manual');
    set(0,'DefaultFigurePaperUnits',paperUnits);
    set(0,'DefaultFigurePaperSize',[paperWidth, paperHeight]);
    set(0,'DefaultFigurePaperPosition',[0, 0, paperWidth, paperHeight]);
    set(0,'DefaultFigureColor',[1 1 1]);
    set(0,'DefaultFigureInvertHardcopy','off');

    set(0, 'DefaultAxesColor', bgColor);
    set(0, 'DefaultAxesXtickmode','auto');
    set(0, 'DefaultAxesYtickmode','auto');
    set(0, 'DefaultAxesZtickmode','auto');
    close;

    figProperties.thumbWidth = 100;
    figProperties.paperUnits = paperUnits;
    figProperties.paperWidth = paperWidth;
    figProperties.paperHeight = paperHeight;
    figProperties.imFormat = imFormat;
    figProperties.imDevice = imDevice;
    figProperties.imResolution = imResolution;
    figProperties.linearColorScale = 1;
    
    figProperties.textFont         = 'Verdana';
    figProperties.textAxisSize     = 20;
    figProperties.textColorbarSize = 20;
    figProperties.textLabelSize    = 24;
    figProperties.textTitleSize    = 32;
    
end