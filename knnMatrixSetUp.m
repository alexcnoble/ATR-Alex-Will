function [reflectivityMatrix, wavelengthMatrix, identityMatrix] = knnMatrixSetUp(materialCount, reflectivity, wavelength, identity)
% Preallocate return variables
reflectivityMatrix = {};
wavelengthMatrix = {};
identityMatrix = {};

% Delete all of the wavelength and reflectivity data if the wavelength is not
% in the region of interest
for i=1:materialCount

    % Store number of observations for file in numWavelengths
    numWavelengths = length(wavelength{1, i}(:, 1));
    k = 1;

    for j=1:numWavelengths

        % Set value of wavelengths and reflectivity to zero if the wavelength is not region of interest
        if wavelength{1, i}(j, 1) < 1.06 || wavelength{1, i}(j, 1) > 1.5447
            wavelength{1, i}(j,1) = 0;
            reflectivity{1, i}(j,1) = 0;
        end 

        % If wavelength is in region of intrest store the wavelength,
        % reflectivity, and identity into return variables
        % (wavelengthMatrix, reflectivityMatrix, identityMatrix)
        if wavelength{1, i}(j, 1) ~= 0
            wavelengthMatrix{i,k} = wavelength{1, i}(j, 1);
            reflectivityMatrix{i,k} = reflectivity{1, i}(j, 1);
            identityMatrix{i,1} = identity;
            k = k + 1;
        end
    end
end
end