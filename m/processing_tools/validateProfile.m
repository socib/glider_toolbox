function [valid, full_rows, varargout] = validateProfile(depth, varargin)
%VALIDATEPROFILE  Check if profile sequence is a proper profile and if it is well sampled.
%
%  Syntax:
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN)
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPTIONS)
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPT1, VAL1, ...)
%    [VALID, FULL_ROWS]= VALIDATEPROFILE(...)
%
%  Description:
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPTIONS) and 
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPT1, VAL1, ...) check 
%    whether vector DEPTH is a proper profile depth sequence
%    and if data in vectors or column arrays DATA1, ... , DATAN
%    is properly sampled over the profile range, according to criteria in 
%    options given in key-value pairs OPT1, VAL1... or in a struct OPTIONS 
%    with field names as option keys and field values as option values.
%    The profile is required to have a minimum depth range and 
%    contain no significant gaps of invalid data readings or depth inversions.
%    The number of rows of DEPTH, and DATA1, ... , DATAN should be the same.
%
%    [VALID, FULL_ROWS] = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, ...) 
%    also returns a logical column vector FULL_ROWS with the same number of 
%    elements as DEPTH, showing whether respective entries in DEPTH or rows in
%    DATA1, ... , DATAN contain some invalid value or lie in a depth inversion.
%
%    [VALID, FULL_ROWS, DATA1, ... , DATAN] = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, ...)
%    also returns then same input data DATA1, ... , DATAN but with entries 
%    corresponding to invalid rows in FULL_ROWS replaced according to the mask
%    value specified in options.
%
%    Valid options are:
%      RANGE: minimum depth range (in the same units as DEPTH).
%        A profile is invalid if the difference between the maximum and minimum
%        depth values is smaller than given threshold.
%        Default value: 0 (only empty profiles are invalid).
%      GAP: maximum gap ratio (in [0,1]).
%        A profile is invalid if the ratio of the depth range of the largest gap
%        to the depth range of the whole profile is larger than given threshold.
%        A gap is a sequence of consecutive incomplete measurements, either 
%        because of invalid values (NaN) in some column of DATA, or because of 
%        invalid entries in DEPTH.
%        Default value: 1 (only empty profiles are invalid).
%      MASK: replacement value for invalid data readings.
%        When data outputs are requested, respective data inputs are returned
%        but with entries correponding to invalid rows replaced by the given
%        value. If empty ([]), the entries are removed instead of replaced.
%        Default value: nan
%
%    New in version v1.1.0:
%      Identify and discard depth inversions in the profile.
%      Return input data with invalid rows masked with specified value.
%
%  Notes:
%    This function is based on the previous work by Tomeu Garau, in functions
%    called FINDPROFILES (not to be confused with the current function with the
%    same name) and CLEANPROFILE. He is the true glider man.
%
%  Examples:
%    depth = [1 2 3 2  5 nan   7 nan   9  10]'
%    data1 = [0 1 1 1  4 nan nan   7   8   9]'
%    data2 = [1 4 4 4 25 nan  49  64 nan 100]'
%    data =  [data1 data2]
%    % Default options: any profile is valid,
%    % useful to retrieve valid rows and flag depth inversions.
%    [valid, full_rows] = validateProfile(depth, data)
%    depth(full_rows)
%    data(full_rows, :)
%    % Invalid profile: range too small.
%    valid = validateProfile(depth, data1, data2, 'range', 15)
%    % Invalid profile: gap too large.
%    valid = validateProfile(depth, data1, data2, 'gap', 0.25)
%    % Valid profile: large enough range and small enough gap.
%    valid = validateProfile(depth, data1, data2, 'range', 5, 'gap', 0.75)
%    % Mask invalid rows in input data with default value (NaN):
%    [valid, full_rows, data1, data2] = ...
%      validateProfile(depth, data(:,1), data(:,2))
%    % Mask invalid rows in input data with a different value (NaN):
%    [valid, full_rows, data1, data2] = ...
%      validateProfile(depth, data(:,1), data(:,2), 'mask', 9999)
%    % Remove invalid rows in input data:
%    [valid, full_rows, data1, data2] = ...
%      validateProfile(depth, data(:,1), data(:,2), 'mask', [])
%
%  See also:
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

  narginchk(1, Inf);
  
  
  %% Parse basic input arguments.
  % Get numeric (non-option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = numel(varargin);
  end
  data = [varargin{1:nargnum}];

  
  %% Set options and default values.
  options.range = 0;
  options.gap = 1;
  options.mask = nan;
  
  
  %% Parse optional arguments.
  % Get numeric data arguments and option arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin(nargnum+1:end);
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:validateProfile:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:validateProfile:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  
  %% Validate the profile.
  % Flag invalid data and depth inversions.
  depth_valid = ~isnan(depth(:));
  data_valid = ~any(isnan(data), 2);
  [depth_min_value, depth_min_index] = min(depth);
  [depth_max_value, depth_max_index] = max(depth);
  % CUMMIN and CUMMAX are available in Octave but not in MATLAB
  % (in release 2014b they are in the Statistics Toolbox).
  % With them, we could use this one-liners:
  %{
  if (depth_min_index < depth_max_index)
    monotonic = cummax(depth(:) == flipud(cummin(flipud(depth(:))));
  elseif (depth_min_index > depth_max_index)
    monotonic = cummin(depth(:) == flipud(cummax(flipud(depth(:))));
  else
    monotonic = true(size(depth(:)));
  end
  %}
  if (depth_min_index < depth_max_index)
    omax = find(depth_valid, 1, 'first');
    omin = find(depth_valid, 1, 'last');
  elseif (depth_min_index > depth_max_index)
    omax = find(depth_valid, 1, 'last');
    omin = find(depth_valid, 1, 'first');
  else
    omax = depth_max_index;
    omin = depth_min_index;
  end
  cmax = depth(:);
  cmin = depth(:);
  tmax = depth(omax);
  tmin = depth(omin);
  for k = 0:sign(omin-omax):(omin-omax)
    if cmax(omax + k) > tmax
      tmax = cmax(omax + k);
    else
      cmax(omax + k) = tmax;
    end
    if cmin(omin - k) < tmin
      tmin = cmin(omin - k);
    else
      cmin(omin - k) = tmin;
    end
  end
  if (depth_min_index < depth_max_index)
    cmax(omin+1:end) = tmax;
    cmin(1:omax-1) = tmin;
  elseif (depth_min_index > depth_max_index)
    cmax(1:omin-1) = tmax;
    cmin(omax+1:end) = tmin;
  end
  monotonic = (cmax == cmin);
  % Initialize output.
  full_rows = depth_valid & data_valid & monotonic;
  valid = false;
  for k = 1:min(nargnum, nargout - 2)
    masked = varargin{k};
    if isequal(options.mask, [])
      masked(~full_rows, :) = [];
    else
      masked(~full_rows, :) = options.mask;
    end
    varargout{k} = masked;
  end
  % Emptiness check.
  if ~any(full_rows)
    return
  end
  % Range check.
  depth_range =  depth_max_value - depth_min_value;
  if depth_range < options.range 
    return
  end
  % Gap check.
  max_gap = max([min(depth(full_rows))-min(depth) ...
                 max(abs(diff(depth(full_rows)))) ...
                 max(depth) - max(depth(full_rows))]);
  if max_gap > options.gap * depth_range
    return
  end
  % Checks passed, profile is valid.
  valid = true;
  
end
