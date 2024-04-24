%{

Authors: Alex Noble & William Collins

The purpose of this script is to:
- Read in the ASTER and KLUM data sets.
- Filter the bad data out and format the good data for use in the Weighted-KNN model.
- Call weighted KNN to predict the class of the test data and calculate
    accuracy, precision, recall, and F1-Score based on it's predictions.

%}


% Clear workspace, command window, and figures.
clear
clc
close all

% Set path and directory for reading files.
path = pwd;
temp = dir([path, '\*.spectrum.txt']);

% Create cell arrays for each file group
manmadeFiles = {};
mineralSilicateFiles = {};
mineralOtherFiles = {};
vegetationFiles = {};
npsVegetationFiles = {};
rockFiles = {};
meteoriteFiles = {};
otherFiles = {};

% Set counts to 0 for each file group
manmadeCount = 0;
mineralSilicateCount = 0;
mineralOtherCount = 0;
vegetationCount = 0;
npsVegetationCount = 0;
rockCount = 0;
meteoriteCount = 0;
otherCount = 0;

% Read in all file names.
fileNames = {temp.name};

% Read files into respective cell array groups based on file name.
for i = 1:length(fileNames)
    if contains(fileNames{i}, 'manmade')
        manmadeFiles{i} = fileNames{i};
        manmadeCount = manmadeCount + 1;
    end

    if contains(fileNames{i}, 'meteorite')
        meteoriteFiles{i-manmadeCount-npsVegetationCount-mineralSilicateCount-mineralOtherCount-rockCount-otherCount-vegetationCount} = fileNames{i};
        meteoriteCount = meteoriteCount + 1;
    end

    if contains(fileNames{i}, 'mineral.silicate')
        mineralSilicateFiles{i-manmadeCount-meteoriteCount-mineralOtherCount-npsVegetationCount-rockCount-otherCount-vegetationCount} = fileNames{i};
        mineralSilicateCount = mineralSilicateCount + 1;
    end

    if contains(fileNames{i}, 'mineral') && contains(fileNames{i}, 'mineral.silicate') == false
        mineralOtherFiles{i-manmadeCount-meteoriteCount-mineralSilicateCount-npsVegetationCount-rockCount-otherCount-vegetationCount} = fileNames{i};
        mineralOtherCount = mineralOtherCount + 1;
    end

    if contains(fileNames{i}, 'nonphoto')
        npsVegetationFiles{i-manmadeCount-meteoriteCount-mineralSilicateCount-mineralOtherCount-rockCount-otherCount-vegetationCount} = fileNames{i};
        npsVegetationCount = npsVegetationCount + 1;
    end

    if contains(fileNames{i}, 'rock')
        rockFiles{i-manmadeCount-meteoriteCount-mineralSilicateCount-mineralOtherCount-npsVegetationCount-otherCount-vegetationCount} = fileNames{i};
        rockCount = rockCount + 1;
    end

    if contains(fileNames{i}, 'water') || contains(fileNames{i}, 'soil')
        otherFiles{i-manmadeCount-meteoriteCount-mineralSilicateCount-mineralOtherCount-rockCount-npsVegetationCount-vegetationCount} = fileNames{i};
        otherCount = otherCount + 1;
    end

    if (contains(fileNames{i}, 'nonphoto') == false && contains(fileNames{i}, 'vegetation'))
        vegetationFiles{i-manmadeCount-meteoriteCount-mineralSilicateCount-mineralOtherCount-rockCount-npsVegetationCount-otherCount} = fileNames{i};
        vegetationCount = vegetationCount + 1;
    end

end

% Read in KLUM dataset and set klumCount to number of files. (Calls readKlum function)
[klumWavelength, klumReflectivity] = readKlum();
klumCount = size(klumReflectivity,1);


% Create and pre-allocate cell arrays for wavelength and reflectivity data
% for each class.
manmadeWavelength = {zeros(1,manmadeCount + klumCount)};
manmadeReflectivity = {zeros(1,manmadeCount + klumCount)};

meteoriteWavelength = {zeros(1,meteoriteCount)};
meteoriteReflectivity = {zeros(1,meteoriteCount)};

