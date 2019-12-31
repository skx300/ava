function [ midi ] = freqToMidi( frequencies )
%FREQTOMIDI convert frequencies to midi
%Input:
%   @frequencies: in Hz
%Output:
%   @midi: in midi number
    frequenciesSize = size(frequencies);
    midi = zeros(frequenciesSize);
    for i = 1:frequenciesSize(1)
       for j = 1:frequenciesSize(2)
           if(frequencies(i,j)<8.18)
               midi(i,j) = 0;
           else
               midi(i,j) = 12*log2(frequencies(i,j)/440) + 69; 
           end
       end
    end

end

