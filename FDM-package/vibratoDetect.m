clear;
clf;

% load('userstudyB.mat')
% audioSampleRate = 48000; %in Hz
% windowStepF0 = 128; 
% f0Fs = audioSampleRate/windowStepF0;
% 
% usefulData = U5(10).dat(U5(10).iwa,:);
% 
% originalPitch = usefulData(:,3);
% originalTime = usefulData(:,5)/audioSampleRate;
% originalTime = originalTime-originalTime(1); %rerange the time from 0

%---------YAMAHA DATA-----
data = csvread('../Dataset/singing-f0-eval-dataset/clk_vt_ky01.pitch');
originalPitch = data(:,3); 
audioSampleRate = 44100;
pitchWindow = 441;
windowStepF0 = 441;
originalTime = (data(:,1)+pitchWindow/2)/audioSampleRate;

f0Fs = audioSampleRate/windowStepF0;
%-------------------------

%use the VB-GMM data
% load('VB_DATA.mat');
% originalTime = VB_DATA(:,1);
% originalPitch = VB_DATA(:,2);
% f0Fs = 1/(originalTime(2)-originalTime(1));

%using my data
% data = csvread('Huangjiangqin-1.csv');
% originalTime = data(:,1);
% originalPitch = data(:,2);
% f0Fs = 1/(originalTime(2)-originalTime(1));

%---------do interpolation for the pitch using spline function---------
%Since the data misses some data points, it is necessary to do
%interpolation.
interpolationF = f0Fs;  %interpolation frequency
newTime = [0:1/interpolationF:originalTime(end)]';
interpolatedSpitch = (interp1(originalTime,originalPitch,newTime,'spline'));
%----------------------------------------------------------------------

time = newTime;
Fs = interpolationF;
midiSpitch = interpolatedSpitch;


figure(1)
plot(originalTime,originalPitch);
xlabel('Time(s)');
ylabel('Pitch in semitone related to A5(440Hz)');

%-----------FDM parameters---------------
f_min = 2;  %f_min = 0, f_max = 20 for evaluation and discussion part of MM14 paper
f_max = 20; 
J = 4;
k_max = 4;  %the number of times we iterate the solution (to make it more accurate). You should only use the final iteration, because in theory that is the most accurate result.
            %k_max = 10 for MM14 paper
%--------------------------------------

%----------decision mechanism criteria---------------------
vibratoRateLimit = [4,9];   %the vibrato searching limit in Hz for decision tree
vibratoAmplitudeLimit = [0.10,NaN]; %the vibrato amplitude limit is for decision tree

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

    %remove the DC component  
    frame = midiSpitch(pin+1:pin+windowLength)-mean(midiSpitch(pin+1:pin+windowLength));
    %using FDM for each frame   
    [tempFk,tempD] = frameFDM3(frame,f0Fs,f_min,f_max,k_max);
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
midiSpitchNoVibrato = getVibratoFreePitch(time,originalPitch,vibratoCandidatesDT);   

save midiSpitchNoVibrato.mat midiSpitchNoVibrato;

figure(2)
subplot(2,1,1)
plot(newTime,midiSpitch);
hold on
% plot(timeF,vibratoIndicateDecisionTree,'g^');
% plot(timeF,vibratoIndicateProbability,'<r');
plot(newTime,midiSpitchNoVibrato);
% plot(newTime(1:end-1),midiSpitchNoVibrato);
hold off
xlim([time(1) time(end)]);
subplot(2,1,2)
%plot the detected vibrato
[row2,col2] = size(vibratoCandidatesDT);
hold on
for i = 1:row2
     plot([vibratoCandidatesDT(i,1),vibratoCandidatesDT(i,2)],[1.25,1.25],'LineWidth',3,'Color','Green');
end
[row3,col3] = size(vibratoCandidatesBR);
for i = 1:row3
     plot([vibratoCandidatesBR(i,1),vibratoCandidatesBR(i,2)],[2.50-1.125,2.50-1.125],'LineWidth',3,'Color','Red');
end
hold off
xlim([time(1) time(end)]);
