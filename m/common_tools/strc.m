function s = strc(c)
%STRC  Convert Matlab/OCTAVE char array to C string array.
%
%  Syntax:
%    S = STRC(C)
%
%  Description:
%    S = STRC(C) converts the blank padded char array C to a new char array S
%    with the same strings in its rows but as C strings (null terminated):
%      - always add a null character at the end of the string, and
%      - replace all trailing whitespace characters with null characters.
%    C may also be a string cell array and is converted to char array with CHAR.
%
%  Notes:
%    The output char array S is always one column bigger than the input one C
%    (because function CHAR pads the shorter rows in a cell array up to the
%    length of the longest one).
%
%  Examples:
%    c = {'- What''s that?'; '  ...  '; ''; '  ...  '; '- Surprise!!!'}
%    s = strc(c)
%    a = char(c)
%    uint8(a)
%    uint8(strc(c))
%
%  See also:
%    CHAR
%    CELLSTR
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
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
  
  c = char(c);
  [m n] = size(c);
  s = char(ones(m, n+1, 'uint8') * 32);
  s(1:m, 1:n) = c;
  [v, i] = min(isspace(s(:,end:-1:1)), [], 2);
  z = bsxfun( @gt, 1:n+1, n - i + 2);
  z(v,:) = true;
  s(z) = 0;

end
