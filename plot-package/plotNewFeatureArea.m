function [ newPatchVibratoArea ] = plotNewFeatureArea( feature,axeInput )
%PLOTNEWFEATUREAREA plot the new Features' (vibrato or portamento) area on pitch curve
%   Input
%   @features:vector [start time,end time,duration]
%   @axeInput: plot the vibrato area on this axe
%   Output
%   @newPatchVibratoArea: the filled new feature area for plot.

    %plot the new created feature
    axes(axeInput);
    hold on
    faceAlpha = 0.5;
    newPatchVibratoArea = fill([feature(1),feature(2),feature(2),feature(1)],...
            [axeInput.YLim(1),axeInput.YLim(1),axeInput.YLim(2),axeInput.YLim(2)],[.5 .0 .0],'EdgeColor','none','FaceAlpha',faceAlpha);    
    hold off

end

