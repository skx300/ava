function exportFeatureAnnoFn(hObject,eventData )
%EXPORTALLVIRAFUNCTION export the feature (vibrato/portamento) annotations
%   Detailed explanation goes here

    global data;
    
    if strcmp(eventData.Source.Parent.Title,'Get Vibrato:')
        savedFileName = [data.fileName,'_vibratos.csv'];
        annotation = data.vibratos;
    elseif strcmp(eventData.Source.Parent.Title,'Get Portamento:')
        savedFileName = [data.fileName,'_portamentos.csv'];
        annotation = data.portamentos;
    end
    
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileName);
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        csvwrite([savedPathName,savedFileName],annotation);
    end
end

