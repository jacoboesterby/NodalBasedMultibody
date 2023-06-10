function Mhat = buildGlobalM(M,L,H)
%Input
%        M:      The FE local mass matrix
%        p:      Vector containing euler parameters
%        xbar:   Nodal local reference positions (Without deformation)
%        cfbar:  Nodal elastic coordinates
%Build Phit matrix

Mhat = H'*(L'*M*L)*H;
% Mhat = L.'*M*L;

%Get transformation matrices A and G

% [A,G] = TransformMat(phi);

%Now contruct global mass matrix
% Mhat = [mtot*eye(3,3),                 -A*Phit.'*M*rfbartilde*G,          A*Phit.'*M*Pr;
%         (-A*Phit.'*M*rfbartilde*G).',  G.'*rfbartilde.'*M*rfbartilde*G,   -G.'*rfbartilde.'*M*Pr;
%         (A*Phit.'*M*Pr).',             (-G.'*rfbartilde.'*M*Pr).',        Pr.'*M*Pr];



end