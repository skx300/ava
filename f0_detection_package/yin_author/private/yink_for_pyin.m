function r=yink(p,fileinfo) 
% YINK - fundamental frequency estimator
% new version (feb 2003)
%
%
%global jj;
%jj=0;


% process signal a chunk at a time
idx=p.range(1)-1;
totalhops=round((p.range(2)-p.range(1)+1) / p.hop);
% r1=nan*zeros(1,totalhops);r2=nan*zeros(1,totalhops);
% r3=nan*zeros(1,totalhops);r4=nan*zeros(1,totalhops);
idx2=0+round(p.wsize/2/p.hop);
%-----LUWEI ADDED START--------
numThresh = length(p.thresholds);    
r1=nan*zeros(numThresh,totalhops);
r2=nan*zeros(numThresh,totalhops);
r3=nan*zeros(numThresh,totalhops);
r4=nan*zeros(numThresh,totalhops);
r5=nan*zeros(numThresh,totalhops);  %GOOD_FLAG
%-----LUWEI ADDED END----------
h = waitbar(0,'Detecting pitch using PYIN (Matlab)...');  %Luwei
while (1)
    
	start = idx+1;
	stop = idx+p.bufsize;
	stop=min(stop, p.range(2));
	xx=sf_wave(fileinfo, [start, stop], []);
% 	if size(xx,1) == 1; xx=xx'; end
	xx=xx(:,1); 			% first channel if multichannel
	[prd,ap0,ap,pwr,good_flag]=yin_helper(xx,p); %for each chunk, perform yin
	n=size(prd ,2);
	if (~n) break; end;
	idx=idx+n*p.hop;
    
% 	r1(idx2+1:idx2+n)= prd;	
% 	r2(idx2+1:idx2+n)= ap0;
% 	r3(idx2+1:idx2+n)= ap;
% 	r4(idx2+1:idx2+n)= pwr;
    r1(:,idx2+1:idx2+n)= prd; %LUWEI	
    r2(:,idx2+1:idx2+n)= ap0; %LUWEI
    r3(:,idx2+1:idx2+n)= ap;  %LUWEI
    r4(:,idx2+1:idx2+n)= pwr; %LUWEI
    r5(:,idx2+1:idx2+n)= good_flag; %LUWEI
	idx2=idx2+n;	
    waitbar(stop/p.range(2),h,sprintf('%d%% Detecting pitch using PYIN (Matlab)...',round(stop/p.range(2)*100)));   %Luwei
end
r.r1=r1; % period estimate
r.r2=r2; % gross aperiodicity measure
r.r3=r3; % fine aperiodicity measure
r.r4=r4; % power
r.r5=r5; % good flag
sf_cleanup(fileinfo);

close(h);   %Luwei
% end of program


% Estimate F0 of a chunk of signal
function [prd,ap0,ap,pwr,good_flag]=yin_helper(x,p,dd)
smooth=ceil(p.sr/p.lpf);
x=rsmooth(x,smooth); 	% light low-pass smoothing
x=x(smooth:end-smooth+1);
[m,n]=size(x);
maxlag = ceil(p.sr/p.minf0); 	
minlag = floor(p.sr/p.maxf0);
mxlg = maxlag+2; % +2 to improve interp near maxlag


hops=floor((m-mxlg-p.wsize)/p.hop);
% prd=zeros(1,hops);
% ap0=zeros(1,hops);
% ap=zeros(1,hops);
% pwr=zeros(1,hops);
%-----LUWEI ADDED START--------
numThresh = length(p.thresholds); 
prd=zeros(numThresh,hops);
ap0=zeros(numThresh,hops);
ap=zeros(numThresh,hops);
pwr=zeros(numThresh,hops);
good_flag=zeros(numThresh,hops);  %indicate the good or not of each period estiamte
%-----LUWEI ADDED END----------
if hops<1; return; end

% difference function matrix
dd=zeros(floor((m-mxlg-p.hop)/p.hop),mxlg);
if p.shift == 0		 % windows shift both ways
	lags1=round(mxlg/2) + round((0:mxlg-1)/2); 
	lags2=round(mxlg/2) - round((1:mxlg)/2);
	lags=[lags1; lags2];
