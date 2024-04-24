clear
clc
path = pwd;
tic
temp = dir([path, '\*.spectrum.txt']);

% Create cell arrays for each file group
manmadeFiles = {};
rockAndMineralFiles = {};
vegetationFiles = {};
npsVegetationFiles = {};
meteoriteFiles = {};

% Set counts to 0 for each file group
manmadeCount = 0;
rockAndMineralCount = 0;
vegetationCount = 0;
npsVegetationCount = 0;
meteoriteCount = 0;

% Read in file names
fileNames = {temp.name};

% Read files into respective cell array groups
for i = 1:length(fileNames)
    if contains(fileNames{i}, 'manmade')
        manmadeFiles{i} = fileNames{i};
        manmadeCount = manmadeCount + 1;
    end

    if contains(fileNames{i}, 'meteorite')
        meteoriteFiles{i-manmadeCount-npsVegetationCount-rockAndMineralCount-vegetationCount} = fileNames{i};
        meteoriteCount = meteoriteCount + 1;
    end

    if contains(fileNames{i}, 'mineral') || contains(fileNames{i}, 'rock') || contains(fileNames{i}, 'soil')
        rockAndMineralFiles{i-manmadeCount-meteoriteCount-npsVegetationCount-vegetationCount} = fileNames{i};
        rockAndMineralCount = rockAndMineralCount + 1;
    end

    if contains(fileNames{i}, 'nonphoto')
        npsVegetationFiles{i-manmadeCount-meteoriteCount-rockAndMineralCount-vegetationCount} = fileNames{i};
        npsVegetationCount = npsVegetationCount + 1;
    end

    if (contains(fileNames{i}, 'nonphoto') == false && contains(fileNames{i}, 'vegetation'))
        vegetationFiles{i-manmadeCount-meteoriteCount-rockAndMineralCount-npsVegetationCount} = fileNames{i};
        vegetationCount = vegetationCount + 1;
    end

end

% Read KLUM dataset
[klumWavelength, klumReflectivity] = readKlum();
klumCount = size(klumReflectivity,1);


% Create and pre-allocate cell arrays for wavelength and reflectivity data
manmadeWavelength = {zeros(1,manmadeCount + klumCount)};
manmadeReflectivity = {zeros(1,manmadeCount + klumCount)};

meteoriteWavelength = {zeros(1,meteoriteCount)};
meteoriteReflectivity = {zeros(1,meteoriteCount)};

rockAndMineralWavelength = {zeros(1,rockAndMineralCount)};
rockAndMineralReflectivity = {zeros(1,rockAndMineralCount)};

npsVegetationWavelength = {zeros(1,vegetationCount)};
npsVegetationReflectivity = {zeros(1,vegetationCount)};

vegetationWavelength = {zeros(1,vegetationCount)};
vegetationReflectivity = {zeros(1,vegetationCount)};


% Reading and Filtering the data
[manamadeBadCount, manmadeCount, manmadeWavelength, manmadeReflectivity,manmadeNames] = filterAndRead(manmadeCount, manmadeFiles, manmadeWavelength, manmadeReflectivity);
%[meteoriteBadCount, meteoriteCount, meteoriteWavelength, meteoriteReflectivity,meterotiteNames] = filterAndRead(meteoriteCount, meteoriteFiles, meteoriteWavelength, meteoriteReflectivity);
[rockAndMineralBadCount, rockAndMineralCount, rockAndMineralWavelength, rockAndMineralReflectivity,rockAndMineralNames] = filterAndRead(rockAndMineralCount, rockAndMineralFiles, rockAndMineralWavelength, rockAndMineralReflectivity);
[npsVegetationBadCount, npsVegetationCount, npsVegetationWavelength, npsVegetationReflectivity,npsNames] = filterAndRead(npsVegetationCount, npsVegetationFiles, npsVegetationWavelength, npsVegetationReflectivity);
[vegetationBadCount, vegetationCount, vegetationWavelength, vegetationReflectivity,vegeNames] = filterAndRead(vegetationCount, vegetationFiles, vegetationWavelength, vegetationReflectivity);

% Add KLUM to manmade
for i = manmadeCount + 1:manmadeCount + klumCount
        manmadeWavelength{i} = klumWavelength(i-manmadeCount,:)';
        manmadeReflectivity{i} = klumReflectivity(i-manmadeCount,:)';
end


% creating matrix to match KNN 
% setup matrix for manmade
identity = 1;
[manmadeReflectivityMatrix, manmadeWavelengthMatrix, manmadeIdentityMatrix] = knnMatrixSetUp(manmadeCount + klumCount, manmadeReflectivity, manmadeWavelength, identity);

% setup matrix for other minerals
identity = 2;
[rockAndMineralReflectivityMatrix, rockAndMineralWavelengthMatrix, rockAndMineralIdentityMatrix] = knnMatrixSetUp(rockAndMineralCount, rockAndMineralReflectivity, rockAndMineralWavelength, identity);

% setup matrix for nonphotosynthetic vegetation
identity = 3;
[npsVegetationReflectivityMatrix, npsVegetationWavelengthMatrix, npsVegetationIdentityMatrix] = knnMatrixSetUp(npsVegetationCount, npsVegetationReflectivity, npsVegetationWavelength, identity);

% setup matrix for vegetation
identity = 4;
[vegetationReflectivityMatrix, vegetationWavelengthMatrix, vegetationIdentityMatrix] = knnMatrixSetUp(vegetationCount, vegetationReflectivity, vegetationWavelength, identity);

