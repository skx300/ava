function [ notesTotal] = NoteAggreBaseline( decodedSeq,Fs )
%NoteAggreBaseline Note aggregation method for baseline
%Any MIDI change will be considered as a note change
%   Input
%   @decodedSeq: the decoded sequence in MIDI NN. If
%   midiTranscription is matrix. Each column is the decode sequence.
%   @Fs: the sampling rate of decoded sequence. If no Fs input, the output time
%   would be in frame.
%   Output
%   @notesTotal: the aggregated notes in cell arrarys. notesTotal{1,numCol}
%   indictes the notes from numCol'th column from midiTranscription matrix.

    if nargin == 1
        %only one input variable, the unit is frame
        Fs = 1;
    end

    numCol = size(decodedSeq,2); %see how many pieces of decoded sequences
    decodedeSeqDiff = [zeros(1,numCol);diff(decodedSeq)];
    notesTotal = cell(1,numCol);

    for c = 1:numCol
        noteIndicateMark  = [1;find(decodedeSeqDiff(:,c))];
        notes = zeros(length(noteIndicateMark),3);  %[start time(s); midi NN; duration(s)]
        for i = 1:length(noteIndicateMark)
            notes(i,1) = noteIndicateMark(i)/Fs;
            notes(i,2) = decodedSeq(noteIndicateMark(i));
            if i == length(noteIndicateMark)
                %check the last
                notes(i,3) = (length(decodedSeq)-noteIndicateMark(i))/Fs;   
            else
                notes(i,3) = (noteIndicateMark(i+1)-noteIndicateMark(i))/Fs;
            end

        end
        %make the time start from zero
        % notes(:,1) = notes(:,1) - 1/Fs;
        notes(notes(:,2) <= 0,:) = []; %delete the row having MIDI NN = 0;
        notesTotal{1,c} = notes;
    end
    
end

