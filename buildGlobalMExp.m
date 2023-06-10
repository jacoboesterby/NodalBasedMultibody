function Mhat = buildGlobalMExp(phi,xbar,cfbar,M)


Phit = repmat(eye(3,3),[size(M,1)/3,1]);

rfbar = xbar + cfbar;
rfbartilde = skew_symmetric(rfbar);

%Construct rigid motion elimination matrix Pr
R = [Phit,skew_symmetric(xbar)];

Pr = eye(size(M))-R*(R.'*M*R)^(-1)*R.'*M;


[A,G] = TransformMat(phi);

%Now contruct global mass matrix
Mhat = [Phit.'*M*Phit,                 -A*Phit.'*M*rfbartilde*G,            A*Phit.'*M;
       (-A*Phit.'*M*rfbartilde*G).',    G.'*rfbartilde.'*M*rfbartilde*G,   -G.'*rfbartilde.'*M;
       (A*Phit.'*M).',                (-G.'*rfbartilde.'*M).',              M];

end