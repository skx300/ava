function [ transitionCost ] = getF0CandidatesCost(f0Candidates, f0CandidatesWeights)
%getF0CANDIDATESCOST Calculates the transition cost for each f0 candidate
%Input:
%   @f0Candidates: the f0 candidates
%   @f0CandidatesWeights: the corresponding weights for each f0 candidate
%Output:
%   @transitionCost: the transition costs for each f0 candidate
    
    %------calculate transition cost-----------
    numF0Candidates = size(f0Candidates,1);   %the number of candidates
    numFrames = size(f0Candidates,2);   %the number of frames
    w = 1; %weight

    transitionCost = zeros(numF0Candidates,numF0Candidates,numFrames);
    for i = 1:numFrames-1
        for n = 1:numF0Candidates
            for y = 1:numF0Candidates
                if (f0Candidates(n,i) == 0 || f0Candidates(y,i+1) == 0)
                    transitionCost(n,y,i) = 99;
%                     transitionCost(n,y,i) = 0;
                else
%                     transitionCost(n,y,i) = abs(log2(f0Candidates(n,i)/f0Candidates(y,i+1)))+(w/f0CandidatesWeights(n,i));
%                     transitionCost(n,y,i) = 0;
                    %use norm distribution to model the transition probablity
                    transitionCost(n,y,i) = normpdf(abs(log2(f0Candidates(n,i)/f0Candidates(y,i+1))),0,2.5)+(w*f0CandidatesWeights(n,i));
                end
            end
        end
    end


end

