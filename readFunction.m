function [wavelength, reflectivity] =  readFunction(fileName)
    % Set number of header lines to not read when reading in data
    numHeaderLines = 21;
    
    % Open file and store the data columns from ASTER in columnData
    fileContents = fopen(fileName, 'r');
    columnData = textscan(fileContents, '%f%f', 'HeaderLines', numHeaderLines);
    
    % Split the columnData into reflectivy and wavelengths
    wavelength = columnData{1};
    reflectivity = columnData{2};
   
    % Close file
    fclose(fileContents);
end