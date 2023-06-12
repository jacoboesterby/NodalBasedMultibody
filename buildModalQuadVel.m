function Qv = buildModalQuadVel(Mtt,phi,phi_dot,eta,eta_dot, M_Psi_Psi, M_Psitilde_Psi, M_Psitilde_Psitilde, M_Phi_Psi, M_Phi_Psitilde, M_xbartilde_Psi, M_xbartilde_Psitilde,chibar_tilde,Theta_u)

%Construct G_dot matix
G_dot = [-phi_dot(1)*sin(phi(1))*cos(phi(3))-phi_dot(3)*cos(phi(1))*sin(phi(3)),  phi_dot(3)*cos(phi(3)), 0;
          phi_dot(2)*sin(phi(2))*sin(phi(3))-phi_dot(3)*cos(phi(2))*cos(phi(3)), -phi_dot(3)*sin(phi(3)), 0;
          phi_dot(2)*cos(phi(2)),                                                 0,                      0];
[A,G] = TransformMat(phi);
%Calculate local angular velocity
omega_bar = G*phi_dot;
% Create xkew symmetric matrix
omega_tilde = skew_symmetric(omega_bar);
%Create block diagonal skew symmetric matrix
omega_tildeCell = repmat({omega_tilde},1,99/3);
omega_tilde_blk = blkdiag(omega_tildeCell{:});

I = eye(3,3);
Ieta = eye(length(eta));

Qvt = A*omega_tilde*(Mtt(1)*chibar_tilde + M_Phi_Psitilde*kron(eta,I))*omega_bar...
      + 2*A*M_Phi_Psitilde*kron(eta_dot,I)*omega_bar...
      + A*(Mtt(1,1)*chibar_tilde+M_Phi_Psitilde*kron(eta,I))*G_dot*phi_dot;
  
Qvr = -G.'*skew_symmetric(omega_bar)*(Theta_u+M_xbartilde_Psitilde*kron(eta,I)+kron(eta,I).'*M_xbartilde_Psitilde.'+kron(eta,I).'*M_Psitilde_Psitilde*kron(eta,I))*omega_bar...
      -2*G.'*(M_xbartilde_Psitilde*kron(eta_dot,I)+kron(eta,I).'*M_Psitilde_Psitilde*kron(eta_dot,I))*omega_bar...
      -G.'*(Theta_u+M_xbartilde_Psitilde*kron(eta,I)+kron(eta,I).'*M_xbartilde_Psitilde.'+kron(eta,I).'*M_Psitilde_Psitilde*kron(eta,I))*G_dot*phi_dot;
Qvf = kron(Ieta,omega_bar).'*(M_xbartilde_Psitilde.'+M_Psitilde_Psitilde*kron(eta,I))*omega_bar + 2*M_Psitilde_Psi.'*kron(eta_dot,I)*omega_bar...
      + (M_xbartilde_Psi.'+M_Psitilde_Psi.'*kron(eta,I))*G_dot*phi_dot;

Qv = [Qvt;Qvr;Qvf];