function [ portamentos ] = portamentoDetectFunc(time,pitch)
%PORTAMENTODETECTFUNC Detect portamentos
%   Input
%   @time: the time vector for pitch vector.
%   @pitch: the pitch vector.
%   output
%   @portamentos: [portamento start time:end time:duration]

    stateRangeTransition = [-1,0,1]'; %the transition states: down, constant, up.

    pitchFs = 1/(time(2)-time(1));
    

    midiPitchOriginal = freqToMidi(pitch);
    %get delta f0
    deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,10))];
    deltaMidiPitch(abs(deltaMidiPitch) > 3) = 0; %it is necessary

    %---------Get initial state PDF, transiton matrix and observation matrix
    initialStateDistibutionTransition = 1/length(length(stateRangeTransition))*ones(1,length(stateRangeTransition));
    transPitchTransition = GetTransMatrixTransition(stateRangeTransition);
    observsTransition = ...
        GetObservsMatrixTransition(deltaMidiPitch,stateRangeTransition);
    %------------------------------

    %-----START of HMM----------------
    decodedHMMTransition = ViterbiAlgHMM(transPitchTransition,observsTransition,initialStateDistibutionTransition);
    %-----END of HMM-----------------

    portamentos = NoteAggreBaseline((decodedHMMTransition == 3 | decodedHMMTransition == 1)',pitchFs);
    portamentos = portamentos{1};
    portamentos(:,2) = portamentos(:,1) + portamentos(:,3);
    
    %------Small duration pruning---------
    durationThresh = 0.09; %in seconds
    portamentos = NotePruning(portamentos, durationThresh);
    %-------------------------------------
end

