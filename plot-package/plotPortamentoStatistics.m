function plotPortamentoStatistics(textPort,portamentoPara,numPortamentoSelected)
%PLOTPORTAMENTOSTATISTICS plot (show) the portamento statistics
%   Input
%   @textPort: text UI list to show portamento parameters (A,B,G,L,M,U).
%   @portamentoPara: the parameters of portamento.
%   @numViratoSelected: the number of selected portamento.
    
    %plot the portamento parameters
    for i = 1:length(textPort)
        textPort(i).set('String',portamentoPara(numPortamentoSelected,i));
    end
end

