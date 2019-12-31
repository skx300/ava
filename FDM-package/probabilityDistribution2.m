%This is going to fit the data into normal distribution

%Find out the frames which contain vibrato and which do not contain vibrato
vibratoFrames = find(groundTruthIndicate == 2);
nonVibratoFrames = find(groundTruthIndicate ~= 2);


%------------fit the Kernel(Normal) Distribution into vibrato rate 
%and the amplitude of peak resonance-----------------
pdVR = fitdist(fdResonanceF(vibratoFrames)','Kernel');
x1_values = -5:0.1:30;
pdf1 = pdf(pdVR,x1_values);


%fit the Kernel(Normal) Distribution into the Amplitude of Peak Resonance
vibratoAmplitude = fdResonanceD(vibratoFrames);
vibratoAmplitude = vibratoAmplitude(find(vibratoAmplitude<3));
% vibratoAmplitude = log(vibratoAmplitude);
    
pdVA = fitdist(vibratoAmplitude','kernel');
x2_values = -2:0.01:3;
pdf2 = pdf(pdVA,x2_values);
%--------------------------------------------------------------------------

%----------fit the Kernel(Normal) Distribution into non vibrato rate
% and the amplitude of peak resonance---------------
pdNR = fitdist(fdResonanceF(nonVibratoFrames)','Kernel');
x3_values = -5:0.1:30;
pdf3 = pdf(pdNR,x3_values);

%fit the Kernel(Normal) Distribution into non vibrato the Amplitude of Peak
%Resonace
nonVibratoAmplitude = fdResonanceD(nonVibratoFrames);
nonVibratoAmplitude = nonVibratoAmplitude(find(nonVibratoAmplitude<3));
% nonVibratoAmplitude = log(nonVibratoAmplitude);
% nonVibratoAmplitude = nonVibratoAmplitude.*10000;

pdNA = fitdist((nonVibratoAmplitude)','Kernel');
x4_values =-2:0.01:3;
pdf4 = pdf(pdNA,x4_values);
%--------------------------------------------------------------------------

%----------save variables to .mat files-------------
save('pdVRFDM.mat','pdVR');
save('pdVAFDM.mat','pdVA');
save('pdNRFDM.mat','pdNR');
save('pdNAFDM.mat','pdNA');
%---------------------------------------------------

fontSize = 30;

% figure(1);
% subplot(2,2,1);
% histfit(fdResonanceF(vibratoFrames),201,'Kernel');
% title('Histogram and Kernel Estimated PDF of Vibrato part Rate');
% xlabel('Frequency(Hz)');
% xlim([0 20]);
% 
% subplot(2,2,3)
% plot(x1_values,pdf1,'LineWidth',2);
% title('PDF of Vibrato Rate');
% xlabel('Frequency(Hz)');
% ylabel('Probability');
% xlim([0 16]);
% hold on
% plot(x3_values,pdf3,'r','LineWidth',2);
% hold off
% hleg1 = legend('Vibrato Part[Pr(R|V)]','Non-Vibrato Part[Pr(R|N)]');
% 
% subplot(2,2,2);
% histfit(fdResonanceF(nonVibratoFrames),201,'Kernel');
% title('Histogram and Kernel Estimated PDF of non-Vibrato part Rate');
% xlabel('Frequency(Hz)');
% xlim([0 20]);
% 
% 
% figure(2)
% subplot(2,2,1)
% histfit(vibratoAmplitude,60,'Kernel');
% title('Histogram and Kernel Estimated PDF of Amplitude of Peak Resonance');
% 
% subplot(2,2,2)
% histfit(nonVibratoAmplitude,60,'Kernel');
% title('Histogram and Kernel Estimated PDF of Non-Vibrato Part of Amplitude of Peak Resonance');
% 
% subplot(2,2,3)
% plot(x2_values,pdf2,'LineWidth',2);
% title('Estimated PDF of Amplitude of Peak Resonance');
% xlabel('Amplitude');
% ylabel('Probability'); xlim([0 3]);
% hold on
% plot(x4_values,pdf4,'r','LineWidth',2);
% hold off
% hleg1 = legend('Vibrato Part[Pr(A|V)]','Non-Vibrato Part[Pr(A|N)]');


%-------------plot for ACM MM paper----------------
%erhu-4
figure(4)
subplot(1,2,1)
plot(x1_values,pdf1,'b-','LineWidth',2);
title('Estimated PDF for \it{F_H}','fontSize',fontSize,'FontWeight','bold');
xlabel('Frequency(Hz)','fontSize',fontSize);
ylabel('Probability','fontSize',fontSize);
xlim([0 16]);
hold on
plot(x3_values,pdf3,'r--','LineWidth',2);
hold off
hleg1 = legend('P(\it{F_H|V})','P(\it{F_H|\negV})');
set(gca, 'FontSize', 24);

subplot(1,2,2)
plot(x2_values,pdf2,'b-','LineWidth',2);
title('Estimated PDF for \it{A_H}','fontSize',fontSize,'FontWeight','bold');
xlabel('Amplitude','fontSize',fontSize);
ylabel('Probability','fontSize',fontSize); 
xlim([0 3]);
hold on
plot(x4_values,pdf4,'r--','LineWidth',2);
hold off
hleg1 = legend('P(\it{A_H|V})','P(\it{A_H|\negV})');
set(gca, 'FontSize', 24);


