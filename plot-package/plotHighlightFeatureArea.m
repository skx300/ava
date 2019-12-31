function plotHighlightFeatureArea( patchFeatureArea,numFeatureSelected,newFeature)
%PLOTHIGHLIGHTVIBRATOAREA highlight the selected feature (vibrato,portamento) area in the pitch
%curve
%   Input
%   @patchFeatureArea: the patch list storing each vibrato area as a patch.
%   @numFeatureSelected: the number of the vibrato selected.
%   @newFeature: 1 means new vibrato, 0 means not new vibrato.
    
    if newFeature == 1
       faceColor = [.5 .0 .0]; 
    elseif newFeature == 0
       faceColor = [.5 .5 .5]; 
    end
    
    if isempty(patchFeatureArea) == 0
        %erase previous highlighted vibrato area or new vibrato area
        numPatch = size(patchFeatureArea,2);
        for i = 1:numPatch
            patchFeatureArea(i).FaceAlpha = 0.2;
            patchFeatureArea(i).FaceColor = [.5,.5,.5];
        end

        %highlight the current selected one
        patchFeatureArea(numFeatureSelected).FaceAlpha = 0.5;
        patchFeatureArea(numFeatureSelected).FaceColor = faceColor;
    end
end

