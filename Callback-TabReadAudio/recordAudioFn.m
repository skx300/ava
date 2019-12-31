function recordAudioFn(hObject,eventData)
%RECORDAUDIOFN Record audio from the user
    global data;
    
    %create the obect for recording audio
    data.recordFs = 44100;
    %16bit, 1 channel, 0th input device (use audiodevinfo for information)
    data.recorder = audiorecorder(data.recordFs,16,1,0);
    
    
    %------create a dialog to indicating the starting of the recording-----
    d = dialog('Unit','Normalized','Position',[0.4 0.4 0.2 0.2],'Name','Record Audio');
    
    fontSize = 20;
    data.AudioRecText = uicontrol('Parent',d,'Unit','Normalized',...
               'Style','text',...
               'Position',[0 0.7 1 0.2],...
               'String','Recording','FontSize',16);
           
    data.elapsedTimeTxt = uicontrol('Parent',d,'Unit','Normalized',...
               'Style','text',...
               'Position',[0 0.5 1 0.2],...
               'String','0s','FontSize',fontSize,'HorizontalAlignment','center');
           
    data.audioRecStartBn = uicontrol('Parent',d,'Unit','Normalized',...
               'Position',[0.1,0.2,0.2,0.25],...
               'String','Start',...
               'Callback',@startRecordAudioFn,'FontSize',12);

    data.audioRecFinishBn = uicontrol('Parent',d,'Unit','Normalized',...
               'Position',[0.3,0.2,0.2,0.25],...
               'String','Finish',...
               'Callback',@finishRecordAudioFn,'FontSize',12,'Enable','off');
    data.audioRecPlayBn = uicontrol('Parent',d,'Unit','Normalized',...
               'Position',[0.5,0.2,0.2,0.25],'String','Play','FontSize',12,...
               'Enable','off','Callback',@playRecordAudioFn);
    data.audioRecCancelBn = uicontrol('Parent',d,'Unit','Normalized',...
               'Position',[0.7,0.2,0.2,0.25],'String','Cancel','FontSize',12,...
               'Callback','delete(gcf)');
           

    %----------------------------------------------------------------------
    
end

function timeChangeRecordAudioFn(hObject,eventData)
    global data;
    %show the elapsed time
    data.elapsedTimeTxt.set('String',[num2str(round((data.recorder.TotalSamples/data.recordFs)*100)/100,'%.2f'),'s']);
end

function startRecordAudioFn(hObject,eventData)
    global data;
    
    data.AudioRecText.set('String','Recording is starting...');
    data.audioRecFinishBn.Enable = 'on';
      
    data.recorder.TimerFcn = @timeChangeRecordAudioFn;
    data.recorder.TimerPeriod = .1; % period of the timer in seconds

    %start recording
    record(data.recorder);
end

function finishRecordAudioFn(hObject,eventData)
    global data;
    
    data.AudioRecText.set('String','Recording is finished!');
    stop(data.recorder);
    
    data.audio = getaudiodata(data.recorder);
    
    data.time = (1:data.recorder.TotalSamples)/data.recordFs;
    data.fs = data.recordFs;
    %plot the audio waveform
    plotAudio(data.time,data.audio,data.axeWave,'New recorded audio')
    
    data.fileName  = 'New_recorded_audio';
    data.fileNameSuffix = [data.fileName,'.wav'];
    audiowrite(data.fileNameSuffix,data.audio,data.fs);
    data.filePath = [pwd,'/']; %get the current path for the recorded audio
    
    data.audioRecPlayBn.Enable = 'on';
    
end

function playRecordAudioFn(hObject,eventData)
    global data;
    
%     play(data.recorder);
    soundsc(data.audio,data.fs);
    
    
end


