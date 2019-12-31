function delPortamentoFn(hObject,eventData)
%DELPORTAMETOFN Summary of this function goes here
%   Detailed explanation goes here

    global data;
    
    if isempty(data.portamentos) == 0
        %delete the portamento time information
        data.portamentos(data.numPortamentoSelected,:) = [];
        %delete the portamento area patch in the plot
        delete(data.patchPortamentoArea(data.numPortamentoSelected));
        data.patchPortamentoArea(data.numPortamentoSelected) = [];
    %     %delete the portamento time and pitch vectors
    %     vibratoNames = fieldnames(data.portamentosDetail);
    %     data.portamentosDetail = rmfield(data.portamentosDetail,char(vibratoNames(data.numPortamentoSelected)));
        %Get the individual portamento time and pitch vector 
        %portamentosDetail:[time from 0:pitch:orginal time]
        data.portamentosDetail = getPassages(data.pitchTime,data.pitch,data.portamentos,0);

        %if the delelted portamento is the last one, then go to the first
        if (data.numPortamentoSelected == size(data.portamentos,1)+1)
            data.numPortamentoSelected = 1;
        end
        
        %higlight the selected portamento
        plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,0);

        %plot the portamento num in the listbox
        plotFeatureNum(data.portamentos,data.portamentoListBox);

        %show the highlighted num of portamento in portamento listbox
        data.portamentoListBox.Value = data.numPortamentoSelected;

        %show individual portamento in the sub axes
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi) 

    end
end

