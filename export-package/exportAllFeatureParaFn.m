function exportAllFeatureParaFn(hObject,eventData)
%EXPORTALLVIRAPARAFUNCTION export all feature (vibrato, portamento) parameters 

    global data;
    
    if strcmp(eventData.Source.Parent.Parent.Title,'Vibrato Analysis')
        %get which para method
        method = get(data.methodVibratoChange,'Value');
        if method == 1
            %FDM
            savedData = data.vibratoPara{1};
            savedFileName = [data.fileName,'_vib_para_FDM.csv'];
        elseif method == 2
            %Max-min
            savedData = data.vibratoPara{2};
            savedFileName = [data.fileName,'_vib_para_Max-min.csv'];
        end
    elseif strcmp(eventData.Source.Parent.Parent.Title,'Portamento Analysis')
        savedFileName = [data.fileName,'_por_para_Logistic.csv'];
        savedData = data.portamentoParaPost;
    end
   
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileName);
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        csvwrite([savedPathName,savedFileName],savedData);
    end

end

