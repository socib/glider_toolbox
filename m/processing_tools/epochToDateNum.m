function date_num = epochToDateNum(posix_time)
%EPOCH2DATENUM  POSIX time to serial date number conversion.
%
%  DATE_NUM = EPOCH2DATENUM(POSIX_TIME) Converts the numeric array POSIX_TIME
%  containing instants expressed as seconds since 1970-01-01 00:00:00.00 UTC to
%  a numeric array DATE_NUM with the correspondin native serial date numbers.
%
%  Notes:
%    The conversion simply uses date vector arithmethic relying on the DATENUM
%    function.
%
%  Examples:
%    epoch = epochToDateNum(0)
%    datestr(epoch, 31)
%    full_week_after_epoch = epochToDateNum(24*3600*(0:6))
%    datestr(full_week_after_epoch, 31)
%
%  See also:
%    DATENUM
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

error(nargchk(1, 1, nargin, 'struct'));

% epoch = datenum([1970 1 1 0 0 0.0]);
% date_num = arrayfun(@(t) addtodate(epoch, t, 'millisecond'), round(1000*posix_time));

epoch = [1970 1 1 0 0 0.0];
date_vec = repmat(epoch, numel(posix_time), 1);
date_vec(:,6) = posix_time(:);
date_num = reshape(datenum(date_vec), size(posix_time));

end
