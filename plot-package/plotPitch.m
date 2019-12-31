function plotPitch( time, pitch,axePitch)
%PLOTPITCH Plot pitch curve
%   Input
%   @time: the time vector for pitch
%   @pitch: the pitch vector
%   @axePitch: the axe for pitch plot
    
    midiScale = (0.5:1:127.5)';
    faceColor = [.5,.5,.5];
    faceAlpha = 0.2;
    
    axes(axePitch);
%     plot(time,pitch);
    plot(time,freqToMidi(pitch),'.');
    xlim([time(1) time(end)]);
    hold on
    %plot the equally-tempered MIDI note scale
%     for i = 1:size(midiScale,1)-1  
%         if mod(i,2) == 1
%             faceAlpha = 0.2;
%         else
%             faceAlpha = 0;
%         end
%         patchMIDIScale(i) = fill([axePitch.XLim(1),axePitch.XLim(2),axePitch.XLim(2),axePitch.XLim(1)],...
%             [midiScale(i),midiScale(i),midiScale(i+1),midiScale(i+1)],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
%     end
    hold off
    title('Pitch Curve');
%     ylabel('Frequency(Hz)');
    ylabel('MIDI number');
    xlabel('Time(s)');
    
%     xlim([0 30]);
    ylim([55 90]);
%     ylim([100 350]);
end

