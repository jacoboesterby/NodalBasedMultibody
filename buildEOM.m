function [Mhat,Chat,Khat,Qv,Qa] = buildEOM(M,C,K,phi,phi_dot,xbar,cfbar,cfbar_dot,F,B)
Phit = repmat(eye(3,3),[size(M,1)/3,1]);
%Build L matrix to give as input to sub-functions
L = buildLmatrix(phi,xbar,cfbar);

%Construct rigid motion elimination matrix Pr
R = [Phit,skew_symmetric(xbar)];

% [Psi,Lambda] = eigs(K,M,12,'smallestabs');
%Mass normalize modes 
%Calculate mass normalized mode shapes
% mr = transpose(Psi)*M*Psi;
% Psibar = Psi*mr^(-1/2);
% R = Psi(:,1:6);

Pr = eye(size(M))-R*(transpose(R)*M*R)^(-1)*transpose(R)*M;
Pr = B;


% [Psi,Lambda] = eigs(K,M,16,'smallestabs');
% Psi = Psi(:,7:end)
% Pr(abs(Pr)<1e-6) = 0;

%Construct transformation matrix H
H = [eye(3,3),             zeros(3,3),            zeros(3, size(Pr,2));
     zeros(3,3),           eye(3,3),              zeros(3, size(Pr,2));
     zeros(size(Pr,1),3),  zeros(size(Pr,1),3),   Pr];
Mhat = buildGlobalM(M, L, H);
Khat = buildGlobalK(K,Pr);
Chat = buildGlobalC(C,Pr);

[Qv,Qa] = buildQuadVelArr(phi, phi_dot, M, xbar, cfbar, cfbar_dot,F,L,H);
end




