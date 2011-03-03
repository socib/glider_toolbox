function prepareFigure(figProperties)

    figure; clf;
    set(gcf,'PaperUnits',figProperties.paperUnits);
    set(gcf,'PaperSize',[figProperties.paperWidth, figProperties.paperHeight]);
    set(gcf,'PaperPosition',[0, 0, figProperties.paperWidth, figProperties.paperHeight]);
    
return;