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
%    ${GLIDER_INSTRUMENT_NAME}: glider instrument name.
%    ${GLIDER_DEPLOYMENT_CODE}: glider deployment code.
%    ${DEPLOYMENT_ID}: deployment unique identifier.
%    ${DEPLOYMENT_NAME}: deployment name.
%    ${DEPLOYMENT_START_DATE}: deployment start date as 'yyyymmdd'.
%    ${DEPLOYMENT_END_DATE}: deployment end date as 'yyyymmdd'.
%    ${DEPLOYMENT_START,...}: formatted deployment start date and time (described below).
%    ${DEPLOYMENT_END,...}: formatted deployment end date an time (described below).
%
%  Time fields may include a modifier selecting the date and time format.
%  The modifier is any date field specifier string accepted by the function 
%  DATESTR. See the examples below.
%
%  Text fields may include a modifier to imply conversion to lower case (,) or 
%  upper case (^). When one of these modifiers is present, the replacement value
%  is converted using LOWER and UPPER functions respectively.
%
%  Notes:
%    This function is inspired by the C function STRFTIME, the shell 
%    command DATE, and Bash parameter expansion.
%
%  Examples:
%    deployment.id = 2;
%    deployment.deployment_name = 'funnymission';
%    deployment.glider_name = 'happyglider';
%    deployment.glider_deployment_code = '0001';
%    deployment.start_time = datenum([2000 1 1 0 0 0]);
%    deployment.end_time =  datenum([2001 1 1 0 0 0]);
%    pattern = '/base/path/${GLIDER_NAME}/${DEPLOYMENT_NAME}'
%    str = strfglider(pattern, deployment)
%    date_pattern = '/base/path/${GLIDER_NAME,^}/${DEPLOYMENT_START,yyyy-mm-dd}'
%    date_str = strfglider(date_pattern, deployment)
%
%  See also:
%    GETDBDEPLOYMENTINFO
%    DATESTR
%    UPPER
%    LOWER
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(2, 2, nargin, 'struct'));

  condsel = @(p,v) (v{p});
  casefun = @(s,m) (feval(condsel(ismember({',' '^'}, m), {@lower @upper}), s));
  rep_map = ...
  {
    '\$\{GLIDER_NAME\}'                   @(d,m)(d.glider_name)
    '\$\{GLIDER_NAME,([,^])\}'            @(d,m)(casefun(d.glider_name, m))
    '\$\{GLIDER_INSTRUMENT_NAME\}'        @(d,m)(d.glider_instrument_name)
    '\$\{GLIDER_INSTRUMENT_NAME,([,^])\}' @(d,m)(casefun(d.glider_instrument_name, m))
    '\$\{GLIDER_DEPLOYMENT_CODE\}'        @(d,m)(d.glider_deployment_code)
    '\$\{GLIDER_DEPLOYMENT_CODE,([,^])\}' @(d,m)(casefun(d.glider_deployment_code, m))
    '\$\{DEPLOYMENT_NAME\}'               @(d,m)(d.deployment_name)
    '\$\{DEPLOYMENT_NAME,([,^])\}'        @(d,m)(casefun(d.deployment_name, m))
    '\$\{DEPLOYMENT_ID\}'                 @(d,m)(num2str(d.deployment_id))
    '\$\{DEPLOYMENT_START_DATE\}'         @(d,m)(datestr(d.deployment_start,'yyyymmdd'))
    '\$\{DEPLOYMENT_END_DATE\}'           @(d,m)(datestr(d.deployment_end,'yyyymmdd'))
    '\$\{DEPLOYMENT_START,([^}]+)\}'      @(d,m)(datestr(d.deployment_start,m))
    '\$\{DEPLOYMENT_END,([^}]+)\}'        @(d,m)(datestr(d.deployment_end,m))
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

 