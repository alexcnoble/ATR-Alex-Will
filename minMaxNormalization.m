function [normalizedReflectivity] = minMaxNormalization(reflectivity, wavelengths)
    
    % Preallocate variables to store min and max 
    minReflectivity = 1000;
    maxReflectivity = 0;

    % Find min and max values of material
    for i = 1:length(reflectivity)
        for j=1:length(wavelengths)

            minR = min(reflectivity(i, j));
            maxR = max(reflectivity(i, j));

            if minR < minReflectivity
                minReflectivity = minR;
            end
            if maxR > maxReflectivity
                maxReflectivity = maxR;
            end

        end
    end
    % Preallocate normalizedReflectivity
    normalizedReflectivity = (length(reflectivity));

    % Normalizing every value to the max and min values of material
    for i=1:length(reflectivity)
        for j = 1:length(wavelengths)
            % Normalization calculation
            normalizedReflectivity(i,j) = (reflectivity(i,j) - minReflectivity) / (maxReflectivity - minReflectivity);
        end
    end
end