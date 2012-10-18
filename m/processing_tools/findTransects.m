function transect_index = findTransects(waypoint_latitude, waypoint_longitude)
%FINDTRANSECTS  Identify transects from waypoint coordinates.
%
%  TRANSECT_INDEX = FINDTRANSECTS(WAYPOINT_LATITUDE, WAYPOINT_LONGITUDE) 
%  identifies transects (travels from one waypoint to the next one) from 
%  waypoint coordinates in vectors WAYPOINT_LATITUDE and WAIPONT_LONGITUDE, 
%  and flags each point with the index of the transect the point belongs to, 
%  starting from 1. WAYPOINT_LATITUDE, WAYPOINT_LONGITUDE and TRANSECT_INDEX
%  have the same length.
%
%  Notes:
%    A new transect starts whenever a change in latitude or longitude waypoint
%    coordinate is found. Transects are numbered cumulating changes of latitude 
%    or longitude coordinates, ignoring invalid values (NaN) in the sequences.
%
%    This function is based on the previous work by Tomeu Garau, in a function
%    called GETTRANSECTS. He is the true glider man.
%
%  Examples:
%    waypoint_latitude  = [39.50   nan 39.50  nan 39.21   nan 39.23   nan   nan   nan 38.98   nan 38.98]
%    waypoint_longitude = [ 2.18   nan   nan  nan  1.65   nan  1.28   nan  1.09   nan  1.09   nan  0.12]
%    transect_index = findTransects(waypoint_latitude, waypoint_longitude)
%    figure
%    subplot(2,1,1)
%    plotyy(waypoint_latitude, 'og', waypoint_longitude, 'or')
%    subplot(2,1,2)
%    stairs(transect_index)
%
%  See also:
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 2, nargin, 'struct'));
  
  waypoint_coordinates = [waypoint_latitude(:) waypoint_longitude(:)];
  
  % Initialize transect index to have the same dimensions as given inputs.
  % This also handles degenerated cases (empty or all data invalid).
  transect_index = ones(size(waypoint_latitude)); 
  if ~isempty(waypoint_coordinates)
    waypoint_coordinate_change = false(size(waypoint_coordinates));
    for i = 1:2
      coord_valid_sel = ~isnan(waypoint_coordinates(:,i));
      coord_valid_ind = find(coord_valid_sel);
      coord_valid = waypoint_coordinates(coord_valid_sel, i);
      coord_valid_change = [false; (coord_valid(2:end) ~= coord_valid(1:end-1))];
      waypoint_coordinate_change(coord_valid_ind(coord_valid_change), i) = true;
    end
    transect_index(:) = 1 + cumsum(any(waypoint_coordinate_change, 2));   
  end
  
end
