function [sinSimilarity] = vibratoShape(data)    
%This is going to obtain the sinusoidal similarity of the vibrato shape by
%using the cross-correlation
%input:
%fileName: the file that contains the pitch contour in xlsx format
%output:
%sinSimilarity: the similariy value that how similar of the vibrato shape
%to the sinusoid with the same vibrato frequency

%     fileName = '\Erquanyingyue-Huangjiangqin\NoPortamento\vibrato48';
%     data = xlsread([fileName '.xlsx']);
    
    %indicates the vibrato start and end point by manually
    pitchStart = 1;
    pitchEnd = length(data(:,1));
    %-------------------------------
    
    time = data(pitchStart:pitchEnd,1);
    pitchFs = 1/(time(2)-time(1));  %get the pitch sampling rate
    
    %-----
    pitch = data(pitchStart:pitchEnd,2);
    %-----
%     spitch = smooth(pitch); %smooth the pitch, this will affect the
%     result of the function
    spitch = pitch;
    midiSpitch = 69+12*log2(spitch/440);
    
    vibratoFreePitch = smooth(midiSpitch,80,'rlowess');  %get the average pitch of the vibrato using Local regression using weighted linear least squares and a 1st degree polynomial model
    
    noDcVibrato = midiSpitch - vibratoFreePitch;    %block the DC of the vibrato, make it centre on zero
    
    %------------------------------------------------
    %do FFT and get the vibrato rate from the FFT
    window = hanning(length(spitch));
    
    NFFT = 4096;
    
    noDcVibratoFFT = (abs(fft(noDcVibrato.*window,NFFT)));
    vibratoMidiFFT = (abs(fft(midiSpitch.*window,NFFT)));
    
    [~,I] = max(noDcVibratoFFT(floor(4*NFFT/pitchFs):NFFT/2));     %only search the 2Hz to the first half of spectrum(pi,Nyquist Rate)
    vibratoRate = (I-1+4*NFFT/pitchFs) * pitchFs/NFFT;
    %--------------------------------------------------
    
    %create a sin wave with the same vibrato rate as the sine wave
    %frequency
    t = [0:1/pitchFs:time(length(time))-time(1)+1/pitchFs];  %sampling rate is 100Hz
    fSin = vibratoRate; %sin frequency in Hz
    sinWave = 1*sin(2*pi*fSin*time);
    
    sinWaveFFT = (abs(fft(sinWave.*window,NFFT)));
    
    %do the normalisation 
    vibratoMidiNoDcFFTNorm = noDcVibratoFFT/norm(noDcVibratoFFT);
    sinWaveFFTNorm = sinWaveFFT/norm(sinWaveFFT);
    
    %cross correlation for vibratoMidiNoDc and Sine wave with normalisation
    c = xcorr(noDcVibrato,sinWave,'coeff');
%     c = xcorr(noDcVibrato,noDcVibrato,'coeff');
    [maxC,maxIndex] = max(c);
%     disp([' Cross correlation index is: ',num2str(maxC)]);
    
    sinSimilarity = maxC; %return the similarity value
    
    %------------------------------------------------------------
    
    f = [0:pitchFs/NFFT:pitchFs/2];

    
%     figure(2)
%     subplot(3,1,1)
%     plot(time,midiSpitch,'linewidth',2);
%     hold on
%     plot(time,vibratoFreePitch,'red','linewidth',2);
%     hold off
%     title('Vibrato Fundamental Frequency and Average Fundamental Frequency in Midi Scale');
%     xlabel('Time(s)');
%     ylabel('Midi Number');
%     hleg1 = legend('Vibrato Fundamental Frequency','Average Fundamental Frequency');
%     xlim([time(1),time(end)]);
%     
%     subplot(3,1,2)
%     plot(time,noDcVibrato,'linewidth',2);
%     title('Vibrato Fundamental Frequqency Centred at 0(No DC)');
%     xlabel('Time(s)');
%     ylabel('Midi Number');
%     xlim([time(1),time(end)]);
%     
%     subplot(3,1,3)
%     plot(time,sinWave,'linewidth',2);
%     title('Sin Wave with the Frequency same as the Vibrato');
%     xlabel('Time(s)');
%     ylabel('Amplitude');
%     xlim([time(1),time(end)]);
%     
%     figure(3)
%     subplot(3,1,1)
%     plot(f,noDcVibratoFFT(1:length(noDcVibratoFFT)/2+1));
%     title('The Spectrum of the Vibrato without the DC in Midi Scale');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');
%     
%     subplot(3,1,2)
%     plot(f,vibratoMidiFFT(1:length(vibratoMidiFFT)/2+1));
%     title('The Spectrum of the Original Vibrato in Midi Scale');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');
%     
%     subplot(3,1,3)
%     plot(f,sinWaveFFT(1:length(sinWaveFFT)/2+1));
%     title('The Spectrum of the Sin Wave with Same Vibrato Rate');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');
%     
%     figure(4)
%     subplot(2,1,1)
%     plot(f,vibratoMidiNoDcFFTNorm(1:length(vibratoMidiNoDcFFTNorm)/2+1));
%     title('The Normalised Spectrum of the Vibrato without the DC in Midi Scale');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');
%     subplot(2,1,2)
%     plot(f,sinWaveFFTNorm(1:length(sinWaveFFTNorm)/2+1));
%     title('The Normalised Spectrum of the Sin Wave with Vibrato Rate');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');
%     
% 
%     figure(5)
%     plot(c,'linewidth',2);
%     hold on
%     plot(maxIndex,maxC,'ro','linewidth',2);
%     hold off
%     title('Normalised Cross Correlation for Vibrato Fundamental Frequency(No Dc) with its Sine Wave');
%     xlabel('Number of Samples');
%     ylabel('Normalised Similarity');
%     xlim([1,length(c)]);
end
