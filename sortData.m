function [wavelengthMatrix, dataMatrix] = sortData(dataMatrix, wavelengthMatrix, wavelengths)
    for i=1:size(dataMatrix)
        if wavelengthMatrix{i,1} == 1.54
            for j=1:5
            storeReflectivity = dataMatrix{i,j};
            storeWavelength = wavelengthMatrix{i,j};
            dataMatrix{i,j} = dataMatrix{i,length(wavelengths)-j+1};
            wavelengthMatrix{i,j} = wavelengthMatrix{i,length(wavelengths)-j+1};
            wavelengthMatrix{i,length(wavelengths)-j+1} = storeWavelength;
            dataMatrix{i,length(wavelengths)-j+1} = storeReflectivity;
            end
        end
    end
end