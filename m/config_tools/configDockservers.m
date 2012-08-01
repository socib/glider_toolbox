function dockservers = configDockservers()
%CONFIGDOCKSERVERS  Configure dockserver parameters for glider data processing.
%
%  DOCKSERVERS = CONFIGDOCKSERVERS() should return a struct array with the
%  access parameters for the dockservers containing Slocum glider data, as
%  needed by the function GETDOCKSERVERFILES.
%
%  Notes:
%    Edit this file filling in the parameters of your dockservers.
%    Once configured, this file will contain private data, so you should not
%    make it public.
%
%  Examples:
%    dockservers = configDockservers()
%
%  See also:
%    GETDOCKSERVERFILES
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  dockservers(1).url  = 'http://mydockserver01.myportal.mydomain';
  dockservers(1).user = 'myself';
  dockservers(1).pass = 'top_secret';

  dockservers(2).url  = 'http://mydockserver02.myportal.mydomain';
  dockservers(2).user = 'myself';
  dockservers(2).pass = 'top_secret';

end
