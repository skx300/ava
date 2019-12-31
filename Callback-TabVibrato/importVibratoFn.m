function importVibratoFn( hObject,eventData )
%IMPORTVIBRATOFN import the vibrato annotation.csv file
%   The vibrato annotation file should be [start(s):end(s):duration(s)]
    global data;
    %input vibrato annation file
    [fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    if isnumeric(fileNameSuffix) == 0
        
        h = waitbar(0,'Import vibrato...');
        
        %if the user doesn't cancel, then read the audio
        fullPathName = strcat(filePath,fileNameSuffix);
        data.vibratos = csvread(fullPathName);
        
        %Get the individual vibrato time and pitch vector 
        %vibratosDetail:[time from 0:pitch:orginal time]
        data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);

%         splitResults = strsplit(fileNameSuffix,'.');
%         data.fileName  = splitResults{1};
%         suffix = splitResults{2};
%         data.audio = audio;
%         data.filePath = filePath;
%         data.fileNameSuffix = fileNameSuffix; 

        %----START of getting vibrato para-------
        %get the threshold for DT
        freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
        ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');

        freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
        ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
        
        %vibratosParaFDM: [vibrato rate:vibrato extent]
        [~,~,data.FDMtime,data.FDMoutput] = vibratoDetectFunc(data.pitch,data.pitchTime,freqThresh,ampThresh);
        vibratosParaFDM = getVibratoParaFDM2( data.vibratos,data.FDMtime,data.FDMoutput );
        waitbar(50/100,h,sprintf('%d%% Import vibrato...',50))
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

        waitbar(75/100,h,sprintf('%d%% Import vibrato...',75))
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
        close(h)
    end    
    
end

