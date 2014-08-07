function display(h)
% DISPLAY Display method for the SFTP object.
%
%  Syntax:
%    DISPLAY(H)
%
%  DISPLAY(H) displays an SFTP object as text.
%
%  Examples:
%    display(h)
%
%  See also:
%    SFTP
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  fprintf('\n%s = \n\n', inputname(1));
  disp(h)
  fprintf('\n');
