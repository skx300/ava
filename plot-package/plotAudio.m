function plotAudio(time,audio,axeAudio,fileName)
%PLOTAUDIO Plot the audio waveform
%   Input
%   @time: the time vector for pitch
%   @audio: the audio vector (one channel)
%   @axeAudio: the axe for audio waveform plot
%   @fileName: the file name of the audio

    axes(axeAudio);
    plot(time,audio);
    title(fileName);   
    ylabel('Amplitude');
    xlabel('Time(s)');
    xlim([time(1) time(end)]);
end

