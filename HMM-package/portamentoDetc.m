clear;
%Portamento detection

folderPath = 'dataset/';
fileName = 'Huangjiangqin-1_vamp_pyin_pyin_smoothedpitchtrack';
data = csvread([folderPath,fileName,'.csv']); 

stateRangeTransition = [-1,0,1]'; %the transition states: down, constant, up.

time = data(:,1);
pitchVibrato = data(:,2);

pitchFs = 1/(time(2)-time(1));

midiPitchOriginal = freqToMidi(pitchVibrato);
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

portaUpArea = NoteAggreBaseline((decodedHMMTransition == 3)',pitchFs);
portaUpArea = portaUpArea{1};
portaDownArea = NoteAggreBaseline((decodedHMMTransition == 1)',pitchFs);
portaDownArea = portaDownArea{1};


fontSize = 24;
figure(1);
subplot(2,1,1)
plot(time,midiPitchOriginal);
hold on
faceColor1 = [.5,0,0];
faceColor2 = [0,.5,0];
faceAlpha = 0.2;
axeInput = findobj('Type','axe');
axeInput = axeInput(1);
for i = 1:size(portaUpArea,1)
    fill([portaUpArea(i,1),portaUpArea(i,1)+portaUpArea(i,3),portaUpArea(i,1)+portaUpArea(i,3),portaUpArea(i,1)],...
            [axeInput.YLim(1),axeInput.YLim(1),axeInput.YLim(2),axeInput.YLim(2)],faceColor1,'EdgeColor','none','FaceAlpha',faceAlpha);
end
for i = 1:size(portaDownArea,1)
    fill([portaDownArea(i,1),portaDownArea(i,1)+portaDownArea(i,3),portaDownArea(i,1)+portaDownArea(i,3),portaDownArea(i,1)],...
            [axeInput.YLim(1),axeInput.YLim(1),axeInput.YLim(2),axeInput.YLim(2)],faceColor2,'EdgeColor','none','FaceAlpha',faceAlpha);
end
hold off
xlabel('Time(s)','FontSize',fontSize);
ylabel('Midi Note Number','FontSize',fontSize);
title('F0, Transition HMM','FontSize',fontSize);
legend('f0','Raw','Ground Truth');
set(gca, 'FontSize', fontSize);
xlim([time(1) time(end)]);
