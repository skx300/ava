function changeMethodVibratoParaFn(hObject,eventData)
%CHANGEMETHODVIBRATOPARAFN The vibrato para have to be updated when the
%method for extracting vibrato paras is changed.

    global data;
    %show the corresponding vibrato parametes
    plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
end

