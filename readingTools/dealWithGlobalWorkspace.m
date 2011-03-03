function dealWithGlobalWorkspace(varargin)
%DEALWITHGLOBALWORKSPACE - Utility to save, clear and restore the global WS
% This function stores the global workspace in a .mat file, clears the
% global workspace and restores it from the .mat file.
% This function is used
%
% Syntax: dealWithGlobalWorkspace(varargin)
%
% Inputs:
%    varargin - It is a list of strings: 'save', 'clear', 'restore'
%
% Outputs: none
%
% Example:
%    dealWithGlobalWorkspace('save', 'clear');
%    ...
%    dealWithGlobalWorkspace('restore');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: GlobalWS.mat
%
% See also: WHOS GLOBAL LOAD, DELETE, SAVE CLEAR
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 22-Feb-2011
%

    % Initialize flags
    saveFlag    = false;
    restoreFlag = false;
    clearFlag   = false;
    
    % Loop through the arguments to set user values
    for idx = 1:nargin
        switch varargin{idx}
            case 'save'
                saveFlag = true;
            case 'restore'
                restoreFlag = true;
            case 'clear'
                clearFlag = true;
        end;
    end;

    % Build a filename to save the global workspace 
    % *make it "constant" for later use in subsequent calls 
    % to this function
    globalVarsFilename = fullfile(tempdir, 'GlobalWS.mat');

    % Get the global variables
    globalVariables = whos('global');

    % If any global variables
    if ~isempty(globalVariables)
        if saveFlag
            % Start with an empty file to save the workspace
            if exist(globalVarsFilename, 'file')
                delete(globalVarsFilename);
            end;
            % For each one of the global variables
            for varIdx = 1:length(globalVariables),

                % Declare them as global inside the function
                % to enable access to them
                globalVarName = globalVariables(varIdx).name;
                eval(['global ', globalVarName]);

                % Store the variable in the temporary file                
                if exist(globalVarsFilename, 'file'),
                    save(globalVarsFilename, '-append', globalVarName);
                else
                    save(globalVarsFilename, globalVarName);
                end;
            end;
        end;
        if clearFlag
            % Clear all the global variables from the workspace
            clear('global');
        end;        
    end;

    if restoreFlag
         if  exist(globalVarsFilename, 'file'),
              load(globalVarsFilename);
            delete(globalVarsFilename);
        end;
    end;
    
return;