mineralSilicateWavelength = {zeros(1,mineralSilicateCount)};
mineralSilicateReflectivity = {zeros(1,mineralSilicateCount)};

mineralOtherWavelength = {zeros(1,mineralOtherCount)};
mineralOtherReflectivity = {zeros(1,mineralOtherCount)};

npsVegetationWavelength = {zeros(1,vegetationCount)};
npsVegetationReflectivity = {zeros(1,vegetationCount)};

rockWavelength = {zeros(1,rockCount)};
rockReflectivity = {zeros(1,rockCount)};

otherWavelength = {zeros(1,otherCount)};
otherReflectivity = {zeros(1,otherCount)};

vegetationWavelength = {zeros(1,vegetationCount)};
vegetationReflectivity = {zeros(1,vegetationCount)};


% Reading and filtering the data for each class. (Calls filterAndRead
% function)
[manamadeBadCount, manmadeCount, manmadeWavelength, manmadeReflectivity,manmadeNames] = filterAndRead(manmadeCount, manmadeFiles, manmadeWavelength, manmadeReflectivity);
[mineralSilicateBadCount, mineralSilicateCount, mineralSilicateWavelength, mineralSilicateReflectivity,mineralSilicateNames] = filterAndRead(mineralSilicateCount, mineralSilicateFiles, mineralSilicateWavelength, mineralSilicateReflectivity);
[mineralOtherBadCount, mineralOtherCount, mineralOtherWavelength, mineralOtherReflectivity,mineralOtherNames] = filterAndRead(mineralOtherCount, mineralOtherFiles, mineralOtherWavelength, mineralOtherReflectivity);
[npsVegetationBadCount, npsVegetationCount, npsVegetationWavelength, npsVegetationReflectivity,npsNames] = filterAndRead(npsVegetationCount, npsVegetationFiles, npsVegetationWavelength, npsVegetationReflectivity);
[rockBadCount, rockCount, rockWavelength, rockReflectivity,rockNames] = filterAndRead(rockCount, rockFiles, rockWavelength, rockReflectivity);
[otherBadCount, otherCount, otherWavelength, otherReflectivity,otherNames] = filterAndRead(otherCount, otherFiles, otherWavelength, otherReflectivity);
[vegetationBadCount, vegetationCount, vegetationWavelength, vegetationReflectivity,vegeNames] = filterAndRead(vegetationCount, vegetationFiles, vegetationWavelength, vegetationReflectivity);


% Add KLUM data to the manmade class.
for i = manmadeCount + 1:manmadeCount + klumCount
    manmadeWavelength{i} = klumWavelength(i-manmadeCount,:)';
    manmadeReflectivity{i} = klumReflectivity(i-manmadeCount,:)';
end


% Set identity for manmade class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 1;
[manmadeReflectivityMatrix, manmadeWavelengthMatrix, manmadeIdentityMatrix] = knnMatrixSetUp(manmadeCount + klumCount, manmadeReflectivity, manmadeWavelength, identity);

% Set identity for Mineral Other class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 2;
[mineralOtherReflectivityMatrix, mineralOtherWavelengthMatrix, mineralOtherIdentityMatrix] = knnMatrixSetUp(mineralOtherCount, mineralOtherReflectivity, mineralOtherWavelength, identity);

% Set identity for Mineral Silicate class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 3;
[mineralSilicateReflectivityMatrix, mineralSilicateWavelengthMatrix, mineralSilicateIdentityMatrix] = knnMatrixSetUp(mineralSilicateCount, mineralSilicateReflectivity, mineralSilicateWavelength, identity);

% Set identity for NPS-Vegetation class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 4;
[npsVegetationReflectivityMatrix, npsVegetationWavelengthMatrix, npsVegetationIdentityMatrix] = knnMatrixSetUp(npsVegetationCount, npsVegetationReflectivity, npsVegetationWavelength, identity);

% Set identity for vegetation class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 5;
[vegetationReflectivityMatrix, vegetationWavelengthMatrix, vegetationIdentityMatrix] = knnMatrixSetUp(vegetationCount, vegetationReflectivity, vegetationWavelength, identity);

% Set identity for rock class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 6;
[rockReflectivityMatrix, rockWavelengthMatrix, rockIdentityMatrix] = knnMatrixSetUp(rockCount, rockReflectivity, rockWavelength, identity);

