function [vibratoParameters] = vibratoRateExtent( data )
%VIBRATORATEEXTENT is going to return the vibrato parameters i.e: average
%vibrato rate and average vibrato extent etc.
%   Input
%   @datta: the vibrato data in 2 columns. The first is the time vector and
%   the second is the relevant f0 data.
%   Output
%   @vibratoParameters: containes
%   [averageVibratoRate (Hz),averageVibratoExtent (cent),stdVibratoRate (Hz),stdVibratoExtent (cent)]



%     fileName = 'Erquanyingyue-Huangjiangqin/NoPortamento/vibrato39';
%     
%     data = xlsread([fileName '.xlsx']);
%     
    time = data(:,1);
    pitchFs = 1/(time(2)-time(1));  %get the pitch sampling rate
    time = [0:length(time)-1]/pitchFs;
    spitch = data(:,2);
%     spitch = smooth(pitch); %smooth the pitch
    
    %vibrato empirical parameters
    tRange = [0.1 0.25];   %the vibrato period limit in second
    fRange = [0.10 0.6];  %the vibrato extent range limit in cents (100cents = 1 semitone)(from the mean to the peak), 
                            %this is one condtion to detect the vibrato
    %tError = 0.005;     %the error for vibrato period prediction error
    
    %get the peaks and troughs of the pitch contour
    [PEKSAll,timePekAll] = getPeakTrough(spitch,time);
    
    
    %----------------------------------------------
    %Algorithm to detect the vibrato is going there
    deltaTime = zeros(length(timePekAll),1);    %store the interval time for consective peaks
    deltaFrequency = zeros(length(timePekAll),1);   %store the frequency difference for consective peaks
    deltaCents = zeros(length(timePekAll),1);   %store the cents difference for consective peaks
    deltaCents2 = zeros(length(timePekAll),1);  %store the cents differnece for consective peaks use the formula:deltaCents2 = 1200*log2(f(n)/f(n-1))
    
    %get the inverval time between peaks
    for n = 1:(length(timePekAll))
        if (n == 1)
            deltaTime(n) = 0;
        else
            deltaTime(n) = timePekAll(n)-timePekAll(n-1);
        end
    end
    
    %get the frequency differnce and the cents difference between peaks
    for n = 1:(length(timePekAll))
        if (n == 1)
            deltaFrequency(n) = 0;
        else
            deltaFrequency(n) = abs(PEKSAll(n) - PEKSAll(n-1));
            deltaCents2(n) = abs(1200*log2(PEKSAll(n)/PEKSAll(n-1)));   %calcualte the cents   
        end
    end
    
    %get the vibrato time that detected by using interval time and cents difference between peaks
    %vibrato segmentation
    vibratoTime = zeros(length(timePekAll),1);
    vibratoSeg = zeros(length(PEKSAll),1);
    i = 1;  %number of vibrato
    for n = 1:length(deltaTime)
        if(deltaCents2(n)>(fRange(2)*2))
            %vibrato segmentation
            %if the frequency difference between two adjacent peaks, then
            %we assume it is a segmentation
            i = i + 1;
        end
        if (deltaTime(n) >= (tRange(1)/2))&&(deltaTime(n) <= (tRange(2)/2))&&(deltaCents(n) >= (fRange(1)*2))&&(deltaCents(n) <= (fRange(2)*2))
            vibratoTime(n-1,i) = timePekAll(n-1);
            vibratoSeg(n-1,i) = 1;
            vibratoTime(n,i) = timePekAll(n);
            vibratoSeg(n,i) = 1;
        end
    end
    %Algorithm to detect the vibrato is end
    %----------------------------------------------
    
    instantVibratoRate = 1./(deltaTime*2);  %Calculate the instant vibrato rate
    instantVibratoExtent = deltaCents2./2;  %Calculate the instant vibrato extent
    %calcualte the average vibrato rate in Hz
    averageVibratoRate = mean(instantVibratoRate(find(instantVibratoRate<50)));
    %calculate the average vibrato extent in semitone
    averageVibratoExtent = mean(instantVibratoExtent(find(instantVibratoExtent)));
    %vibrato rate standard deviation
    stdVibratoRate = std(instantVibratoRate(find(instantVibratoRate<50)));
    %vibrato extent standrade deviation
    stdVibratoExtent = std(instantVibratoExtent(find(instantVibratoExtent)));
    
    vibratoParameters = [averageVibratoRate,averageVibratoExtent,stdVibratoRate,stdVibratoExtent];
    
