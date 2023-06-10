function Mhat = buildGlobalMModal(M,L,H)
%Input
%        M:      The FE local mass matrix
%        p:      Vector containing euler parameters
%        xbar:   Nodal local reference positions (Without deformation)
%        cfbar:  Nodal elastic coordinates
%Build Phit matrix

%Build submatrices
MPsiPsi           = transpose(Psi)*M*Psi;
MPsitildePsi      = transpose(Psitilde)*M*Psi;
MPsitildePsitilde = transpose(Psitilde)*M*Psitilde;
MPhiPsi           = transpose(Phit)*M*Psi;
MPhiPsitilde      = transpose(Phit)*M*Psitilde;
MxtildePsi        = transpose(xbartilde)*M*Psi;
MxbarPsitilde     = transpose(xbartilde)*M*Psitilde;

%Calculate mass and moment of inertia
Phiu = transpose(xbartilde)*M*xbartilde;

%Construct global matrix entries
Mtt = eye(3)*m; 
Mff = MPsiPsi;
Mtf = A*MhiPsi;
Mtr = -A*(m*XIbartilde+MPhiPsitilde*kron(eta,eye()))*G;
Mrf = -transpose(G)*(MxbartildePsi+kron(eta,eye())*MPsitildePsi);
Mrr = transpose(G)*(Phiu+MxbartildePsitilde*kron(eta,eye())+transpose(kron(eta,eye()))*transpose(MxbartildePsitilde)+transpose(kron(eta,eye()))*MPsitildePsitilde*kron(eta,eye()))*G;

%To form global mass matrix
Mhat = [Mtt,   Mtr, Mtf;
        Mrt.', Mrr, Mrf;
        Mtf.', Mrf.',Mff];

% Mhat = H'*(L'*M*L)*H;

%Get transformation matrices A and G

% [A,G] = TransformMat(phi);

%Now contruct global mass matrix
% Mhat = [mtot*eye(3,3),                 -A*Phit.'*M*rfbartilde*G,          A*Phit.'*M*Pr;
%         (-A*Phit.'*M*rfbartilde*G).',  G.'*rfbartilde.'*M*rfbartilde*G,   -G.'*rfbartilde.'*M*Pr;
%         (A*Phit.'*M*Pr).',             (-G.'*rfbartilde.'*M*Pr).',        Pr.'*M*Pr];



end