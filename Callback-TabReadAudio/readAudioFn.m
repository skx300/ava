function readAudioFn(hObject,eventData)
%READAUDIOFUNCTION Summary of this function goes here
%   Detailed explanation goes here
    global data;
    %input audio
    [fileNameSuffix,filePath] = uigetfile({'*.wav';'*.mp3'},'Select File');
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the audio
        fullPathName = strcat(filePath,fileNameSuffix);
        [audio,data.fs] = audioread(fullPathName);

        %sum the two channels into one channel
        channels = size(audio,2);
        if channels > 1
            audio = sum(audio,2);
        end
        data.time = (1:size(audio,1))/data.fs;

        splitResults = strsplit(fileNameSuffix,'.');
        data.fileName  = splitResults{1};
        suffix = splitResults{2};
        data.audio = audio;
        data.filePath = filePath;
        data.fileNameSuffix = fileNameSuffix; 

        plotAudio(data.time,data.audio,data.axeWave,data.fileNameSuffix);
    end

end

