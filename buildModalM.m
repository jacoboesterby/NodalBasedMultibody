function Mhat = buildModalM(Mtt,phi,eta,M_Psi_Psi, M_Psitilde_Psi, M_Psitilde_Psitilde, M_Phi_Psi, M_Phi_Psitilde, M_xbartilde_Psi, M_xbartilde_Psitilde,chibar_tilde,Theta_u)

%Calculate transformation matrix
[A,G] = TransformMat(phi);

%Build global submatrics
Mff = M_Psi_Psi;
Mtf = A*M_Phi_Psi;
Mtr = -A*(Mtt(1,1)*chibar_tilde+M_Phi_Psitilde*kron(eta,eye(3)))*G;
Mrf = -G.'*(M_xbartilde_Psi+kron(eta,eye(3)).'*M_Psitilde_Psi);
Mrr = G.'*(Theta_u+M_xbartilde_Psitilde*kron(eta,eye(3))+kron(eta,eye(3)).'*M_xbartilde_Psitilde.'+kron(eta,eye(3)).'*M_Psitilde_Psitilde*kron(eta,eye(3)))*G;


Mhat = [Mtt,   Mtr,   Mtf;
        Mtr.', Mrr,   Mrf;
        Mtf.', Mrf.', Mff];