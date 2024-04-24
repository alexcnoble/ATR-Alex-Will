%{

Authors: Alex Noble & William Collins

Classes for Classification:
- This script aggregates the rock, mineral, and soil data into a single
    class.
- Other classes are Manmade, Vegetation, and Non-Photosynthetic Vegetation.

The purpose of this script is to act as the main driver and:
- Call functions to read in the ASTER and KLUM data sets.
- Call functions to filter the bad data out and format the good data for use in the KNN model.
- Call SMOTE to create synthetic data for under-represented classes and add this synthetic data to 
    the training data.
- Call weighted KNN to predict the class of the test data and calculate
    accuracy, precision, recall, and F1-Score based on it's predictions.

%}


% Clear workspace and command window.
clear
clc

% Set path and directory for reading files.
path = pwd;
temp = dir([path, '\*.spectrum.txt']);


% Create cell arrays for each file group
manmadeFiles = {};
rocksAndMineralFiles = {};
vegetationFiles = {};
npsVegetationFiles = {};
meteoriteFiles = {};


% Set counts to 0 for each file group
manmadeCount = 0;
rocksAndMineralCount = 0;
vegetationCount = 0;
npsVegetationCount = 0;
meteoriteCount = 0;

% Read in all file names.
fileNames = {temp.name};

% Read files into respective cell array groups based on file name.
for i = 1:length(fileNames)
    if contains(fileNames{i}, 'manmade')
        manmadeFiles{i} = fileNames{i};
        manmadeCount = manmadeCount + 1;
    end

    if contains(fileNames{i}, 'meteorite')
        meteoriteFiles{i-manmadeCount-npsVegetationCount-rocksAndMineralCount-vegetationCount} = fileNames{i};
        meteoriteCount = meteoriteCount + 1;
    end

    if contains(fileNames{i}, 'mineral') || contains(fileNames{i}, 'rock') || contains(fileNames{i}, 'soil')
        rocksAndMineralFiles{i-manmadeCount-meteoriteCount-npsVegetationCount-vegetationCount} = fileNames{i};
        rocksAndMineralCount = rocksAndMineralCount + 1;
    end

    if contains(fileNames{i}, 'nonphoto')
        npsVegetationFiles{i-manmadeCount-meteoriteCount-rocksAndMineralCount-vegetationCount} = fileNames{i};
        npsVegetationCount = npsVegetationCount + 1;
    end


    if (contains(fileNames{i}, 'nonphoto') == false && contains(fileNames{i}, 'vegetation'))
        vegetationFiles{i-manmadeCount-meteoriteCount-rocksAndMineralCount-npsVegetationCount} = fileNames{i};
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

rocksAndMineralWavelength = {zeros(1,rocksAndMineralCount)};
rocksAndMineralReflectivity = {zeros(1,rocksAndMineralCount)};

npsVegetationWavelength = {zeros(1,vegetationCount)};
npsVegetationReflectivity = {zeros(1,vegetationCount)};

vegetationWavelength = {zeros(1,vegetationCount)};
vegetationReflectivity = {zeros(1,vegetationCount)};


% Reading and filtering the data for each class. (Calls filterAndRead
% function)
[manamadeBadCount, manmadeCount, manmadeWavelength, manmadeReflectivity,manmadeNames] = filterAndRead(manmadeCount, manmadeFiles, manmadeWavelength, manmadeReflectivity);
[rocksAndMineralBadCount, rocksAndMineralCount, rocksAndMineralWavelength, rocksAndMineralReflectivity,rocksAndMineralNames] = filterAndRead(rocksAndMineralCount, rocksAndMineralFiles, rocksAndMineralWavelength, rocksAndMineralReflectivity);
[npsVegetationBadCount, npsVegetationCount, npsVegetationWavelength, npsVegetationReflectivity,npsNames] = filterAndRead(npsVegetationCount, npsVegetationFiles, npsVegetationWavelength, npsVegetationReflectivity);
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

% Set identity for rock and mineral class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 2;
[rocksAndMineralReflectivityMatrix, rocksAndMineralWavelengthMatrix, rocksAndMineralIdentityMatrix] = knnMatrixSetUp(rocksAndMineralCount, rocksAndMineralReflectivity, rocksAndMineralWavelength, identity);

% Set identity for non-photosynthetic vegetation class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 3;
[npsVegetationReflectivityMatrix, npsVegetationWavelengthMatrix, npsVegetationIdentityMatrix] = knnMatrixSetUp(npsVegetationCount, npsVegetationReflectivity, npsVegetationWavelength, identity);

