function [fk,d] = FDM3(c0,Fs, f_min,f_max,k_max)
%FDMFUNCTION This is the implemation of the FDM
%   Input
%   @c0: the real signal data
%   @Fs: samling rate
%   @f_min and @f_max: the frequency search range
%   @k_max: the number of iteration
% tic
Zu = [];    %the complex frequencies
d = [];     %the complex amplitudes
N=length(c0)-1;
tau=1/Fs;   %sampling period

%: the frequency search range
w_min=2*pi*f_min;
w_max=2*pi*f_max;

J0=max(2,ceil(N*tau/4/pi*(w_max-w_min)));   %step(2)
% J0 = 3;
J=J0;
j=1:J;
phi=tau*(w_min+(w_max-w_min)/(J-1)*(j-1));  %set the evenly spaced frequency grid,  step(2)
% phi = ([1:J]*(w_max-w_min)/J+w_min)*tau;  
% phi=tau*(w_min+(w_max-w_min)/(J)*(j-1));  %new
z=exp(-1j*phi); %create a small set of complex values

M=floor((N-1)/2)-1; %step(3)
%% 

%Some parameters
% k_max=5;    %k_max is the number of times we iterate the solution (to make it more accurate). You should only use the final iteration, because in theory that is the most accurate result.
err=1e4;    %error criterion

%%
%The Filter Diagonalisation algorithm
for k=1:k_max   %k_max's iteration
%---------equation (25)----------------
    for p=1:3 %usually the p = 0,1,2; however in this case the p = 1,2,3
        X=eye(J);
        for j0=1:J
            fp(p,j0)=c0(p);
            gp(p,j0)=0;
            for m=1:M
                fp(p,j0)=fp(p,j0) + z(j0)^(-m)*c0(m+p);
                gp(p,j0)=gp(p,j0) + z(j0)^(-(m-1))*c0(m+M+p);
            end
        end
        for j0=1:J
            for j1=j0:J
                if j0==j1
                    X(j0,j0) = c0(p);
                    for m=1:2*M
                        X(j0,j0) = X(j0,j0) + (M-abs(M-m)+1)*c0(m+p)*z(j0)^(-m);
                    end
                else
                    X(j0,j1) = 1/(z(j0)-z(j1))*(z(j0)*fp(p,j1) - z(j1)*fp(p,j0) -...
                        z(j0)^(-M)*gp(p,j1) + z(j1)^(-M)*gp(p,j0));
                    X(j1,j0) = X(j0,j1);
                end
            end
        end

        if p==1
            Y0=X;   %Y0: U(P=1)
        elseif p==2 
            Y1=X;   %Y1: U(P=2)
        elseif p==3
            Y2=X;   %Y2: U(P=3), this is only used to exmaine whether accept u_k(eigenvalues). It is not used in calculation for u_k(eignvalues)
        end
          %-------------above equation (25)---------------------
    end   
    %%
    Y1(find(isnan(Y1))) = 1;        %new added
    Y1(find(isinf(Y1))) = 1;        %new added
    Y0(find(isnan(Y0))) = 0;        %new added
    Y0(find(isinf(Y0))) = 0;        %new added
%     if(isnan(Y1)==1)
%         Y1 = 1;
%     end
%     if(isnan(Y0)==1)
%         Y0 = 0;  
%     end
    [VY,uY] = eig(Y1,Y0);   %step(4), VY(B_k): columns are eigen vectors for corresponding eighen value; uY(u_k): eigen values in diagonal matrix
    Z = VY.'*Y0*VY;
    [VZ,uZ] = eig(Z);
    CZ = VZ*diag(diag(uZ).^-0.5)*VZ^-1;
    VY = VY*CZ;
    
    v_min = 1e100;  %1*10^100
    n_min = 1e100;
    J1 = J;
    for j0=1:J
        vY(j0) = norm(VY(:,j0));
        nY(j0) = norm((Y2-uY(j0,j0)^2*Y0)*VY(:,j0));    %step(5), evaluate the error for complex frequencies
        if vY(j0) < v_min
            v_min = vY(j0);
        end
        if nY(j0) < n_min
            n_min = nY(j0);
        end
    end
    
    j2 = 1;

    for j0=1:J
         % err*n_min is the e in step(5), it is always changing.
        if vY(j0) < err*v_min & nY(j0) < err*n_min
            Zu(k,j2) = 1j/(2*pi*tau)*log(uY(j0,j0));    %get the digonal value of the maxtrix uY. the resulted value is the complex frequency
            for j1=1:J
                VYY(j1,j2) = VY(j1,j0);
            end
            %---new added---------------
            if(k<k_max)
                z(j2) = uY(j0,j0);     %change z=uY(eigenvalues) here, this is step(6), this is going to get more accurate result
            end
            %---------------------------
                j2 = j2+1;
        else 
            J1 = J1-1;  %change the J1 number here, since the eigenvalue uY(u_k) cannot satisfy the error criterion
        end
    end
    J=J1;   %change the J to J1, finally the J is consistent with the number of non-zero frequencies of the final iteration of Zu.
end

%%
%we need this for iteration
[m,n] = size(Zu);
if m~= k_max
    fk = 0;
    d = 0;
else
    % Calculate the resonant frequencies (real parts) and their respective damping
    % coefficients (imaginary bits).
    fk = Zu(k_max,:);   %get the final iteration result which is the most accurate result, the complex frequencies
    wk = 2*pi*fk;

    % toc

    zk = exp(-1j*tau*(wk));
    z0 = z;
    %%
    % Calculating the amplitude coefficients for each component:
    %---------equation (27)----------------
    for j=1:J0
        for kNum=1:J   %only calculte the J number resonance's amplitude
            if abs(z0(j)-zk(kNum)) < 1e-12
                Ud(j,kNum) = c0(1);
                for m=1:2*M
                    Ud(j,kNum) = Ud(j,kNum) + (M - abs(M-m) + 1)*c0(m+1)*z0(j)^-m;
                end
            else
                Ud(j,kNum) = c0(1)*(z0(j)-zk(kNum));
                for m=1:M
                    Ud(j,kNum) = Ud(j,kNum) + c0(m+1)*(z0(j)*zk(kNum)^-m-zk(kNum)*z0(j)^-m)...
                        + c0(m+M+1)*(zk(kNum)^-M*z0(j)^-(m-1)-z0(j)^-M*zk(kNum)^-(m-1));
                end
                Ud(j,kNum) = Ud(j,kNum)/(z0(j)-zk(kNum));
            end
        end
    end

    for kNum=1:J
        d(kNum) = 0;
        %----new added-------------
        %---for iteration to get accurate complitude values.
        if(k_max == 1)
            J = J0;
        end
        %---------------------
        for j=1:J
            d(kNum) = d(kNum) + VYY(j,kNum)*Ud(j,kNum);
        end
        d(kNum) = d(kNum)^2/(M+1)^2; %the resonances' amplitude
end
    
end
% toc
% outputData = [fk.',d.'];
end

