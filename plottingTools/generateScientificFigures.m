function varargout = generateScientificFigures(processedData, griddedData, imageryPath, imgPreffix)
%GENERATESCIENTIFICFIGURES - Main function to generate all glider plots
% This function generates all the possible plots, given the glider data
%
% Syntax: imgList = generateScientificFigures(processedData, griddedData, imageryPath, imgPreffix)
%
% Inputs:
%    processedData - The resulting structur from processGliderData
%    griddedData - The resulting structur from gridGliderData
%    imageryPath - Folder where resulting images should be stored
%    imgPreffix - Preffix for the generated image files
%
% Outputs:
%    imgList - A structure vector containing the list of generated images
%       along with a description and their respective title
%
% Example:
%    imgList = generateScientificFigures(processedData, griddedData, imageryPath, imgPreffix)
%
% Other m-files required: setFigureProperties, plotVerticalTransect,
%   plotMeanProfiles, plotTSDiagram, plotCurrentsMap
% Subfunctions: none
% MAT-files required: none
%
% See also: PROCESSGLIDERDATA, GRIDGLIDERDATA,
%   SETFIGURESPROPERTIES, PLOTVERTICALTRANSECT,
%   PLOTMEANPROFILES, PLOTTSDIAGRAM, PLOTCURRENTSMAP
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 04-Mar-2011
%

    [figProperties, cmJet] = setFiguresProperties([1280, 768]);

    texts.imgsPath = imageryPath;

    imageList = struct('name', {}, 'description', {}, 'path', {});
    

    % Plot vertical transects of in situ Temperature, Salinity and Density
    desiredAxis = 'dist';
    switch lower(desiredAxis),
        case 'time'
            texts.xLabelStr = 'Time';
            xAxisVar = epoch2datenum(processedData.navTime);
        case 'dist'
            texts.xLabelStr = 'Distance (Km)';
            xAxisVar = processedData.distanceOverGround;
        case 'lat'
            texts.xLabelStr = 'Latitude (Degrees)';
            xAxisVar = processedData.lat;
        case 'lon'
            texts.xLabelStr = 'Longitude (Degrees)';
            xAxisVar = processedData.lon;
    end;

    if isfield(processedData, 'temperature')
        texts.colorbarTitle = 'Temperature (^{o}C)';
        texts.figureTitle = 'In Situ Temperature';
        texts.imageFilename = [imgPreffix, 'temperature'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.temperature, texts);
        imageList(end+1).name = 'Temperature Section';
        imageList(end).description = ['Cross Section of in situ measured temperature', genStr];
        imageList(end).path = fn;
    end;
    
    if isfield(processedData, 'salinity_corrected_TH')
        texts.colorbarTitle = 'Salinity (PSU)';
        texts.figureTitle = 'In Situ Salinity (Thermal Lag corrected)';
        texts.imageFilename = [imgPreffix, 'salinity'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.salinity_corrected_TH, texts);
        imageList(end+1).name = 'Salinity Section';
        imageList(end).description = ['Cross Section of thermal lag corrected derived salinity', genStr];
        imageList(end).path = fn;
        
    elseif isfield(processedData, 'salinity')
        texts.colorbarTitle = 'Salinity (PSU)';
        texts.figureTitle = 'In Situ Salinity';
        texts.imageFilename = [imgPreffix, 'salinity'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.salinity, texts);
        imageList(end+1).name = 'Salinity Section';
        imageList(end).description = ['Cross Section of derived salinity', genStr];
        imageList(end).path = fn;
    end;
		
    if isfield(processedData, 'density')
        texts.colorbarTitle = 'Density (Kg m-3)';
        texts.figureTitle = 'In Situ Density';
        texts.imageFilename = [imgPreffix, 'density'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.density, texts);
        imageList(end+1).name = 'Density Section';
        imageList(end).description = ['Cross Section of derived density', genStr];
        imageList(end).path = fn;

    end;

    if isfield(processedData, 'sound_velocity')
        texts.colorbarTitle = 'Sound Speed (m s-1)';
        texts.figureTitle = 'Sound Speed';
        texts.imageFilename = [imgPreffix, 'soundspeed'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.sound_velocity, texts);
        imageList(end+1).name = 'Sound Velocity Section';
        imageList(end).description = ['Cross Section of in situ measured salinity', genStr];
        imageList(end).path = fn;

    end;
    
    % Plot vertical transects of in situ Chlorophyll, Turbidity and Oxygen
    if isfield(processedData, 'chlorophyll')
        texts.colorbarTitle = 'Chlorophyll (\mug l-1)';
        texts.figureTitle = 'In Situ Chlorophyll';
        texts.imageFilename = [imgPreffix, 'chlorophyll'];
        figProperties.linearColorScale = 0;

        varValues = processedData.chlorophyll;
        varValues(varValues <= 0) = eps; % Avoid inf results
        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, log10(varValues), texts);
        imageList(end+1).name = 'Chlorophyll Section';
        imageList(end).description = ['Cross Section of derived chlorophyll', genStr];
        imageList(end).path = fn;
    end;

    if isfield(processedData, 'cdom')
        texts.colorbarTitle = 'CDOM (ppb)';
        texts.figureTitle = 'In Situ CDOM';
        texts.imageFilename = [imgPreffix, 'cdom'];
        figProperties.linearColorScale = 0;

        varValues = processedData.cdom;
        varValues(varValues <= 0) = eps;
        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, log10(varValues), texts);
        imageList(end+1).name = 'CDOM Section';
        imageList(end).description = ['Cross Section of in situ measured CDOM', genStr];
        imageList(end).path = fn;
    end;
    
    if isfield(processedData, 'turbidity')
        texts.colorbarTitle = 'Turbidity (NTU)';
        texts.figureTitle = 'In Situ Turbidity';
        texts.imageFilename = [imgPreffix, 'turbidity'];
        figProperties.linearColorScale = 0;

        varValues = processedData.turbidity;
        varValues(varValues <= 0) = eps;
        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, log10(varValues), texts);
        imageList(end+1).name = 'Turbidity Section';
        imageList(end).description = ['Cross Section of in situ measured turbidity', genStr];
        imageList(end).path = fn;
    end;
    
    if isfield(processedData, 'oxygen_saturation')
        texts.colorbarTitle = 'Oxygen (perc.)';
        texts.figureTitle = 'In Situ Oxygen Saturation';
        texts.imageFilename = [imgPreffix, 'oxygen_saturation'];
        figProperties.linearColorScale = 1;

        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotVerticalTransect(figProperties, cmJet, ...
            xAxisVar, processedData.depth, processedData.oxygen_saturation, texts);
        imageList(end+1).name = 'Oxygen Section';
        imageList(end).description = ['Cross Section of in situ measured dissolved oxygen', genStr];
        imageList(end).path = fn;
    end;

    % Irradiance
    for wavLen = [412, 442, 491, 664]
        varName = sprintf('irradiance%03dnm', wavLen);
        if isfield(processedData, varName)
            varValues = processedData.(varName);
            varValues(varValues <= 0) = min(varValues(varValues > 0)) / 2;
            texts.colorbarTitle = 'Irradiance (uW/cm^2/nm)';
            texts.figureTitle = sprintf('Irradiance at %03d nm', wavLen);
            texts.imageFilename = [imgPreffix, varName];
            figProperties.linearColorScale = 0;
            
            genStr = [' (generated on ', datestr(now, 31), ')'];
            fn = plotVerticalTransect(figProperties, cmJet, ...
                xAxisVar, processedData.depth, log10(varValues), texts);
            imageList(end+1).name = [varName, ' Section'];
            imageList(end).description = ['Cross Section of in situ measured ', varName, genStr];
            imageList(end).path = fn;
        end;
    end;
    
    % Backscatter:
    colorChannels = {'470', '532', '660'};
    for channelIdx = 1:length(colorChannels)
        varName = sprintf('backscatter%s', colorChannels{channelIdx});
        if isfield(processedData, varName)
            varValues = processedData.(varName);
            varValues(varValues <= 0) = min(varValues(varValues > 0));
            texts.colorbarTitle = 'Backscatter (1)';
            texts.figureTitle = sprintf('%s backscatter', colorChannels{channelIdx});
            texts.imageFilename = [imgPreffix, varName];
            figProperties.linearColorScale = 0;
            
            genStr = [' (generated on ', datestr(now, 31), ')'];
            fn = plotVerticalTransect(figProperties, cmJet, ...
                xAxisVar, processedData.depth, log10(varValues), texts);
            imageList(end+1).name = [varName, ' Section'];
            imageList(end).description = ['Cross Section of in situ measured ', varName, genStr];
            imageList(end).path = fn;
        end;
    end

    % Plot mean vertical profiles of in situ Temperature, Salinity and Density
    if isfield(griddedData, 'grids') && ...
        isfield(griddedData, 'meanProfiles') && ...
        isfield(griddedData, 'stdProfiles') && ...
        all(isfield(griddedData.meanProfiles, ...
            {'temperature';'salinity'; 'density'})) && ...
        all(isfield(griddedData.stdProfiles, ...
            {'temperature';'salinity'; 'density'})) 
         
        texts.imageFilename = [imgPreffix, 'ctd_profiles'];

        clear profileData;
        profileData(1).meanVarProfile = griddedData.meanProfiles.temperature;
        profileData(1).stdVarProfile  = griddedData.stdProfiles.temperature;
        profileData(1).varName        = 'Temperature';
        profileData(1).varUnits       = '^{o}C';

        if isfield(griddedData.meanProfiles, 'salinity_corrected_TH') && ...
            isfield(griddedData.stdProfiles, 'salinity_corrected_TH')
            profileData(2).meanVarProfile = griddedData.meanProfiles.salinity_corrected_TH;
            profileData(2).stdVarProfile  = griddedData.stdProfiles.salinity_corrected_TH;
        else
            profileData(2).meanVarProfile = griddedData.meanProfiles.salinity;
            profileData(2).stdVarProfile  = griddedData.stdProfiles.salinity;
        end;
        profileData(2).varName        = 'Salinity';
        profileData(2).varUnits       = 'psu';

        profileData(3).meanVarProfile = griddedData.meanProfiles.density;
        profileData(3).stdVarProfile  = griddedData.stdProfiles.density;
        profileData(3).varName        = 'Density';
        profileData(3).varUnits       = 'Kg/m^3';
    
        for k = 1:length(profileData)
            if any(isnan(profileData(k).stdVarProfile))
                refVar = griddedData.gridCoords.depthRange;
                goodIdx = find(~isnan(profileData(k).stdVarProfile));
                profileData(k).stdVarProfile = ...
                    interp1(refVar(goodIdx), profileData(k).stdVarProfile(goodIdx), ...
                    refVar, 'pchip', NaN);
            end;
        end;
        
        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotMeanProfiles(figProperties, profileData,...
            griddedData.gridCoords.depthRange, texts);
        imageList(end+1).name = ' CTD Profiles';
        imageList(end).description = ['CTD Profiles', genStr];
        imageList(end).path = fn;

    end;
    
    if isfield(griddedData, 'grids') && ...
        isfield(griddedData, 'meanProfiles') && ...
        isfield(griddedData, 'stdProfiles') && ...
        all(isfield(griddedData.meanProfiles, ...
            {'chlorophyll'; 'turbidity'})) && ...
        all(isfield(griddedData.stdProfiles, ...
            {'chlorophyll'; 'turbidity'})) 
         
        texts.imageFilename = [imgPreffix, 'bgc_profiles'];

        clear profileData;
        profileData(1).meanVarProfile = griddedData.meanProfiles.chlorophyll;
        profileData(1).stdVarProfile  = griddedData.stdProfiles.chlorophyll;
        profileData(1).varName        = 'Chlorophyll';
        profileData(1).varUnits       = 'ug l-1';

        profileData(2).meanVarProfile = griddedData.meanProfiles.turbidity;
        profileData(2).stdVarProfile  = griddedData.stdProfiles.turbidity;
        profileData(2).varName        = 'Turbidity';
        profileData(2).varUnits       = 'NTU';

        for k = 1:length(profileData)
            if any(isnan(profileData(k).stdVarProfile))
                refVar = griddedData.gridCoords.depthRange;
                goodIdx = find(~isnan(profileData(k).stdVarProfile));
                profileData(k).stdVarProfile = ...
                    interp1(refVar(goodIdx), profileData(k).stdVarProfile(goodIdx), ...
                    refVar, 'pchip', NaN);
            end;
        end;
        
        genStr = [' (generated on ', datestr(now, 31), ')'];
        fn = plotMeanProfiles(figProperties, profileData,...
            griddedData.gridCoords.depthRange, texts);
        imageList(end+1).name = ' Chlor Profiles';
        imageList(end).description = ['Chlorohpyll and Turbidity Profiles', genStr];
        imageList(end).path = fn;

    end;

    if isfield(griddedData, 'grids') && ...
        isfield(griddedData, 'meanProfiles') && ...
        isfield(griddedData, 'stdProfiles') && ...
        all(isfield(griddedData.meanProfiles, ...
            {'oxygen'; 'oxygen_saturation'})) && ...
        all(isfield(griddedData.stdProfiles, ...
            {'oxygen'; 'oxygen_saturation'})) 
         
        texts.imageFilename = [imgPreffix, 'oxy_profiles'];

        clear profileData;
        profileData(1).meanVarProfile = griddedData.meanProfiles.oxygen;
        profileData(1).stdVarProfile  = griddedData.stdProfiles.oxygen;
        profileData(1).varName        = 'Oxygen';
        profileData(1).varUnits       = 'ug l-1';

        profileData(2).meanVarProfile = griddedData.meanProfiles.oxygen_saturation;
        profileData(2).stdVarProfile  = griddedData.stdProfiles.oxygen_saturation;
        profileData(2).varName        = 'Oxygen Sat.';
        profileData(2).varUnits       = '1e2';
        
        for k = 1:length(profileData)
            if any(isnan(profileData(k).stdVarProfile))
                refVar = griddedData.gridCoords.depthRange;
                goodIdx = find(~isnan(profileData(k).stdVarProfile));
                profileData(k).stdVarProfile = ...
                    interp1(refVar(goodIdx), profileData(k).stdVarProfile(goodIdx), ...
                    refVar, 'pchip', NaN);
            end;
        end;
        
        genStr = [' (generated on ', datestr(now, 31), ')'];
        try
            fn = plotMeanProfiles(figProperties, profileData,...
                griddedData.gridCoords.depthRange, texts);
            imageList(end+1).name = ' OXY Profiles';
            imageList(end).description = ['Oxygen and Saturation Profiles', genStr];
            imageList(end).path = fn;
        catch ME
            disp('Could not perform the Mean Profiles plot');
            disp(getReport(ME, 'extended'));
        end;
    end;

    
    [figProperties, ~] = setFiguresProperties([1280, 1024]);

    % Plot a TS Diagram for water masses identification
    if isfield(processedData, 'temperature') && (...
            isfield(processedData, 'salinity') || ...
            isfield(processedData, 'salinity_corrected_TH'))
        
        texts.imageFilename = [imgPreffix, 'ts_diagram'];
        if isfield(processedData, 'salinity_corrected_TH')
            salt = processedData.salinity_corrected_TH;
        else
            salt = processedData.salinity;
        end;
        genStr = [' (generated on ', datestr(now, 31), ')'];
        try
            fn = plotTSDiagram(figProperties, processedData.profile_index, processedData.temperature, salt, texts);
            imageList(end+1).name = 'TS Diagram';
            imageList(end).description = ['Temperature vs. Salinity Diagram', genStr];
            imageList(end).path = fn;
        catch ME
            disp('Could not perform the TS Diagram plot');
            disp(getReport(ME, 'extended'));
        end;
    end;
    
    % Plot a horizontal map to check glider trajectory
    % and currents found along the way
    if isfield(processedData, 'waterInfo')
        texts.imageFilename = [imgPreffix, 'currents'];
        genStr = [' (generated on ', datestr(now, 31), ')'];
        try
            fn = plotCurrentsMap(figProperties, processedData.waterInfo, texts);
            imageList(end+1).name = 'Currents Map';
            imageList(end).description = ['Map with vertically integrated currents derived from navigation', genStr];
            imageList(end).path = fn;
        catch ME
            disp('Could not perform the Currents Map plot');
            disp(getReport(ME, 'extended'));
        end;
        
    end;
    % Plot gridded vertical sections here?

    close all;
    
    if nargout > 0
    	varargout{1} = imageList;
    end

end
