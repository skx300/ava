function [standardFStatistics,ColorFStatistics] = detectionEvaluationStat(vibratoIndicate,groundTruthIndicate,vibratoIndicateSign,groundTruthIndicateSign,nonVibratoSign)
%DETECTIONEVALUATIONSTAT This is going to return the evaluation statistics
%of the vibrato detection performance
%   input
%   @vibratoIndicate: the vibrato detection vector
%   @groundTruthIndicate: the vibrato ground truch vector, it should have the same
%   length with @vibratoIndicate
%   @vibratoIndicateSign: the sign for the vibrato indication, integer
%   @groundTruthIndicateSign: the sign for the ground truth indication,
%   integer
%   @nonVibratoSign: the sign for the non-vibrato, integer
%   output
%   @standardFStatistics: [presicion, recall, f-measure]
%   @ColorFStatistics: [precisionColer,recallColer,FColer]

evaluationResult = vibratoIndicate - groundTruthIndicate;
TPSign = vibratoIndicateSign - groundTruthIndicateSign;     %the sign for true positives
FPSign = vibratoIndicateSign - nonVibratoSign;  %the sign for false positives
FNSign = nonVibratoSign - groundTruthIndicateSign;  %the sign for false negatives
TNSign = nonVibratoSign - nonVibratoSign;   %the sign for true negatives

TP = sum(evaluationResult(:)==TPSign);
FP = sum(evaluationResult(:)==FPSign);
FN = sum(evaluationResult(:)==FNSign);
TN = sum(evaluationResult(:)==TNSign);

precision = TP/(TP+FP);
recall = TP/(TP+FN);
F = 2*precision*recall/(precision+recall);

standardFStatistics = [precision,recall,F];

precisionColer = TP/(TP+FN);
recallColer = TN/(TN+FP);
FColer = 2*precisionColer*recallColer/(precisionColer+recallColer);

ColorFStatistics = [precisionColer,recallColer,FColer];
end