% down sample to data with least number of wavelengths
wavelengths = {1.06 1.08 1.10 1.22 1.24 1.26 1.28 1.30 1.52 1.54};
[manmadeWavelengthMatrix, manmadeReflectivityMatrix] = downsample2Wavelengths(manmadeWavelengthMatrix, wavelengths, manmadeReflectivityMatrix);
[rockAndMineralWavelengthMatrix, rockAndMineralReflectivityMatrix] = downsample2Wavelengths(rockAndMineralWavelengthMatrix, wavelengths, rockAndMineralReflectivityMatrix);
[npsVegetationWavelengthMatrix, npsVegetationReflectivityMatrix] = downsample2Wavelengths(npsVegetationWavelengthMatrix, wavelengths, npsVegetationReflectivityMatrix);
[vegetationWavelengthMatrix, vegetationReflectivityMatrix] = downsample2Wavelengths(vegetationWavelengthMatrix, wavelengths, vegetationReflectivityMatrix);

% normalize the data
[normalizedManmade] = minMaxNormalization(cell2mat(manmadeReflectivityMatrix) , wavelengths);
manmadeReflectivityMatrix = num2cell(normalizedManmade);
[normalizedRockMineral] = minMaxNormalization(cell2mat(rockAndMineralReflectivityMatrix) , wavelengths);
rockAndMineralReflectivityMatrix = num2cell(normalizedRockMineral);
[normalizednpsVegetation] = minMaxNormalization(cell2mat(npsVegetationReflectivityMatrix) , wavelengths);
npsVegetationReflectivityMatrix = num2cell(normalizednpsVegetation);
[normalizedVegetation] = minMaxNormalization(cell2mat(vegetationReflectivityMatrix) , wavelengths);
VegetationReflectivityMatrix = num2cell(normalizedVegetation);

%put all data in one matrix
dataMatrix = [manmadeReflectivityMatrix; rockAndMineralReflectivityMatrix; npsVegetationReflectivityMatrix; vegetationReflectivityMatrix];
identityMatrix = [manmadeIdentityMatrix; rockAndMineralIdentityMatrix; npsVegetationIdentityMatrix; vegetationIdentityMatrix];
wavelengthMatrix = [manmadeWavelengthMatrix; rockAndMineralWavelengthMatrix; npsVegetationWavelengthMatrix; vegetationWavelengthMatrix];

%%
[dataMatrix, wavelengthMatrix, identityMatrix] = removeNans(dataMatrix, wavelengthMatrix, identityMatrix);
[wavelengthMatrix, dataMatrix] = sortData(dataMatrix, wavelengthMatrix, wavelengths);

for w=1:10

%split into training and testing
% Define the ratio for splitting
training_ratio = 0.8;
testing_ratio = 0.2;

% Create cell arrays to hold data for training and testing
trainingData = {};
testingData = {};
trainingIdentityMatrix = {};
testingIdentityMatrix = {};

% Generate a random partition for the data
c = cvpartition(length(dataMatrix),'HoldOut', testing_ratio);

% Indexes for training and testing sets
trainingIndexes = training(c);
testingIndexes = ~training(c);


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
            testingDataMatrix{l,j} = dataMatrix{i, j};
            testingIdentityMatrix{l, 1} = identityMatrix{i, 1};
        end
        l = l + 1;
    end
end

% Create arrays for data and identity matricies
% Initialize a numeric array with zeros
[numRowsTraining,numColTraining] = size(trainingDataMatrix);
[numRowsTesting,numColTesting] = size(testingDataMatrix);

trainingData = zeros(numRowsTraining, numColTraining);
trainingIdentity = zeros(numRowsTraining, 1);
testingData = zeros(numRowsTesting, numColTesting);
testingIdentity = zeros(numRowsTesting, 1);

% Loop through each cell and assign its value to the corresponding element in the numeric array
for i = 1:numRowsTraining
    for j = 1:numColTraining
        trainingData(i, j) = trainingDataMatrix{i, j};
    end
    trainingIdentity(i, 1) = trainingIdentityMatrix{i, 1};
end

for i = 1:numRowsTesting
    for j = 1:numColTesting
        testingData(i, j) = testingDataMatrix{i, j};
    end
    testingIdentity(i, 1) = testingIdentityMatrix{i, 1};
end


% Manual 
%%

k = 1;
r = 1;
weights = 'gaussian';
knn = KNNWeightedModel(trainingData, trainingIdentity, k, r, weights);
yogurt = knn.predict(testingData);

predictionMat = zeros(size(testingData, 1), 1);

for i = 1:size(testingData, 1)
    if (testingIdentity(i, 1) == yogurt(i, 1))
        predictionMat(i, 1) = 1;
    end
end

accuracy = (sum(predictionMat)/size(predictionMat, 1)) * 100
labels = ["Manmade", "Rocks & Minerals", "Vegetation: NPS", "Vegetation"]; 
C = confusionmat(testingIdentity, yogurt);
figure(w)
confusionchart(C,labels)

% Calculate Individual Precision/Recall for each class, Overall Precision/Recall, and F1-Score.
Ct = C';
diagonal = diag(Ct);
sumOfRows = sum(Ct, 2);

precision = diagonal ./ sumOfRows;

classPrecisions(:, w) = precision;

overallPrecision = mean(precision);

overallPrecisions(w) = overallPrecision;

sumOfCols = sum(Ct, 1);

recall = diagonal ./ sumOfCols'

classRecalls(:, w) = recall;

overallRecall = mean(recall);

overallRecalls(w) = overallRecall;

f1Score = (2 * (overallPrecision * overallRecall) / (overallPrecision + overallRecall));

f1Scores(w) = f1Score;

end