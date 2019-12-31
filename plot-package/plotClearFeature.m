function plotClearFeature(featureName)
%plotClearFeature Clear feature, i.e. vibrato or portamenti 
%Input
%@featureName: 'Vibrato' or 'Portamento'

    global data;
    
    if strcmp(featureName,'Vibrato')
        features = 'vibratos';
        featuresDetail = 'vibratosDetail';
        patchFeatureAreaName = 'patchVibratoArea';
        numFeatureSelected = 'numVibratoSelected';
        featureListBox = data.vibratoListBox;
        axeFeature= data.axePitchTabVibratoIndi;
    elseif strcmp(featureName,'Portamento')
        features = 'portamentos';
        featuresDetail = 'portamentosDetail';
        patchFeatureAreaName = 'patchPortamentoArea';
        numFeatureSelected = 'numPortamentoSelected';
        featureListBox = data.portamentoListBox;
        axeFeature= data.axePitchTabPortamentoIndi;
    end
    
    if isfield(data,features) == 1
       data = rmfield(data,features); 
    end
    if isfield(data,featuresDetail) == 1
       data = rmfield(data,featuresDetail); 
    end
    if isfield(data,patchFeatureAreaName) == 1
        %delete the patches from the plot
       delete(data.(char(patchFeatureAreaName)));
       data = rmfield(data,patchFeatureAreaName); 
    end
    if isfield(data,numFeatureSelected) == 1
       data = rmfield(data,numFeatureSelected); 
    end
    
    %clear the content in the listbox
    plotFeatureNum([],featureListBox);
    
    %clear the axes for individual feature
    cla(axeFeature,'reset');
end

