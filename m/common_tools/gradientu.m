function varargout = gradientu(f,varargin)
%GRADIENT Approximate gradient function patched to deal with unevenly spaced coordinates.
%
%   [FX1,...,FXN] = GRADIENT(F, H1,...,HN) returns the numerical gradient of the
%   matrix F using central differences as in function GRADIENT, but with a
%   second order accurate formula for the case of unevenly spaced coordinates.
%
%   Notes:
%     The original formula for interior points in GRADIENT is:
%       h = h(3:n) - h(1:n-2);
%       g(2:n-1,:) = (f(3:n,:)-f(1:n-2,:))./h(:,ones(p,1));
%     It is replaced by:
%       dh = diff(h);
%       df_dh = (f(2:n,:) - f(1:n-1,:)) ./ dh(:,ones(p,1));
%       ddh = h(3:n) - h(1:n-2);
%       g(2:n-1,:) = (dh(2:end,  ones(p,1)) .* df_dh(1:end-1,:) + ...
%                     dh(1:end-1,ones(p,1)) .* df_dh(2:end,  :) ) ...
%                   ./ ddh(:,ones(p,1));
%
%   Examples:
%       x = [-1 -0.5 0 0.5 1]; % evenly spaced
%       y = [-1 -0.6 0 0.4 1]; % unevenly spaced
%       [xgrid,ygrid] = meshgrid(x,y);
%       z = xgrid .* exp(-xgrid.^2 - ygrid.^2);
%       [px1,py1] = gradient(z, x, y);
%       [px2,py2] = gradientu(z, x, y);
%       all(px1 == px2);
%       figure();
%       contour(xgrid, ygrid, z);
%       hold('on');
%       quiver(xgrid, ygrid, px1, py1, 'r');
%       quiver(xgrid, ygrid, px2, py2, 'b');
%
%   See also:
%     GRADIENT

[msg,f,ndim,loc,rflag] = parse_inputs(f,varargin);
if ~isempty(msg), error('glider_toolbox:gradientu:InvalidInputs', msg); end

% Loop over each dimension. Permute so that the gradient is always taken along
% the columns.

if ndim == 1
  perm = [1 2];
else
  perm = [2:ndim 1]; % Cyclic permutation
end

for k = 1:ndim
   [n,p] = size(f);
   h = loc{k}(:);
   g  = zeros(size(f),class(f)); % case of singleton dimension

   % Take forward differences on left and right edges
   if n > 1
      g(1,:) = (f(2,:) - f(1,:))/(h(2)-h(1));
      g(n,:) = (f(n,:) - f(n-1,:))/(h(end)-h(end-1));
   end

   % Take centered differences on interior points
   % accounting for possibly unevenly spaced data.
   if n > 2
      dh = diff(h);
      dhmin = min(dh);
      dhmax = max(dh);
      if dhmax - dhmin < eps * abs(dhmin)
        % Original MATLAB implementation:
        h = h(3:n) - h(1:n-2);
        g(2:n-1,:) = (f(3:n,:)-f(1:n-2,:)) ./ h(:,ones(p,1));
      else
        % 2nd order accurate formula:
        df_dh = (f(2:n,:) - f(1:n-1,:)) ./ dh(:,ones(p,1));
        ddh = h(3:n) - h(1:n-2);
        g(2:n-1,:) = (dh(2:end,  ones(p,1)) .* df_dh(1:end-1,:) + ...
                      dh(1:end-1,ones(p,1)) .* df_dh(2:end,  :) ) ...
                  ./ ddh(:,ones(p,1));
      end
   end

   varargout{k} = ipermute(g,[k:ndims(f) 1:k-1]);

   % Set up for next pass through the loop
   f = permute(f,perm);
end

% Swap 1 and 2 since x is the second dimension and y is the first.
if ndim>1
  tmp = varargout{1};
  varargout{1} = varargout{2};
  varargout{2} = tmp;
end

if rflag, varargout{1} = varargout{1}.'; end


%-------------------------------------------------------
function [msg,f,ndim,loc,rflag] = parse_inputs(f,v)
%PARSE_INPUTS
%   [MSG,F,LOC,RFLAG] = PARSE_INPUTS(F,V) returns the spacing
%   LOC along the x,y,z,... directions and a row vector
%   flag RFLAG. MSG will be non-empty if there is an error.

msg = '';
loc = {};
nin = length(v)+1;

% Flag vector case and row vector case.
ndim = ndims(f);
vflag = 0; rflag = 0;
if iscolumn(f)
   ndim = 1; vflag = 1;
elseif isrow(f) % Treat row vector as a column vector
   ndim = 1; vflag = 1; rflag = 1;
   f = f.';
end;

indx = size(f);

% Default step sizes: hx = hy = hz = 1
if nin == 1, % gradient(f)
   for k = 1:ndims(f)
      loc(k) = {1:indx(k)};
   end;

elseif (nin == 2) % gradient(f,h)
   % Expand scalar step size
   if (length(v{1})==1)
      for k = 1:ndims(f)
         h = v{1};
         loc(k) = {h*(1:indx(k))};
      end;
   % Check for vector case
   elseif vflag
      loc(1) = v(1);
   else
      msg = 'Invalid inputs to GRADIENT.';
   end

elseif ndims(f) == numel(v), % gradient(f,hx,hy,hz,...)
   % Swap 1 and 2 since x is the second dimension and y is the first.
   loc = v;
   if ndim>1
     tmp = loc{1};
     loc{1} = loc{2};
     loc{2} = tmp;
   end

   % replace any scalar step-size with corresponding position vector
   for k = 1:ndims(f)
      if length(loc{k})==1
         loc{k} = loc{k}*(1:indx(k));
      end;
   end;

else
   msg = 'Invalid inputs to GRADIENT.';

end
