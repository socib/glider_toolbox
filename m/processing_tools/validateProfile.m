function [valid, full_rows] = validateProfile(depth, data, varargin)
%VALIDATEPROFILE  Check if profile sequence is a proper profile and if it is well sampled.
%
%  Syntax:
%    VALID = VALIDATEPROFILE(DEPTH, DATA)
%    VALID = VALIDATEPROFILE(DEPTH, DATA, OPT1, VAL1, ...)
%    [VALID, FULL_ROWS]= VALIDATEPROFILE(...)
%
%  VALID = VALIDATEPROFILE(DEPTH, DATA, OPT1, VAL1, ...) checks if vector DEPTH
%  is a proper profile depth sequence and if data in vector or array DATA is
%  properly sampled over the profile range, according to criteria in option and 
%  value pairs OPT1, VAL1... The profile is required to have a minimum depth 
%  range and contain no significant gaps. Number of rows of DATA and number of 
%  elements of DEPTH should be the same. Valid options are:
%    RANGE: minimum depth range (in the same units as DEPTH).
%      A profile is invalid if the difference between the maximum and minimum
%      depth values is smaller than given threshold.
%      Default value: 0 (only empty profiles are invalid).
%    GAP: maximum gap ratio (in [0,1]).
%      A profile is invalid if the ratio of the depth range of the largest gap
%      to the depth range of the whole profile is larger than given threshold.
%      A gap is a sequence of consecutive incomplete measurements, either 
%      because of invalid values (NaN) in some column of DATA, or because of 
%      invalid entries in DEPTH.
%      Default value: 1 (only empty profiles are invalid).
%
%  [VALID, FULL_ROWS]= VALIDATEPROFILE(...) also returns a logical column vector
%  FULL_ROWS with the same number of elements as DEPTH, showing whether
%  respective entries in DEPTH or rows in DATA contain some invalid value.
%
%  Notes:
%    This function is based on the previous work by Tomeu Garau, in functions
%    called FINDPROFILES (not to be confused with the current function with the
%    same name) and CLEANPROFILE. He is the true glider man.
%
%  Examples:
%    depth = [1 2   3 nan  5 nan   7  nan   9  10]
%    data1 = [0 0 nan nan  4 nan nan    7   8   9]
%    data2 = [1 4 nan nan 25 nan  49   64 nan 100]
%    data =  [data1(:) data2(:)]
%    % Default options: any profile is valid, usefull to retrieve valid rows.
%    [valid, full_rows] = validateProfile(depth, data)
%    depth(full_rows)
%    data(full_rows, :)
%    % Invalid profile: range too small.
%    valid = validateProfile(depth, data, 'range', 15)
%    % Invalid profile: gap too large.
%    valid = validateProfile(depth, data, 'gap', 0.25)
%    % Valid profile: large enough range and small enough gap.
%    valid = validateProfile(depth, data, 'range', 5, 'gap', 0.75)
%
%  See also:
%    ISNAN
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  error(nargchk(2, 6, nargin, 'struct'));
  
  min_range = 0;
  max_gap_ratio = 1;
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'range'
        min_range = val;
      case 'gap'
        max_gap_ratio = val;
      otherwise
        error('glider_toolbox:validateProfile:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end
  
  % Initialize output.
  full_rows = ~any(isnan([depth(:) data]), 2);
  valid = false;
  
  % Emptiness check.
  if ~any(full_rows)
    return
  end
  
  % Range check.
  depth_range = range(depth);
  if depth_range < min_range 
    return;
  end
  
  % Gap check.
  max_gap = max([min(depth(full_rows))-min(depth) ...
                 max(abs(diff(depth(full_rows)))) ...
                 max(depth) - max(depth(full_rows))]);
  if max_gap > max_gap_ratio * depth_range
    return
  end
  
  valid = true;
  
end