elseif p.shift == 1 % one window fixed, other shifts right
	lags=[zeros(1,mxlg); 1:mxlg]; 
elseif p.shift == -1 % one window fixed, other shifts right
	lags=[mxlg-1:-1:0; mxlg*ones(1,mxlg)]; 
else
	error (['unexpected shift flag: ', num2str(p.shift)]);
end
rdiff_inplace(x,x,dd,lags,p.hop);
rsum_inplace(dd,round(p.wsize/p.hop));
dd=dd';
[dd,ddx]=minparabolic(dd); 	% parabolic interpolation near min
cumnorm_inplace(dd);		% cumulative mean-normalize

% first period estimate
%global jj;
%-----LUWEI ADDED START--------
for si = 1:numThresh
%-----LUWEI ADDED END----------
    for j=1:hops
        d=dd(:,j);
        if p.relflag
%             pd=dftoperiod2(d,[minlag,maxlag],p.thresh); 
            %add the global min to the threshold
            [pd,flag]=dftoperiod3(d,[minlag,maxlag],p.thresholds(si)); %LUWEI
            
        else
%             pd=dftoperiod(d,[minlag,maxlag],p.thresh); 
            pd=dftoperiod(d,[minlag,maxlag],p.thresholds(si)); %LUWEI
            flag = 0;
        end
%         ap0(j)=d(pd+1);
        ap0(si,j)=d(pd+1); %LUWEI
%         prd(j)=pd;
        prd(si,j) = pd; %LUWEI
        good_flag(si,j) = flag; %LUWEI
    end
%-----LUWEI ADDED START--------   
end
%-----LUWEI ADDED END----------

% replace each estimate by best estimate in range
range = 2*round(maxlag/p.hop);
% if hops>1; prd=prd(mininrange(ap0,range*ones(1,hops))); end
%prd=prd(mininrange(ap0,prd)); 	
%-----LUWEI ADDED START--------
if hops>1;
    for si = 1:numThresh
        prd(si,:)=prd(si,mininrange(ap0(si,:),range*ones(1,hops)));
    end
end
%-----LUWEI ADDED END----------

% refine estimate by constraining search to vicinity of best local estimate
margin1=0.6; 		
margin2=1.8; 	
for si = 1:numThresh %LUWEI
    for j=1:hops
        d=dd(:,j);
        dx=ddx(:,j);
%         pd=prd(j);
        pd = prd(si,j); %LUWEI
        lo=floor(pd*margin1); lo=max(minlag,lo);
        hi=ceil(pd*margin2); hi=min(maxlag,hi);
        pd=dftoperiod(d,[lo,hi],0); 
        ap0(j)=d(pd+1);
        pd=pd+dx(pd+1)+1;	% fine tune based on parabolic interpolation
%         prd(j)=pd;
        prd(si,j)=pd; %LUWEI

        % power estimates
        idx=(j-1)*p.hop;
        k=(1:ceil(pd))';
        x1=x(k+idx);
        x2=k+idx+pd-1;
        interp_inplace(x,x2);
        x3=x2-x1;
        x4=x2+x1;
        x1=x1.^2; rsum_inplace(x1,pd);
        x3=x3.^2; rsum_inplace(x3,pd);
        x4=x4.^2; rsum_inplace(x4,pd);

        x1=x1(1)/pd;
        x2=x2(1)/pd;
        x3=x3(1)/pd;
        x4=x4(1)/pd;
        % total power
%         pwr(j)=x1;
        pwr(si,j)=x1;%LUWEI

        % fine aperiodicity
%         ap(j)=(eps+x3)/(eps+(x3+x4)); % accurate, only for valid min
        ap(si,j)=(eps+x3)/(eps+(x3+x4)); %LUWEI

        %ap(j)
        %plot(min(1, d)); pause

%         prd(j)=pd;
        prd(si,j)=pd; %LUWEI
    end
end %LUWEI



%cumulative mean-normalize 
function y=cumnorm(x)
[m,n]=size(x);
y = cumsum(x);
y = (y)./ (eps+repmat((1:m)',1,n)); % cumulative mean
y = (eps+x) ./  (eps+y);
