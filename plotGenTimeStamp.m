function plotGenTimeStamp

    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

    pos = get(gca, 'OuterPosition');
    cornerX = pos(1) + pos(3); % x_0 + width
    cornerY = pos(2) + pos(4); % y_0 + height
    genString = ['Image generated at ' datestr(now)];
    text(cornerX, cornerY, genString, ...
        'HorizontalAlignment', 'Right', ...
          'VerticalAlignment', 'Top');

end