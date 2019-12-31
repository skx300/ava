function importPitchCurveFn( hObject,eventData )
%IMPORTPITCHCURVEFN import the pitch curve from .csv file
%the .csv file should be in the format [pitchTime:pitch]
    global data;
    
    %import pitch data
    [fileNameSuffix,filePath] = uigetfile({'*.csv'},'Select File');
    
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the pitch data .csv file
        fullPathName = strcat(filePath,fileNameSuffix);
        rawData = csvread(fullPathName);
        
        
        data.pitchTime = rawData(:,1);
        data.pitch = rawData(:,2);
        
%         data.pitch(data.pitch<= 0) = nan;

        %clear vibrato
        plotClearFeature('Vibrato');
        
        %plot
        plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio);
        plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato);
    end

end

