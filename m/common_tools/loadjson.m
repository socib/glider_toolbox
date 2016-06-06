function object = loadjson(json, varargin)
%LOADJSON  JSON decoder and parser.
%
%  Syntax:
%    OBJECT = LOADJSON(JSON)
%    OBJECT = LOADJSON([], FILENAME)
%
%  Description:
%    OBJECT = LOADJSON(JSON) deserializes the value of OBJECT from string JSON
%    encoded in Javascript Object Notation format (JSON).
%
%    OBJECT = LOADJSON([], FILENAME) performs the same conversion but reading
%    from the file named by string FILENAME. The first argument is ignored.
%
%  Notes:
%    This function is inspired by a previous function by Tomeu Garau with the
%    same name. He is the true glider man. Main changes are:
%      - Added support for file input.
%      - Changed NaN mapping from string 'NaN' to value null.
%      - Changed character array mapping: only row char vectors map to strings
%        and escaped characters are unescaped properly.
%
%    There is no one-to-one map between MATLAB/Octave values and JSON values.
%    The conversion is done according to this rules:
%      - Boolean literals (true or false) map to corresponding boolean scalars.
%      - Numeric literals map to double scalars.
%      - Null literal (null) maps to double scalar NaN.
%      - String literals are converted to strings (character row vectors) 
%        unescaping character sequences according to section 2.5 of RFC in 
%        references.
%      - Objects map to scalar structs with keys as field names and values as 
%        field values mapped according to this same set of rules.
%      - Arrays map to column vector cell arrays with elements mapped according
%        to this same set of rules.
%
%  References:
%    Crockford, D.; 2006:
%    The application/json Media Type for JavaScript Object Notation (JSON).
%    <http://www.ietf.org/rfc/rfc4627.txt>
%
%  Examples:
%    % Decode from string:
%    object = loadjson('[]')
%    object = loadjson('{}')
%    object = cell2mat(loadjson('[25, 14.3, null]'))
%    object = cell2mat(loadjson('[true,false]'))
%    object = loadjson(['["unescape this:' ...
%      ' \b (backspace) \f (form feed) \n (line feed) \t (tab)' ...
%      ' \r (carriage return) \u001a (escaped unicode character)' ...
%      ' \" (quotation mark) \\ (backslash)"]'])
%    object = loadjson(['[{ "field1": "a" ,"field2" : [1, 2]},' ...
%                       ' {"field1" : "b", "field2" :[3, 5] },' ...
%                       ' {"field1":"c" , "field2":[4, 3.14]}]']);
%    % Decode from file:
%    object = loadjson([], 'json/example.json')
%
%  See also:
%    SAVEJSON
%    FOPEN
%    FREAD
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
  
  if nargin > 1
    filename = varargin{1};
    [fid, message] = fopen(filename, 'r');
    if fid < 0 
      error('glider_toolbox:loadjson:FileError', ...
            'Could not open file for reading %s: %s.', filename, message);
    end
    json = fread(fid, '*char')';
    status = fclose(fid);
    if status < 0
      error('glider_toolbox:loadjson:FileError', ...
            'Could not close file %s: %d characters read.', filename, count);
    end
  end
  
  nspc = ~isspace(json);
  step([true nspc]) = diff([0 find(nspc) length(nspc)+1]);
  next = cumsum(step);
  curs = next(1);
  tokn = json(curs);
  if tokn == '['
    object = loadjsonArray(json, curs, next);
  else
    object = loadjsonObject(json, curs, next);
  end
  
end

function [object, curs] = loadjsonObject(json, curs, next)
%LOADJSONOBJECT  Decode a scalar struct from a JSON object.
  % Initialize empty object:
  object = struct();
  % Assert begin-object found, read members if any:
  not_bad_object = (json(curs) == '{');
  curs = next(curs + 1);
  not_end_object = (json(curs) ~= '}');
  while not_bad_object && not_end_object
    % Read key:
    [key, curs] = loadjsonString(json, curs);
    % Read key-value separator:
    curs = next(curs);
    if json(curs) ~= ':'
      not_bad_object = false;
      break
    end
    curs = next(curs + 1);
    % Read value:
    [val, curs] = loadjsonValue(json, curs, next);
    % Set key-value in object:
    object.(key) = val;
    % Read member (pair) separator or end-object:
    curs = next(curs);
    switch json(curs);
      case ','
        curs = next(curs + 1);
      case '}'
        not_end_object = false;
      otherwise
        not_bad_object = false;
    end
  end
  % Assert no errors and end-object found.
  if not_bad_object
    curs = next(curs + 1);
  else
    error('glider_toolbox:loadjson:InvalidObject', ...
          'Invalid object at position %d: %s.', ...
          curs, json(max(curs-16, 1):curs));
  end
