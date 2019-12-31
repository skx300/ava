function changePitchDetection(hObject,eventData)
%CHANGEPITCHDETECTION Change the method name for pitch detection method
%   

    global data;
    
    pressedNum = eventData.Source.Value;
    pitchMethodList = eventData.Source.String;
    
    data.pitchMethod = pitchMethodList{pressedNum};

end

