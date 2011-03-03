function varargout = printImage(figProperties, texts)

    % Define image file names
    imgFilename = [texts.imageFilename, '.', figProperties.imFormat];
    
    % Print the image to file 
    print(['-d', figProperties.imDevice], ...
        ['-r', figProperties.imResolution],...
        fullfile(texts.imgsPath, imgFilename));

    % Print the thumbnail to file 
%     thumbFilename = [texts.imageFilename, '_thumb.', figProperties.imFormat];
%     img = imread(fullfile(texts.imgsPath, imgFilename));
%     scaleFactor = figProperties.thumbWidth / ...
%         (figProperties.paperWidth .* str2double(figProperties.imResolution));
%     thumb = imresize(img, scaleFactor);
%     imwrite(thumb, fullfile(texts.imgsPath, thumbFilename), figProperties.imFormat);
    
    close(gcf);

    if nargout > 0
        varargout{1} = imgFilename;
    end
return;
