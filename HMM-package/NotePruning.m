function [ notesOutput ] = NotePruning(notesInput,durationThresh)
%NOTEPRUNING Summary of this function goes here
%   Input:
%   @notesInput: [start time:end time:duration]
%   @durationThresh: the duration threshold for pruning. Any notes with
%   duritaion smaller this threshold will be deleted. (seconds)
%   Output:
%   @notesOutput: [start time:end time:duration]

    notesInput(notesInput(:,3) < durationThresh,:) = [];   
    notesOutput = notesInput;
end

