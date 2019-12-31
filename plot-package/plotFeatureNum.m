function plotFeatureNum( features, featureListBox)
%PLOTVIBRATONUM plot the feature (vibrato or portamento) num in the corresponding listbox
%   Input:
%   @vibratos: [vibrato start time:end time:duration]
%   @vibratoListBox: uicontrl - listbox

    vibratoNumberList = cell(size(features,1),1);
    for i = 1:size(features,1)
        vibratoNumberList{i} = num2str(i);
    end
    set(featureListBox,'String',vibratoNumberList);
    
end

