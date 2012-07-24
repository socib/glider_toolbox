function varargout = printImage(figProperties, texts)
%PRINTIMAGE - Prints an image of the current figure with specific properties
% This function prints the current figure in an image file with specific
% properties like the format and size. It can also create a thumbnail view
%
% Syntax: imageName = printImage(figProperties, texts)
%
% Inputs:
%    figProperties - A structure specifying figure properties like size
%    texts - A structure containing the files names and paths
%
% Outputs:
%    imageName - Name of the generated image file
%
% Example:
%    imageName = printImage(figProperties, texts)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: PRINT, IMREAD, IMRESIZE, IMWRITE
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 04-Mar-2011
%

    % Define image file names
    imgFilename = [texts.imageFilename, '.', figProperties.imFormat];
    epsFilename = [texts.imageFilename, '.eps'];

    % Print the image to file
%     print(['-d', figProperties.imDevice], ...
%           ['-r', figProperties.imResolution], ...
%           fullfile(texts.imgsPath, imgFilename));

    % Print an eps (vector, no raster) intermediate file
    print('-depsc2', ['-r', figProperties.imResolution], fullfile(texts.imgsPath, epsFilename));

    % Convert eps to user desired format using ImageMagick system command
    [isError, result] = system(['convert', ...
        ' -size ', num2str(figProperties.imWidth), 'x', num2str(figProperties.imHeight), ...
        ' -density ', figProperties.imResolution, ...
        ' -font ', figProperties.textFont, ...
        ' -quality 100', ...
        ' ', fullfile(texts.imgsPath, epsFilename), ...
        ' ', fullfile(texts.imgsPath, imgFilename)]);
    if isError
        disp(['ImageMagick convert command failed:', result]);
    else
        delete(fullfile(texts.imgsPath, epsFilename));
    end;

    % Print the thumbnail to file if required
    if isfield(figProperties, 'thumbnailDesired') && figProperties.thumbnailDesired
        thumbFilename = [texts.imageFilename, '_thumb.', figProperties.imFormat];
        img = imread(fullfile(texts.imgsPath, imgFilename));
        scaleFactor = figProperties.thumbWidth / ...
            (figProperties.paperWidth .* str2double(figProperties.imResolution));
        thumb = imresize(img, scaleFactor);
        imwrite(thumb, fullfile(texts.imgsPath, thumbFilename), figProperties.imFormat);
    end;

    close(gcf);

    if nargout > 0
        varargout{1} = imgFilename;
    end;

return;
