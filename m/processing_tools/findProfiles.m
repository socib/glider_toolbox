function [profile_index, profile_direction] = findProfiles(varargin)
%FINDPROFILES  Identify individual profiles and compute vertical direction from depth sequence.
%
%  Syntax:
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(STAMP, DEPTH)
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(STAMP, DEPTH, OPTIONS)
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(STAMP, DEPTH, OPT1, VAL1)
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(DEPTH, ...)
%
%  Description:
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(DEPTH) and
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(STAMP, DEPTH)
%    identify upcast and downcast profiles in depth (or pressure) vector DEPTH,
%    with optional timestamps in vector STAMP, and computes a vector of profile
%    indices PROFILE_INDEX and a vector of vertical direction PROFILE_DIRECTION.
%    STAMP, DEPTH, PROFILE_DIRECTION and PROFILE_INDEX are the same length N,
%    and if STAMP is not specified, it is assumed to be the sample index [1:N].
%    PROFILE_DIRECTION entries may be 1 (down), 0 (flat), -1 (up).
%    PROFILE_INDEX entries associate each sample with the number of the profile
%    it belongs to. Samples in the middle of a profile are flagged with a whole 
%    number, starting at 1 and increased by 1 every time a new cast is detected,
%    while samples between profiles are flagged with an offset of 0.5.
%    See note on identification algorithm below.
%
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(..., OPTIONS) and
%    [PROFILE_INDEX, PROFILE_DIRECTION] = FINDPROFILES(..., OPT1, VAL1) accept
%    the following options given in key-value pairs OPT1, VAL1... or in a struct 
%    OPTIONS with field names as option keys and field values as option values:
%      STALL: maximum range of a stalled segment (in the same units as DEPTH).
%        Only strictly monotonic intervals of depth spanning a depth range
%        not less than the given value are considered valid profile segments.
%        Shorter intervals are considered stalled segments inside or between
%        profiles.
%        Default value: 0 (all segments are valid cast segments)
%      SHAKE: maximum duration of a shake segment (in the same units as STAMP).
%        Only strictly monotonic intervals of depth with duration
%        not less than the given value are considered valid profile segments.
%        Shorter intervals are considered shake segments inside or between
%        profiles.
%        Default value: 0 (all segments are valid cast segments)
%      INVERSION: maximum depth inversion between cast segments of a profile.
%        Consecutive valid cast segments with the same direction are joined 
%        together in the same profile if the range of the introduced depth 
%        inversion, if any, is less than the given value.
%        Default value: 0 (never join cast segments)
%      INTERRUPT: maximum time separation between cast segments of a profile.
%        Consecutive valid cast segments with the same direction are joined 
%        together in the same profile if the duration of the lapse (sequence of
%        stalled segments or shakes between them) is less than the given value.
%        When STAMP is not specified, the duration will be the number of samples
%        between them.
%        Default value: 0 (never join cast segments)
%      LENGTH: minimum length of a profile.
%        A sequence of joined cast segments will be considered a valid profile
%        only if the total spanned depth is greater or equal than the given.
%        value.
%        Default value: 0 (all profiles are valid)
%      PERIOD: minimum duration of a profile.
%        A sequence of joined cast segments will be considered a valid profile
%        only if the total duration is greater or equal than the given value.
%        Default value: 0 (all profiles are valid)
%
%    The following options are deprecated and should not be used:
%       RANGE: minimum depth range.
%         Deprecated in v1.1.0:
%           Superseded by STALL.
%       JOIN: whether to join consecutive profiles with the same direction.
%         Deprecated in v1.1.0:
%           Superseded by INTERRUPT and INVERSION:
%           Equivalent to INVERSION = INF and INTERRUPT = INF, and
%           INVERSION = 0 and INTERRUPT = 0.
%
%  Notes:
%    Direction is inferred from the sign of forward differences of vector DEPTH.
%
%    Profiles are identified as sequences of cast segments with the same
%    vertical direction allowing for stalled or shake segmens in between.
%    Vertical segments are intervals of strictly monotonic depth,
%    and are delimited identifying changes of direction (depth extrema).
%    A segment is considered stalled if it is to short in depth,
%    or a shake if it is to short in time. Otherwise it is a cast segment.
%    Consecutive cast segments with the same direction are joined together
%    if the lapse between the segments and the introduced depth inversion
%    are not significant according to the specified thresholds.
%
%    Invalid samples (NaN) in input are ignored. In output, they are marked as 
%    belonging to the previous profile, and with the direction of the previous
%    sample.
%
%  Examples:
%    depth = [4 4 3 2 3 4 4 5 6 6 6 5 4 4 5 3 2 3 1 1 0 4 4]
%    [profile_index, profile_direction] = findProfiles(depth)
%    figure
%    subplot(3, 1, 1)
%    stairs(profile_direction, '-g')
%    subplot(3, 1, 2)
%    plot(depth, '-db')
%    subplot(3, 1, 3)
%    stairs(profile_index, '-r')
%    hold on
%    [profile_index, profile_direction] = findProfiles(depth, 'stall', 1.5)
%    stairs(profile_index, '-c')
%    [profile_index, profile_direction] = ...
%       findProfiles(depth, 'stall', 1.5, 'inversion', 1.5, 'interrupt', inf)
%    stairs(profile_index, '-m')
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2013-2015
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

  error(nargchk(1, 14, nargin, 'struct'));
  
  
  %% Set options and default values.
  options.length = 0;
  options.period = 0;
  options.inversion = 0;
  options.interrupt = 0;
  options.stall = 0;
  options.shake = 0;
    
  options.range = []; % Deprecated since v1.1.0.
  options.join = [];  % Deprecated since v1.1.0.
  
  
  %% Parse basic input arguments.
  % Get numeric (non-option) arguments.
  nargnum = find(~cellfun(@isnumeric, varargin), 1, 'first') - 1;
  if isempty(nargnum)
    nargnum = nargin;
  end
  switch(nargnum)
    case 1
      depth = varargin{1};
      stamp = reshape(1:numel(depth), size(depth));
    case 2
      [stamp, depth] = varargin{1:2};
  end
  
  
  %% Parse optional arguments.
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
  
  
  %% Handle deprecated options.
  if ~isempty(options.range)
    warning('glider_toolbox:findProfiles:DeprecatedOption', ...
            'Deprecated option: range. See option: stall.');
    options.stall = options.range;
  end
  if ~isempty(options.join)
    warning('glider_toolbox:findProfiles:DeprecatedOption', ...
            'Deprecated option: join. See option: shake.');
    options.interrupt = options.join * inf;
    options.inversion = options.join * inf;
  end
  
  
  %% Identify the profiles.
  profile_index = nan(size(depth));
  profile_direction = nan(size(depth));
  valid_ind = find(~(isnan(depth(:)) | isnan(stamp(:))));
  if numel(valid_ind) >= 2
    sdy = sign(diff(depth(valid_ind)));
    depth_peak_ind = valid_ind(diff([0; sdy(:); 0]) ~= 0);
    sgmt_frst = stamp(depth_peak_ind(1:end-1));
    sgmt_last = stamp(depth_peak_ind(2:end));
    sgmt_strt = depth(depth_peak_ind(1:end-1));
    sgmt_fnsh = depth(depth_peak_ind(2:end));
    sgmt_sinc = sgmt_last - sgmt_frst;
    sgmt_vinc = sgmt_fnsh - sgmt_strt;
    sgmt_vdir = sign(sgmt_vinc);
    sgmt_valid = ...
      ~(abs(sgmt_vinc(:)) < options.stall | sgmt_sinc(:) < options.shake);
    sgmt_index = find(sgmt_valid);
    sgmt_lapse = ...
      (sgmt_frst(sgmt_index(2:end)) - sgmt_last(sgmt_index(1:end-1)));
    sgmt_space = -sgmt_vdir(sgmt_index(1:end-1)) .* ...
      (sgmt_strt(sgmt_index(2:end)) - sgmt_fnsh(sgmt_index(1:end-1)));
    cast_oppos = diff(sgmt_vdir(sgmt_index)) ~= 0;
    cast_break = ...
      ~(sgmt_lapse(:) < options.interrupt & sgmt_space(:) < options.inversion);
    cast_bound = cast_oppos(:) | cast_break(:);
    cast_head_ind = depth_peak_ind(sgmt_index([true; cast_bound]));
    cast_tail_ind = depth_peak_ind(sgmt_index([cast_bound; true]) + 1);
    cast_length = abs(depth(cast_tail_ind) - depth(cast_head_ind));
    cast_period = stamp(cast_tail_ind) - stamp(cast_head_ind);
    cast_good = ~(cast_length < options.length | cast_period < options.period);
    cast_head = zeros(size(depth));
    cast_tail = zeros(size(depth));
    cast_head(cast_head_ind(cast_good) + 1) = 0.5;
    cast_tail(cast_tail_ind(cast_good)) = 0.5;
    profile_index = 0.5 + cumsum(cast_head + cast_tail);
    for i = 1:numel(valid_ind)-1
      profile_direction(valid_ind(i):valid_ind(i+1)-1) = sdy(i);
    end
    profile_direction(valid_ind(end):end) = sdy(end);
  end

end