% Set identity for other class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 7;
[otherReflectivityMatrix, otherWavelengthMatrix, otherIdentityMatrix] = knnMatrixSetUp(otherCount, otherReflectivity, otherWavelength, identity);


% Down sample to wavelengths of interest. Adjust wavelengths in the
% wavelengths cell array as desired. (Calls downsample2Wavelengths function.)
wavelengths = {1.06 1.08 1.10 1.22 1.24 1.26 1.28 1.30 1.52 1.54};
[manmadeWavelengthMatrix, manmadeReflectivityMatrix] = downsample2Wavelengths(manmadeWavelengthMatrix, wavelengths, manmadeReflectivityMatrix);
[mineralOtherWavelengthMatrix, mineralOtherReflectivityMatrix] = downsample2Wavelengths(mineralOtherWavelengthMatrix, wavelengths, mineralOtherReflectivityMatrix);
[mineralSilicateWavelengthMatrix, mineralSilicateReflectivityMatrix] = downsample2Wavelengths(mineralSilicateWavelengthMatrix, wavelengths, mineralSilicateReflectivityMatrix);
[npsVegetationWavelengthMatrix, npsVegetationReflectivityMatrix] = downsample2Wavelengths(npsVegetationWavelengthMatrix, wavelengths, npsVegetationReflectivityMatrix);
[vegetationWavelengthMatrix, vegetationReflectivityMatrix] = downsample2Wavelengths(vegetationWavelengthMatrix, wavelengths, vegetationReflectivityMatrix);
[rockWavelengthMatrix, rockReflectivityMatrix] = downsample2Wavelengths(rockWavelengthMatrix, wavelengths, rockReflectivityMatrix);
[otherWavelengthMatrix, otherReflectivityMatrix] = downsample2Wavelengths(otherWavelengthMatrix, wavelengths, otherReflectivityMatrix);

% Normalize the data for each class using Min/Max Normalization (Calls
% minMaxNormalization function).
[normalizedManmade] = minMaxNormalization(cell2mat(manmadeReflectivityMatrix) , wavelengths);
manmadeReflectivityMatrix = num2cell(normalizedManmade);

[normalizedMineralOther] = minMaxNormalization(cell2mat(mineralOtherReflectivityMatrix) , wavelengths);
mineralOtherReflectivityMatrix = num2cell(normalizedMineralOther);

[normalizedMineralSilicate] = minMaxNormalization(cell2mat(mineralSilicateReflectivityMatrix) , wavelengths);
mineralSilicateReflectivityMatrix = num2cell(normalizedMineralSilicate);

[normalizednpsVegetation] = minMaxNormalization(cell2mat(npsVegetationReflectivityMatrix) , wavelengths);
npsVegetationReflectivityMatrix = num2cell(normalizednpsVegetation);

[normalizedVegetation] = minMaxNormalization(cell2mat(vegetationReflectivityMatrix) , wavelengths);
VegetationReflectivityMatrix = num2cell(normalizedVegetation);

[normalizedRock] = minMaxNormalization(cell2mat(rockReflectivityMatrix) , wavelengths);
rockReflectivityMatrix = num2cell(normalizedRock);

[normalizedOther] = minMaxNormalization(cell2mat(otherReflectivityMatrix) , wavelengths);
otherReflectivityMatrix = num2cell(normalizedOther);


% Aggregate data from each class into a single matrix for KNN.
% (reflectivity, identity, and wavelength data)
dataMatrix = [manmadeReflectivityMatrix; mineralOtherReflectivityMatrix; mineralSilicateReflectivityMatrix; npsVegetationReflectivityMatrix; vegetationReflectivityMatrix; rockReflectivityMatrix; otherReflectivityMatrix];
identityMatrix = [manmadeIdentityMatrix; mineralOtherIdentityMatrix; mineralSilicateIdentityMatrix; npsVegetationIdentityMatrix; vegetationIdentityMatrix; rockIdentityMatrix; otherIdentityMatrix];
wavelengthMatrix = [manmadeWavelengthMatrix; mineralOtherWavelengthMatrix; mineralSilicateWavelengthMatrix; npsVegetationWavelengthMatrix; vegetationWavelengthMatrix; rockWavelengthMatrix; otherWavelengthMatrix];

