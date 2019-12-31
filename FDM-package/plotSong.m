function [ output_args ] = plotSong(inUser, inSet, inID)
%plotSong Summary of this function goes here
%   Detailed explanation goes here
figure;

tmpWA = find(inUser(inSet).dat(:,5) ~= 0);
plot(inUser(inSet).dat(tmpWA,5), inUser(inSet).dat(tmpWA,3))
if (~isempty(inUser(inSet).iwa))
    hold on; plot(inUser(inSet).dat(inUser(inSet).iwa,5), inUser(inSet).dat(inUser(inSet).iwa,3),'r')
    plot(inUser(inSet).dat(inUser(inSet).iwa,5), round(inUser(inSet).dat(inUser(inSet).iwa,3)),'g')
end

if exist('inID')
    title(inID);
end

