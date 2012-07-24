function availablePotentialEnergy = computeAvailablePotentialEnergy(densityProfile, depthProfile)
%COMPUTEAVAILABLEPOTENTIALENERGY - Potential energy wrt no density inversion
% It computes the difference between the actual potential energy of the
% given profile and the potential energy that it would have without
% density inversion (stable).
%
% Syntax: availablePotentialEnergy = computeAvailablePotentialEnergy(densityProfile, depthProfile)
%
% Inputs:
%    densityProfile - Vector with densities (in kg m-3)
%    depthProfile - Vector with depths (in m)
%
% Outputs:
%    availablePotentialEnergy - remanent potential energy (in J)
%
% Example:
%    availablePotentialEnergy = computeAvailablePotentialEnergy(densityProfile, depthProfile)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: MAX, SORT, SUM
%
% Author: Bartolome Garau
% Work address: Parc Bit, Naorte, Bloc A 2ºp. pta. 3; Palma de Mallorca SPAIN. E-07121
% Author e-mail: tgarau@socib.es
% Website: http://www.socib.es
% Creation: 17-Feb-2011
%

    % Gravity acceleration constant
    g = 9.81;

    % Get the profile as a downcast
    [depthProfile, rightOrder] = sort(depthProfile(:));

    % Make sure also density is a column vector in the right order
    densityProfile = densityProfile(rightOrder);

    % Build a profile with same values but without density inversions
    sortedDensityProfile = sort(densityProfile);

    % Compute the height of each control volum with respect to the bottom
    columnHeight = max(depthProfile) - depthProfile;

    % Compute potential energy of the sorted profile
    referencePotentialEnergy = sum(sortedDensityProfile .* g .* columnHeight);

    % Compute potential energy of the original profile
    totalPotentialEnergy = sum(densityProfile .* g .* columnHeight);

    % Compute available potential energy of the original profile by
    % substracting the reference value
    availablePotentialEnergy = totalPotentialEnergy - referencePotentialEnergy;

end