function [badCount, materialCount, materialWavelength, materialReflectivity,names] = filterAndRead(materialCount, materialFiles, materialWavelength, materialReflectivity)
    % Create variable badCount to store number of files that have no
    % wavelengths of interest for the class that filterAndRead is called
    % on.
    badCount = 0;

    for i=1:materialCount
        % Read in wavelength and reflectivity data from ASTER dataset
        % (calls readFunction)
        [materialWavelength{1, i - badCount}, materialReflectivity{1, i - badCount}] = readFunction(materialFiles{i});
        
        % Down sample files that do not have any wavelengths less than
        % 1.5um and increment badCount 
        if min(materialWavelength{i - badCount}) > 1.5
            materialWavelength(i - badCount) = [];
            materialReflectivity{i - badCount} = [];
            badCount = badCount + 1;
        else 
            % Store the names of files that have wavelengths of interest in
            % names
            names{i-badCount} = materialFiles{i};
        end
        
    end
    % Calculate the number of files with wavelengths of interest 
    materialCount = materialCount - badCount;
end
