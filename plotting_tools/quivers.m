function hh = quivers(x, y, u, v, Gscale, Spos, Sunit, lineProps, textProps)
%QUIVERS Quiver plot with reference vector showing scale .
%   QUIVERS(x,y,u,v,Gscale,Spos,Sunit) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).
%
%   Gscale scales the arrows to fit within the grid and then stretches them by Gscale.
%
%   Spos defines the location of the scale:
%   Spos=1: top right, Spos=2: top left, Spos=3: bottom left, Spos=4: bottom right
%
%   Sunit is a text string defining the scale to be displayed.
%
%   Acol is the color of the arrows.
%
%   Example:
%   load wind
%   x=x(1,:,1); y=y(:,1,1)';
%   [X,Y]=meshgrid(x,y);
%   n=6; u=u(:,:,n);  v=v(:,:,n);
%   quivers(X,Y,u,v,2,1,'m/s','k')
%
%   Bertrand Dano, 06-19-2009
%   Improved from Clay M. Thompson 3-3-94


    % Arrow head parameters
    alpha = 0.33; % Size of arrow head relative to the length of the vector
    beta  = 0.33; % Width of the base of the arrow head relative to the length

    Vmag = sqrt(u.^2 + v.^2);
    Vmax = round(max(Vmag(:)));
    k = 0;
    while Vmax == 0
        k = k + 1;
        Vmax = round(10^k * max(Vmag(:))) / 10^k;
    end

    autoscale = Gscale;
    if autoscale,
      % Base autoscale value on average spacing in the x and y
      % directions.  Estimate number of points in each direction as
      % either the size of the input arrays or the effective square
      % spacing if x and y are vectors.
      if min(size(x)) == 1
          n = sqrt(numel(x));
          m = n;
      else
          [m, n] = size(x);
      end;
      delx = diff([min(x(:)) max(x(:))]) / n;
      dely = diff([min(y(:)) max(y(:))]) / m;
      del = delx.^2 + dely.^2;
      if del > 0
        len = sqrt((u.^2 + v.^2) / del);
        maxlen = max(len(:));
      else
        maxlen = 0;
      end;

      autoscale = autoscale * 0.9;
      if maxlen>0
        autoscale = autoscale / maxlen;
      end;
      u = u * autoscale;
      v = v * autoscale;
    end



    Vmaxs = Vmax * autoscale;

    ax = newplot;
    next = lower(get(ax,'NextPlot'));
    hold_state = ishold;

    % Make velocity vectors
    x = x(:).';
    y = y(:).';
    u = u(:).';
    v = v(:).';
    uu = [x; x + u; NaN(size(u))];
    vv = [y; y + v; NaN(size(u))];

    h1 = plot(uu(:), vv(:), lineProps{:});

    % Make arrow heads and plot them
    hu = [x + u - alpha * (u + beta * (v + eps)); x + u; ...
          x + u - alpha * (u - beta * (v + eps)); NaN(size(u))];
    hv = [y + v - alpha * (v - beta * (u + eps)); y + v; ...
          y + v - alpha * (v + beta * (u + eps)); NaN(size(v))];
    hold on;
    h2 = plot(hu(:), hv(:), lineProps{:});

    if ~hold_state
        hold off;
        view(2);
        set(ax,'NextPlot',next);
    end;

    if nargout > 0
        hh = [h1; h2; h3];
    end;

    % draw vector and scale
    set(gcf, 'color', [1 1 1]);
    axis image;

    hx = get(gca,'xlim');
    hy = get(gca,'ylim');
    lx = (hx(2) - hx(1)) / 5;
    ly = lx / 3;

    switch Spos
        case 1
            rx = hx(2) - lx;
            ry = hy(2) - ly;
        case 2
            rx = hx(1);
            ry = hy(2) - ly;
        case 3
            rx = hx(1);
            ry = hy(1);
        otherwise
            rx = hx(2) - lx;
            ry = hy(1);
    end;

    rectangle('Position', [rx ry lx ly], 'Facecolor', 'w', 'EdgeColor', 'k');

    hold on;
    u = Vmaxs;
    v = 0;

    x  = rx + (lx - Vmaxs) / 2;
    y  = ry + ly - ly / 3;
    hu = [x; x + u; x + u - alpha * (u + beta * (v + eps)); x + u; x + u - alpha * (u - beta * (v + eps))];
    hv = [y; y + v; y + v - alpha * (v - beta * (u + eps)); y + v; y + v - alpha * (v + beta * (u + eps))];
    plot(hu(:), hv(:), lineProps{:});

    xt = x;
    yt = ry + ly - 2 * ly / 3;

    legendText = [num2str(Vmax), ' ', Sunit];
    ht = text(xt, yt, legendText, textProps{:});

    if nargout > 0
        hh = [hh; ht];
    end;

%     D  = get(ht, 'extent');
%     set(ht, 'visible', 'off');
%
%     xt = rx + (lx - D(3)) / 2;
%     ht = text(xt, yt, legendText, textProps{:});

end
