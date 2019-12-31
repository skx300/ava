function delVibratoFn(hObject,eventData)
%DELVIBRATOFN Delete vibrato
%   Detailed explanation goes here

    global data;
    
    if isempty(data.vibratos) == 0
        %delete the vibrato time information
        data.vibratos(data.numViratoSelected,:) = [];
        %delete the vibrato area patch in the plot
        delete(data.patchVibratoArea(data.numViratoSelected));
        data.patchVibratoArea(data.numViratoSelected) = [];
    %     %delete the vibrato time and pitch vectors
    %     vibratoNames = fieldnames(data.vibratosDetail);
    %     data.vibratosDetail = rmfield(data.vibratosDetail,char(vibratoNames(data.numViratoSelected)));
        %Get the individual vibrato time and pitch vector 
        %vibratosDetail:[time from 0:pitch:orginal time]
        data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);
        %delete the para information
        data.vibratoPara{1,1}(data.numViratoSelected,:) = [];
        data.vibratoPara{1,2}(data.numViratoSelected,:) = [];

        %if the delelted vibrato is the last one, then go to the first
        if (data.numViratoSelected == size(data.vibratos,1)+1)
            data.numViratoSelected = 1;
        end

        %higlight the selected vibrato
        plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,0);

        %plot the vibrato num in the listbox
        plotFeatureNum(data.vibratos,data.vibratoListBox);

        %show the highlighted num of vibrato in vibrato listbox
        data.vibratoListBox.Value = data.numViratoSelected;

        %show individual vibrato in the sub axes
        plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi) 

        %show individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
    end
end

