function [] = convertBinaryData( input_path, output_path, glider_type, varargin)
% CONVERTBINARYDATA  Create human readable files from binary glider data
%
%  Syntax:
%    CONVERTBINARYDATA(INPUT_PATH, OUTPUT_PATH, GLIDER_TYPE)
%
%    CONVERTBINARYDATA(INPUT_PATH, OUTPUT_PATH, GLIDER_TYPE, OPT1, VAL1, ...)
%
%  Description:
%    CONVERTBINARYDATA converts binary glider files to ascii human readable
%    format for Slocum data. Check deployment files available in binary
%    directory, convert them to ascii format in the ascii directory, and
%    store the returned absolute path for later use. Since some conversion
%    may fail use a cell array of string cell arrays and flatten it when
%    finished, leaving only the succesfully created dbas. Give a second try
%    to failing files, because they might have failed due to  a missing
%    cache file generated later. 
%
%  Input:
%    INPUT_PATH: Location where the binary xdb files are in the local drive.
%    OUTPUT_PATH: Location where the ascii files are created. 
%    GLIDER_TYPE: Glider type may be slocum_g1, slocum_g2 or seaglider. It
%      is used to select the dockserver retrieval method. Onlly slocum
%      types creates a process since the other glider types do not produce
%      binary files.
%    
%  Options:
%    XBD_NAME_PATTERN: Pattern to identify XBD files. Default is
%      ^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$ 
%    DBA_NAME_REPLACE: Convention to create the DBA ascii files. Default is
%      $1-$2.dba
%    CACHE: Directory where the cache files containing the header
%      information are created. These files are used because only the first
%      file of a data set received from the Slocum contains the entire
%      header information in order to save satellite communication
%      time/data. Default is input path.
%    CMDNAME: Command used to convert the data. Default is the WRC binary
%      file dbd2asc which converts Slocum files.
%
%  Output: Files are created in the output directory.
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
%  Copyright (C) 2013-2016
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

    
    narginchk(3, 11);
  
    options.xbd_name_pattern = '^(\w+-\d{4}-\d+-\d+-\d+)\.([smdtne]bd)$';
    options.dba_name_replace = '$1-$2.dba';
    options.cache            = input_path;
    options.cmdname          = 'dbd2asc';
    
    %% Parse optional arguments.
    % Get option key-value pairs in any accepted call signature.
    argopts = varargin;
    if isscalar(argopts) && isstruct(argopts{1})
        % Options passed as a single option struct argument:
        % field names are option keys and field values are option values.
        opt_key_list = fieldnames(argopts{1});
        opt_val_list = struct2cell(argopts{1});
    elseif mod(numel(argopts), 2) == 0
        % Options passed as key-value argument pairs.
        opt_key_list = argopts(1:2:end);
        opt_val_list = argopts(2:2:end);
    else
        error('glider_toolbox:gliderDataProcessingEGO:InvalidOptions', ...
              'Invalid optional arguments (neither key-value pairs nor struct).');
    end
    % Overwrite default options with values given in extra arguments.
    for opt_idx = 1:numel(opt_key_list)
        opt = lower(opt_key_list{opt_idx});
        val = opt_val_list{opt_idx};
        if isfield(options, opt)
          options.(opt) = val;
        else
          error('glider_toolbox:gliderDataProcessingEGO:InvalidOption', ...
                'Invalid option: %s.', opt);
        end
    end



  %% Convert binary glider files to ascii human readable format
  switch glider_type
    case {'slocum_g1' 'slocum_g2'}
        % Look for xbds in binary directory.
        disp('Converting binary data files to ascii format...');
        bin_dir_contents = dir(input_path);
        xbd_select = ~[bin_dir_contents.isdir] ...
          & ~cellfun(@isempty, regexp({bin_dir_contents.name}, options.xbd_name_pattern));
        xbd_names = {bin_dir_contents(xbd_select).name};
        xbd_sizes = [bin_dir_contents(xbd_select).bytes];
        disp(['Binary files path: ' input_path]);
        disp(['Binary files found: ' num2str(numel(xbd_names)) ...
             ' (' num2str(sum(xbd_sizes)*2^-10) ' kB).']);
        new_files = cell(size(xbd_names));
        for conversion_retry = 1:2
          for xbd_idx = 1:numel(xbd_names)
            if isempty(new_files{xbd_idx})
              xbd_name_ext = xbd_names{xbd_idx};
              dba_name_ext = regexprep(xbd_name_ext, ...
                                       options.xbd_name_pattern, ...
                                       options.dba_name_replace);
              xbd_fullfile = fullfile(input_path, xbd_name_ext);
              dba_fullfile = fullfile(output_path, dba_name_ext);
              try
                new_files{xbd_idx} = ...
                  {xbd2dba(xbd_fullfile, dba_fullfile, ...
                           'cache', options.cache, ...
                           'cmdname', options.cmdname)};
              catch exception
                new_files{xbd_idx} = {};
                if conversion_retry == 2
                  disp(['Error converting binary file ' xbd_name_ext ':']);
                  disp(getReport(exception, 'extended'));
                end
              end
            end
          end
        end
        new_files = [new_files{:}];
        disp(['Binary files converted: ' ...
              num2str(numel(new_files)) ' of ' num2str(numel(xbd_names)) '.']);
    otherwise
  end

end

