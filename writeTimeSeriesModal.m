function writeTimeSeriesModal(Nodes,xbar,c,t,Psi,dofG2R)
%Recreate nodal positions
step = 5;
%Total displacement field
x    = zeros(size(Nodes,1),length(t(1:step:end)));
y    = zeros(size(Nodes,1),length(t(1:step:end)));
z    = zeros(size(Nodes,1),length(t(1:step:end)));
%Elastic displacement field in global reference frame
dx   = zeros(size(Nodes,1),length(t(1:step:end)));
dy   = zeros(size(Nodes,1),length(t(1:step:end)));
dz   = zeros(size(Nodes,1),length(t(1:step:end)));
idx  = 1:step:length(t);
k  = 1;
for i=idx
    [A,G] = TransformMat(c(4:6,i));
    A_Cell = repmat({A},1,length(xbar)/3);
    Abd = blkdiag(A_Cell{:});
    cfR = Abd*(Psi*c(7:end,i));
    cf  = cfR(dofG2R);
    dx(:,k) = cf(1:3:end);
    dy(:,k) = cf(2:3:end);
    dz(:,k) = cf(3:3:end);
    
    xglob = Abd*xbar;
    x(:,k) = c(1,i) + xglob(1:3:end) + cf(1:3:end) - (c(1,1) + xbar(1:3:end));
    y(:,k) = c(2,i) + xglob(2:3:end) + cf(2:3:end) - (c(2,1) + xbar(2:3:end));
    z(:,k) = c(3,i) + xglob(3:3:end) + cf(3:3:end) - (c(3,1) + xbar(3:3:end));
    k = k+1;
end

figure(5)
hold on
plot(t(1:step:end),y(50,:),'displayname','Reduced - 20 Dyn. Mode')
legend()

dlmwrite('NDt.txt',t(1:step:end))
dlmwrite('NDx.txt',x)
dlmwrite('NDy.txt',y)
dlmwrite('NDz.txt',z)
dlmwrite('NDdx.txt',dx)
dlmwrite('NDdy.txt',dy)
dlmwrite('NDdz.txt',dz)
end