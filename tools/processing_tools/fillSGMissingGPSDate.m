function [stampnum, hhmmss, ddmmyy] = fillSGMissingGPSDate(hhmmss, ddmmyy)
%FILLSGMISSINGGPSDATE  Fill missing date component of Seaglider GPS timestamps.
%
%  Syntax:
%    STAMPNUM = FILLSGMISSINGGPSDATE(DDMMYY, HHMMSS)
%    [STAMPNUM, HHMMSS, DDMMYY] = FILLSGMISSINGGPSDATE(HHMMSS, DDMMYY)
%
%  Description:
%    STAMPNUM = FILLSGMISSINGGPSDATE(DDMMYY, HHMMSS) fills the date component
%    of GPS timestamps given by character arrays or string cell arrays HHMMSS
%    and DDMMYY and returns them as serial date numbers in array STARTNUM.
%    See note below.
%
%    [STAMPNUM, HHMMSS, DDMMYY] = FILLSGMISSINGGPSDATE(HHMMSS, DDMMYY) also 
%    returns the same input arrays HHMMSS and DDMMYY but with the empty
%    entries in DDMMYY filled with the corresponding date component value.
%
%  Notes:
%    GPS lines in Seaglider log may have no date component and the corresponding
%    entries of input DDMMYY will be empty. Those entries are filled computing
%    the corresponding date from the next timestamp with a date component and
%    taking into account day roll backs inferred from the time components.
%
%  Examples:
%    stampvec = fillSGMissingGPSTimestamp(hhmmss, ddmmyy)
%
%  See also:
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
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

  error(nargchk(2, 2, nargin, 'struct'));
  
  nodate = cellfun(@isempty, cellstr(ddmmyy));
  stampvec(~nodate, :) = ...
    datevec(strcat(ddmmyy(~nodate,:),hhmmss(~nodate,:)), 'ddmmyyHHMMSS');
  nodate_boundary = find([true; xor(nodate(1:end-1), nodate(2:end))]);
  for i = numel(nodate_boundary):-1:2
    index_curr = nodate_boundary(i);  
    index_prev = nodate_boundary(i-1);  
    if nodate(index_prev)
      stampvec(index_prev:index_curr-1, :) = ...
        datevec(strcat(ddmmyy(index_curr,:), hhmmss(index_prev:index_curr-1,:)), ...
                'ddmmyyHHMMSS');
      dateroll = 0 > diff(datenum(stampvec(index_prev:index_curr,:)));
      stampvec(index_prev:index_curr-1, 3) = ...
        stampvec(index_prev:index_curr-1, 3) - flipud(cumsum(flipud(dateroll)));
    end
  end
  stampnum = datenum(stampvec);
  if nargout > 1
    if ischar(ddmmyy)
      ddmmyy(nodate, 1:6) = datestr(stampnum(nodate), 'ddmmyy');
    else
      ddmmyy(nodate) = cellstr(datestr(stampnum(nodate), 'ddmmyy'));
    end
  end
  
end
