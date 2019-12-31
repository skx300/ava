function [ vibratoIndicate ] = BayesRule(peakFrequency, peakAmplitude,indicateSign,vibratoProbabilityCriterion,methodName)
%BAYESRULE Bayes' Rule classfication
%   Input:
%   @peakFrequency: the frequency of peak for each frame
%   @peakAmplitude: the amplitude of peak for each frame
%   @groundTruthIndicate: the ground truth vector indicating whether each
%   frame has vibrato or not.
%   @groundTruthIndicateSign: the sign to indicate a vibrato frame
%   @indicateSign: the sign to indicate a vibrato. Non-vibrato is indicated
%   as 0.
%   @vibratoProbabilityCriterion:
%   @methodName: the vibrato detection method name. e.g:
%   'FDM','Herrera1998','Ventura2012'
%   Output:
%   @vibratoIndicate: vector to indicate each frame has vibrato or not.
    PrV = 0.5;
    PrN = 0.5;
    
    %----load the distribution-------------------
    load(['pdVR',methodName,'.mat']);
    load(['pdNR',methodName,'.mat']);
    if(isempty(peakAmplitude)==0)
        %when the peak amplitude is used.
        load(['pdVA',methodName,'.mat']);
        load(['pdNA',methodName,'.mat']);
    end
    %--------------------------------------------
    
    PrRV = pdf(pdVR,peakFrequency)*0.1;  %Pr(R|V)
    PrRN = pdf(pdNR,peakFrequency)*0.1;  %Pr(R|N)
    if(isempty(peakAmplitude)==0)
        %when the peak amplitude is used.
        PrAV= pdf(pdVA,peakAmplitude)*0.01;  %Pr(A|V)
        PrAN = pdf(pdNA,peakAmplitude)*0.01; %Pr(A|N)
    end
    
    PrVR = PrRV*PrV./(PrRV*PrV+PrRN*PrN);   %Pr(V|R) = Pr(R|V)*Pr(V)/Pr(R)=Pr(R|V)*Pr(V)/(Pr(R|V)*Pr(V)+Pr(R|N)*Pr(N))
    if(isempty(peakAmplitude)==0)
        %when the peak amplitude is used.
        PrVA = PrAV*PrV./(PrAV*PrV+PrAN*PrN);   %Pr(V|A) = Pr(A|V)*Pr(V)/Pr(A)=Pr(A|V)*Pr(V)/(Pr(A|V)*Pr(V)+Pr(A|N)*Pr(N))
    else
        PrVA = 1;
    end
    vibratoProbability = PrVR.*PrVA;
    
    %----for Bayes' Ratio--------------
%     testRatioR = (PrRV*PrV)./(PrRN*PrN);
%     testRatioR(find(isnan(testRatioR))) = 0;
%     
%     if(isempty(peakAmplitude)==0)
%         testRatioA = (PrAV*PrV)./(PrAN*PrN);
%         testRatioA(find(isnan(testRatioA))) = 0;
%     else
%         testRatioA = 1;
%     end
%     
%     testRatio = testRatioR.*testRatioA;
    %-----------------------------------
    
    frameNum = length(peakFrequency);
    vibratoIndicate = zeros(1,frameNum);
    vibratoIndicate(vibratoProbability >= vibratoProbabilityCriterion) = indicateSign;
%     vibratoIndicate(testRatio > 1.5) = indicateSign;
    
end

