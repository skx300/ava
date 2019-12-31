function [ vibratoCandidatesDT,vibratoParametersFDMDT,timeF,FDMoutput] = vibratoDetectFunc( originalPitch,originalTime,vibratoRateLimit,vibratoAmplitudeLimit)
%VIBRATODETECTFUNC Detection the vibratos
%   Input:
%   @originalPitch: the pitch curve
%   @originalTime: the cooresponding time for the pitch curve
%   @vibratoRateLimit: frequency threshold for DT. [min,max]Hz
%   @vibratoAmplitudeLimit: amplitude threshold for DT. [min,max]
%   Output:
%   @vibratoCandidatesDT: the detected vibratos using DT. [start:end:duration]
%   @vibratoParametersFDMDT: the corresponding vibrato parameters for DT.
%   @timeF: the time vector match FDMoutput. Each point is one frame.
%   @FDMoutput: the output of FDM in frame wise. 1st column: frequency; 2nd
%   column: amplitude(vibrato extent). Each row is one frame.
    h = waitbar(0,'Vibrato detecting...');
    f0Fs = 1/(originalTime(2)-originalTime(1));

    %---------do interpolation for the pitch using spline function---------
    %Since the data misses some data points, it is necessary to do
    %interpolation.
%     interpolationF = f0Fs;  %interpolation frequency
%     newTime = [0:1/interpolationF:originalTime(end)]';
%     interpolatedSpitch = (interp1(originalTime,originalPitch,newTime,'spline'));
    %----------------------------------------------------------------------

%     time = newTime;
    time = originalTime;
%     midiSpitch = interpolatedSpitch;
    %To have correct extent, we shuold use the MIDI scale
    midiSpitch = freqToMidi(originalPitch);
    
    midiSpitch = smooth(midiSpitch,10);

    %-----------FDM parameters---------------
    f_min = 2;  %f_min = 0, f_max = 20 for evaluation and discussion part of MM14 paper
    f_max = 20; 
    J = 4;
    k_max = 4;  %the number of times we iterate the solution (to make it more accurate). You should only use the final iteration, because in theory that is the most accurate result.
                %k_max = 10 for MM14 paper
    %--------------------------------------

    %----------decision mechanism criteria---------------------
%     vibratoRateLimit = [5,8];   %the vibrato searching limit in Hz for decision tree
%     vibratoAmplitudeLimit = [0.1,NaN]; %the vibrato amplitude limit is for decision tree

    vibratoProbabilityCriterion = 0.25; %for Bayes' Rule method
    %--------------------------------------------------------

    %---------sign-----------------------------
    groundTruthIndicateSign = 2;
    nonVibratoSign = 0;

    FDMDTSign = 1.25;
    FDMBRSign = 2.5;
    %-----------------------------------------

    %-----------get the frame---------------------------------------
    windowLengthTime = 0.125;  %window length in seconds
    windowLength = floor(windowLengthTime*f0Fs);
    stepOfWindow = 0.25;
    step = floor(windowLength*stepOfWindow);

    frameNumTotal = ceil((length(midiSpitch)-windowLength)/step);
    fdResonanceF = zeros(1,frameNumTotal);
    fdResonanceD = zeros(1,frameNumTotal);

    pin  = 0;
    pend = length(midiSpitch)-windowLength;
    frameNum = 0;
    while pin<pend
        frameNum = frameNum + 1;
        waitbar(frameNum/frameNumTotal,h,sprintf('%d%% Vibrato detecting...',round(frameNum/frameNumTotal*100)));
        %remove the DC component  
        frame = midiSpitch(pin+1:pin+windowLength)-mean(midiSpitch(pin+1:pin+windowLength));
        %using FDM for each frame   
        [tempFk,tempD] = frameFDM3(frame,f0Fs,f_min,f_max,k_max);
%         [tempFk,tempD] = frameFDM_FFT(frame,f0Fs,f_min,f_max,k_max);
        output = [tempFk(1:length(tempD)).',tempD.'];

        %delete the negative real frequency
        output2 = [output(real(output(:,1))>0,1),output(real(output(:,1))>0,2)];

        %throw away any real frequency outside the preset frequency range
        output3 = [output2((output2(:,1)>=f_min&output2(:,1)<=f_max),1),output2((output2(:,1)>=f_min&output2(:,1)<=f_max),2)];

        tempFk = output3(:,1);
        tempD = output3(:,2);

        if isempty(output3) == 1
            fdResonanceF(frameNum) = NaN;
            fdResonanceD(frameNum) = NaN;
        else
             extent = 2*abs(tempD);  %this is the vibrato extent.
            [fdResonanceD(frameNum),indexMaxfdD] = max(extent); %find the biggest resonance
            fdResonanceF(frameNum) = real(tempFk(indexMaxfdD));   %get the biggest resonance's frequency  
        end

        pin = pin + step;

    end

    %----obtain the time axis for frames---------
    timeF = zeros(frameNum,1);
    timeF(1) = windowLength/2/f0Fs + time(1);
    for n = 2:frameNum
        timeF(n) = timeF(n-1) + step/f0Fs;
    end
    %----------------------------------------------------------

    %--------get the vibrato detection--------------------------------- 
    %-----------Desicion Tree Method-------------------------------
    %---------FDM+DT(F,A)--------------------------------
    vibratoIndicateDecisionTree = DecisionTree(fdResonanceF,fdResonanceD,vibratoRateLimit,vibratoAmplitudeLimit,FDMDTSign);
    vibratoIndicateDecisionTree = deleteOutlier(vibratoIndicateDecisionTree,FDMDTSign);
    %-------------------------------------------------------------

    %------Probability Modeling Method(Bayes' Rule Method)------------------------
    %-------FDM+BR-------------------------------
    vibratoIndicateProbability = BayesRule(fdResonanceF,fdResonanceD,FDMBRSign,vibratoProbabilityCriterion,'FDM');
    vibratoIndicateProbability = deleteOutlier(vibratoIndicateProbability,FDMBRSign);
    %---------------------------------------------------------

    %--------get the vibrato parameters----------------------------
    %--------get the detected vibrato candidates based on the
    %frameCriterion
    frameCriterion = 5; %the frame criterion for the vibrato candidates, make it larger or equal to 6 consecutive frames.
    vibratoCandidatesDT = vibratoCandidates(vibratoIndicateDecisionTree ,1.25,frameCriterion,timeF);
    vibratoCandidatesBR = vibratoCandidates(vibratoIndicateProbability ,2.5,frameCriterion,timeF);

    %--------Vibrato parameter extraction used the FDM output--------------
    vibratoParametersFDMDT = getVibratoParaFDM(vibratoIndicateDecisionTree,1.25,frameCriterion,[fdResonanceF',fdResonanceD']);
    % vibratoParametersFDMBR = getVibratoParaFDM(vibratoIndicateProbability,2.5,frameCriterion,[fdResonanceF',fdResonanceD']);
    %----------------------------------------------------------------------

    vibratoCandidatesDT(:,3) = vibratoCandidatesDT(:,2)-vibratoCandidatesDT(:,1);
    %note pruning
    vibratoCandidatesDT = NotePruning(vibratoCandidatesDT,0.25);
    
    FDMoutput = [fdResonanceF',fdResonanceD'];

    close(h);
end

