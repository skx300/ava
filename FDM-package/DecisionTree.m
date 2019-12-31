function [ vibratoIndicate ] = DecisionTree( peakFrequency,peakAmplitude,vibratoRateLimit,vibratoAmplitudeLimit, indicateSign)
%DECISIONTREE Decision Tree classification
%   Input
%   @peakFrequency: the frequency of peak for each frame
%   @peakAmplitude: the amplitude of peak for each frame
%   @vibratoRateLimit: the vibrato searching limit in Hz for decision tree
%   @vibratoAmplitudeLimit: the vibrato amplitude limit is for decision
%   @indicateSign: the sign to indicate a vibrato. Non-vibrato is indicated
%   as 0.
%   Output
%   @vibratoIndicate: vector to indicate each frame has vibrato or not.
    
    frameNum = length(peakFrequency);
    vibratoIndicate = zeros(1,frameNum);
    for i = 1:frameNum
        %judge the vibrato based on the vibrato rate amd amplitude limit
        %ranges
        if(isempty(peakAmplitude) == 1)
            %only look at the vibrato rate limit
              if(peakFrequency(i)<=vibratoRateLimit(2)&&peakFrequency(i)>=vibratoRateLimit(1))
                vibratoIndicate(i) = indicateSign;
              end
        else
            %look at both the vibrato rate limit and vibrato extent limit
                if(peakFrequency(i)<=vibratoRateLimit(2)&&peakFrequency(i)>=vibratoRateLimit(1) && (peakAmplitude(i)>=vibratoAmplitudeLimit(1)))
                      vibratoIndicate(i) = indicateSign;
                end
        end
    end


end

