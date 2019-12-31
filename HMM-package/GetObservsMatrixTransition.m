function [ observsMatrix ] = GetObservsMatrixTransition( deltaMidiPitch,stateRangeTransition )
%GETOBSERVSMATRIXTRANSITION Return observation matrix for transition HMM.
%   Input
%   @deltaMidiPitch: the corresponding delta-f0
%   @stateRangeTransition: state range for transition. (up, constant, down).
%   Output
%   @observsMatrix: 
    
    numStatesTransition = length(stateRangeTransition);
    %-------START of delta pitch observation matrix---------
    observsMatrix = zeros(numStatesTransition,length(deltaMidiPitch));
    for i = 1:numStatesTransition %3 transition states
        if i == 1
            %DOWN
%             paraObservsDeltaPitch = [-0.5,0.3];
            observsMatrix(i,:) = pdf('Gamma',-deltaMidiPitch,1.1,30);
        elseif i == 2
            %Constant
%             paraObservsDeltaPitch = [0,0.015];
            paraObservsDeltaPitch = [0,0.010];  %0.014
            observsMatrix(i,:) = normpdf(deltaMidiPitch,paraObservsDeltaPitch(1),paraObservsDeltaPitch(2))*0.01;
        elseif i == 3
            %UP
%             paraObservsDeltaPitch = [0.5,0.3]; 
            observsMatrix(i,:) = pdf('Gamma',deltaMidiPitch,1.1,30);
        end
        
    end
    
%     observsDeltaPitch = [observsDeltaPitchSilent';observsDeltaPitch];
    %-----------END of delta pitch observation matrix---------------


end

