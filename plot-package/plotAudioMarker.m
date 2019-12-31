function plotAudioMarker(hObject,eventData,player,fs, axeInput)
%PLOTAUDIOMARKER Plot the audio playing vertical marker on the waveform or
%pitch curve
%   Input:
%   @player: the audio player object.
%   @fs: sampling rate.
%   @axeInput: the axe on which the marker will be shown.

    % check if sound is playing, then only plot new marker
    
    axes(axeInput);
    hold on
    if strcmp(player.Running, 'on')
    
        % get the handle of current marker and delete the marker
        hMarker = findobj(axeInput, 'Color', 'r','Tag','audioLine');
        hMarker.XData = hMarker.XData+fs*0.01;
%         delete(hMarker);

%         markerData = [axeInput.YLim(1):0.1:axeInput.YLim(2)];
        % plot the new marker
%         plot(repmat(player.CurrentSample/fs, size(markerData)), markerData, 'r','Tag','audioLine');
        disp('Called!');
    end
    hold off
    
end

