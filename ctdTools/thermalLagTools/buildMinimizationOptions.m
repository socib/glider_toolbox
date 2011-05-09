function options = buildMinimizationOptions
%BUILDMINIMIZATIONOPTIONS - Builds a set of options for minimization
% Optional file header info (to give more details about the function than in the H1 line)
% Optional file header info (to give more details about the function than in the H1 line)
%
% Syntax: options = buildMinimizationOptions
%
% Inputs: none
%
% Outputs:
%    options - an optimset output
%
% Example:
%    options = buildMinimizationOptions
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OPTIMSET
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%
    defaultOptions = optimset('fmincon');
    
    options = optimset(defaultOptions, ...
        'Display',    'iter',          ...
        'LargeScale', 'off',           ...
        'Algorithm',  'active-set',    ...
        'TolFun',     1e-4,            ...
        'TolCon',     1e-5,            ...
        'TolX',       1e-5);%,            ...
%        'Plotfcns',   []); % {@optimplotfval, @optimplotfirstorderopt, @optimplotx});

end