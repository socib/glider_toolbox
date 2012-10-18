function distance = computeCumulativeDistance(latitude, longitude)
%COMPUTECUMULATIVEDISTANCE  Cumulate distance along given trajectory.
%
%  DISTANCE = COMPUTECUMULATIVEDISTANCE(LATITUDE, LONGITUDE) computes the
%  cumulative distance (in km) of a trajectory defined by coordinate vectors 
%  LATITUDE and LONGITUDE. DISTANCE, LATITUDE and LONGITUDE have the same 
%  dimensions. Invalid values (NaN) are ignored but preserved in output.
%
%  Notes:
%    Two functions may be used to compute distance between consecutive 
%    geographical coordinates: 
%      M_LLDIST (from M_Map toolbox)
%      SW_DIST (from CSIRO's SeaWater library)
%    Function M_LLDIST is preferred because its method (haversine) seems to be
%    more accurate. If it is not available, function SW_DIST is used instead.
%    
%  Examples:
%    latitude  = [39.50   nan 39.50  nan 39.21   nan 39.23   nan   nan   nan 38.98   nan 38.98]
%    longitude = [ 2.18   nan   nan  nan  1.65   nan  1.28   nan  1.09   nan  1.09   nan  0.12]
%    distance = computeCumulativeDistance(latitude, longitude)
%
%  See also:
%    M_LLDIST
%    SW_DIST
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 2, nargin, 'struct'));
  
  distance = nan(size(latitude));
  valid_point_sel = ~(isnan(latitude) | isnan(longitude));
  latitude_valid = latitude(valid_point_sel);
  longitude_valid = longitude(valid_point_sel);
  switch sum(valid_point_sel)
    case 0
    case 1
      distance(valid_point_sel) = 0;
    otherwise
      if exist('m_lldist', 'file') == 2 % exists and is a file (not a folder)
        distance(valid_point_sel) = ...
          cumsum([0; m_lldist(longitude_valid(:), latitude_valid(:))]);
      elseif exist('sw_dist', 'file') == 2
        distance(valid_point_sel) = ...
          cumsum([0; sw_dist(latitude_valid(:), longitude_valid(:), 'km')]);
      else
        error('glider_toolbox:computeCumulativeDistance:MissingBackendFunction', ...
              'Missing backend functions: m_lldist (preferred) or sw_dist');
      end
  end

end
