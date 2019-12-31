function addVibratoFn(hObject,eventData)
%ADDVIBRATOFN Add vibrato

    global data;
    
    %binary variable show whether the new added vibrato is valid or not
    %1: valide, 0: not valid
    validNewVibrato = 1;    
    rect = getrect(data.axePitchTabVibrato);
    
    newVibratoStart = rect(1);
    newVibratoEnd = rect(1) + rect(3);
    
    %----START of new vibrato validation---------------
    %check the partly overlapping with exising vibratos
    if isfield(data,'vibratos') == 1
        for i = 1:size(data.vibratos,1)
           if (validNewVibrato == 1) && (newVibratoStart >= data.vibratos(i,1) && newVibratoStart <= data.vibratos(i,2)) ||...
                   (newVibratoEnd >= data.vibratos(i,1) && newVibratoEnd <= data.vibratos(i,2))
               validNewVibrato = 0;
               uiwait(msgbox('The new vibrato is overlapping exisiting vibratos!','Warning!','Error'));
               break;
           end
        end

        %check the coverage all of the exisiting vibratos
        for i = 1:size(data.vibratos,1)
           if (validNewVibrato == 1) && (newVibratoStart <= data.vibratos(i,1) && newVibratoEnd >= data.vibratos(i,2))
               validNewVibrato = 0;
               uiwait(msgbox('The new vibrato is overlapping exisiting vibratos!','Warning!','Error'));
               break;
           end
        end

        %check whether it is out of the scope of the recording
        if (validNewVibrato == 1) && ((newVibratoStart < data.axePitchTabVibrato.XLim(1)) || ...
                (newVibratoEnd > data.axePitchTabVibrato.XLim(2)))
            validNewVibrato = 0;
            uiwait(msgbox('The new vibrato should be within the recording!','Warning!','Error'));
        end
        
        %check whether the new added vibrato is an area
        if (validNewVibrato == 1) && ((newVibratoStart == newVibratoEnd))
            validNewVibrato = 0;
            uiwait(msgbox('The new vibrato should be an area!','Warning!','Error'));
        end        
    else
        %if there is no vibrato
        validNewVibrato = 0;
        uiwait(msgbox('Please click Get Vibrato(s) button! It is necessary to run FDM-based vibrato detection before adding vibrato.','Warning!','Error'));
    end
    %----END of new vibrato validation---------------
    
    if validNewVibrato == 1
        if isfield(data,'vibratos') == 1
            % add the new vibrato into the vibrato array
            [data.vibratos,index] = sort([data.vibratos(:,[1 2]);newVibratoStart,newVibratoEnd]);
            indexNewVibrato = find(index(:,1) == size(index,1));
            data.vibratos(:,3) = data.vibratos(:,2)-data.vibratos(:,1); %duration

            %add the time-pitch into the vibratosDetail struct
            vibratoNames = fieldnames(data.vibratosDetail);
            for i = size(data.vibratos,1):-1:indexNewVibrato + 1
               data.vibratosDetail = setfield(data.vibratosDetail,['passage',num2str(i)],getfield(data.vibratosDetail, char(vibratoNames(i-1))));
            end
            timePitchNewVibrato = getPassages(data.pitchTime,data.pitch,data.vibratos(indexNewVibrato,:),0);
            data.vibratosDetail = setfield(data.vibratosDetail,['passage',num2str(indexNewVibrato)],timePitchNewVibrato.passage1);

    %         %Get the individual vibrato time and pitch vector 
    %         %vibratosDetail:[time from 0:pitch:orginal time]
    %         data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);
    
            vibratoNames = fieldnames(data.vibratosDetail);
            %-----START of calculating the new para-----------
            vibratosParaFDMNewVibrato = getVibratoParaFDM2(data.vibratos(indexNewVibrato,:),data.FDMtime,data.FDMoutput);
            vibratoTimePitchNewVibrato = getfield(data.vibratosDetail, char(vibratoNames(indexNewVibrato)));
            vibratoParaMaxMinNewVibrato = vibratoRateExtent(vibratoTimePitchNewVibrato(:,[1,2]));
            vibratosSSNewVibrato = vibratoShape(vibratoTimePitchNewVibrato(:,[1,2]));

            vibratosParaFDMNewVibrato = [vibratosParaFDMNewVibrato,vibratosSSNewVibrato];
            vibratoParaMaxMinNewVibrato = [vibratoParaMaxMinNewVibrato,vibratosSSNewVibrato];
            %add the new para into the para array
            data.vibratoPara{1} = [data.vibratoPara{1}(1:indexNewVibrato-1,:);vibratosParaFDMNewVibrato;data.vibratoPara{1}(indexNewVibrato:end,:)];
            data.vibratoPara{2} = [data.vibratoPara{2}(1:indexNewVibrato-1,:);vibratoParaMaxMinNewVibrato;data.vibratoPara{2}(indexNewVibrato:end,:)];
            %-----END of calculating the new para-----------
        else
            %the new added vibrato is the first vibrato
            indexNewVibrato = 1;
            data.vibratos = zeros(1,3);
            data.vibratos(:,[1 2]) = [newVibratoStart,newVibratoEnd];
            data.vibratos(:,3) = data.vibratos(:,2)-data.vibratos(:,1); %duration
           
            data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos(indexNewVibrato,:),0);
            
            %----START of getting vibrato para-------
            %vibratosParaFDM: [vibrato rate:vibrato extent]
            vibratosParaFDM = getVibratoParaFDM2( data.vibratos,data.FDMtime,data.FDMoutput );
            %get vibrato rate, extent(using max-min method) vibrato sinusoid similarity for all passages
            vibratoNames = fieldnames(data.vibratosDetail);
            %vibratoParaMin: [rate, extent, std rate, std extent, SS]
            vibratoParaMaxMin = zeros(length(vibratoNames),5);
            vibratosSS = zeros(length(vibratoNames),1);
            for i = 1:length(vibratoNames)
                vibratoTimePitch = getfield(data.vibratosDetail, char(vibratoNames(i)));
                %sinusoid similarity
                vibratosSS(i) = vibratoShape(vibratoTimePitch(:,[1,2]));

                vibratoParaMaxMin(i,[1:4]) = vibratoRateExtent(vibratoTimePitch(:,[1,2]));
                vibratoParaMaxMin(i,5) = vibratosSS(i);
            end
            %add sinusoid similarity to the vibratosParaFDM ([rate:extent:SS])        
            vibratosParaFDM = [vibratosParaFDM,vibratosSS];

            %vibratosPara{1}from FDM
            %vibratosPara{2}from Max-min
            data.vibratoPara{1} = vibratosParaFDM;
            data.vibratoPara{2} = vibratoParaMaxMin;
            %-----END of calculating the new para-----------
        end
        
        
        data.numViratoSelected = indexNewVibrato;
        

        %plot the new created vibrato
        newPatchVibratoArea = plotNewFeatureArea(data.vibratos(data.numViratoSelected,:),data.axePitchTabVibrato);
        %add the new patch into patch list
        data.patchVibratoArea = [data.patchVibratoArea(1:indexNewVibrato-1),newPatchVibratoArea,data.patchVibratoArea(indexNewVibrato:end)];
        
        %higlight the selected vibrato
        plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);
    
        %plot the vibrato num in the listbox
        plotFeatureNum(data.vibratos,data.vibratoListBox);
        
        %show the highlighted num of vibrato in vibrato listbox
        data.vibratoListBox.Value = data.numViratoSelected;
        
        %show individual vibrato in the sub axes
        plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi) 
        
        %show individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
    end
end

