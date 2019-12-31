function plotVibratoStatistics(textList,vibratosParaAll,numViratoSelected,methodVibratoChange)
%PLOTVIBRATOSTATISTICS plot (show) the vibrato statistics
%   Input
%   @testList: text UI to show vibrato rate, extent and sinusoid similarity
%   @vibratosParaAll: vibratosParaAll{1} from FDM, vibratosParaAll{2} from
%   Max-min
%   @numViratoSelected: the number of selected vibrato.
%   @methodVibratoChange: £¨popup Uicontrol£©indicates which method of extracting vibrato para shoud be used. (1: FDM, 2: Max-min)
    
    method = get(methodVibratoChange,'Value');
    rateIndex = 1;
    extentIndex = 2;
    SSIndex = 0;
    if method == 1
        %FDM
        vibratosPara = vibratosParaAll{1};
        SSIndex = 3;
    elseif method == 2
        %Max-min
        vibratosPara = vibratosParaAll{2};
        SSIndex = 5;
    end
    if isempty(vibratosPara) == 0
        textList(1).set('String',vibratosPara(numViratoSelected,rateIndex));
        textList(2).set('String',vibratosPara(numViratoSelected,extentIndex));
        textList(3).set('String',vibratosPara(numViratoSelected,SSIndex));
    else
        textList(1).set('String',[]);
        textList(2).set('String',[]);
        textList(3).set('String',[]);      
    end
end

