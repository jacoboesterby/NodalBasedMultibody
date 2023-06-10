function [Qv,Qa] = buildQuadVelArr(phi, phi_dot, M, xbar, cfbar, cf_dot,F,L,H)
%Construct G_dot matix
G_dot = [-phi_dot(1)*sin(phi(1))*cos(phi(3))-phi_dot(3)*cos(phi(1))*sin(phi(3)),  phi_dot(3)*cos(phi(3)), 0;
          phi_dot(2)*sin(phi(2))*sin(phi(3))-phi_dot(3)*cos(phi(2))*cos(phi(3)), -phi_dot(3)*sin(phi(3)), 0;
          phi_dot(2)*cos(phi(2)),                                                 0,                      0];
[A,G] = TransformMat(phi);
%Build Phit matrix
Phit = repmat(eye(3,3),[size(M,1)/3,1]);
%Calculate local angular velocity
omega_bar = G*phi_dot;
% Create xkew symmetric matrix
omega_tilde = skew_symmetric(omega_bar);
%Create block diagonal skew symmetric matrix
omega_tildeCell = repmat({omega_tilde},1,size(M,1)/3);
omega_tilde_blk = blkdiag(omega_tildeCell{:});
rfbar = xbar + cfbar; %Sum of nodal reference position and deformation
rfbartilde = skew_symmetric(rfbar);

% Build Pr to eliminate rigid body motion
% R = [Phit,skew_symmetric(xbar)];
% tmp = inv(R.'*M*R)
% tmp(tmp<1e-9)=0
% Pr = eye(size(M))-R*tmp*(R.'*M);

Qv = H.'*[-A*Phit.'*M*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot);
           G.'*rfbartilde.'*M*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot);
          -M*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot)];

% Qv = [-A*Phit.'*M*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot);
%             G.'*rfbartilde.'*M*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot);
%            -PsiTM*(omega_tilde_blk*omega_tilde_blk*rfbar+2*omega_tilde_blk*cf_dot-rfbartilde*G_dot*phi_dot)];

%Build global force vector Qa
% mres = zeros(3,1);
% fbar = zeros(size(M,1),1);
% for i=1:size(M,1)/3
%     rfbartilde = skew_symmetric(rfbar(i*3-2:i*3));
%     fbar(i*3-2:i*3) = fbar(i*3-2:i*3) + A.'*F(i*3-2:3*i);
%     mres = mres + rfbartilde*fbar(i*3-2:i*3);
% end
% Qa = [Phit.'*F;G.'*mres;Pr.'*fbar];
Qa = H.'*L.'*F;
% Qa = L.'*F;
end