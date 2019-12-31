function [ vibratoCandidateVector ] = vibratoCandidates( vibratoIndicate, vibartoIndicateSign, frameCriterion, timeF )
%VIBRATOCANDIDATES is going to return the detected vibratos that can be
%used for vibrato parameters extraction
%   Input
%   @vibratoIndicate: the vibrato indicate vector indicating the detected
%   vibrato frame by frame
%   @vibratoIndicateSign: the sign for vibrato indicate(in number). e.g: 1
%   for vibrato frame and 0 for non-vibrato frame
%   @frameCriterion: only return the vibrato that has morn than or equal to
%   the frameCriterion number consecutive vibarto frames.
%   @timeF: time vector for vibratoIndicate vector
%   Output
%   @vibratoCandidateVector: return vibratos. Each line is one vibarto with beginning
%   and ending time mark.

    vibratoIndicateIndex = find(vibratoIndicate == vibartoIndicateSign);
    vibratoIndicateIndexDiff = ones(1,length(vibratoIndicateIndex));
    vibratoIndicateIndexDiff(2:end) = diff(vibratoIndicateIndex);
    vibratoIndicateMark = find(vibratoIndicateIndexDiff>1);
    if isempty(vibratoIndicateMark) == 1
        vibratoCandidateVector = [];
    else
        if (vibratoIndicateMark(end)~= length(vibratoIndicateIndexDiff))
            vibratoIndicateMark = [vibratoIndicateMark length(vibratoIndicateIndexDiff)];
        end
        vibratoIndicateSeg = zeros(length(vibratoIndicateMark),2);
        for i = 1:length(vibratoIndicateMark)
            if i==1
                vibratoIndicateSeg(i,1) = 1;
                vibratoIndicateSeg(i,2) = vibratoIndicateMark(i)-1;
            elseif i==length(vibratoIndicateMark)
                %Check the last one
                vibratoIndicateSeg(i,1) = vibratoIndicateMark(i-1);
                if vibratoIndicateIndexDiff(vibratoIndicateMark(end))==1
                    vibratoIndicateSeg(i,2) = vibratoIndicateMark(i);
                else
                    vibratoIndicateSeg(i,2) = vibratoIndicateMark(i)-1;
                end
            else
                vibratoIndicateSeg(i,1) = vibratoIndicateMark(i-1);
                vibratoIndicateSeg(i,2) = vibratoIndicateMark(i)-1;
            end
        end

        %get the detected vibrato whose duration is larger than frameCriterion frames
        vibratoIndicateSegChosen = vibratoIndicateSeg(find(vibratoIndicateSeg(:,2)-vibratoIndicateSeg(:,1)>=frameCriterion),:);
        vibratoCandidateVector = vibratoIndicateIndex(vibratoIndicateSegChosen);
        vibratoCandidateVector = timeF(vibratoCandidateVector);   %get each vibarto's time
    end
    
end

