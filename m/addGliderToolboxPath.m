function addGliderToolboxPath()
%ADDGLIDERTOOLBOXPATH  Configure path to include this toolbox.
%
%  ADDGLIDERTOOLBOXPATH() adds the directory containing this function 
%  and all subdirectories in it to the workspace path.
%
%  Examples:
%    path
%    addGliderToolboxPath()
%    path
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

error(nargchk(0, 0, nargin, 'struct'));

[mfile_path, ~, ~] = fileparts(mfilename('fullpath'));
addpath(genpath(mfile_path));

end
