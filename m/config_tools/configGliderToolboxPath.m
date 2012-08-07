function [glider_toolbox_dir] = configGliderToolboxPath()
%CONFIGGLIDERTOOLBOXPATH  Configure path to include the glider toolbox.
%
%  GLIDER_TOOLBOX_DIR = CONFIGGLIDERTOOLBOXPATH() adds the parent directory
%  of the one containing this function and all its subdirectories
%  to the workspace path and returns the parent directory path.
%
%  Examples:
%    glider_toolbox_dir = configGliderToolboxPath()
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  [mfile_path, ~, ~] = fileparts(mfilename('fullpath'));
  [glider_toolbox_dir, ~, ~] = fileparts(mfile_path);
  addpath(genpath(glider_toolbox_dir));

end
