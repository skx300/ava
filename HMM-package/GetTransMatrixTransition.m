function [ transPitchTransition ] = GetTransMatrixTransition( stateRangeTransition )
%GETTRANSMATRIXTRANSITION Summary of this function goes here
%   Return the transition probability matrix for transition HMM
%   Input
%   @stateRangeTransition: state range for transition. (up, constant, down).
%   Output
%   @transPitchTransition: the transition matrix for transition HMM
    
    %-----create the transition matrix for transition HMM-------
    %                       down,steady,up
    transPitchTransition = [0.4,0.4,0.2;...
                            1/3,1/3,1/3;...
                            0.2,0.4,0.4;];
    %----------------------------------------------------------

end

