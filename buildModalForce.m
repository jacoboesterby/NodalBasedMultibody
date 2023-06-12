function Qa = buildModalForce(phi,Psi,xbarR,eta,FR)
cfbarR = Psi*eta;
L = buildLmatrix(phi,xbarR,cfbarR);
H = [eye(3,3),             zeros(3,3),            zeros(3, size(Psi,2));
    zeros(3,3),            eye(3,3),              zeros(3, size(Psi,2));
    zeros(size(Psi,1),3), zeros(size(Psi,1),3), Psi];

Qa = H.'*L.'*FR;




end