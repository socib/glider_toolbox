function [profile_direction, profile_index] = findProfiles(depth, varargin)
%FINDPROFILES  Compute vertical direction and identify individual profiles from depth sequence.
%
%  Syntax:
%    [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH)
%    [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH, OPTIONS)
%    [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH, OPT1, VAL1)
%
%  [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH) identifies upcast
%  and downcast profiles in depth (or pressure) vector DEPTH, and computes a 
%  vector of vertical direction PROFILE_DIRECTION and a vector of profile
%  indices PROFILE_INDEX. DEPTH, PROFILE_DIRECTION and PROFILE_INDEX have the
%  same length. PROFILE_DIRECTION entries may be 1 (down), 0 (flat), -1 (up).
%  PROFILE_INDEX entries associate each sample with the number of the profile it
%  belongs to. Samples in the middle of a profile are flagged with a whole 
%  number, starting from 1 and increased by 1 every time a new cast is 
%  identified, while samples between profiles are flagged with an offset of 0.5.
%
%  [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH, OPTIONS) and
%  [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH, OPT1, VAL1) accept
%  the following options given in key-value pairs OPT1, VAL1... or in a struct 
%  OPTIONS with field names as option keys and field values as option values:
%    RANGE: minimum depth range (in the same units as DEPTH).
%      Only monotonic intervals of depth spanning a range greater or equal than
%      the given value are considered valid profiles.
%      Default value: 0 (all profiles are valid).
%
%  Notes:
%    Direction is inferred from the sign of forward differences of vector DEPTH.
%
%    Profiles are numbered identifying intervals of monotonic depth, 
%    delimited by changes of direction (strict depth peaks).
%
%    To deal with (the very unusual) points with 0 direction, they are marked as
%    belonging to the previous profile.
%
%    Invalid samples (NaN) in input are ignored. In output, they are marked as 
%    belonging to the previous profile, and with the direction of the previous
%    sample.
%
%  Examples:
%    depth = [3 3 2 1 2 3 3 4 5 5 5 4 3 3 4 2 1 1 0 3 3]
%    [profile_direction, profile_index] = findProfiles(depth)
%    figure
%    subplot(3, 1, 1)
%    stairs(profile_direction, '-g')
%    subplot(3, 1, 2)
%    plot(depth, '-db')
%    subplot(3, 1, 3)
%    stairs(profile_index, '-r')
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

  error(nargchk(1, 3, nargin, 'struct'));

  
  %% Set options and default values.
  options.range = 0;

  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
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
    error('glider_toolbox:findProfiles:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:findProfiles:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end

  
  %% Identify the profiles.
  profile_direction = nan(size(depth));
  profile_index = nan(size(depth));
  depth_valid_ind = find(~isnan(depth));
  depth_valid = depth(depth_valid_ind);
  if numel(depth_valid) >= 2
    dy = diff(depth_valid);
    sdy_flat = sign(dy(:));
    sdy_ind = find(sdy_flat ~= 0);
    sdy = sdy_flat(sdy_ind);
    sdy_peak = [false; (sdy(1:(end-1)).*sdy(2:end) < 0)];
    depth_peak_ind = depth_valid_ind([1; sdy_ind(sdy_peak); end]);
    cast_found = (abs(diff(depth(depth_peak_ind))) >= options.range);
    cast_head = zeros(size(depth));
    cast_tail = zeros(size(depth));
    cast_head(depth_peak_ind([cast_found(:); false])+1) = 0.5;
    cast_tail(depth_peak_ind([false; cast_found(:)])) = 0.5;
    profile_index = 0.5 + cumsum(cast_head + cast_tail);
    for i = 1:numel(depth_valid_ind)-1
      profile_direction(depth_valid_ind(i):depth_valid_ind(i+1)-1) = sdy_flat(i);
    end
    profile_direction(depth_valid_ind(end):end) = sdy_flat(end);
  end

end
