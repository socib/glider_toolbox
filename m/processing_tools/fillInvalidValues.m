function [filled, invalid] = fillInvalidValues(varargin)
%FILLINVALIDVALUES  Fill invalid values in sequence with given method.
%
%  Syntax:
%    FILLED = FILLINVALIDVALUES(X0, Y0, X, Y, METHOD)
%    FILLED = FILLINVALIDVALUES(X, Y, METHOD)
%    FILLED = FILLINVALIDVALUES(X, Y, VALUE)
%    FILLED = FILLINVALIDVALUES(X, Y)
%    FILLED = FILLINVALIDVALUES(Y, METHOD)
%    FILLED = FILLINVALIDVALUES(Y, VALUE)
%    FILLED = FILLINVALIDVALUES(Y)
%    [FILLED, INVALID] = FILLINVALIDVALUES(...)
%
%  Description:
%    FILLED = FILLINVALIDVALUES(X0, Y0, X, Y, METHOD) fills invalid values (NaN) 
%    in vector Y, using the method specified by string METHOD, which is one of:
%      'none': do nothing, X0, Y0 and X are ignored and Y is returned.
%      'previous': previous valid value found in X0 and Y0, if any.
%      'next': next valid value found in X0 and Y0.
%      'nearest', 'linear', 'spline', 'pchip' and 'cubic': interpolate values 
%        in X0 and Y0 over X using function INTERP1 with given method.
%    FILLED is a copy of vector Y but with invalid values filled.
%
%    FILLED = FILLINVALIDVALUES(X, Y, METHOD) fills invalid values (NaN) in 
%    vector Y, using the method specified by string METHOD, which is one of:
%      'none': do nothing, X is ignored and Y is returned.
%      'previous': previous valid value found (if any), X is ignored.
%      'next': next valid value found (if any), X is ignored.
%      'nearest', 'linear', 'spline', 'pchip' and 'cubic': interpolate valid 
%        values in Y over corresponding entries in independent variable 
%        vector X  using function INTERP1 with given method.
%        X and Y should have the same  dimensions.
%    FILLED is a copy of vector Y but with invalid values filled.
%
%    FILLED = FILLINVALIDVALUES(X, Y, VALUE) fills invalid values in Y
%    using number VALUE as fill value. X is ignored.
%
%    FILLED = FILLINVALIDVALUES(X, Y) fills invalid values in Y
%    using 'linear' as default interpolation method.
%
%    FILLED = FILLINVALIDVALUES(Y, ...) assumes that X = 1:N, where N is the 
%    length of Y. Please note that this is only relevant when used with
%    interpolation methods: 'nearest', 'linear', 'spline', 'pchip' or 'cubic'.
%
%    [FILLED, INVALID] = FILLINVALIDVALUES(...) also returns a logical vector
%    INVALID with the same dimensions as Y, showing whether respective entries
%    in Y are invalid values.
%
%  Examples:
%    x = [0 2 4 8 10 12 14 16 18 20]
%    y = [0 nan 16 64 nan nan nan 256 324 400] % y = x.^2
%    % Default linear interpolation over 1:N.
%    filled = fillInvalidValues(y)
%    % Default linear interpolation over given independent coordinates.
%    filled = fillInvalidValues(x, y)
%    % Interpolation using cubic splines given independent coordinates.
%    filled = fillInvalidValues(x, y, 'cubic')
%    % Fill with previous valid value (x not needed but could be there).
%    filled = fillInvalidValues(y, 'previous')
%    filled = fillInvalidValues(x, y, 'previous')
%    % Fill with next valid value (x not needed but could be there).
%    filled = fillInvalidValues(y, 'next')
%    filled = fillInvalidValues(x, y, 'next')
%    % Fill with given value (x not needed but could be there).
%    filled = fillInvalidValues(x, y, 0)
%    filled = fillInvalidValues(y, 0)
%    % Get also the index of invalid entries in Y.
%    [filled, invalid] = fillInvalidValues(x, y)
%
%  See also:
%    INTERP1
%    ISNAN
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(1, 5, nargin, 'struct'));
  
  switch nargin
    case 5
      method = varargin{5};
      y = varargin{4};
      x = varargin{3};
      y0 = varargin{2};
      x0 = varargin{1};
    case 4
      method = 'linear';
      y = varargin{4};
      x = varargin{3};
      y0 = varargin{2};
      x0 = varargin{1};
    case 3
      method = varargin{3};
      y = varargin{2};
      x = varargin{1};
    case 2
      if ischar(varargin{2}) || isscalar(varargin{2})
        method = varargin{2};
        y = varargin{1};
        x = 1:numel(y);
      else
        method = 'linear';
        y = varargin{2};
        x = varargin{1};
      end
    case 1
      method = 'linear';
      y = varargin{1};
      x = 1:numel(y);
  end

  value_fill = false;
  self_fill = true;
  if ~ischar(method)
    value_fill = true;
  elseif nargin > 3
    self_fill = false;
  end
    
  invalid = isnan(y);
  
  if value_fill
    % Fill invalid values with given scalar value.
    filled = y;
    filled(invalid) = method;
  elseif self_fill
    % Fill invalid values with given method using values from sequence itself.
    switch method
      case 'none'
        filled = y;
      case 'prev'
        filled = y;
        ind_val = find(~invalid(:));
        first = ind_val+1;
        last  = [ind_val(2:end)-1; length(y)];
        value = y(ind_val);
        for i = 1:numel(ind_val)
          filled(first(i):last(i)) = value(i);
        end
      case 'next'
        filled = y;
        ind_val = find(~invalid(:));
        first = [1; ind_val(1:end-1)+1];
        last  = ind_val - 1;
        value = y(ind_val);
        for i = 1:numel(ind_val)
          filled(first(i):last(i)) = value(i);
        end
      case {'nearest', 'linear', 'spline', 'pchip', 'cubic'}
        filled = y;
        filled(invalid) = ...
          interp1(x(~invalid), y(~invalid), x(invalid), lower(method));
      otherwise
        error('glider_toolbox:fillInvalidValues:InvalidMethod', ...
              'Invalid method: %s.', method);
    end
  else
    % Fill invalid values with given method using values from other sequence.
    switch lower(method)
      case 'none'
        filled = y;
      case 'prev'
        filled = y;
        x1 = x(invalid);
        d = bsxfun(@minus, x1(:)', x0(:));
        d(d<0) = nan;
        [dmin, prev] = min(d);
        fillable(invalid) = isfinite(dmin);
        filled(invalid & fillable) = y0(prev(fillable(invalid)));
      case 'next'
        filled = y;
        x1 = x(invalid);
        d = bsxfun(@minus, x1(:)', x0(:));
        d(d>0) = nan;
        [dmin, next] = max(d);
        fillable(invalid) = isfinite(dmin);
        filled(invalid & fillable) = y0(next(fillable(invalid)));
      case {'nearest', 'linear', 'spline', 'pchip', 'cubic'}
        filled = y;
        [xref, i0, iref] = unique(x0);
        yref = y0(i0);
        if any(xref(iref) ~= x0)
          error('glider_toolbox:fillInvalidValues:InconsistentData', ...
                'Inconsistent reference data.');
        end
        fillable(invalid) = isfinite(x(invalid));
        filled(fillable) = ...
          interp1(xref, yref, x(fillable), lower(method));
      otherwise
        error('glider_toolbox:fillInvalidValues:InvalidMethod', ...
              'Invalid method: %s.', method);
    end
  end

end
