function [newmaterialWavelengthMatrix,newmaterialReflectivityMatrix] = downsample2Wavelengths(materialWavelengthMatrix,wavelengths,materialReflectivityMatrix)
    
    % Set wavelengthValues to the wavelengths of interest
    for z=1:length(wavelengths)
        WavelengthValues{z} = wavelengths{1,z};
    end

    % Make wavelengthValues a matrix for ismember to work
    WavelengthValues = cell2mat(WavelengthValues);
    [m,n] = size(materialWavelengthMatrix);

    for i = 1:m
        k = 1;
        for j=1:n
            % Store the current wavelength of the material in wavelength_to_compare
            wavelength_to_compare = materialWavelengthMatrix{i,j};

            % Compare the material wavelength with all wavelengths of interest
            if ~ismember(wavelength_to_compare,WavelengthValues)

                % Delete cells that don't contain wavelengths of interest
                materialWavelengthMatrix{i,j} = [];
                materialReflectivityMatrix{i,j} = [];
            end
            % If the material wavelength is of interest store the
            % wavelength and reflectivty in
            % newMaterialWavelength/Reflectivity Matricies
            if ~isnan(materialWavelengthMatrix{i,j})
                newmaterialWavelengthMatrix{i,k} = materialWavelengthMatrix{i,j};
                newmaterialReflectivityMatrix{i,k} = materialReflectivityMatrix{i,j};
                k = k + 1;
            end
        end
    end
end