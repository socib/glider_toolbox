function [filled, indices] = fillInvalidValues(varargin)
%FILLINVALIDVALUES  Fill invalid values in sequence with given method.
%
%  Syntax:
%    [FILLED, INDICES] = FILLINVALIDVALUES(X, Y, METHOD)
%    [FILLED, INDICES] = FILLINVALIDVALUES(X, Y, VALUE)
%    [FILLED, INDICES] = FILLINVALIDVALUES(X, Y)
%    [FILLED, INDICES] = FILLINVALIDVALUES(Y, METHOD)
%    [FILLED, INDICES] = FILLINVALIDVALUES(Y, VALUE)
%    [FILLED, INDICES] = FILLINVALIDVALUES(Y)
%
%  [FILLED, INDICES] = FILLINVALIDVALUES(X, Y, METHOD) fills invalid 
%  values (nan occurrences) in vector X, using the method specified by string
%  METHOD, which is one of:
%    'none': do nothing, X is ignored and Y is returned.
%    'previous': previous valid value found (if any), X is ignored.
%    'next': next valid value found (if any), X is ignored.
%    'nearest', 'linear', 'spline', 'pchip' and 'cubic': interpolate valid 
%      values in Y over corresponding entries in independent variable vector X 
%      using function INTERP1 with given method. X and Y should have the same 
%      dimensions.
%  FILLED is a vector with the same dimension as X with invalid values filled.
%  INDICES is a vector with the indices of invalid values in X.
%
%  [FILLED, INDICES] = FILLINVALIDVALUES(X, Y, VALUE) fills invalid values in X
%  using number VALUE as fill value. X is ignored.
%
%  [FILLED, INDICES] = FILLINVALIDVALUES(X, Y) fills invalid values in X
%  using 'linear' as default interpolation method.
%
%  [FILLED, INDICES] = FILLINVALIDVALUES(Y, ...) assume that X = 1:N, where N
%  is the length of Y. Please note that this is only relevant when used with
%  interpolation methods: 'nearest', 'linear', 'spline', 'pchip' or 'cubic'.
%
%  Examples:
%    x = [0 2 4 8 10 12 14 16 18 20]
%    y = [0 nan 16 64 nan nan nan 256 324 400] % y = x.^2
%    % Default linear interpolation over 1:N.
%    [filled, indices] = fillInvalidValues(y)
%    % Default linear interpolation over given independent coordinates.
%    [filled, indices] = fillInvalidValues(x, y)
%    % Interpolation using cubic splines given independent coordinates.
%    [filled, indices] = fillInvalidValues(x, y, 'cubic')
%    % Fill with previous valid value (x not needed but could be there).
%    [filled, indices] = fillInvalidValues(y, 'previous')
%    [filled, indices] = fillInvalidValues(x, y, 'previous')
%    % Fill with next valid value (x not needed but could be there).
%    [filled, indices] = fillInvalidValues(y, 'next')
%    [filled, indices] = fillInvalidValues(x, y, 'next')
%    % Fill with given value (x not needed but could be there).
%    [filled, indices] = fillInvalidValues(y, 0)
%    [filled, indices] = fillInvalidValues(x, y, 0)
%
%  See also:
%    INTERP1
%    ISNAN
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 3, nargin, 'struct'));
  
  switch nargin
    case 1
      y = varargin{1};
      x = 1:numel(y);
      method = 'linear';
    case 2
      if ischar(varargin{2}) || isscalar(varargin{2})
        y = varargin{1};
        x = 1:numel(y);
        method = varargin{2};
      else
        x = varargin{1};
        y = varargin{2};
        method = 'linear';
      end
    otherwise
      x = varargin{1};
      y = varargin{2};
      method = varargin{3};
  end
  
  invalid = isnan(y);
  
  if ischar(method)
    % Fill invalid values with given method.
    switch lower(method)
      case 'none'
        indices = find(invalid);
        filled = y;
      case 'previous'
        indices = find(invalid);
        filled = y;
        ind_val = find(~invalid);        
        for i = 1:(numel(ind_val)-1)
          first = ind_val(i) + 1;
          last = ind_val(i+1) - 1;
          value = y(ind_val(i));
          filled(first:last) = value;
        end
      case 'next'
        indices = find(invalid);
        filled = y;
        ind_val = find(~invalid);        
        for i = 1:(numel(ind_val)-1)
          first = ind_val(i) + 1;
          last = ind_val(i+1) - 1;
          value = y(ind_val(i+1));
          filled(first:last) = value;
        end
      case {'nearest', 'linear', 'spline', 'pchip', 'cubic'}
        indices = find(invalid);
        filled = y;
        filled(invalid) = ...
          interp1(x(~invalid), y(~invalid), x(invalid), lower(method));
      otherwise
        error('glider_toolbox:fillInvalidValues:InvalidMethod', ...
              'Invalid method: %s.', method);
    end
  else
    % Fill invalid values with given scalar value.
    indices = find(invalid);
    filled = y;
    filled(invalid) = method;
  end

end
