function [ passages,passagesIndex,pitchRange] = getPassages( time,midiSpitch,groundTruthData,timeShift )
%GETPORTAMENTOPASSAGES Return the passages according to the groundTruthData
%   Input:
%   @time: the time vector for the midiSpitch.
%   @midiSpitch: the midi scaled pitch
%   @groundTruthData: the annotation for vibrato or portamento or anything else.
%   @timeShift: temporary variable 
%   output:
%   @passages: the struct the contains passage clips
%   @passagesIndex: the passage index corresponding to the @time vector
%   @pitchRange: the pitch range for each passage

%--------------Extract the passages from pitch contour-------------------
passages = struct;    %store the passage clips into struct
pitchRange = zeros(size(groundTruthData,1),1);
for i = 1:size(groundTruthData,1)
    startTimeAnn = groundTruthData(i,1) - timeShift;
    endTimeAnn = groundTruthData(i,1) + groundTruthData(i,3) + timeShift;
    
    [~,minStartIndex] = min(abs(time - startTimeAnn));
    [~,minEndIndex] = min(abs(time - endTimeAnn));
    
    passageTemp = [time(minStartIndex:minEndIndex),midiSpitch(minStartIndex:minEndIndex)];
    
    %normalization
%     portamentoTempNorm = [(portamentoTemp(:,1)-min(portamentoTemp(:,1)))/(max(portamentoTemp(:,1))-min(portamentoTemp(:,1))),portamentoTemp(:,2),];
    %align the time vector
    passageTempNorm = [(passageTemp(:,1)-min(passageTemp(:,1))),passageTemp(:,2),passageTemp(:,1)]; 
    
    pitchRange(i,1) = max(passageTemp(:,2))-min(passageTemp(:,2));  %pitch range
    
    passagesIndex(i,:) = [minStartIndex,minEndIndex];
    passages = setfield(passages,['passage',num2str(i)],passageTempNorm);
end
%--------------------------------------------------------------------------

end

