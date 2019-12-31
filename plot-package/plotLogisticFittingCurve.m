function plotLogisticFittingCurve(portamentosDetail,numPortamentoSelected,...
    portamentoXaxisPara,portamentosDetailLogistic,axePortamento)
%PLOTLOGISTICFITTINGCURVE plot the Logistic fitted line for portamento
%   Input
%   @portamentosDetail: [time from 0:MIDI pitch:orginal time]
%   @numPortamentoSelected: the number of selected portamento
%   @portamentoXaxisPara:£¨popup Uicontrol£©indicates which kind of x-axis shoud be used. (1: original time, 2: normalized time)
%   @portamentosDetailLogistic: the vector storing the fitted Logistic
%   fitting line for reach portamento
%   @axePortamento: the plot handle

    portamentosName = fieldnames(portamentosDetail);
    
    %choose which x-axis will be used
    xAxis= get(portamentoXaxisPara,'Value');
    portamentoXY = portamentosDetail.(char(portamentosName(numPortamentoSelected)));
    if xAxis == 1
        X = portamentoXY(:,3);
    elseif xAxis == 2
        X = portamentoXY(:,1);    
    end
    axes(axePortamento);
    hold on
    plot(X,portamentosDetailLogistic.(char(portamentosName(numPortamentoSelected))),'r--');
    hold off
    legend({'Original Pitch Curve','Logistic Fitting'},'FontSize',12);
end

