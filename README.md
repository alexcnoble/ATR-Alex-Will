# ATR-Alex-Will
The files in this repository include the code and data files for the Weighted-KNN and Random Forest classifiers using the data from the ASTER and KLUM data sets. The repository does not include all versions/code files that we have worked on, only those using ASTER &amp; KLUM. KLUM data is added directly to the manmade data from ASTER in all cases.

Steps for Executing the Scripts:
* Clone this repository onto your machine. (Or download each file individually)
* To download the ASTER and KLUM data, navigate to this link: https://drive.google.com/file/d/1WB4BsC5ZTwgXtZGSInrfv6KFG4XthUvU/view?usp=sharing
    - Ensure that all of the following code (.m) files are in the same directory as all of the data files (.txt for ASTER, .csv for KLUM). To do this, extract the .zip from the Google Drive link above and simply place all of the code files in the extracted folder.
    - Main driver files that are to be executed include:
        - knnMain_holdout.m
        - knnMain_kfold.m
        - knnMain_4Classes.m
        - knnMainSMOTE_holdout.m
        - knnMainSMOTE_kfold.m
        - knnMainSMOTE_4Classes.m
        - forestMain_holdout.m
        - forestMain_kfold.m
        - forestMainSMOTE_holdout.m
        - PCA_kMeans.m
    - Files that act as functions to be called in the main files include:
        - readKlum.m
        - filterAndRead.m
        - readFunction.m
        - knnMatrixSetUp.m
        - downsample2Wavelengths.m
        - minMaxNormalization.m
        - removeNans.m
        - removeNans2.m
        - sortData.m
        - smote.m
        - KNNWeightedModel.m
        - populateNames.m
    - Once all of this is certain, you can open and execute the main scripts.
    
Navigating the code files and what they do differently from one another:

* knnMain_holdout.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a holdout partition.
    - Does NOT use SMOTE to upsample minority classes.
 
* knnMain_kfold.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a kfold cross validation partition.
    - Does NOT use SMOTE to upsample minority classes.
 
* knnMain_4Classes.m:
    - Classification of 4 distinct classes (Manmade, Rocks & Minerals, Vegetation, NPS Vegetation) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a holdout partition.
    - Rock, Silicate Minerals, Other Minerals, and Soil are aggregated into a single class (Rocks & Minerals).
    - Does NOT use SMOTE to upsample minority classes. (Manmade, NPS Vegetation)

* knnMainSMOTE_holdout.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a holdout partition.
    - DOES use SMOTE to upsample minority classes. (Manmade, Other, NPS Vegetation)

* knnMainSMOTE_kfold.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a kfold cross validation partition.
    - DOES use SMOTE to upsample minority classes. (Manmade, Other, NPS Vegetation)

* knnMainSMOTE_4Classes.m:
    - Classification of 4 distinct classes (Manmade, Rocks & Minerals, Vegetation, NPS Vegetation) using the Weighted-KNN Model.
    - Uses both ASTER & KLUM data for training and testing using a holdout partition.
    - Rock, Silicate Minerals, Other Minerals, and Soil are aggregated into a single class (Rocks & Minerals).
    - DOES use SMOTE to upsample minority classes. (Manmade, NPS Vegetation)

* forestMain_holdout.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Random Forest Model (TreeBagger).
    - Uses both ASTER & KLUM Data for training and testing using a holdout partition.
    - Does NOT use SMOTE to upsample minority classes.

* forestMain_kfold.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Random Forest Model (TreeBagger).
    - Uses both ASTER & KLUM Data for training and testing using a kfold cross validation partition.
    - Does NOT use SMOTE to upsample minority classes.

* forestMainSMOTE_holdout.m:
    - Classification of 7 distinct classes (Manmade, Silicate Minerals, Other Minerals, Rock, Vegetation, NPS Vegetation, Other) using the Random Forest Model (TreeBagger).
    - Uses both ASTER & KLUM data for training and testing using a holdout partition.
    - DOES use SMOTE to upsample minority classes. (Manmade, Other, NPS Vegetation)

* PCA_kMeans.m:
    - Performs principal component analysis on the aggregated manmade data from ASTER & KLUM data sets.
    - Calculates Within-Cluster Sum of Squares and Silhouette Scores to determine best k-number of clusters and best principal components.
    - Plots data points across 2 and 3 Principal Components for a varying number of clusters.
    - Cluster assignments are written to an excel sheet (ClusterAssignments.xlsx) for easier reading of all assignments.
    - Points on the plots are able to be hovered/clicked to see what materials are clustered where.
