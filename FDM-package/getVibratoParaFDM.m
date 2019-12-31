function [ vibratoParameters ] = getVibratoParaFDM(  vibratoIndicate, vibartoIndicateSign, frameCriterion, FDMoutput)
%GETVIBRATOPARAFDM Returns the vibrato parameters rate and extent from the
%FDM output
%   Input
%   @vibratoIndicate: the vibrato indicate vector indicating the detected
%   vibrato frame by frame
%   @vibratoIndicateSign: the sign for vibrato indicate(in number). e.g: 1
%   for vibrato frame and 0 for non-vibrato frame
%   @frameCriterion: only return the vibrato that has morn than or equal to
%   the frameCriterion number consecutive vibarto frames.
%   @FDMoutput: the output of FDM in frame wise. 1st column: frequency; 2nd
%   column: amplitude(vibrato extent).
%   Output
%   @vibratoParameters: return vibrato parameters. 1st column: vibrato
%   rate, second column: vibrato extent
    
    vibratoIndicateIndex = find(vibratoIndicate == vibartoIndicateSign);
    vibratoIndicateIndexDiff = ones(1,length(vibratoIndicateIndex));
    vibratoIndicateIndexDiff(2:end) = diff(vibratoIndicateIndex);
    vibratoIndicateMark = find(vibratoIndicateIndexDiff>1);
    if (vibratoIndicateMark(end)~= length(vibratoIndicateIndexDiff))
        vibratoIndicateMark = [vibratoIndicateMark length(vibratoIndicateIndexDiff)];
    end
    vibratoIndicateSeg = zeros(length(vibratoIndicateMark),2);
    for i = 1:length(vibratoIndicateMark)
        if i==1
            vibratoIndicateSeg(i,1) = vibratoIndicateIndex(1);
            vibratoIndicateSeg(i,2) = vibratoIndicateIndex(vibratoIndicateMark(i)-1);
        elseif i==length(vibratoIndicateMark)
            %Check the last one
            vibratoIndicateSeg(i,1) = vibratoIndicateIndex(vibratoIndicateMark(i-1));
            if vibratoIndicateIndexDiff(vibratoIndicateMark(end))==1
                vibratoIndicateSeg(i,2) = vibratoIndicateIndex(vibratoIndicateMark(i));
            else
                vibratoIndicateSeg(i,2) = vibratoIndicateIndex(vibratoIndicateMark(i)-1);
            end
        else
            vibratoIndicateSeg(i,1) = vibratoIndicateIndex(vibratoIndicateMark(i-1));
            vibratoIndicateSeg(i,2) = vibratoIndicateIndex(vibratoIndicateMark(i)-1);
        end
    end
    
    %get the detected vibrato whose duration is larger than frameCriterion frames
    vibratoIndicateSegChosen = vibratoIndicateSeg(find(vibratoIndicateSeg(:,2)-vibratoIndicateSeg(:,1)>=frameCriterion),:);
    
    row = size(vibratoIndicateSegChosen,1);
    vibratoParameters = zeros(row,2);
    for n =1:row
        vibratoParameters(n,1) = mean(FDMoutput(vibratoIndicateSegChosen(n,1):vibratoIndicateSegChosen(n,2),1));
        vibratoParameters(n,2) = mean(FDMoutput(vibratoIndicateSegChosen(n,1):vibratoIndicateSegChosen(n,2),2));
    end


end