% Set identity for vegetation class and format reflectivity, wavelength, and
% identity matrices. (Calls knnMatrixSetup function).
identity = 4;
[vegetationReflectivityMatrix, vegetationWavelengthMatrix, vegetationIdentityMatrix] = knnMatrixSetUp(vegetationCount, vegetationReflectivity, vegetationWavelength, identity);


% Down sample to wavelengths of interest. Adjust wavelengths in the
% wavelengths cell array as desired. (Calls downsample2Wavelengths function.)
wavelengths = {1.06 1.08 1.10 1.22 1.24 1.26 1.28 1.30 1.52 1.54};
[manmadeWavelengthMatrix, manmadeReflectivityMatrix] = downsample2Wavelengths(manmadeWavelengthMatrix, wavelengths, manmadeReflectivityMatrix);
[rocksAndMineralWavelengthMatrix, rocksAndMineralReflectivityMatrix] = downsample2Wavelengths(rocksAndMineralWavelengthMatrix, wavelengths, rocksAndMineralReflectivityMatrix);
[npsVegetationWavelengthMatrix, npsVegetationReflectivityMatrix] = downsample2Wavelengths(npsVegetationWavelengthMatrix, wavelengths, npsVegetationReflectivityMatrix);
[vegetationWavelengthMatrix, vegetationReflectivityMatrix] = downsample2Wavelengths(vegetationWavelengthMatrix, wavelengths, vegetationReflectivityMatrix);

% Normalize the data for each class using Min/Max Normalization (Calls
% minMaxNormalization function).
[normalizedManmade] = minMaxNormalization(cell2mat(manmadeReflectivityMatrix) , wavelengths);
manmadeReflectivityMatrix = num2cell(normalizedManmade);

[normalizedRockMineral] = minMaxNormalization(cell2mat(rocksAndMineralReflectivityMatrix) , wavelengths);
rocksAndMineralReflectivityMatrix = num2cell(normalizedRockMineral);

[normalizednpsVegetation] = minMaxNormalization(cell2mat(npsVegetationReflectivityMatrix) , wavelengths);
npsVegetationReflectivityMatrix = num2cell(normalizednpsVegetation);

[normalizedVegetation] = minMaxNormalization(cell2mat(vegetationReflectivityMatrix) , wavelengths);
VegetationReflectivityMatrix = num2cell(normalizedVegetation);


% Aggregate data from each class into a single matrix for KNN.
% (reflectivity, identity, and wavelength data)
dataMatrix = [manmadeReflectivityMatrix; rocksAndMineralReflectivityMatrix; npsVegetationReflectivityMatrix; vegetationReflectivityMatrix];
identityMatrix = [manmadeIdentityMatrix; rocksAndMineralIdentityMatrix; npsVegetationIdentityMatrix; vegetationIdentityMatrix];
wavelengthMatrix = [manmadeWavelengthMatrix; rocksAndMineralWavelengthMatrix; npsVegetationWavelengthMatrix; vegetationWavelengthMatrix];

% Remove NaN's from dataMatrix. (Calls removeNans function).
[dataMatrix, wavelengthMatrix, identityMatrix] = removeNans(dataMatrix, wavelengthMatrix, identityMatrix);

% Sort the data so that all observations are in the same order (wavelengths low to
% high. Calls sortData function.)
[wavelengthMatrix, dataMatrix] = sortData(dataMatrix, wavelengthMatrix, wavelengths);

%for w = 1:10

% Define the ratio for splitting into train and test data.
training_ratio = 0.8;
testing_ratio = 0.2;

% Create data and identity cell arrays to hold data for training and testing
trainingData = {};
testingData = {};

trainingIdentityMatrix = {};
testingIdentityMatrix = {};

% Generate a random partition for the data
c = cvpartition(length(dataMatrix),'HoldOut', testing_ratio);

% Indexes for training and testing sets
trainingIndexes = training(c);
testingIndexes = ~training(c);

% Split data into training and testing based on indexes from random partition.
k = 1;
l = 1;
for i = 1:length(dataMatrix)
    if (trainingIndexes(i) == 1)
        for j = 1:length(wavelengths)
        trainingDataMatrix{k,j} = dataMatrix{i, j};
        trainingIdentityMatrix{k, 1} = identityMatrix{i, 1};
        end
        k = k + 1;
    end

     if (testingIndexes(i) == 1)
        for j = 1:length(wavelengths)
            testingDataMatrix{l, j} = dataMatrix{i, j};
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
% corresponding element in the numeric cell arrays. (Conversion to matrices
% from cell arrays)
for i = 1:length(trainingDataMatrix)
    for j = 1:numColTraining
        trainingData(i, j) = trainingDataMatrix{i, j};
    end
    trainingIdentity(i, 1) = trainingIdentityMatrix{i, 1};
