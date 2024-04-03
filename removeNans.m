function [newDataMatrix, newWavelengthMatrix, newIdentity] = removeNans(dataMatrix, wavelengthMatrix, identityMatrix)
    k = 1;
    [m,n] = size(dataMatrix);
    for i = 1:m
            yur = ~isnan(dataMatrix{i, n});
            if yur == 1
                for j =1:n
                newDataMatrix{k, j} = dataMatrix{i, j};
                newWavelengthMatrix{k, j} = wavelengthMatrix{i, j};
                newIdentity{k, 1} = identityMatrix{i, 1};
                end
                k = k + 1;
            end
    end
end

  