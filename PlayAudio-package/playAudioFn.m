function playAudioFn( hObject,eventData)
%PLAYVIBRATOFUNCTION Play feature audio.
%   Detailed explanation goes here
    global data;
    currentTabName = data.tgroup.SelectedTab.Title;
    if strcmp(currentTabName,'Read Audio');
        %play the whole audio
        startPoint = 1;
        endPoint = length(data.audio);
        axeFeature = data.axeWave;
    elseif strcmp(currentTabName,'Vibrato Analysis');
        startPoint = round(data.vibratos(data.numViratoSelected,1) * data.fs);
        endPoint = round(data.vibratos(data.numViratoSelected,2) * data.fs);
        axeFeature = data.axePitchTabVibratoIndi;
    elseif strcmp(currentTabName,'Portamento Analysis');
        startPoint = round(data.portamentos(data.numPortamentoSelected,1) * data.fs);
        endPoint = round(data.portamentos(data.numPortamentoSelected,2) * data.fs);     
        axeFeature = data.axePitchTabPortamentoIndi;
    end

    data.featureAudio = data.audio(startPoint:endPoint);
    data.audioFeaturePlayer = audioplayer(data.featureAudio, data.fs);
    
    %setup the timer for the audioplayer object
%     data.audioFeaturePlayer.TimerFcn = {@plotAudioMarker, data.audioFeaturePlayer,data.fs, axeFeature}; % timer callback function (defined below)
%     data.audioFeaturePlayer.TimerPeriod = 0.01; % period of the timer in seconds
    
    play(data.audioFeaturePlayer);

end

