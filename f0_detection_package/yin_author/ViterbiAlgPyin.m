function [ viterbiF0 ] = ViterbiAlgPyin( f0Candidates, f0CandidatesWeights)
%VITERBIALG USING Viterbi algorithm to find the most likelihood(largest) cost path
%Requirement: getF0CandidatesCost function
%Input:
%   @f0Candidates: the f0 candidates
%   @f0CandidatesWeights: the corresponding weights for each f0 candidate
%Output:
%   @viterbiF0: the most likelihood(largest) f0 path
    
    %get the transition cost for each f0 candidate
    transitionCost = getF0CandidatesCost(f0Candidates,f0CandidatesWeights);
    
    %-------Viterbi Algorithm------------------
    numF0Candidates = size(f0Candidates,1);   %the number of candidates
    numFrames = size(f0Candidates,2);   %the number of frames
    
    preLoc = zeros(numF0Candidates,numFrames); 
    curVal = zeros(numF0Candidates,numFrames); 

    for n = 2:numFrames
        for i = 1:numF0Candidates
            tempDelta = curVal(:,n-1)+transitionCost(:,i,n-1);            
%             [curVal(i,n),preLoc(i,n)] = min(tempDelta);
            [curVal(i,n),preLoc(i,n)] = max(tempDelta); %LUWEI
        end
    end

    %check the final frame
%     [~,minIndexFinal] = min(curVal(:,numFrames));
    [~,minIndexFinal] = max(curVal(:,numFrames)); %LUWEI
    
    viterbiIndex = zeros(1,numFrames);
    viterbiIndex(numFrames) = minIndexFinal;
    for n = numFrames-1:-1:1
        viterbiIndex(n) = preLoc(viterbiIndex(n+1),n+1);
    end
    viterbiF0 = zeros(1,numFrames);
    for n = 1:numFrames
        viterbiF0(n) = f0Candidates(viterbiIndex(n),n); 
    end

end

