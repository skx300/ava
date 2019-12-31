function exportPitchCurveFn( hObject,eventData  )
%EXPORTPITCHCURVEFN export the pitch curve
%   Detailed explanation goes here

    global data;
    
    savedFileName = [data.fileName,'_pitch.csv'];
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileName);
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        csvwrite([savedPathName,savedFileName],[data.pitchTime,data.pitch]);
    end
end

