function stopAudioFn( hObject,eventData )
%STOPVIBRATOFUNCTION Stop the feature audio
%   Detailed explanation goes here
    global data;
    stop(data.audioFeaturePlayer);

end

