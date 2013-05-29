function [profile_direction, profile_index] = findProfiles(depth, varargin)
%FINDPROFILES  Compute vertical direction and identify individual profiles from depth sequence.
%
%  Syntax:
%    [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH)
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
%  [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH, OPT1, VAL1) accepts
%  the following options in key-value pairs:
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

  error(nargchk(1, 3, nargin, 'struct'));

  min_range = 0;
  for opt_idx = 1:2:numel(varargin)
    opt = varargin{opt_idx};
    val = varargin{opt_idx+1};
    switch lower(opt)
      case 'range'
        min_range = val;
      otherwise
        error('glider_toolbox:findProfiles:InvalidOption', ...
              'Invalid option: %s.', opt);
    end
  end
  
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
    cast_found = (abs(diff(depth(depth_peak_ind))) >= min_range);
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
