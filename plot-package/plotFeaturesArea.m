function [patchFeaturesArea] = plotFeaturesArea( features,axeInput)
%PLOTVIBRATOSAREA plot Features' (vibrato or portamento) area on pitch curve
%   Input
%   @features:matrix [start time:end time:duration]
%   @axeInput: plot the vibrato area on this axe
%   Output
%   @patchFeaturesArea: the filled features area for plot.
    
%     patchVibratoArea = zeros(size(vibratos,1),1);
    faceColor = [.5,.5,.5];
    faceAlpha = 0.2;
    axes(axeInput);
    hold on
    for i = 1:size(features,1)  
        patchFeaturesArea(i) = fill([features(i,1),features(i,2),features(i,2),features(i,1)],...
            [axeInput.YLim(1),axeInput.YLim(1),axeInput.YLim(2),axeInput.YLim(2)],faceColor,'EdgeColor','none','FaceAlpha',faceAlpha);
    end
    hold off
end

