function [glider_toolbox_dir] = configGliderToolboxPath()
%CONFIGGLIDERTOOLBOXPATH  Configure path to include the glider toolbox.
%
%  GLIDER_TOOLBOX_DIR = CONFIGGLIDERTOOLBOXPATH() adds the directory
%  containing this function and all its subdirectories to the workspace
%  path and returns the full directory path.
%
%  Examples:
%    glider_toolbox_dir = configGliderToolboxPath()
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));

  [glider_toolbox_dir, ~, ~] = fileparts(mfilename('fullpath'));
  addpath(genpath(glider_toolbox_dir));

end
