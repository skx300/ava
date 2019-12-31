function addPortamentoFn(hObject,eventData)
%ADDPORTAMENTOFN Add portamento

    global data;
    
    %binary variable show whether the new added portamento is valid or not
    %1: valide, 0: not valid
    validNewPortamento = 1;    
    rect = getrect(data.axePitchTabPortamento);
    
    newPortamentoStart = rect(1);
    newPortamentoEnd = rect(1) + rect(3);
    
    %----START of new portamento validation---------------
    %check the partly overlapping with exising portamentos
    if isfield(data,'portamentos') == 1
        for i = 1:size(data.portamentos,1)
           if (validNewPortamento == 1) && (newPortamentoStart >= data.portamentos(i,1) && newPortamentoStart <= data.portamentos(i,2)) ||...
                   (newPortamentoEnd >= data.portamentos(i,1) && newPortamentoEnd <= data.portamentos(i,2))
               validNewPortamento = 0;
               uiwait(msgbox('The new portamento is overlapping exisiting portamentos','Warning!','Error'));
               break;
           end
        end

        %check the coverage all of the exisiting portamentos
        for i = 1:size(data.portamentos,1)
           if (validNewPortamento == 1) && (newPortamentoStart <= data.portamentos(i,1) && newPortamentoEnd >= data.portamentos(i,2))
               validNewPortamento = 0;
               uiwait(msgbox('The new portamento is overlapping exisiting portamentos','Warning!','Error'));
               break;
           end
        end

        %check whether it is out of the scope of the recording
        if (validNewPortamento == 1) && ((newPortamentoStart < data.axePitchTabPortamento.XLim(1)) || ...
                (newPortamentoEnd > data.axePitchTabPortamento.XLim(2)))
            validNewPortamento = 0;
            uiwait(msgbox('The new portamento should be within the recording','Warning!','Error'));
        end
        
        %check whether the new added portamento is an area
        if (validNewPortamento == 1) && ((newPortamentoStart == newPortamentoEnd))
            validNewPortamento = 0;
            uiwait(msgbox('The new portamento should be an area!','Warning!','Error'));
        end  
    end
    %----END of new portamento validation---------------
    
   if validNewPortamento == 1
        if isfield(data,'portamentos') == 1
            % add the new portamento into the portamento array
            [data.portamentos,index] = sort([data.portamentos(:,[1 2]);newPortamentoStart,newPortamentoEnd]);
            indexNewPortamento = find(index(:,1) == size(index,1));
            data.portamentos(:,3) = data.portamentos(:,2)-data.portamentos(:,1); %duration

            %add the time-pitch into the portamentosDetail struct
            portamentoNames = fieldnames(data.portamentosDetail);
            for i = size(data.portamentos,1):-1:indexNewPortamento + 1
               data.portamentosDetail.(['passage',num2str(i)]) = data.portamentosDetail.(char(portamentoNames(i-1)));
            end
            timePitchNewPortamento = getPassages(data.pitchTime,data.pitchVFree,data.portamentos(indexNewPortamento,:),0);
            data.portamentosDetail.(['passage',num2str(indexNewPortamento)]) = timePitchNewPortamento.passage1;

    %         %Get the individual vibrato time and pitch vector 
    %         %vibratosDetail:[time from 0:pitch:orginal time]
    %         data.portamentosDetail = getPassages(data.pitchTime,data.pitch,data.portamentos,0);
            
            %-----START of calculating the new para-----------
            if isfield(data,'portamentosDetailLogistic')
                portamentoNames = fieldnames(data.portamentosDetail);        
                TimePitchNewPortamento = data.portamentosDetail.(char(portamentoNames(indexNewPortamento)));

                %the logistic model fitting
                [fittedPortamentoLogistic6,~] = createGeneralLogistic6Fit(TimePitchNewPortamento(:,1),freqToMidi(TimePitchNewPortamento(:,2)));
                portamentoParaNew = coeffvalues(fittedPortamentoLogistic6);

                %add the new para into the para array
                data.portamentoPara = [data.portamentoPara(1:indexNewPortamento-1,:);portamentoParaNew;data.portamentoPara(indexNewPortamento:end,:)];
                
                %add the new fitted line vector
                %-------get the fitted line-----------
                A = data.portamentoPara(indexNewPortamento,1); 
                B = data.portamentoPara(indexNewPortamento,2);
                G = data.portamentoPara(indexNewPortamento,3); 
                L = data.portamentoPara(indexNewPortamento,4); 
                M = data.portamentoPara(indexNewPortamento,5); 
                U = data.portamentoPara(indexNewPortamento,6);
                portamentosDetailLogisticNew = MidiToFreq( L + (U-L)./((1+A*exp(-G*(TimePitchNewPortamento(:,1)-M))).^(1/B)));
                %----------------------   
                for i = size(data.portamentos,1):-1:indexNewPortamento + 1
                   data.portamentosDetailLogistic.(['passage',num2str(i)]) = data.portamentosDetailLogistic.(char(portamentoNames(i-1)));
                end                
                data.portamentosDetailLogistic.(['passage',num2str(indexNewPortamento)]) = portamentosDetailLogisticNew;
            end
            %-----END of calculating the new para-----------
        else
            %the new added portamento is the first portamento
            indexNewPortamento = 1;
            data.portamentos = zeros(1,3);
            data.portamentos(:,[1 2]) = [newPortamentoStart,newPortamentoEnd];
            data.portamentos(:,3) = data.portamentos(:,2)-data.portamentos(:,1); %duration
           
            data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos(indexNewPortamento,:),0);
            
        end
        
        
        data.numPortamentoSelected = indexNewPortamento;
        

        %plot the new created portamento
        newPatchPortamentoArea = plotNewFeatureArea(data.portamentos(data.numPortamentoSelected,:),data.axePitchTabPortamento);
        if isfield(data,'patchPortamentoArea') == 1
            %add the new patch into patch list
            data.patchPortamentoArea = [data.patchPortamentoArea(1:indexNewPortamento-1),newPatchPortamentoArea,data.patchPortamentoArea(indexNewPortamento:end)];
        else
            data.patchPortamentoArea = newPatchPortamentoArea;
        end
            
        %higlight the selected portamento
        plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);
    
        %plot the portamento num in the listbox
        plotFeatureNum(data.portamentos,data.portamentoListBox);
        
        %show the highlighted num of portamento in portamento listbox
        data.portamentoListBox.Value = data.numPortamentoSelected;
        
        %show individual portamento in the sub axes
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi) 
        
        %plot the portamento logisitic fitting line and portamento para
        %in the sub axes
        if isfield(data,'portamentosDetailLogistic')  
            %plot the portamento Logistic fitting line
            plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
            data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);

            %plot the portamneto statistics
            plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected)            
        end
    end

end