%     disp(['Average vibrato rate: ',num2str(averageVibratoRate),' Hz']);
%     disp(['Average vibrato extent: ',num2str(averageVibratoExtent),' semitone']);
%     disp(['Vibrato rate standard deviation: ',num2str(stdVibratoRate),' Hz']);
%     disp(['Vibrato extent standard deviation: ',num2str(stdVibratoExtent),' semitone']);
%     disp([num2str(averageVibratoRate),' ',num2str(averageVibratoExtent),' ',num2str(stdVibratoRate),' ',num2str(stdVibratoExtent)]);
    
%     plot the pitch and local maximum and local minimum
%     figure(1)
%     subplot(3,1,1)
%     plot(time,spitch);
%     %plot(time,pitch,'red');
%     title('Pitch Contour Obtained from Praat');
%     xlabel('Time(s)');
%     ylabel('Frequency(Hz)');
%     xlim([0 time(length(time))]);
%     hold on;
%     %plot(time2,spitch2,'red');
%     plot(timePekAll,PEKSAll,'o');
%     %plot(timePekAll,semitones,'red');
%     %plot(timePekAll,vibratoTime);
%     hold off;
%     
%     %plot the interval time
%     subplot(3,1,2)
%     plot(timePekAll(2:end),deltaTime(2:end));
%     title('Interval Time between Consective Peaks and Troughs');
%     xlabel('Time(s)');
%     ylabel('Interval Time(s)');
%     xlim([0 time(length(time))]);
%     ylim([0 0.25]);
%     hold on
%     %plot period boundary to detect the vibrato
% %     plot([time(1) time(length(time))],[tRange(1)/2 tRange(1)/2],'magenta');   
% %     plot([time(1) time(length(time))],[tRange(2)/2 tRange(2)/2],'magenta');
%     hold off
%     
%    
%     %plot the cents difference
%     subplot(3,1,3)
%     plot(timePekAll(2:end),deltaCents2(2:end));
%     title('Cents Difference between Consective Peaks and Troughs');
%     xlabel('Time(s)');
%     ylabel('Cents(*100)');
%     xlim([0 time(length(time))]);
%     ylim([0.1 2]);
%     hold on
%     %plot frequency (in cents) boudary to detect the vibrato
% %     plot([time(1) time(length(time))],[fRange(1)*2 fRange(1)*2],'magenta'); 
% %     plot([time(1) time(length(time))],[fRange(2)*2 fRange(2)*2],'magenta'); 
%     hold off
%     
%     figure(2)
%     subplot(3,1,1)
%     plot(time,spitch);
%     title('Pitch');
%     xlabel('Time(s)');
%     ylabel('Frequency(Hz)');
%     xlim([0 time(length(time))]);
%     
%     subplot(3,1,2)
%     plot(timePekAll,instantVibratoRate);
%     title(['Instant Vibrato Rate']);
%     xlabel('Time(s)');
%     ylabel('Vibrato Rate(Hz)');
%     xlim([0 time(length(time))]);
%     ylim([0 15]);
%     
%     subplot(3,1,3)
%     plot(timePekAll(2:end),instantVibratoExtent(2:end));
%     title(['Instant Vibrato Extent']);
%     xlabel('Time(s)');
%     ylabel('Semitone');
%     xlim([0 time(length(time))]);
%     %ylim([0 0.25]);
%     
%     
%     figure(3)
%     plot(time,spitch,'linewidth',2);
%     title('Vibrato Fundamental Frequency');
%     xlabel('Time(s)');
%     ylabel('Frequency(Hz)');
%     xlim([0 time(length(time))]);
%     hold on
%     %plot(time,smooth(noVibratoPitch),'green');
%     %plot(time,smooth(spitch,65,'rlowess'),'red');
%     %plot(timePekAll,vibratoAveCircle,'green');
%     plot(timePekAll,PEKSAll,'o','linewidth',2);
%     hold off
%     %hleg1 = legend('Original Pitch','Vibrato-free Pitch');
%     figure_FontSize=12;
% %     set(get(gca,'XLabel'),'FontSize',figure_FontSize,'Weight','Bold','Vertical','top');
%     set(get(gca,'YLabel'),'FontSize',figure_FontSize,'Vertical','middle');
%     set(get(gca,'title'),'FontSize',figure_FontSize,'Vertical','middle');
%     set(findobj('FontSize',12),'FontSize',figure_FontSize);
    
end
