function [PEKSAll,timePekAll,LOCSAll] = getPeakTrough(pitch,time)
%GETPEAKTROUGH Return the peaks and trougns of the pitch contour
%input:
%pitch: the pitch contour
%time: the time vector for the pitch contour
%output:
%PEKSAll: the peaks and troughs of the pitch contour
%timePekAll: the timing point for each peaks and troughs
%LOCSAll: the location of the peaks and troughs in the time vector
    
    %-----------------------------------------------
    %PEKS:local maximums
    %PEKS2:local minimums
    %find the local maximums in the smoothed pitch
    [PEKS,LOCS] = findpeaks(pitch);
    timePek = zeros(length(LOCS),1);
    for n = 1:length(LOCS)
        timePek(n) = time(LOCS(n));
    end
    
    %find the local minimums in the smoothed pitch
    negSPitch = -pitch;
    [PEKS2,LOCS2] = findpeaks(negSPitch);
    PEKS2 = -PEKS2;
    timePek2 = zeros(length(LOCS2),1);
    for n = 1:length(LOCS2)
        timePek2(n) = time(LOCS2(n));
    end
    
    LOCSAll = [LOCS;LOCS2]; %store the locations for all local maximums and local minimums
    LOCSAll = sort(LOCSAll);    %sort the locations in ascent order
    timePekAll = zeros(length(LOCSAll),1);
    for n = 1:length(LOCSAll)
        %get the time locations for all local maximums and local minimums
        timePekAll(n) = time(LOCSAll(n));
    end
    
    PEKSAll = zeros(length(LOCSAll),1);
    for n = 1:length(LOCSAll)
        %get all local maximums and locam minimums
        PEKSAll(n) = pitch(LOCSAll(n));
    end

end

