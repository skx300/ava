function [ frequencies ] = MidiToFreq( midi )
%MIDITOFREQ convert midi to frequencies
%Input:
%   @midi: in Hz
%Output:
%   @frequencies: in midi number
    MidiSize = size(midi);
    frequencies = zeros(MidiSize);
    for i = 1:MidiSize(1)
       for j = 1:MidiSize(2)
           frequencies(i,j) = 2.^((midi(i,j)-69)./12)*440;
       end
    end

end