end

function [object, curs] = loadjsonArray(json, curs, next)
%LOADJSONARRAY  Decode a cell array from a JSON array.
  % Initialize empty cell array:
  object = {};
  % Assert begin-array found, read elements if any:
  not_bad_array = (json(curs) == '[');
  curs = next(curs + 1);
  not_end_array = (json(curs) ~= ']');
  while not_bad_array && not_end_array
    % Read value:
    [val, curs] = loadjsonValue(json, curs, next);
    % Set value in object:
    object{end+1} = val;
    % Read element separator or end-array:
    curs = next(curs);
    switch json(curs);
      case ','
        curs = next(curs + 1);
      case ']'
        not_end_array = false;
      otherwise
        not_bad_array = false;
    end
  end
  % Assert no errors and end-array found.
  if not_bad_array
    curs = next(curs + 1);
  else
    error('glider_toolbox:loadjson:InvalidArray', ...
          'Invalid array at position %d: %s.', ...
          curs, json(max(curs-16, 1):curs));
  end
end

function [object, curs] = loadjsonValue(json, curs, next)
%LOADJSONVALUE  Decode arbitrary value from a JSON value.
  tokn = json(curs);
  if tokn == '{'
    [object, curs] = loadjsonObject(json, curs, next);
  elseif tokn == '['
    [object, curs] = loadjsonArray(json, curs, next);
  elseif tokn == '"'
    [object, curs] = loadjsonString(json, curs);
  elseif tokn == 't' || tokn == 'f'
    [object, curs] = loadjsonBoolean(json, curs);
  else
    [object, curs] = loadjsonNumber(json, curs);
  end
end

function [object, curs] = loadjsonBoolean(json, curs)
%LOADJSONBOOLEAN  Decode a logical scalar from a JSON boolean value.
  if strncmp(json(curs:end), 'true', 4)
    object = true;
    curs = curs + 4;
  elseif strncmp(json(curs:end), 'false', 5);
    object = false;
    curs = curs + 5;
  else
    error('glider_toolbox:loadjson:InvalidBoolean', ...
          'Invalid boolean at position %d: %s.', ...
          curs, json(max(curs-16, 1):curs));
  end
end

function [object, curs] = loadjsonNumber(json, curs)
%LOADJSONNUMBER  Decode a numeric scalar value from a JSON number value.
  if strncmp(json(curs:end), 'null', 4)
    object = nan;
    curs = curs + 4;
  else
    [object, count, emsg, nextidx] = sscanf(json(curs:end), '%f', 1);
    curs = curs + nextidx - 1;
    if count ~= 1
      error('glider_toolbox:loadjson:InvalidNumber', ...
            'Invalid number at position %d: %s (%s).', ...
            curs, json(max(curs-16, 1):curs), emsg);
    end
  end
end

function [object, curs] = loadjsonString(json, curs)
%LOADJSONSTRING  Decode a row character vector from a JSON string value.
  % pattern = '^"([^"\\]+|(?:\\u[0-9a-fA-F]{4}){1,2}|\\["/\\bfnrt])*"';
  string_pattern = '^"(?:\\"|[^"])*"';
  endidx = regexp(json(curs:end), string_pattern, 'once', 'end');
  if isempty(endidx) > 1
    error('glider_toolbox:loadjson:InvalidString', ...
          'Invalid string at position %d: %s.', ...
          curs, json(max(curs-16, 1):curs));
  end
  escape_pattern = '(?:\\u[0-9a-fA-F]{4}){1,2}|\\.';
  [escape, split] = ...
    regexp(json(curs+1:curs+endidx-2), escape_pattern, 'match', 'split');
  for e = 1:length(escape)
    esc = escape{e};
    switch length(esc)
      case 12
        esc = native2unicode(uint8(hex2dec(esc([3 4; 5 6; 9 10; 11 12]))), ...
                             'UTF-16BE');
      case 6
        esc = native2unicode(uint8(hex2dec(esc([3 4; 5 6]))), 'UTF-16BE');
      case 2
        switch esc(2)
          case {'"' '\' '/'}
            esc = esc(2);
          case {'b' 'f' 't' 'n' 'r'}
            esc = sprintf(esc);
          otherwise
            error('glider_toolbox:loadjson:InvalidString', ...
                  'Invalid string at position %d: %s.', ...
                   curs, json(max(curs-16, 1):curs));
        end
    end
    split{2,e} = esc;
  end
  object = [split{:}];
  curs = curs + endidx;
end

