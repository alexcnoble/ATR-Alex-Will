clear
clc
close all

path = pwd;
temp = dir([path, '\*.spectrum.txt']);

% Create cell arrays for each file group
manmadeFiles = {};

% Set counts to 0 for each file group
manmadeCount = 0;

% Read in file names
fileNames = {temp.name};

% Read files into respective cell array groups
for i = 1:length(fileNames)
    if contains(fileNames{i}, 'manmade')
        manmadeFiles{i} = fileNames{i};
        manmadeCount = manmadeCount + 1;
    end
end

% Read KLUM dataset
[klumWavelength, klumReflectivity, klumNames] = readKlum();
klumCount = size(klumReflectivity,1);

% Create and pre-allocate cell arrays for wavelength and reflectivity data
manmadeWavelength = {zeros(1,manmadeCount)};
manmadeReflectivity = {zeros(1,manmadeCount)};

% Reading and Filtering the data
[manmadeBadCount, manmadeCount, manmadeWavelength, manmadeReflectivity, asterNames] = filterAndRead(manmadeCount, manmadeFiles, manmadeWavelength, manmadeReflectivity);
asterNames = asterNames';

manmadeNames = [asterNames; klumNames];

% Add KLUM to manmade
for i = manmadeCount + 1:manmadeCount + klumCount
    manmadeWavelength{i} = klumWavelength(i-manmadeCount,:)';
    manmadeReflectivity{i} = klumReflectivity(i-manmadeCount,:)';
end

identity = 1;
[manmadeReflectivityMatrix, manmadeWavelengthMatrix, manmadeIdentityMatrix] = knnMatrixSetUp(manmadeCount + klumCount, manmadeReflectivity, manmadeWavelength, identity);

% down sample to data with least number of wavelengths
wavelengths = {1.06 1.08 1.26 1.52 1.54}; % 1.10 1.22 1.24 1.28 1.30 
[manmadeWavelengthMatrix, manmadeReflectivityMatrix] = downsample2Wavelengths(manmadeWavelengthMatrix, wavelengths, manmadeReflectivityMatrix);

% normalize the data
[normalizedManmade] = minMaxNormalization(cell2mat(manmadeReflectivityMatrix) , wavelengths);
manmadeReflectivityMatrix = num2cell(normalizedManmade);

%put all data in one matrix
dataMatrix = manmadeReflectivityMatrix;
identityMatrix = manmadeIdentityMatrix;
wavelengthMatrix = manmadeWavelengthMatrix;

[dataMatrix, wavelengthMatrix, identityMatrix] = removeNans(dataMatrix, wavelengthMatrix, identityMatrix);
[wavelengthMatrix, dataMatrix] = sortData(dataMatrix, wavelengthMatrix);

X = cell2mat(dataMatrix);

X_standardized = zscore(X);

maxClusters = 20;  % maximum number of clusters to try
maxComponents = 3;  % maximum number of principal components to consider

% Pre-allocate arrays to store results
WCSS = zeros(maxClusters, 1);
silhouetteScores = zeros(maxClusters, maxComponents);
clusterDetails = struct();

% Initialize an empty table for cluster information
clusterInfo = table();

% Specify the path for the Excel file
excelFilePath = fullfile(path, 'ClusterAssignments.xlsx');

%% Loop through clusters and components
for k = 6:maxClusters
    for numComponents = 1:maxComponents
        
        % Perform PCA with numComponents
        [coeff, score, ~, ~, explained] = pca(X_standardized, 'NumComponents', numComponents);
        reducedData = score(:, 1:numComponents);
        
        % Perform k-means clustering
        [idx, C, sumd] = kmeans(reducedData, k);
        
        % Calculate WCSS for the current number of clusters
        WCSS(k) = sum(sumd);
        
        % Calculate silhouette scores and store them
        clusterDetails(k, numComponents).SilhouetteValues = silhouette(reducedData, idx);
        silhouetteScores(k, numComponents) = mean(clusterDetails(k, numComponents).SilhouetteValues);
        
        % Create a table with file names and cluster assignments
        clusterAssignments = table(manmadeNames, idx, 'VariableNames', {'FileName', 'ClusterAssignment'});
        
        % Sort the table by cluster assignments
        sortedClusterAssignments = sortrows(clusterAssignments, 'ClusterAssignment');
        
        % Generate a sheet name for this specific cluster and component configuration
        sheetName = sprintf('K%d_Component%d', k, numComponents);
        
        % Write the table to the specified sheet in the Excel file
        writetable(sortedClusterAssignments, excelFilePath, 'Sheet', sheetName);

        % 2D Plot for 2 Components
        if numComponents == 2
            figure;
            scatter(reducedData(:,1), reducedData(:,2), 36, idx, 'filled');
            hold on;
            scatter(C(:,1), C(:,2), 100, 'k', 'filled', 'MarkerEdgeColor', 'w');
            title(sprintf('2D Clusters after PCA: K=%d', k));
            xlabel('Principal Component 1');
            ylabel('Principal Component 2');
            hold off;

            % Enable data cursor mode
            dcm_obj = datacursormode(gcf);
            set(dcm_obj,'UpdateFcn',{@populateNames, manmadeNames});
        end

        % 3D Plot for 3 Components
        if numComponents == 3
            figure;
            scatter3(reducedData(:,1), reducedData(:,2), reducedData(:,3), 36, idx, 'filled');
            hold on;
            scatter3(C(:,1), C(:,2), C(:,3), 100, 'k', 'filled', 'MarkerEdgeColor', 'w');
            title(sprintf('3D Clusters after PCA: K=%d', k));
            xlabel('Principal Component 1');
            ylabel('Principal Component 2');
            zlabel('Principal Component 3');
            hold off;

            % Enable data cursor mode
            dcm_obj = datacursormode(gcf);
            set(dcm_obj,'UpdateFcn',{@populateNames, manmadeNames});

        end
    end
end

% Convert the silhouette scores into a table
silhouetteTable = array2table(silhouetteScores, 'VariableNames', strcat('Component', string(1:maxComponents)), 'RowNames', strcat('K', string(1:maxClusters)));

% Plot WCSS
figure;
plot(1:maxClusters, WCSS, '-o');
xlabel('Number of clusters (K)');
ylabel('Within-Cluster Sum of Squares (WCSS)');
title('Elbow Method for Optimal K');