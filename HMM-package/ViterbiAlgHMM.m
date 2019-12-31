function [ stateSeqOutput ] = ViterbiAlgHMM(transMatrix,observMatrix,initalTrans)
%VITERBIALG USING Viterbi algorithm to decode HMM
%Input:
%   @transMatrix: transition probability matrix
%   @observMatrix: observation probability matrix (numStates * length(observSeq))
%   @initalTrans: inital state probability vector
%Output:
%   @stateSeqOutput: the decoded state sequence
 
    numStates = size(transMatrix,1);
    L = size(observMatrix,2);
    
    % transMatrix must be square
    checkTransition = size(transMatrix,2);
    if checkTransition ~= numStates
        error(message('stats:hmmviterbi:BadTransitions'));
    end

    % number of rows of observMatrix must be same as number of states
    checkObservMatrix = size(observMatrix,1);
    if checkObservMatrix ~= numStates
        error(message('stats:hmmviterbi:InputSizeMismatch'));
    end


    %log the probability to avoid numerical issue
    logTransMatrix = log(transMatrix);
    logObservMatrix = log(observMatrix);
    logInitalTransMatrix = log(initalTrans);

    %------------Viterbi Algorithm-----------
    delta = zeros(numStates,L); %store the cumulative probability
    psi = zeros(numStates,L);   %store the index for previous max value
    stateSeqOutput = zeros(1,L);    
    for t = 1:L  
        for i = 1:numStates
            if t == 1
%                 delta(i,t) = logInitalTransMatrix(i)+logObservMatrix(i,observSeq(1));
                delta(i,t) = logInitalTransMatrix(i)+logObservMatrix(i,t);
                psi(:,t) = 0; 
            else
                %use the forloop to avoid lots of max calls
                bestDelta = -Inf;
                bestPosition = 0;
                for innerI = 1:numStates
                    tempDelta = delta(innerI,t-1) + logTransMatrix(innerI,i);
                    if tempDelta > bestDelta
                        bestDelta = tempDelta;
                        bestPosition = innerI;
                    end
                end
%                 delta(i,t) = bestDelta+logObservMatrix(i,observSeq(t));
                delta(i,t) = bestDelta+logObservMatrix(i,t);
                psi(i,t) = bestPosition;
                %-----------------
%                 [tempDelta,psi(i,t)] = max(delta(:,t-1)+logTransMatrix(:,i));
%                 delta(i,t) = tempDelta+logObservMatrix(i,observSeq(t));
                %-----------------
            end
        end
    end

    %the final frame
    [~,stateSeqOutput(end)] = max(delta(:,end));

    %back tracking
    for t = L-1:-1:1
        stateSeqOutput(t) = psi(stateSeqOutput(t+1),t+1);
    end
    %---------------END of Viterbi Algorithm------------------
end

