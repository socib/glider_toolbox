function preprocessing_options = configPreprocessingOptions()
%CONFIGPREPROCESSINGOPTIONS  Configure glider data preprocessing.
%
%  PREPROCESSING_OPTIONS = CONFIGPREPROCESSINGOPTIONS() should return a struct
%  setting the options for glider data preprocessing as needed by the function
%  PREPROCESSGLIDERDATA.
%
%  Examples:
%    preprocessing_options = configPreprocessingOptions()
%
%  See also:
%    PREPROCESSGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  preprocessing_options.nmea_coord_sensors = {
    'm_gps_lat'
    'm_gps_lon'
    'm_lat'
    'm_lon'
    'c_wpt_lat'
    'c_wpt_lon'
  };

end
