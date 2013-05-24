function json = writeJSON(object, varargin)
%WRITEJSON  JSON encoder and emitter.
%
%  Syntax:
%    JSON = WRITEJSON(OBJECT)
%    WRITEJSON(OBJECT, FILENAME)
%
%  JSON = WRITEJSON(OBJECT) serializes the value of OBJECT in string JSON
%  encoded in Javascript Object Notation format (JSON).
%
%  WRITEJSON(OBJECT, FILENAME) performs the same conversion but prints it to the
%  file named by string FILENAME.
%
%  Notes:
%    These function is inspired by a previous function by Tomeu Garau with the
%    same name. He is the true glider man. Main changes are:
%      - Added support for string output.
%      - Added support for automatic creation of target directory if needed.
%      - Changed NaN mapping from string 'NaN' to value null.
%      - Changed character array mapping: only row char vectors map to strings.
%
%    There is no one-to-one map between MATLAB/Octave values and JSON values.
%    The conversion is done according to this rules:
%      - Boolean scalars map to corresponding boolean literals (true or false).
%      - Numeric scalars map to corresponding numeric literals, except from NaN 
%        which maps to null (because it is not a valid JSON value).
%      - Strings (character row vectors) are converted to string literals.
%      - Other arrays (either numeric arrays, struct arrays or cell arrays) map
%        to arrays in row major order. Dimensionality and shape information is
%        lost.
%      - Structs map to objects with field names as keys and field values as
%        values mapped according to these same set of rules.
%
%  Examples:
%    % Encode to string:
%    json = writeJSON([])
%    json = writeJSON({})
%    json = writeJSON(struct())
%    json = writeJSON(25)
%    json = writeJSON(NaN)
%    json = writeJSON(true)
%    json = writeJSON(false)
%    json = writeJSON(rand(1,10))
%    json = writeJSON(struct('field1', {'a', 'b', 'c'}, ...
%                            'field2', {[1 2], [3 5], [4 pi]}))
%    % Encode to file:
%    json = writeJSON(rand(1,10), 'json/example.json')
%
%  See also:
%    FOPEN
%    FPRINTF
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(1, 2, nargin, 'struct'));
  
  if isscalar(object) && isstruct(object)
    json = writeJSONObject(object);
  else
    json = writeJSONArray(object);
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
        error('glider_toolbox:writeJSON:DirectoryError', ...
              'Could not create directory %s: %s.', filepath, message);
      end
    elseif ~attrout.directory
      error('glider_toolbox:writeJSON:DirectoryError', ...
            'Not a directory %s.', filepath);
    end
    [fid, message] = fopen(filename, 'w');
    if fid < 0 
      error('glider_toolbox:writeJSON:FileError', ...
            'Could not open file for writing %s: %s.', filename, message);
    end
    count = fprintf(fid, '%s', json);
    status = fclose(fid);
    if status < 0
      error('glider_toolbox:writeJSON:FileError', ...
            'Could not close file %s: %d bytes written.', filename, count);
    end
    
  end

end

function json = writeJSONObject(object)
%WRITEJSONOBJECT  Encode a scalar struct as a JSON object.
  keys = fieldnames(object);
  vals = struct2cell(structfun(@writeJSONValue, object, 'UniformOutput', false));
  pairs = [keys(:) vals(:)]';
  if isempty(pairs)
    json = '{}';
  else
    json = ['{' ...
            sprintf('"%s":%s,', pairs{:, 1:end-1}) ...
            sprintf('"%s":%s', pairs{:, end}) ...
            '}'];
  end
end

function json = writeJSONArray(object)
%WRITEJSONARRAY  Encode a cell array or array as a JSON array.
  if iscell(object)
    vals = cellfun(@writeJSONValue, object, 'UniformOutput', false);
  else
    vals = arrayfun(@writeJSONValue, object, 'UniformOutput', false);
  end
  if isempty(vals)
    json = [];
  else
    json  = ['[' sprintf('%s,', vals{1:end-1}) sprintf('%s', vals{end}) ']'];
  end
end

function json = writeJSONValue(object)
%WRITEJSONVALUE  Encode an arbitrary value as a JSON value.
  if ischar(object) && isrow(object)
    json = writeJSONString(object);
  elseif ~isscalar(object) || iscell(object)
    json = writeJSONArray(object);
  elseif islogical(object)
    json = writeJSONBoolean(object);
  elseif isnumeric(object)
    json = writeJSONNumber(object);
  elseif isstruct(object)
    json = writeJSONObject(object);
  end
end

function json = writeJSONBoolean(object)
%WRITEJSONBOOLEAN  Encode a scalar boolean value as a JSON boolean value.
  if object
    json = 'true';
  else
    json = 'false';
  end
end

function json = writeJSONNumber(object)
%WRTIEJSONNUMBER  Encode a scalar numeric value as a JSON number value.
  if isnan(object)
    json = 'null';
  else
    json = sprintf('%G', object);
  end
end

function json = writeJSONString(object)
%WRITEJSONSTRING  Encode a row char vector value as a JSON string value.
  json = sprintf('"%s"', object);
end
