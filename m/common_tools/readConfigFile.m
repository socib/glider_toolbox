function [ readvals ] = readConfigFile( fconfig, varargin )
%READCONFIGFILE 
%        TODO: Add description
%   This function should read the configuration file and return a structure
%   with the appropriate values from the text file
%   From https://rosettacode.org/wiki/Read_a_configuration_file#MATLAB_.2F_Octave
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

  narginchk(1, 3);
  
  options.array_delimiter = '|';  
    
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
    error('glider_toolbox:readConfigFile:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:readConfigFile:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  %% Read configuration file
  fid = fopen(fconfig, 'rt');
  if fid<0, error('cannot open file %s\n',fconfig); end; 
 
  while ~feof(fid)
    line = strtrim(fgetl(fid));
    
    % Reads only uncommented (# and ; symbols) and no-empty lines 
    if isempty(line) || all(isspace(line)) || strncmp(line,'#',1) || strncmp(line,';',1),
	  ; % no operation for commented line
    else 
      %% Process valid lines of the configuration file
      %      - split two sides of the equation (var = tok)
      %      - Check whether the right side (tok) is an array or a single value
      %      - Create a field readvals.(var) with the value (or array of values)
      [var,tok] = strtok(line,'=');
      var = strtrim(lower(var));
      tok = strtrim(tok);
      tok = strtok(tok,'=');  % remove = sign
      tok = strtrim(tok);
      if ~isempty(options.array_delimiter) && any(tok==options.array_delimiter),   % for arrays
        k = 1; 
        while (1)
            [val, tok]=strtok(tok,options.array_delimiter);
            %R.(var){k} = strtrim(val);  	% return value of function 
            eval(sprintf('readvals.%s{%i}=''%s'';',var,k,strtrim(val)));  % stores variable in local workspace
        if isempty(tok), break; end;
            k=k+1;
        end;
      else  % for single value
        tok = strtrim(tok);
        %R.(var) = tok;		% return value of function
        %sprintf('readvals.%s=''%s''; ',var,tok);
        
        % replaces ' character with '' in the tok value so it is evaluated correctly
        tok=strrep(tok,'''',''''''); 
        eval(sprintf('readvals.%s=''%s''; ',var,tok));  % stores variable in local workspace
      end;
    end;
  end; 
  
  fclose(fid);
  
end

