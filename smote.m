function [syntheticReflectivity] = smote(reflectivity, k, percentage,wavelengths)
    kVal = k;
    
    % Calculate the number of synthetic samples to generate
    numSynthetic = round(length(reflectivity) * (percentage / 100));

    % Initialize synthetic data arrays
    syntheticReflectivity = {};

    % Randomly choose an instance
    for z = 1:numSynthetic
        randIndex = randi(length(reflectivity));

        distancesFromRandIndex = {};
        % Find distances of files from random instance
        for i = 1:length(reflectivity)
            for j = 1:length(wavelengths)
                distancesFromRandIndex{i, j} = pdist2(reflectivity{i, j}, reflectivity{randIndex, j});
            end
        end

        % Take average of every neighbor's distance from the random index
        for i = 1:length(reflectivity)
            sum = 0;
            % Find sum of distances for each files
            for j = 1:length(wavelengths)
                sum = distancesFromRandIndex{i, j} + sum;
            end
            averages{i} = sum/length(wavelengths); 
        end

        % Sort averages to find closest file
        avgs = [];
        avgs = cell2mat(averages);
        sortedAvgs = sort(avgs, 'ascend');

        % Find index (file) of sorted avg
        for i = 1:length(reflectivity)
            k=1;
            for j = 1:length(reflectivity)
                if (sortedAvgs(i) == avgs(j))
                    sortedIndex(i) = k;
                end
                k = k + 1;
            end
        end

        knnIndices = {};

        for i = 2:kVal+1
            knnIndices{i - 1} = sortedIndex(i);
        end
        % Use closest file to calculate SMOTE
        for j = 1:length(wavelengths)
                r = round(1 + (kVal-1) .* rand(1,1));
                idx = knnIndices{r};
                randomNumber = rand();
                % SMOTE calculation
                syntheticReflectivity{z, j} = reflectivity{randIndex, j} + (randomNumber * abs(reflectivity{randIndex, j} - reflectivity{idx, j}));
        end
    end

end