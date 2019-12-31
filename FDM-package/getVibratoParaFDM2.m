function [ vibratoPara ] = getVibratoParaFDM2( vibratos,time,FDMoutput )
%GETVIBRATOPARAFDM2 Return the vibrato rate and extent according to FDM
%output
%   Input
%   @vibratos: the vibrato list [vibrato start time:end time:duration].
%   @time: the time vector match FDMoutput. Each point is one frame.
%   @FDMoutput: the output of FDM in frame wise. 1st column: frequency; 2nd
%   column: amplitude(vibrato extent). Each row is one frame.
%   @vibratoPara: the matrix storing vibrato para. each row is one vibrato: [rate,extent]

    vibratoPara = zeros(size(vibratos,1),2);
    
    for i = 1:size(vibratos,1)
        startTime = vibratos(i,1);
        endTime = vibratos(i,2);
        
        [~,minStartIndex] = min(abs(time - startTime));
        [~,minEndIndex] = min(abs(time - endTime));
        
        passageFDMoutput = FDMoutput(minStartIndex:minEndIndex,:);
        vibratoPara(i,:) = nanmean(passageFDMoutput);
    end
end