% Remove NaN's from dataMatrix. (Calls removeNans function).
[dataMatrix, wavelengthMatrix, identityMatrix] = removeNans(dataMatrix, wavelengthMatrix, identityMatrix);

% Sort the data so that all observations are in the same order (wavelengths low to
% high. Calls sortData function.)
[wavelengthMatrix, dataMatrix] = sortData(dataMatrix, wavelengthMatrix, wavelengths);

% Define the number of folds for k-fold cross-validation
% 5 folds is 80/20 split
numFolds = 5;

% Create data and identity cell arrays to hold data for all folds
allDataMatrix = dataMatrix;
allIdentityMatrix = identityMatrix;

% Generate a k-fold partition for the data
c = cvpartition(length(dataMatrix),'KFold', numFolds);

% Initialize variables to collect overall results
overallAccuracy = zeros(numFolds, 1);
confusionMatrices = cell(numFolds, 1);

% Process each fold
for fold = 1:numFolds
    % Indexes for training and testing sets in this fold
    trainingIndexes = training(c, fold);
    testingIndexes = test(c, fold);

    % Initialize data structures for this fold's training and testing data
    trainingDataMatrix = {};
    testingDataMatrix = {};
    trainingIdentityMatrix = {};
    testingIdentityMatrix = {};
    k = 1;
    l = 1;
    for i = 1:length(dataMatrix)
        if (trainingIndexes(i) == 1)
            for j = 1:length(wavelengths)
                trainingDataMatrix{k,j} = dataMatrix{i, j};
                trainingIdentityMatrix{k, 1} = identityMatrix{i, 1};
            end
            k = k + 1;
        elseif (testingIndexes(i) == 1)
            for j = 1:length(wavelengths)
                testingDataMatrix{l,j} = dataMatrix{i, j};
                testingIdentityMatrix{l, 1} = identityMatrix{i, 1};
            end
            l = l + 1;
        end
    end

    % Create variables to hold the number of rows and columns in training and
    % testing data.
    [numRowsTraining, numColTraining] = size(trainingDataMatrix);
    [numRowsTesting, numColTesting] = size(testingDataMatrix);

    % Pre-allocating trainingData and testingData matrices with zero's based on
    % the number of rows and cols respectively.
    trainingData = zeros(numRowsTraining, numColTraining);
    trainingIdentity = zeros(numRowsTraining, 1);
    testingData = zeros(numRowsTesting, numColTesting);
    testingIdentity = zeros(numRowsTesting, 1);

    % Loop through each cell in trainingDataMatrix and assign its value to the 
    % corresponding element in the numeric cell arrays.
    for i = 1:length(trainingDataMatrix)
        for j = 1:numColTraining
            trainingData(i, j) = trainingDataMatrix{i, j};
        end
        trainingIdentity(i, 1) = trainingIdentityMatrix{i, 1};
    end

    % Convert testing data and testing identity cell arrays to matrices.
    for i = 1:numRowsTesting
        for j = 1:numColTesting
            testingData(i, j) = testingDataMatrix{i, j};
        end
        testingIdentity(i, 1) = testingIdentityMatrix{i, 1};
    end


    % Storing Manmade, NPS Vegetation, and Other training data and identities to variables for SMOTE
    for i = 1:length(trainingDataMatrix)
        if trainingIdentityMatrix{i} == 1
            for j = 1:numColTraining
                manmadeTrainingData{i, j} = trainingDataMatrix{i, j};
            end
            manmadeTrainingIdentity{i, 1} = trainingIdentityMatrix{i, 1};
        end

        if trainingIdentityMatrix{i} == 4
            for j = 1:numColTraining
                npsTrainingData{i, j} = trainingDataMatrix{i, j};
            end
            npsTrainingIdentity{i, 1} = trainingIdentityMatrix{i, 1};
        end

        if trainingIdentityMatrix{i} == 7
            for j = 1:numColTraining
                otherTrainingData{i, j} = trainingDataMatrix{i, j};
            end
            otherTrainingIdentity{i, 1} = trainingIdentityMatrix{i, 1};
        end
    end

 
    % Remove NaNs from NPS vegetation and other training data.
    [npsTrainingData, npsTrainingIdentity] = removeNans2(npsTrainingData, npsTrainingIdentity);
    [otherTrainingData, otherTrainingIdentity] = removeNans2(otherTrainingData, otherTrainingIdentity);


    % Create synthetic data for manmade, other, and NPS vegetation classes.
    % (Calls smote function).
    % Parameter 1: Original reflectivities for the respective class.
    % Parameter 2: number of k nearest neighbors to consider when calculating
    %               the synthetic data.
    % Parameter 3: Percentage of synthetic files to create based on original
    %               number of files.
    % Parameter 4: wavelengths cell array.
    [syntheticManmadeReflectivity] = smote(manmadeTrainingData, 1, 500, wavelengths);
    [syntheticOtherReflectivity] = smote(otherTrainingData, 1, 700, wavelengths);
    [syntheticNPSVegetationReflectivity] = smote(npsTrainingData, 1, 700, wavelengths);


    % Add Synthetic Manmade data to trainingData matrix.
    k = 1;
    for i = length(trainingDataMatrix) + 1:(length(trainingDataMatrix) + length(syntheticManmadeReflectivity))
        for j = 1:numColTraining
            trainingData(i, j) = syntheticManmadeReflectivity{k, j};
        end
        k = k + 1;
        trainingIdentity(i, 1) = 1;
    end

    % Add Synthetic Other data to trainingData matrix.
    k = 1;
    for i = length(trainingData) + 1:(length(trainingData) + length(syntheticOtherReflectivity))
        for j = 1:numColTraining
            trainingData(i, j) = syntheticOtherReflectivity{k, j};
        end
        k = k + 1;
        trainingIdentity(i, 1) = 7;
    end

    % Add Synthetic NPS Vegetation data to trainingData matrix.
    k = 1;
    for i = length(trainingData) + 1:(length(trainingData) + length(syntheticNPSVegetationReflectivity))
        for j = 1:numColTraining
            trainingData(i, j) = syntheticNPSVegetationReflectivity{k, j};
        end
        k = k + 1;
        trainingIdentity(i, 1) = 4;
    end

    % Set parameters for KNNWeightedModel call.
    k = 1;
    r = 1;
    weights = 'gaussian';

    % Call KNNWeightedModel passing in the trainingData and identity matrices
    % and the parameters defined above.
    % weights: gaussian, inverse, quadratic, or triangular.
    knn = KNNWeightedModel(trainingData, trainingIdentity, k, r, weights);

    % Holds the weighted KNN's predictions for each test point.
    yogurt = knn.predict(testingData);

    % Evaluate the model's performance on this fold
    predictionMat = testingIdentity == yogurt;
    accuracy = mean(predictionMat) * 100;
    overallAccuracy(fold) = accuracy;
    confusionMatrices{fold} = confusionmat(testingIdentity, yogurt);

    % Calculate Individual Precision/Recall for each class, Overall Precision/Recall, and F1-Score for each fold.
    disp(['Individual Precision/Recall for each class, Overall Precision/Recall, and F1-Score for Kfold: ', num2str(fold)]);
    Ct = confusionMatrices{fold}';
    diagonal = diag(Ct);
    sumOfRows = sum(Ct, 2);

    precision = diagonal ./ sumOfRows

    overallPrecision = mean(precision)

    sumOfCols = sum(Ct, 1);

    recall = diagonal ./ sumOfCols'

    overallRecall = mean(recall)

    f1Score = (2 * (overallPrecision * overallRecall) / (overallPrecision + overallRecall))
end

% Average accuracy over all folds
meanAccuracy = mean(overallAccuracy);

meanAccuracies(w) = meanAccuracy;

% Display mean accuracy for all folds
disp(['Mean Classification Accuracy across all folds: ', num2str(meanAccuracy)]);
% Display confusion matrices for each fold
for fold = 1:numFolds
    figure;
    labels = ["Manmade", "Mineral: Non-Silicate", "Mineral: Silicate", "Vegetation: NPS", "Vegetation", "Rock", "Other"];
    confusionchart(confusionMatrices{fold}, labels);
    title(['Confusion Matrix for Fold ', num2str(fold)]);
end