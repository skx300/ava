function plotZoomInPost( hObject,eventData )
%PLOTZOOMINPOST change the feature area height according to the zoomed
%in/out
%   Detailed explanation goes here

%     disp('A zoom function is occurred.');
%     disp(['YLim: ',num2str(eventData.Axes.YAxis.Limits)]);
    %get the axe that is zoomed.
    currentAxe = eventData.Axes;
    
    %get all of things on this axe
    children = currentAxe.Children;
    for i =1:length(children)
       if isgraphics(children(i),'Patch')
           children(i).YData = [currentAxe.YLim(1),currentAxe.YLim(1),currentAxe.YLim(2),currentAxe.YLim(2)];
       end
    end
end

