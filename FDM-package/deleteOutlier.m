function [output] = deleteOutlier(vibratoIndicate,sign)
%DELETEOUTLIER is going to delete the outlier for vibrato indication,delete outlier, if single indication without neighbourhood, then
    %consider it as outlier and delete it
%   input
%   @vibratoIndicate: the indication vector of vibrato, @sign means
%   vibrato, 0 means no vibrato
%   @sign: the number sign to indicate the vibrato
%   output
%   @output: the vibrato indication vector without outlier

    %-------for the sign----------------
    for i = 1:length(vibratoIndicate)
        if (i == 1)
            if (vibratoIndicate(i)==sign)&&(vibratoIndicate(i+1)~=sign)
            vibratoIndicate(i) = 0;
            end
        elseif (i == length(vibratoIndicate))
            if(vibratoIndicate(i)==sign)&&(vibratoIndicate(i-1)~=sign)
            vibratoIndicate(i) = 0;
            end
        elseif (vibratoIndicate(i-1)~=sign)&&(vibratoIndicate(i+1)~=sign)
            vibratoIndicate(i) = 0;
        end
    end
    
    %-----------for the 0-------------
    for i = 1:length(vibratoIndicate)
        if (i==1)
            if (vibratoIndicate(i)==0)&&(vibratoIndicate(i+1)~=0)
                vibratoIndicate(i) = sign;
            end
        elseif (i == length(vibratoIndicate))
            if (vibratoIndicate(i)==0)&&(vibratoIndicate(i-1)~=0)
                vibratoIndicate(i) = sign;
            end
        elseif (vibratoIndicate(i-1)~=0)&&(vibratoIndicate(i+1)~=0)
            vibratoIndicate(i) = sign;
        end
    end
    
    output = vibratoIndicate;
end

