function [h, c_h] = fast_scatter(X, Y, C, varargin)
%
% ============================================================================
% $RCSfile: fast_scatter.m,v $
% $Source: /home/kerfoot/cvsroot/matlab/plotting/fast_scatter.m,v $
% $Revision: 1.2 $
% $Date: 2007/04/27 13:08:28 $
% $Author: kerfoot $
% $Name:  $
% 
% USAGE: [h, c_h] = fast_scatter(X, Y, C, varargin)
% 
% A MUCH faster and less memory intensive version of Matlab's scatter.m 
% function.
% 
% Optional arguments, in the form of 'name', value pairs can be used to 
% customize the output of the plot.  
%
% Optional name=value arguments are:
%   
%   'colormap' - integer: specifies the number of rows in the colormap used 
%                   for plotting.  Default is 64 rows.
%   'clim'     - [min max]: specify the minimum and maximum values for 
%                   color-scaling the plots.  Defaults to [min(C) max(C)].
%   'colorbar' - ['horiz'|'vert'|'none']: specify the type of colorbar to 
%                   use (or none at all).  Default is 'horiz'.
%   'marker'   - a structure containing one or both of the following fields
%                   along with a value:
%                   .Marker = valid marker type - Default is '.'
%                   .MarkerSize = integer - Default is 8
%                   .Tag - assign a tag to the plotted points - default tag is
%                   'default_scatter'
%
% ============================================================================
%

% Initialize output arguments
h   = [];
c_h = [];

% Validate args
if isempty(X) || isempty(Y) || isempty(C)
    error('One or more array inputs (X, Y, C) is empty.');
elseif ~isequal(length(X), length(Y)) || ~isequal(length(X), length(C))
    error('Array args must be of equal length.');
end;

% Get rid of rows for which at least one column is NaN
XYC = [X Y C];
XYC(any(isnan(XYC),2),:) = [];

if isempty(XYC)
    return;
end

X = XYC(:,1);
Y = XYC(:,2);
C = XYC(:,3);

% Initialize default settings
cmap              = jet(64);
clim              = [min(C)-eps max(C)+eps];
marker            = struct( 'Marker', '.',...
    'MarkerSize', 7,...     %'MarkerSize', 10,...
    'LineStyle', 'None',...
    'Tag', 'default_scatter');
cbar              = 'horiz';

% Process the options
user_inputs = varargin;      
for x = 1:2:length(user_inputs) - 1
    name  = user_inputs{x};
    value = user_inputs{x+1};

    switch name
        case 'colormap'
            if ischar(value) || isempty(value) || ~isequal(size(value,2), 3)
                disp(['Invalid colormap specified.']);
                return;
            else
                cmap = value;
            end
        case 'clim'
            if ~isnumeric(value) & length(value) ~= 2
                disp(['Invalid color limits.']);
                return;
            else
                clim = [min(value)-0.0001 max(value)+0.0001];
            end
        case 'colorbar'
            colorbar_types = {'vert',...
                    'horiz',...
                };
            if ~isempty(strmatch(value, 'none', 'exact'))
                clear cbar
            elseif ~isempty(strmatch(value, colorbar_types, 'exact'))
                cbar = value;
            else
                disp(['Invalid colorbar arg.']);
                clear cbar
            end

        case 'marker'
            if ~isstruct(value)
                error(['Marker properties arg must be a structure.']);
            else
                marker_props = fieldnames(value);
                for z = 1:length(marker_props)
                    marker.(marker_props{z}) = value.(marker_props{z});
                end
            end

        otherwise
            disp([this_arg ': Invalid option.']);
    end
end


% Set the colormap
colormap(cmap);

set(gca,...
    'NextPlot', 'add');

% Set the ranges for determining marker color
color_ranges = linspace( min(clim), max(clim), size(cmap,1) )';

% I don't know why this works, but by doing it, I don't have to manually set 
% the colorbar
bs_patch = fill(mean(X), mean(Y), 'k');
set(bs_patch,...
    'Visible', 'off');

caxis(clim);

% Determine the color bin and plot the data ==================================

% Minimum color limit
ind = find(C <= color_ranges(1));
if ~isempty(ind)
    marker.Color = cmap(1,:);
    
    % Plot the points
    plot(X(ind), Y(ind), marker);
    
    % Delete points to speed things up
    X(ind,:) = [];
    Y(ind,:) = [];
    C(ind,:) = [];
end;

for x = 1:length(color_ranges) - 1
    
    ind = find(C > color_ranges(x) & C <= color_ranges(x + 1));
    
    if ~isempty(ind)
        
        marker.Color = cmap(x+1,:);
        
        % Plot the points
        plot(X(ind), Y(ind), marker);
        
        % Delete points to speed things up
        X(ind,:) = [];
        Y(ind,:) = [];
        C(ind,:) = [];
        
    end;
    
end;

% Maximum color limit
ind = find(C > color_ranges(end));
if ~isempty(ind)
    
    marker.Color = cmap(end,:);
    
    % Plot the points
    plot(X(ind), Y(ind), marker);
    
    % Delete points to speed things up
    X(ind,:) = [];
    Y(ind,:) = [];
    C(ind,:) = [];
end;

if exist( 'cbar', 'var' )
    c_h = colorbar(cbar);
end

h = findobj('Tag', marker.Tag);
