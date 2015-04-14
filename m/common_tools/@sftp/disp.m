function disp(h)
% DISP Display method for the SFTP object.
%
%  Syntax:
%    DISP(H)
%
%  Description:
%    DISP(H) displays an SFTP object as text.
%
%  Examples:
%    disp(h)
%
%  See also:
%    SFTP
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

if length(h) ~= 1
    % FTP array; Should work for empty case as well.
    s = size(h);
    str = sprintf('%dx',s);
    str(end) = [];
    fprintf('%s array of SFTP objects\n', str);
else
    disp(sprintf( ...
      '  SFTP Object\n     host: %s\n     port: %s\n     user: %s\n      dir: %s\n', ...
      h.host, num2str(h.port), h.username, mexsftp('pwd', h.sftp_handle)));
end
