function getVibratoFn(hObject,eventData)
%GETVIBRATO get the vibratos using FDM and plot vibratos
%   Detailed explanation goes here
    global data;
    
    %clear vibratos;
    plotClearFeature('Vibrato');
        
    %get the threshold for DT
    freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
    ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');
    
    freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
    ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
    
    
    %Get vibratos using FDM method
    %vibratos: [vibrato start time:end time:duration]
    [data.vibratos,~,data.FDMtime,data.FDMoutput] = vibratoDetectFunc(data.pitch,data.pitchTime,freqThresh,ampThresh);


    %Get the individual vibrato time and pitch vector 
    %vibratosDetail:[time from 0:pitch:orginal time]
    data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);

    %----START of getting vibrato para-------
    %vibratosParaFDM: [vibrato rate:vibrato extent]
    vibratosParaFDM = getVibratoParaFDM2( data.vibratos,data.FDMtime,data.FDMoutput );
    %get vibrato rate, extent(using max-min method) vibrato sinusoid similarity for all passages
    vibratoNames = fieldnames(data.vibratosDetail);
    %vibratoParaMin: [rate, extent, std rate, std extent, SS]
    vibratoParaMaxMin = zeros(length(vibratoNames),5);
    vibratosSS = zeros(length(vibratoNames),1);
    for i = 1:length(vibratoNames)
        vibratoTimePitch = getfield(data.vibratosDetail, char(vibratoNames(i)));
        %sinusoid similarity
        vibratosSS(i) = vibratoShape(vibratoTimePitch(:,[1,2]));

        vibratoParaMaxMin(i,[1:4]) = vibratoRateExtent(vibratoTimePitch(:,[1,2]));
        vibratoParaMaxMin(i,5) = vibratosSS(i);
    end
    %add sinusoid similarity to the vibratosParaFDM ([rate:extent:SS])        
    vibratosParaFDM = [vibratosParaFDM,vibratosSS];

    %vibratosPara{1}from FDM
    %vibratosPara{2}from Max-min
    data.vibratoPara{1} = vibratosParaFDM;
    data.vibratoPara{2} = vibratoParaMaxMin;
    %----END of getting vibrato para-------
       
    
    %plot the vibratos on the pitch curve
    if isfield(data,'patchVibratoArea') == 1;
        %if there are already some vibratos
        delete(data.patchVibratoArea);
    end
    data.patchVibratoArea =  plotFeaturesArea(data.vibratos,data.axePitchTabVibrato);
    
    %highlight the first vibrato
    data.numViratoSelected = 1;
    plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,0);
     
    %plot the vibrato num in the listbox
    plotFeatureNum(data.vibratos,data.vibratoListBox);
    
    %show the first vibrato in vibrato listbox
    data.vibratoListBox.Value = data.numViratoSelected;
    
    %show individual vibrato in the sub axes
    plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi)
    
    %show the first individual vibrato statistics
    plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
end

