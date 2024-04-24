% Custom update function for data cursor
function txt = populateNames(~, event_obj, manmadeNames)
    % Gets the index of the selected data point
    idx = get(event_obj, 'DataIndex');
    
    % Retrieves the name of the data point using its index
    name = manmadeNames{idx};
    
    % Set the text to display. You can include additional information here.
    txt = {['Name: ', name]};
end