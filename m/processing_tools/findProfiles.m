function [profile_direction, profile_index] = findProfiles(depth)
%FINDPROFILES  Compute vertical direction and identify individual profiles from depth sequence.
%
%  Syntax:
%    [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH)
%
%  [PROFILE_DIRECTION, PROFILE_INDEX] = FINDPROFILES(DEPTH) identifies upcast
%  and downcast profiles in depth (or pressure) vector DEPTH, and computes a 
%  vector of vertical direction PROFILE_DIRECTION and a vector of profile
%  indices PROFILE_INDEX. DEPTH, PROFILE_DIRECTION and PROFILE_INDEX have the
%  same lenght. PROFILE_DIRECTION entries may be 1 (down), 0 (flat), -1 (up).
%  PROFILE_INDEX entries flag each sample with the profile it belongs to,
%  starting from 1.
%
%  Notes:
%    Direction is inferred from the sign of forward differences of vector DEPTH.
%    Last sample is always marked with direction 0.
%
%    Profiles are numbered cumulating changes of direction (depth peaks).
%    To deal with (the very unusual) points with 0 direction, they are marked as
%    belonging to the previous profile.
%
%  Examples:
%    depth = [3 2 1 2 3 3 4 5 5 5 4 3 3 4 2 1 1 0 3 3]
%    [profile_direction, profile_index] = findProfiles(depth)
%    figure
%    subplot(3, 1, 1)
%    stairs(profile_direction, '-g')
%    subplot(3, 1, 2)
%    plot(depth, '-b')
%    subplot(3, 1, 3)
%    stairs(profile_index, '-r')
%
%  See also:
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 1, nargin, 'struct'));
  
  profile_direction = zeros(size(depth));
  profile_index = ones(size(depth));
  if numel(depth) >= 2
    sdy_flat = sign(diff(depth(:)));
    sdy_ind = find(sdy_flat ~= 0);
    sdy = sdy_flat(sdy_ind);
    sdy_peak = [false; (sdy(1:(end-1)).*sdy(2:end) < 0); false];
    depth_peak = zeros(size(depth));
    depth_peak(sdy_ind(sdy_peak)) = 1;
    profile_index = 1 + cumsum(depth_peak);
    profile_direction(1:end-1) = sdy_flat;
  end
      
end
