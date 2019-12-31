function getPortamentoFn(hObject,eventData)
%GETPORTAMENTOFN get portmaneto using HMM method

    global data;
    
    %clear portamento in case
    plotClearFeature('Portamento');
    
    h = waitbar(0,'Portamento detecting...');
    data.pitchVFree = smooth(data.pitchVFree,10);
    %portamentos: [portamento start time:end time:duration]
    data.portamentos = portamentoDetectFunc(data.pitchTime,data.pitchVFree);
    
    waitbar(50/100,h,sprintf('%d%% Portamento detecting...',50));
    %Get the individual portamento time and pitch vector 
    %portamentosDetail:[time from 0:pitch:orginal time]
    data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos,0);
    
    %remove the old portamentosDetailLogistic
    if isfield(data,'portamentosDetailLogistic') 
        data = rmfield(data,'portamentosDetailLogistic');
    end
    %Logistic modeling and get parameters
%     portamentosName = fieldnames(data.portamentosDetail);
%     fittedDataLogistic6 = zeros(size(portamentosName,1),6);
%     for i = 1:length(portamentosName)
%         portamentoXY = getfield(data.portamentosDetail, char(portamentosName(i)));
%         
%         portamentoX = portamentoXY(:,1);
%         portamentoY = freqToMidi(portamentoXY(:,2));
%         
%         [fittedPortamentoLogistic6,fittedGOFLogistic6(i)] = createGeneralLogistic6Fit(portamentoX,portamentoY);
%         fittedDataLogistic6(i,:) = coeffvalues(fittedPortamentoLogistic6);
%     end
%     
    waitbar(75/100,h,sprintf('%d%% Portamento detecting...',75));
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
    
    close(h);
end

