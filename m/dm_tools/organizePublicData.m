function [ ] = organizePublicData( output_path, outputs, figures )
% ORGANIZEPUBLICDATA  Copies data (netCDF and figures) to public directories
%
%  Syntax:
%    ORGANIZEPUBLICDATA(CONFIG, OUTPUTS, FIGURES)
%
%  Description:
%    ORGANIZEPUBLICDATA copies netCDF files and figures to the public
%    directories that are defined in the configuration input. 
%
%  Input:
%    PUBLIC_PATH defines the location of the public directories where the
%      netCDF and figures will be copied.
%    OUTPUTS is a structure containing the names of the NetCDF files that
%      were created along the process. The structure may contain
%      (optionally) these fields
%       - netcdf_l0:    L0 level NetCDF file
%       - netcdf_l1:    L1 level NetCDF file
%       - netcdf_l2:    L2 level NetCDF file
%       - netcdf_egol0: L1 level NetCDF-EGO file
%    FIGURES is a structure containing the file names of the figures that
%      were created along the process. The structure may contain
%      (optionally) these fields
%       - fig_proc: structure with the figures of processed data
%       - fig_grid: structure with the figures of gridded data  
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
 
  %% Initialization
  narginchk(3, 3);
  
  %% Set the directory paths
  public_paths = struct();  
  if isfield(output_path, 'netcdf_l0') && ~isempty(output_path.netcdf_l0)
    public_paths.netcdf_l0 = fullfile(output_path.base_dir, output_path.netcdf_l0);
  end 
  %Note: The L0 engineering files are not added here in purpose in order to
  %      avoid making the engineering files on purpose.
  if isfield(output_path, 'netcdf_l1') && ~isempty(output_path.netcdf_l1)
    public_paths.netcdf_l1 = fullfile(output_path.base_dir, output_path.netcdf_l1);
  end
  if isfield(output_path, 'netcdf_egol1') && ~isempty(output_path.netcdf_egol1)
    public_paths.netcdf_egol1 = fullfile(output_path.base_dir, output_path.netcdf_egol1);
  end
  if isfield(output_path, 'netcdf_l2') && ~isempty(output_path.netcdf_l2)
    public_paths.netcdf_l2 = fullfile(output_path.base_dir, output_path.netcdf_l2);
  end
  if isfield(output_path, 'base_url') && isfield(output_path, 'base_html_dir') && ...
     isfield(output_path, 'figure_dir') && isfield(output_path, 'figure_info')     
      public_paths.figure_dir = fullfile(output_path.base_html_dir, output_path.figure_dir);
      public_paths.figure_url = fullfile(output_path.base_url, output_path.figure_dir);
      public_paths.figure_info = fullfile(output_path.base_html_dir, output_path.figure_info);
  end
    
  %% Copy selected products to corresponding public location, if needed.
  if ~isempty(fieldnames(outputs))
    disp('Copying public outputs...');
    strloglist = '';
    output_name_list = fieldnames(outputs);
    num_outputs = numel(output_name_list);
    for output_name_idx = 1:num_outputs
      output_name = output_name_list{output_name_idx};
      %disp([num2str(output_name_idx) '/' num2str(num_outputs) {' ===> '} output_name]);
      if isfield(public_paths, output_name) ...
           && ~isempty(public_paths.(output_name))
        output_local_file = outputs.(output_name);
        output_public_file = public_paths.(output_name);
        output_public_dir = fileparts(output_public_file);
        [status, attrout] = fileattrib(output_public_dir);
        if ~status
          [status, message] = mkdir(output_public_dir);
        elseif ~attrout.directory
          status = false;
          message = 'not a directory';
        end
        if status
          [success, message] = copyfile(output_local_file, output_public_file);
          if success
            disp(['Public output ' output_name ' succesfully copied: ' ...
                  output_public_file '.']);
            if ~isempty(strloglist)
                strloglist = strcat(strloglist,{', '});
            end
            strloglist = strcat(strloglist,output_public_file);
          else
            disp(['Error creating public copy of deployment product ' ...
                  output_name ': ' output_public_file '.']);
            disp(message);
          end
        else
          disp(['Error creating public output directory ' ...
                output_public_dir ':']);
          disp(message);
        end
      end
    end
    if ~isempty(strloglist)
        strloglist = strcat({'__SCB_LOG_MSG_UPDATED_PUBLIC_FILES__ ['}, strloglist, ']'); 
        disp(strloglist{1});
    end
  end


  %% Copy selected figures to its public location, if needed.
  % Copy all generated figures or only the ones in the include list (if any) 
  % excluding the ones in the exclude list. 
  if ~isempty(fieldnames(figures)) ...
      && isfield(public_paths, 'figure_dir') ...
      && ~isempty(public_paths.figure_dir)
    disp('Copying public figures...');
    public_figure_baseurl = public_paths.figure_url;
    public_figure_dir     = public_paths.figure_dir;
    public_figure_include_all = true;
    public_figure_exclude_none = true;
    public_figure_include_list = [];
    public_figure_exclude_list = [];
    if isfield(public_paths, 'figure_include')
      public_figure_include_all = false;
      public_figure_include_list = public_paths.figure_include;
    end
    if isfield(public_paths, 'figure_exclude')
      public_figure_exclude_none = false;
      public_figure_exclude_list = public_paths.figure_exclude;
    end
    public_figures = struct();
    public_figures_local = struct();
    figure_output_name_list = fieldnames(figures);
    num_figure_outputs = numel(figure_output_name_list);
    for figure_output_name_idx = 1:num_figure_outputs
      figure_output_name = figure_output_name_list{figure_output_name_idx};
      disp([num2str(figure_output_name_idx) '/' num2str(num_figure_outputs) {' ===> '} figure_output_name]);
      figure_output = figures.(figure_output_name);
      figure_name_list = fieldnames(figure_output);
      for figure_name_idx = 1:numel(figure_name_list)
        figure_name = figure_name_list{figure_name_idx};
        if (public_figure_include_all ...
            || ismember(figure_name, public_figure_include_list)) ...
            && (public_figure_exclude_none ...
            || ~ismember(figure_name, public_figure_exclude_list))
          if isfield(public_figures_local, figure_name)
            disp(['Warning: figure ' figure_name ' appears to be duplicated.']);
          else
            public_figures_local.(figure_name) = figure_output.(figure_name);
          end
        end
      end
    end
    public_figure_name_list = fieldnames(public_figures_local);
    if ~isempty(public_figure_name_list)
      [status, attrout] = fileattrib(public_figure_dir);
      if ~status
        [status, message] = mkdir(public_figure_dir);
      elseif ~attrout.directory
        status = false;
        message = 'not a directory';
      end
      if status
        for public_figure_name_idx = 1:numel(public_figure_name_list)
          public_figure_name = public_figure_name_list{public_figure_name_idx};
          figure_local = public_figures_local.(public_figure_name);
          figure_public = figure_local;
          figure_public.url = ...
            [public_figure_baseurl '/' ...
             figure_public.filename '.' figure_public.format];
          figure_public.dirname = public_figure_dir;
          figure_public.fullfile = ...
            fullfile(figure_public.dirname, ...
                     [figure_public.filename '.' figure_public.format]);
          [success, message] = ...
            copyfile(figure_local.fullfile, figure_public.fullfile);
          if success
            public_figures.(public_figure_name) = figure_public;
            disp(['Public figure ' public_figure_name ' succesfully copied.']);
          else
            disp(['Error creating public copy of figure ' ...
                  public_figure_name ': ' figure_public.fullfile '.']);
            disp(message);
          end
        end
      else
        disp(['Error creating public figure directory ' public_figure_dir ':']);
        disp(message);
      end
    end
    % Write the figure information to the JSON service file.
    if isfield(public_paths, 'figure_info') && ~isempty(public_paths.figure_info)
      disp('Generating figure information service file...');
      public_figure_info_file = public_paths.figure_info;
      try
        savejson(public_figures, public_figure_info_file);
        disp(['Figure information service file successfully generated: ' ...
              public_figure_info_file]);
      catch exception
        disp(['Error creating figure information service file ' ...
              public_figure_info_file ':']);
        disp(message);
      end
    end
    
  end

end

