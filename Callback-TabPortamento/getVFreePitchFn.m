function getVFreePitchFn(hObject,eventData)
%GETVFREEPITCHFN return vibrato free pitch curve for portmaneto detection
    global data;
    
    %clear portamentos;
    plotClearFeature('Portamento');
    
    data.pitchVFree = getVibratoFreePitch(data.pitchTime,data.pitch,data.vibratos);
    plotPitch(data.pitchTime,data.pitchVFree,data.axePitchTabPortamento);

end

