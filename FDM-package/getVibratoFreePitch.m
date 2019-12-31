function [ midiSpitchVibratoFree ] = getVibratoFreePitch( time, midiSpitch, groundTruthDataVibrato)
%GETVIBRATOFREEPITCH Return the vibrato free pitch contour
%   Input
%   @time: the time vector corresponding to the midiSpitch
%   @midiSpitch: the pitch contour in midi scale
%   @groundTruthDataVibrato: the ground truth of vibrato. Each row is one
%   vibrato, 1st column: start time, third column: duration
%   Output
%   @midiSpitchVibratoFree: the pitch contour without vibrato

    midiSpitchVibratoFree = midiSpitch;

    %get vibrato passages without shifting
    [vibrato,vibratoIndex] = getPassages(time,midiSpitch, groundTruthDataVibrato,0);

    vibratoNames = fieldnames(vibrato);
    for i = 1:length(vibratoNames)
    % for i = 1
        vibratoEach = getfield(vibrato, char(vibratoNames(i)));

        %get the average pitch of the vibrato using Local regression using weighted linear least squares and a 1st degree polynomial model
        %It is used in (Yang2013)
        vibratoFreePitch = smooth(vibratoEach(:,2),100,'rlowess');  
%         vibratoFreePitch = medf(vibratoEach(:,2)',101,length(vibratoEach(:,2)));

        midiSpitchVibratoFree(vibratoIndex(i,1):vibratoIndex(i,2)) = vibratoFreePitch;

    %     figure(1)
    %     plot(vibratoEach(:,1),vibratoEach(:,2));
    %     hold on
    %     plot(vibratoEach(:,1),vibratoFreePitch,'r');\
    %     hold off

    end

end

