function str = strfglider(pattern, deployment)
%STRFGLIDER  Replace deployment field specifiers in pattern with deployment field values.
%
%  STR = STRFGLIDER(PATTERN, DEPLOYMENT) replaces deployment field specifiers in
%  string PATTERN with the corresponding field values in struct DEPLOYMENT.
%  Recognized field specifier keys match the fields in the deployment structure.
%  They are deployment field names in capital letters enclosed in curly braces 
%  and prefixed with a dollar sign. Specifiers may also include a comma 
%  separatated list of modifiers, separated from the specifier key by a comma. 
%  These modifiers are intended to allow transformations affecting the format 
%  of the replacement value. These transformations are applied sequentially as 
%  they appear in the specifier, from left to right. Each transformation is 
%  applied to the output of the previous one, starting from value of the 
%  deployment field matching the specifier key, or the empty string if there is
%  no such field. Finally, if the resulting replacement value is a numeric
%  value, it is converted to string by function NUM2STRING before applying the
%  replacement. Recognized modifiers are:
%    %...: string conversion with desired format using SPRINTF.
%      The current replacement value is passed to function SPRINTF using the
%      modifier value as format string.
%      Example:
%        '${DEPLOYMENT_ID,%04d}' with DEPLOYMENT_ID=2 is replaced by 0002.
%    ^: upper case conversion.
%      The current replacement value is converted to upper case by passing it to
%      function UPPER.
%      Example:
%        '${GLIDER_NAME,^}' with GLIDER_NAME='deepy' is replaced by 'DEEPY'.
%    v: lower case conversion.
%      The current replacement value is converted to lower case by passing it to
%      function LOWER.
%      Example:
%        '${GLIDER_NAME,^}' with GLIDER_NAME='DEEPY' is replaced by 'deepy'.
%    T...: time string representation.
%      The current replacement value is passed to function DATESTR using the
%      the modifier value as format string with leading T removed.
%      Example:
%        ${DEPLOYMENT_END,Tyyyymmmdd} with DEPLOYMENT_END=datestr([2001 01 17]) 
%        is replaced by '2001Jan17'.
%    s/.../...: regular expression replacement.
%      The current replacement value is passed to function REGEXPREP to replace
%      the occurrences of a pattern subexpression by a replacement, both
%      specified in the modifier as substrings separated by a delimiter. The 
%      delimiter is the second character in the modifier (here is '/', but any
%      other character may be used). The pattern is the substring between the 
%      first and the second occurrence of the delimiter in the modifier. The 
%      replacement is the substring starting right after the second occurence 
%      of the delimiter until the end of the modifier. If the replacement is
%      the null string, the second delimiter is optional, and subexpressions in
%      the current replacement value matching the pattern are deleted.
%      Example:
%        ${GLIDER_NAME,s/(-|\s*)/_} with 
%        GLIDER_NAME='complex-compound  glider name' is replaced by 
%        'complex_compound_glider_name'.
%    
%  Notes:
%    This function is inspired by the C function STRFTIME, the shell 
%    command DATE, and Bash parameter expansion.
%
%  Examples:
%    deployment.deployment_id = 2;
%    deployment.deployment_name = 'funnymission';
%    deployment.glider_name = 'happyglider';
%    deployment.glider_deployment_code = '0001';
%    deployment.deployment_start = datenum([2000 1 1 0 0 0]);
%    deployment.deployment_end =  datenum([2001 1 1 0 0 0]);
%    pattern = '/base/path/${GLIDER_NAME}/${DEPLOYMENT_NAME}'
%    str = strfglider(pattern, deployment)
%    nums_pattern = '/base/path/${GLIDER_NAME}/${DEPLOYMENT_ID,%04d}'
%    nums_str = strfglider(nums_pattern, deployment)
%    case_pattern = '/base/path/${GLIDER_NAME,^}/${DEPLOYMENT_NAME}'
%    case_str = strfglider(case_pattern, deployment)
%    date_pattern = '/base/path/${GLIDER_NAME}/${DEPLOYMENT_START,Tyyyy-mm-dd}'
%    date_str = strfglider(date_pattern, deployment)
%    subs_pattern = '/base/path/${GLIDER_NAME}/${DEPLOYMENT_NAME,s/funny/boring}'
%    subs_str = strfglider(subs_pattern, deployment)
%
%  See also:
%    SPRINTF
%    DATESTR
%    UPPER
%    LOWER
%    REGEXPREP
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
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

  error(nargchk(2, 2, nargin, 'struct'));

  repflds = fieldnames(deployment);
  repvals = struct2cell(deployment);
  repkeys = upper(repflds);
  specprefix = '${';
  specsuffix = '}';
  specinchar = ',';
  expression = [regexptranslate('escape', specprefix) ...
                '.*?' ...
                regexptranslate('escape', specsuffix)];
  match_list = unique(regexp(pattern, expression, 'match'));
  str = pattern;
  for match_idx = 1:numel(match_list)
    match = match_list{match_idx};
    rep = '';
    token_list = ...
      regexp(match(length(specprefix)+1:end-length(specsuffix)), ...
             regexptranslate('escape', specinchar), 'split');
    key = token_list{1};
    [key_present, key_index] = ismember(key, repkeys);
    if key_present
      rep = repvals{key_index};
    end
    for token_idx = 2:numel(token_list)
      modtok = token_list{token_idx};
      switch modtok(1)
        case '%'
          rep = sprintf(modtok, rep);
        case '^'
          rep = upper(rep);
        case 'v'
          rep = lower(rep);
        case 'T'
          rep = datestr(rep, modtok(2:end));
        case 's'
          subsdelim = modtok(2);
          subsbound = 2 + find(modtok(3:end) == subsdelim, 1, 'first');
          if isempty(subsbound)
            subspatstr = modtok(3:end);
            subsrepstr = '';
          else
            subspatstr = modtok(3:subsbound(1)-1);
            subsrepstr = modtok(subsbound(1)+1:end);
          end
          rep = regexprep(rep, subspatstr, subsrepstr);
      end
      if isnumeric(rep)
        rep = num2str(rep);
      end
    end
    str = regexprep(str, regexptranslate('escape', match), rep);
  end
  
end

 