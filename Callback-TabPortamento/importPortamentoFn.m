function importPortamentoFn(  hObject,eventData  )
%UNTITLED Import the vibrato annotation.csv file
%   The portamento annotation file should be [start(s):end(s):duration(s)]
    global data;
    %input portamento annation file
    [fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    if isnumeric(fileNameSuffix) == 0
        
        h = waitbar(0,'Initializing waitbar...');
        
        %if the user doesn't cancel, then read the portamento annotation
        %.csv file
        fullPathName = strcat(filePath,fileNameSuffix);
        data.portamentos = csvread(fullPathName);
        
        waitbar(50/100,h,sprintf('%d%% along...',75))
        %Get the individual portamento time and pitch vector 
        %portamentosDetail:[time from 0:pitch:orginal time]
        data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos,0);

        %remove the old portamentosDetailLogistic
        if isfield(data,'portamentosDetailLogistic') 
            data = rmfield(data,'portamentosDetailLogistic');
        end

        waitbar(75/100,h,sprintf('%d%% along...',75))
        %plot the portamentos on the pitch curve
        if isfield(data,'patchPortamentoArea') == 1;
            %if there are already some vibratos
            delete(data.patchPortamentoArea);
        end
        data.patchPortamentoArea =  plotFeaturesArea(data.portamentos,data.axePitchTabPortamento);

        %highlight the first portamento
        data.numPortamentoSelected = 1;
        plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,0);

        %plot the portamento num in the listbox
        plotFeatureNum(data.portamentos,data.portamentoListBox);

        %show the first portamento in vibrato listbox
        data.portamentoListBox.Value = data.numPortamentoSelected;

        %show individual portamento in the sub axes
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
        close(h)
    end    
        
  
end