end

% Loop through each cell in testingDataMatrix and assign its value to the 
% corresponding element in the numeric cell arrays. (Conversion to matrices
% from cell arrays)
for i = 1:numRowsTesting
    for j = 1:numColTesting
        testingData(i, j) = testingDataMatrix{i, j};
    end
    testingIdentity(i, 1) = testingIdentityMatrix{i, 1};
end

% Storing Manmade, NPS Vegetation training data and identities to variables for SMOTE
for i = 1:length(trainingDataMatrix)
    if trainingIdentityMatrix{i} == 1
        for j = 1:numColTraining
            manmadeTrainingData{i, j} = trainingDataMatrix{i, j};
        end
        manmadeTrainingIdentity{i, 1} = trainingIdentityMatrix{i, 1};
    end

    if trainingIdentityMatrix{i} == 3
        for j = 1:numColTraining
            npsTrainingData{i, j} = trainingDataMatrix{i, j};
        end
        npsTrainingIdentity{i, 1} = trainingIdentityMatrix{i, 1};
    end
end

% Remove NaNs from npsTrainingData cell array
[npsTrainingData, npsTrainingIdentity] = removeNans2(npsTrainingData, npsTrainingIdentity);


% Create synthetic data for manmade and NPS vegetation classes.
% (Calls smote function).
% Parameter 1: Original reflectivities for the respective class.
% Parameter 2: number of k nearest neighbors to consider when calculating
%               the synthetic data.
% Parameter 3: Percentage of synthetic files to create based on original
%               number of files.
% Parameter 4: wavelengths cell array.
[syntheticManmadeReflectivity] = smote(manmadeTrainingData, 1, 500, wavelengths);
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

% Add Synthetic NPS Vegetation data to trainingData matrix.
k = 1;
for i = length(trainingData) + 1:(length(trainingData) + length(syntheticNPSVegetationReflectivity))
    for j = 1:numColTraining
        trainingData(i, j) = syntheticNPSVegetationReflectivity{k, j};
    end
    k = k + 1;
    trainingIdentity(i, 1) = 3;
end
%%

% Set parameters for KNNWeightedModel call. 
k = 6;
r = 1;
weights = 'gaussian';

% Call KNNWeightedModel passing in the trainingData and identity matrices
% and the parameters defined above.
% weights: gaussian, inverse, quadratic, or triangular.
knn = KNNWeightedModel(trainingData, trainingIdentity, k, r, weights);

% Holds the weighted KNN's predictions for each test point.
yogurt = knn.predict(testingData);

% Initialize predictionMat to the size of the rows in testingData
% matrix and pre-allocate it with zeros.
predictionMat = zeros(size(testingData, 1), 1);

% Loop through number of test points and set predictionMat value to 1 for
% correct predictions. Compares true identity to predicted identity at each
% index.
for i = 1:size(testingData, 1)
    if (testingIdentity(i, 1) == yogurt(i, 1))
        predictionMat(i, 1) = 1;
    end
end

% Calculate overall classification accuracy
accuracy = (sum(predictionMat)/size(predictionMat, 1)) * 100

%accuracies(w) = accuracy;

% Create and display confusion chart.
labels = ["Manmade", "Rocks & Mineral", "Vegetation: NPS", "Vegetation"]; 
C = confusionmat(testingIdentity, yogurt);
%figure(w)
confusionchart(C,labels)

% Calculate Individual Precision/Recall for each class, Overall Precision/Recall, and F1-Score.
Ct = C';
diagonal = diag(Ct);
sumOfRows = sum(Ct, 2);

precision = diagonal ./ sumOfRows

%classPrecisions(:, w) = precision;

overallPrecision = mean(precision);

%overallPrecisions(w) = overallPrecision;

sumOfCols = sum(Ct, 1);

recall = diagonal ./ sumOfCols'

%classRecalls(:, w) = recall;

overallRecall = mean(recall);

%overallRecalls(w) = overallRecall;

f1Score = (2 * (overallPrecision * overallRecall) / (overallPrecision + overallRecall));

%f1Scores(w) = f1Score;

%end