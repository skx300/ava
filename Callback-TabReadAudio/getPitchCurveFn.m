function getPitchCurveFn(hObject,eventData)
%GETPITCHCURVE get the pitch curve using pyin method and plot pitch curve 
    global data;
    
    
    if strcmp(data.pitchMethod,'Yin') == 1
        %--------using YIN method------------------
        P.hop = 256;
        h = waitbar(0,'Detecting pitch using YIN...');
        yinOutput = yin([data.filePath,data.fileNameSuffix],P); 
        close(h);
        data.pitch = ((2.^yinOutput.f0)*440)'; %convert YIN's original output F0 from 440Hz octave to Hz, colum vector
    %     data.pitch(yinOutput.ap>0.4) = nan; %raw remove non-pitched sound
        data.pitchTime = ((1:length(data.pitch))/(yinOutput.sr/yinOutput.hop));   
        %------------------------------------------
        
    elseif strcmp(data.pitchMethod,'Pyin(Matlab)') == 1
        %--------using PYIN method MATLAB------------------
        [data.pitch,data.pitchTime] = getPitchPyin([data.filePath,data.fileNameSuffix]);
        %------------------------------------------
        
    elseif strcmp(data.pitchMethod,'Pyin(Tony)') == 1
    %use pYin to get f0
    %use the changed parameters in pyinParameters.n3 file.
    %force to override the existing file.
%     system(['./sonic-annotator -t pyinParameters.n3 ',data.filePath,data.fileNameSuffix,' -w csv --csv-force']);
    
%     system(['./sonic-annotator -t pyinParameters.n3 ',data.filePath,data.fileNameSuffix,' -w csv']);
    %------using pyin sv plugin---------------
%     get the cmd output and directly use the cmd output
%     shoud add the dumb quotes before and after file names to allow the
%     file name has spaces
    h = waitbar(0,'Detecting pitch using Pyin(Tony)...');
    [~,cmdout] = system(['./sonic-annotator -t pyinParameters.n3 "',data.filePath,data.fileNameSuffix,'" -w csv --csv-stdout'],'-echo');
    C = strsplit(cmdout,',');
    data.pitchTime = zeros((length(C)-2)/2,1);
    data.pitch = zeros((length(C)-2)/2,1);
    for i = 3:2:length(C);
        data.pitchTime(floor(i/2),1) = str2double(C{i});
        data.pitch(floor(i/2),1) = str2double(C{i+1});
    end
    close(h);
    %---------------------------------------
        
    end
    
    %make it to column vector
    if iscolumn(data.pitchTime) == 0
        data.pitchTime = data.pitchTime';
    end
    
    if iscolumn(data.pitch) == 0
        data.pitch = data.pitch';
    end
    
    %delete all NaNs in pitchTime and pitch vectors
%     data.pitchTime(isnan(data.pitchTime)) = [];
%     data.pitch(isnan(data.pitch)) = [];
    
    %clear vibrato
    plotClearFeature('Vibrato');

    plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio);
    plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato);

end

