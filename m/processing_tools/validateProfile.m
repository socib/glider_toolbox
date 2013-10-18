function [valid, full_rows] = validateProfile(depth, varargin)
%VALIDATEPROFILE  Check if profile sequence is a proper profile and if it is well sampled.
%
%  Syntax:
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN)
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPTIONS)
%    VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPT1, VAL1, ...)
%    [VALID, FULL_ROWS]= VALIDATEPROFILE(...)
%
%  VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPTIONS) and 
%  VALID = VALIDATEPROFILE(DEPTH, DATA1, ... , DATAN, OPT1, VAL1, ...) check if 
%  vector DEPTH is a proper profile depth sequence and if data in vectors or 
%  column arrays DATA1, ... , DATAN is properly sampled over the profile range, 
%  according to criteria in option struct OPTIONS or in option key-value pairs 
%  OPT1, VAL1... The profile is required to have a minimum depth range and 
%  contain no significant gaps. The number of rows of DEPTH, and DATA1, ... , 
%  DATAN should be the same. Valid options are:
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
%  respective entries in DEPTH or rows in DATA1 , ... , DATAN contain some 
%  invalid value.
%
%  Notes:
%    This function is based on the previous work by Tomeu Garau, in functions
%    called FINDPROFILES (not to be confused with the current function with the
%    same name) and CLEANPROFILE. He is the true glider man.
%
%  Examples:
%    depth = [1 2   3 nan  5 nan   7  nan   9  10]'
%    data1 = [0 0 nan nan  4 nan nan    7   8   9]'
%    data2 = [1 4 nan nan 25 nan  49   64 nan 100]'
%    data =  [data1 data2]
%    % Default options: any profile is valid, usefull to retrieve valid rows.
%    [valid, full_rows] = validateProfile(depth, data)
%    depth(full_rows)
%    data(full_rows, :)
%    % Invalid profile: range too small.
%    valid = validateProfile(depth, data1, data2, 'range', 15)
%    % Invalid profile: gap too large.
%    valid = validateProfile(depth, data1, data2, 'gap', 0.25)
%    % Valid profile: large enough range and small enough gap.
%    valid = validateProfile(depth, data1, data2, 'range', 5, 'gap', 0.75)
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

  error(nargchk(1, Inf, nargin, 'struct'));
  
  
  %% Parse basic input arguments.
  % Get numeric (non option) arguments.
  nargdata = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargdata)
    nargdata = numel(varargin);
  end
  data = [varargin{1:nargdata}];

  
  %% Set options and default values.
  options.range = 0;
  options.gap = 1;
  
  
  %% Parse optional arguments.
  % Get numeric data arguments and option arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin(nargdata+1:end);
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
  % Initialize output.
  full_rows = ~any(isnan([depth(:) data]), 2);
  valid = false;
  % Emptiness check.
  if ~any(full_rows)
    return
  end
  % Range check.
  depth_range = max(depth(:)) - min(depth(:));
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
