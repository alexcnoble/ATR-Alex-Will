function [wavelengths, spectra, names] = readKlum()
    KLUM_quality_file = csvread('KLUM_quality.csv',1,1);
    KLUM_spectra_file = csvread('KLUM_spectra.csv',1,1);
    KLUM_metadata = readtable('KLUM_metadata.csv');
    class = KLUM_metadata.class;
    subclass = KLUM_metadata.subclass;
    usage = KLUM_metadata.usage;
    color = KLUM_metadata.color;
    surface_structure_texture_coating = KLUM_metadata.surface_structure_texture_coating;
    status = KLUM_metadata.status;
    names = append(class,subclass,usage,color,surface_structure_texture_coating,status);

    quality = KLUM_quality_file(:,4:end);
    notes = KLUM_quality_file(:,1:3);

    lambda = KLUM_spectra_file(1,:);
    spectra = KLUM_spectra_file(2:end,:);

    % Convert lambda (wavelength in nm) to wavelengths matrix (microns)
    for i = 1:length(lambda)
        for j = 1:size(spectra, 1)
            wavelengths(j, i) = lambda(i) / 1000;
        end
    end
end