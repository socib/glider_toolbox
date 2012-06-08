function prepareFigure(figProperties)
%PREPAREFIGURE - Prepares a clean figure to plot on
% This function prepares a clean figure with specific size properties
% to plot on
%
% Syntax: prepareFigure(figProperties)
%
% Inputs:
%    figProperties - A structure specifying figure properties like size
%
% Example:
%    prepareFigure(figProperties);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: FIGURE, CLF, SET, GCF
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 04-Mar-2011
%

    figure; clf;
    set(gcf,'PaperUnits',figProperties.paperUnits);
    set(gcf,'PaperSize',[figProperties.paperWidth, figProperties.paperHeight]);
    set(gcf,'PaperPosition',[0, 0, figProperties.paperWidth, figProperties.paperHeight]);

return;