function [newDataMatrix, newIdentity] = removeNans2(dataMatrix, identityMatrix)
    k = 1;
    [m,n] = size(dataMatrix);
    for i = 1:m
            yur = ~isnan(dataMatrix{i, n});
            if yur == 1
                for j =1:n
                    newDataMatrix{k, j} = dataMatrix{i, j};
                    newIdentity{k, 1} = identityMatrix{i, 1};
                end
                k = k + 1;
            end
    end
end