function pauseAudioFn( hObject,eventData )
%PAUSEVIBRATOFUNCTION Pause the feature audio.
%   Detailed explanation goes here   
    global data;
    pause(data.audioFeaturePlayer);
end

