function str = strfglider(pattern, deployment)
%STRFGLIDER  Replace deployment field specifiers in pattern with deployment field values.
%
%  STR = STRFGLIDER(PATTERN, DEPLOYMENT) replaces deployment field specifiers in
%  string PATTERN with the corresponding field values in struct DEPLOYMENT.
%  Recognized field specifiers match deployment struct fields returned by 
%  GETDBDEPLOYMENTINFO. They are deployment field names in capital letters 
%  enclosed in curly braces prefixed with a dollar sign.
%  Some specifiers accept a modifier, separated from the specifier by a comma, 
%  affecting the replacement format. This is the list of valid specifiers:
%    ${GLIDER_NAME}: glider platform name.
%    ${MISSION_NAME}: deployment name.
%    ${START_DATE}: deployment start date as 'yyyymmdd'.
%    ${END_DATE}: deployment end date as 'yyyymmdd'.
%    ${START_TIME,...}: formatted deployment start date and time (described below).
%    ${END_TIME,...}: formatted deployment end date an time (described below).
%
%  Time fields may include a modifier selecting the date an time format.
%  The modifier is any date field specifier string  accepted by the function 
%  DATESTR. See the examples below.
%    
%  Notes:
%    This function is inspired by the C function STRFTIME, the shell 
%    command DATE, and Bash parameter expansion.
%
%  Examples:
%    deployment.id = 2;
%    deployment.mission_name = 'funnymission';
%    deployment.glider_name = 'happyglider';
%    deployment.glider_deployment_code = '0001';
%    deployment.start_time = datenum([2000 1 1 0 0 0]);
%    deployment.end_time =  datenum([2001 1 1 0 0 0]);
%    pattern = '/base/path/${GLIDER_NAME}/${MISSION_NAME}'
%    str = strfglider(pattern, deployment)
%    date_pattern = '/base/path/${GLIDER_NAME}/${START_TIME,yyyy-mm-dd}'
%    date_str = strfglider(date_pattern, deployment)
%
%  See also:
%    GETDBDEPLOYMENTINFO
%    DATESTR
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 2, nargin, 'struct'));

  rep_map = ...
    { ... 
    '\$\{GLIDER_NAME\}'          @(d,m)(d.glider_name); ...
    '\$\{MISSION_NAME\}'         @(d,m)(d.mission_name); ...
    '\$\{START_DATE\}'           @(d,m)(datestr(d.start_time,'yyyymmdd')); ...
    '\$\{END_DATE\}'             @(d,m)(datestr(d.end_time,'yyyymmdd')); ...
    '\$\{START_TIME,([^}]+)\}'   @(d,m)(datestr(d.start_time,m)); ...
    '\$\{END_TIME,([^}]+)\}'     @(d,m)(datestr(d.end_time,m)) ...
    };
  
  specifiers = rep_map(:,1);
  repl_funcs = rep_map(:,2);
  
  str = pattern;
  for s = 1:numel(specifiers)
    spec = specifiers{s};
    func = repl_funcs{s};
    [matches, tokens] = regexp(pattern, spec, 'match', 'tokens');
    [matches, indices] = unique(matches);
    tokens = tokens(indices);
    values = cellfun(@(t) func(deployment,t{:}), tokens, 'UniformOutput', false);
    str = regexprep(str, regexptranslate('escape', matches), values);
  end
  
end
