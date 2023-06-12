function [Mhat,Chat,Khat,Qv,Qa] = buildEOMModal(MR,CR,KR,Psi,phi,phi_dot,xbarR,eta,eta_dot,FR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates the system of equations when using a modal
% decomposition method like the Craig Bampton method. 
%Inputs:       MR:        The full rearranged structure mass matrix
%              CR:        The full rearranged structure damping matrix
%              KR:        The full rearranged structure stiffness matrix
%              Psi:       The reduction matrix (Product of two modal decompositions)              
%              phi:       Bryant angles
%              phi_dot:   Bryant angle time derivatives
%              xbarR:     Rearranged structure local nodal positions
%              eta:       Felxible modal dof displacements
%              eta_dot:   Flexible modal dof velocities
%              FR:        Rearranged full global force vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build L matrix to give as input to sub-functions
% cfbar = 

%%
%Construct cfbar
cfbarR = Psi*eta; 
cfbarR_dot = Psi*eta_dot;


%%

L = buildLmatrix(phi,xbarR,cfbarR);

%Construct transformation matrix H
H = [eye(3,3),             zeros(3,3),            zeros(3, size(Psi,2));
    zeros(3,3),            eye(3,3),              zeros(3, size(Psi,2));
    zeros(size(Psi,1),3), zeros(size(Psi,1),3), Psi];
Mhat = buildGlobalM(MR, L, H);
Khat = buildGlobalK(KR, Psi);
Chat = buildGlobalC(CR, Psi);

% [PSI,Lambda] = eigs(Psi.'*K*Psi,Psi.'*M*Psi,10,'smallestabs');
% f = diag(Lambda)
% f(1:3)


[Qv,Qa] = buildQuadVelArr(phi, phi_dot, MR, xbarR, cfbarR, cfbarR_dot,FR,L,H);
end




