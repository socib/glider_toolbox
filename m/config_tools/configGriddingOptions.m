function gridding_options = configGriddingOptions()
%CONFIGGRIDDINGOPTIONS  Configure glider data gridding.
%
%  GRIDDING_OPTIONS = CONFIGGRIDDINGOPTIONS() should return a struct
%  setting the options for glider data processing as needed by the function
%  GRIDGLIDERDATA.
%
%  Examples:
%    gridding_options = configGriddngOptions()
%
%  See also:
%    GRIDGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  gridding_options = struct();
  
  gridding_options.profile = {'profile_index'};
  
  gridding_options.time = {'time'};
  
  gridding_options.position(1).latitude = 'latitude';
  gridding_options.position(1).longitude = 'longitude';
  
  gridding_options.depth = {'depth'};
  
  gridding_options.depth_step = 1;

  gridding_options.variables = { 
    'conductivity' 
    'temperature' 
    'pressure'   
    'chlorophyll'
    'turbidity'
    'oxygen_concentration'
    'oxygen_saturation'
    'conductivity_corrected_thermal'
    'temperature_corrected_thermal'
    'salinity'
    'density'
    'salinity_corrected_thermal'
    'density_corrected_thermal'
  };

end
