function json = savejson(object, varargin)
%SAVEJSON  JSON encoder and emitter.
%
%  Syntax:
%    JSON = SAVEJSON(OBJECT)
%    SAVEJSON(OBJECT, FILENAME)
%
%  Description:
%    JSON = SAVEJSON(OBJECT) serializes the value of OBJECT in string JSON
%    encoded in Javascript Object Notation format (JSON).
%
%    SAVEJSON(OBJECT, FILENAME) performs the same conversion but prints 
%    it to the file named by string FILENAME.
%
%  Notes:
%    This function is inspired by a previous function by Tomeu Garau with the
%    same name. He is the true glider man. Main changes are:
%      - Added support for string output.
%      - Added support for automatic creation of target directory if needed.
%      - Changed NaN mapping from string 'NaN' to value null.
%      - Changed character array mapping: only row char vectors map to strings 
%        and control characters are escaped properly.
%
%    There is no one-to-one map between MATLAB/Octave values and JSON values.
%    The conversion is done according to this rules:
%      - Boolean scalars map to corresponding boolean literals (true or false).
%      - Numeric scalars map to corresponding numeric literals, except from NaN 
%        which maps to null (because it is not a valid JSON value).
%      - Structs map to objects with field names as keys and field values as
%        values mapped according to this same set of rules.
%      - Strings (character row vectors) are converted to string literals
%        escaping characters according to section 2.5 of RFC in references.
%      - Other arrays (either character arrays, numeric arrays, struct arrays 
%        or cell arrays) map to flat arrays in column major order. 
%        Dimensionality and shape information is lost.
%
%  References:
%    Crockford, D.; 2006:
%    The application/json Media Type for JavaScript Object Notation (JSON).
%    <http://www.ietf.org/rfc/rfc4627.txt>
%
%  Examples:
%    % Encode to string:
%    json = savejson([])
%    json = savejson({})
%    json = savejson(struct())
%    json = savejson(25)
%    json = savejson(NaN)
%    json = savejson(true)
%    json = savejson(false)
%    json = savejson(rand(1,10))
%    json = savejson(...
%      {sprintf(['escape this:' ...
%                ' \b (backspace) \f (form feed) \n (line feed) \t (tab)' ...
%                ' \r (carriage return) \x001A (escaped unicode character)' ...
%                ' " (quotation mark) \\ (backslash)'])})
%    json = savejson(struct('field1', {'a', 'b', 'c'}, ...
%                            'field2', {[1 2], [3 5], [4 pi]}))
%    % Encode to file:
%    json = savejson(rand(1,10), 'json/example.json')
%
%  See also:
%    LOADJSON
%    FOPEN
%    FWRITE
%    FCLOSE
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  error(nargchk(1, 2, nargin, 'struct'));
  
  if isscalar(object) && isstruct(object)
    json = savejsonObject(object);
  else
    json = savejsonArray(object);
  end
  
  if nargin > 1
    filename = varargin{1};
    [filepath, ~, ~] = fileparts(filename);
    % MATLAB does not provide a proper way to check if a relative path points to
    % an existing directory (EXIST checks for existance in the whole load path).
    [status, attrout] = fileattrib(filepath);
    if ~status
      [success, message] = mkdir(filepath);
      if ~success
        error('glider_toolbox:savejson:DirectoryError', ...
              'Could not create directory %s: %s.', filepath, message);
      end
    elseif ~attrout.directory
      error('glider_toolbox:savejson:DirectoryError', ...
            'Not a directory %s.', filepath);
    end
    [fid, message] = fopen(filename, 'w');
    if fid < 0 
      error('glider_toolbox:savejson:FileError', ...
            'Could not open file for writing %s: %s.', filename, message);
    end
    count = fwrite(fid, json, 'char');
    status = fclose(fid);
    if status < 0
      error('glider_toolbox:savejson:FileError', ...
            'Could not close file %s: %d characters written.', filename, count);
    end
  end
  
end

function json = savejsonObject(object)
%SAVEJSONOBJECT  Encode a scalar struct as a JSON object.
  keys = fieldnames(object);
  vals = struct2cell(structfun(@savejsonValue, object, 'UniformOutput', false));
  pairs = [keys(:) vals(:)]';
  switch size(pairs, 2)
    case 0
      json = '{}';
    case 1
      json = ['{' sprintf('"%s":%s', pairs{:}) '}'];
    otherwise
      json = ['{' ...
              sprintf('"%s":%s,', pairs{:, 1:end-1}) ...
              sprintf('"%s":%s', pairs{:, end}) ...
              '}'];
  end
end

function json = savejsonArray(object)
%SAVEJSONARRAY  Encode a cell array or array as a JSON array.
  if iscell(object)
    vals = cellfun(@savejsonValue, object, 'UniformOutput', false);
  else
    vals = arrayfun(@savejsonValue, object, 'UniformOutput', false);
  end
  switch numel(vals)
    case 0
      json = '[]';
    case 1
      json  = ['[' sprintf('%s', vals{:}) ']'];
    otherwise
      json  = ['[' sprintf('%s,', vals{1:end-1}) sprintf('%s', vals{end}) ']'];
  end
end

function json = savejsonValue(object)
%SAVEJSONVALUE  Encode an arbitrary value as a JSON value.
  if ischar(object) && isrow(object)
    json = savejsonString(object);
  elseif ~isscalar(object) || iscell(object)
    json = savejsonArray(object);
  elseif islogical(object)
    json = savejsonBoolean(object);
  elseif isnumeric(object)
    json = savejsonNumber(object);
  elseif isstruct(object)
    json = savejsonObject(object);
  end
end

function json = savejsonBoolean(object)
%SAVEJSONBOOLEAN  Encode a scalar boolean value as a JSON boolean value.
  if object
    json = 'true';
  else
    json = 'false';
  end
end

function json = savejsonNumber(object)
%WRTIEJSONNUMBER  Encode a scalar numeric value as a JSON number value.
  if isnan(object)
    json = 'null';
  else
    json = sprintf('%G', object);
  end
end

function json = savejsonString(object)
%SAVEJSONSTRING  Encode a row char vector value as a JSON string value.
  control_characters = arrayfun(@(b)(native2unicode(b, 'UTF-8')), ...
                                uint8(0:31), 'UniformOutput', false);
  control_escapeseqs = arrayfun(@(b)(sprintf('\\u%04x', b)), ...
                                uint8(0:31), 'UniformOutput', false);
  control_escapeseqs(1+[8 9 10 12 13])  = {'\b' '\t' '\n' '\f' '\r'};
  json = [ ...
    '"' ...    
    regexprep(object, ...
              regexptranslate('escape', [{'\'  '"' } control_characters]), ...
              regexptranslate('escape', [{'\\' '\"'} control_escapeseqs])) ...
    '"' ];
end
