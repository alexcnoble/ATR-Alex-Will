classdef KNNWeightedModel
    
    
    properties
        trainingData    % Training data
        trainingLabels  % Training labels
        k               % Number of neighbors
        r               % Parameter for quadratic & triangular fcns.
        weights         % Weight function
    end
    
    methods
        function obj = KNNWeightedModel(trainingData, trainingLabels, k, r, weights)
            obj.trainingData = trainingData;
            obj.trainingLabels = trainingLabels;
            obj.k = k;
            obj.r = r;
            obj.weights = weights;
        end
        
        function prediction = predict(obj, testingData)
            % Calculate distances between test and training points
            distance = pdist2(testingData, obj.trainingData);

            % Sort the distances and get the indices of the k-nearest neighbors
            [~, index] = sort(distance, 2);
            index = index(:, 1:obj.k);

            % Calculate the weights based on the users input
            %(inverse, gaussian, quadratic,or triangular)
            if strcmp(obj.weights, 'inverse')
                
                for i = 1:size(distance, 1)
                    inc = 1;
                    for j = 1:length(distance)
                        for z = 1:obj.k
                            if (j == index(i, z))
                                % Weight calculation
                                weight(i, inc) = 1./distance(i, index(i, z));
                                inc = inc + 1;
                            end
                        end
                    end
                end

                elseif strcmp(obj.weights, 'gaussian')
                    sigma = 1;
                    
                    for i = 1:size(distance, 1)
                        inc = 1;
                        for j = 1:length(distance)
                            for z = 1:obj.k
                                if (j == index(i, z))
                                    % Weigth calculation
                                    weight(i, inc) = exp(-distance(i, index(i, z)).^2./(2*sigma^2));
                                    inc = inc + 1;
                                end
                            end
                        end
                    end

                    elseif strcmp(obj.weights, 'quadratic')
                        for i = 1:size(distance, 1)
                            inc = 1;
                            for j = 1:length(distance)
                                for z = 1:obj.k
                                    if (j == index(i, z))
                                        % Weigth calculation
                                        weight(i, inc) = 1 - (distance(i, index(i, z)) / obj.r).^2;
                                        inc = inc + 1;
                                    end
                                end
                            end
                        end

                     elseif strcmp(obj.weights, 'triangular')
                        for i = 1:size(distance, 1)
                            inc = 1;
                            for j = 1:length(distance)
                                for z = 1:obj.k
                                    if (j == index(i, z))
                                        % Weigth calculation
                                        weight(i, inc) = 1 - (distance(i, index(i, z)) / obj.r);
                                        inc = inc + 1;
                                    end
                                end
                            end
                        end
            end

            % Normalize the weights
            weight = weight./sum(weight, 2);

            % Predict the class labels
            prediction = cell(size(testingData, 1), 1);

            for i = 1:size(testingData, 1)
                % Get the class labels of the k-nearest neighbors
                Yknn = obj.trainingLabels(index(i, :));

                % Calculate the weighted frequency of each class
                frequency = accumarray(Yknn, weight(i, :), []);

                % Get the class label with the highest weighted frequency
                [~, maxFreqIndex] = max(frequency);
                prediction{i} = maxFreqIndex;
            end
            prediction = cell2mat(prediction);
        end
    end
end

