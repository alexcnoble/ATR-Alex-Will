# ATR-Alex-Will
The files in this repository include the code and data files for the Weighted-KNN and Random Forest classifiers using the data from the ASTER and KLUM data sets. The repository does not include all versions/code files that we have worked on, only those using ASTER &amp; KLUM. KLUM data is added directly to the manmade data from ASTER in all cases.

Steps for Executing the Scripts:
* Clone this repository onto your machine. (Or download each file individually)
    - Ensure that all of the following code (.m) files are in the same directory as all of the data files (.txt for ASTER, .csv for KLUM).
    - Main driver files that are to be executed include:
        - knnMainKLUM.m
        - knnMainSyntheticKLUM.m
        - forestMainKLUM.m
        - forestMainSyntheticKLUM.m
        - rockMineralsSoilSYNTHETIC.m
    - Files that act as functions to be called in the main files include:
        - readKlum.m
        - filterAndRead.m
        - readFunction.m
        - knnMatrixSetUp.m
        - downsample2Wavelengths.m
        - minMaxNormalization.m
        - removeNans.m
        - sortData.m
        - smote.m
        - KNNWeightedModel.m
    - Once all of this is certain, you can open and execute the main scripts.
    
Navigating the code files and what they do differently from one another:

* knnMainKLUM.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing.
    - Does NOT use SMOTE to upsample minority classes.

* knnMainSyntheticKLUM.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing.
    - DOES use SMOTE to upsample minority classes. (Manmade, Other, NPS Vegetation)

* forestMainKLUM.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Random Forest Model (TreeBagger).
    - Uses both ASTER & KLUM Data for training and testing.
    - Does NOT use SMOTE to upsample minority classes.

* forestMainSyntheticKLUM.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Random Forest Model (TreeBagger).
    - Uses both ASTER & KLUM data for training and testing.
    - DOES use SMOTE to upsample minority classes. (Manmade, Other, NPS Vegetation)

* rockMineralsSoilSYNTHETIC.m:
    - Classification of 4 distinct classes (Manmade, Rocks and Minerals, Vegetation, NPS Vegetation) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing.
    - Rock, Silicate Minerals, Other Minerals, and Soil are aggregated into a single class (Rock and Mineral).
    - DOES use SMOTE to upsample minority classes. (Manmade, NPS Vegetation)
