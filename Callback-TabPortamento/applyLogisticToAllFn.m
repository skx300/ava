function applyLogisticToAllFn(hObject,eventData)
%APPLYLOGISTICTOALLFN apply Logistic model to all portamentos

    global data;
    portamentosName = fieldnames(data.portamentosDetail);
    
    %store the original Logistic 6 parameters (A,B,G,M,L,U)
    data.portamentoPara = zeros(length(portamentosName),6);
    %sotre the post-processed portamento paras according to the original
    %Logistic parameters [slope:transition duration:transition interval:
    %Norm inflection Point Time:Norm inflection Point Pitch:inflection Point Time:
    %inflection point in midi]
    data.portamentoParaPost = zeros(length(portamentosName),5);
    
    data.portamentosDetailLogistic = struct();
    for i = 1:length(portamentosName)
%     for i = 1:10
        portamentoXY = data.portamentosDetail.(char(portamentosName(i)));
        
        %the logistic model fitting
        [fittedPortamentoLogistic6,~] = createGeneralLogistic6Fit(portamentoXY(:,1),freqToMidi(portamentoXY(:,2)));
        %Get the Logistic paras
        data.portamentoPara(i,:) = coeffvalues(fittedPortamentoLogistic6);
        
        %add the new fitted line vector
        %-------get the fitted line-----------
        A = data.portamentoPara(i,1); 
        B = data.portamentoPara(i,2);
        G = data.portamentoPara(i,3); 
        L = data.portamentoPara(i,4); 
        M = data.portamentoPara(i,5); 
        U = data.portamentoPara(i,6);
        portamentoYLogistic = L + (U-L)./((1+A*exp(-G*(portamentoXY(:,1)-M))).^(1/B));
        data.portamentosDetailLogistic.(char(portamentosName(i))) = MidiToFreq(portamentoYLogistic);
        %----------------------   
        
        %----the post processed portamento para-----
        %1.slope
        data.portamentoParaPost(i,1) = G;
        
        %2.transition duration
        diffFittedYLogistic = [0;abs(diff(portamentoYLogistic))];
        transitionDuration = portamentoXY(diffFittedYLogistic>0.005,1);  %find the transition interval for one transition
        if isempty(transitionDuration) == 1
            transitionDuration = 0;
        end
        %the transition interval in sec
        data.portamentoParaPost(i,2) = transitionDuration(end)-transitionDuration(1);
    
        %3.transition interval in semitone
        data.portamentoParaPost(i,3) = abs(U-L);
        
        %4.normalized Timing of the inflection point
        %reflectionPoint = ln(A/B)/G+M;
%         InflectionPointTime = log(fittedDataLogistic6(i,1)./fittedDataLogistic6(i,2))./(fittedDataLogistic6(i,3))+fittedDataLogistic6(i,5);
        inflectionPointTime = log(A/B)/G+M;
        %the normalised inflection point in time
        data.portamentoParaPost(i,4) = (inflectionPointTime-transitionDuration(1))/data.portamentoParaPost(i,2);  
        
        %5.normalized pitch of the inflection point
        inflectionPointPitch =  L + (U-L)/((1+A*exp(-G*(inflectionPointTime-M)))^(1/B));
        %the normliased infelction point in pitch
        data.portamentoParaPost(i,5) = (inflectionPointPitch-min([L,U]))/data.portamentoParaPost(i,3);       
        %-----------------------------------------
        
        
        disp(['Portamento: ',num2str(i),'/',num2str(length(portamentosName))]);
    end
    disp('Logistic Modeling is finished!');
    
    %plot the portamento Logistic fitting line
    plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
    data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);
    
    %plot the portamneto statistics
    plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected);

end

