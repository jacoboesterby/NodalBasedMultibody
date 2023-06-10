clear all
%====== Control parameters ==========%
%Use full or CMS reduced structure
CMSRed = false;
VisMod = false;

%====================================%


%% Flexible Rotor

% Import full mass and stiffness matrix
%Read stiffness matrix
kfile = readmatrix('SoftBar_STIF1.txt');
mfile = readmatrix('SoftBar_MASS1.txt');
rows = max(kfile(:,1));
K = zeros(rows,rows);
M = zeros(rows,rows);
for i=1:length(kfile)
    row = kfile(i,1);
    col =kfile(i,2);
    K(row,col) = kfile(i,3);
end
for i=1:length(mfile)
    row = mfile(i,1);
    col = mfile(i,2);
    M(row,col) = mfile(i,3);
end



[Nodes,Elem] = readAbaInp('SoftBar.inp');

if VisMod
    figure(1);
    plot3(Nodes(:,2),Nodes(:,3),Nodes(:,4),'.','color','blue','markersize',12)
    axis equal
end

%%

% Build rbm to flex dofs transforamtion matrix Phi_t. Eq (12)
Phit = repmat(eye(3,3),[size(Nodes,1),1]);
%Build block diagonal identity matrix Ibd
Ibd = eye(3*size(Nodes,1));


% Create vector containing dof reference position (Constant)
xbar = zeros(3*size(Nodes,1),1);
xbar(1:3:end) = Nodes(:,2); %x-positions
xbar(2:3:end) = Nodes(:,3); %y-positions
xbar(3:3:end) = Nodes(:,4); %z-positions

B = eye(size(M));
%Find node coinciding with COG
RCnodes = [Nodes(Nodes(:,4)==-0.5&Nodes(:,3)==0&Nodes(:,2)==-0.1,1);Nodes(Nodes(:,4)==0.5&Nodes(:,3)==0&Nodes(:,2)==0,1);Nodes(Nodes(:,4)==-0.5&Nodes(:,3)==0&Nodes(:,2)==0.1,1)];
RCdofs = node2dof(RCnodes);
RCdofs = RCdofs([1,2,3,4,6,8]);
alldofs = node2dof(Nodes(:,1));
B = B(:,setdiff(alldofs,RCdofs));


%Newmark integration scheme
h     = 1e-4; 
gamma = 1/2;
beta  = 1/4;
nstep = 10000;

%Allocate time history deformation matrix
cdd = zeros(size(K,1),nstep);
cd  = zeros(size(K,1),nstep);
c    = zeros(size(K,1),nstep);
cf   = zeros(size(K,1),nstep);

%Initial parameters

r0           = [0,0,0].';
% p0           = [cos(0),0,0,sin(0)].'; %Euler parameters
phi0         = [0,0,0].';
omega_bar0   = [0,0,0].';
%Convert angulat velocity to bryant angle derivatives
phi_dot0     = omega2phi_dot(phi0)*omega_bar0;   
rd0          = [0,0,0].'; %No initial velocity
cf0          = zeros(size(K,1),1); %No initial deformation
cf_dot0      = zeros(size(K,1),1); %No initial deformation velocity    
c(:,1)       = [r0;phi0;B.'*cf0];
cd(:,1) = [rd0;phi_dot0;B.'*cf_dot0];

%Proportional damping
C = (1e-4.*M  + 1e-4.*K).*0;
 

% Apply gravitational pull
Fgrav = zeros(size(K,1),1);
% grav = zeros(size(M,1),1);
% grav(2:3:end) = -9.82;
% FF = M*grav;
%Read gravity nodal force from file (To avoid needing to do integration)
forceFile = readmatrix('SoftBar_LOAD1.txt');%(This containes nodal indices and their respective force)
Fgrav(forceFile(:,1)) = forceFile(:,2);
F = zeros(length(xbar),1);
F = Fgrav.*100;
%Add initial force
% F(50*3-1) = -100;
[Mhat,Chat,Khat,Qv,Qa] = buildEOM(M,C,K,phi0,phi_dot0,xbar,cf0,cf_dot0,F,B);
% MhatExp = buildGlobalMExp(phi0,xbar,cf0,M)

%Calculate initial acceleration
cdd(:,1) = Mhat\(Qv+Qa - Chat*cd(:,1)-Khat*c(:,1));
k1 = 5e6;
k2 = 5e6;

[Amat,Gmat] = TransformMat(c(4:6,1));

omega_hist = zeros(3,nstep);
omega_hist(:,1) = Gmat*phi_dot0;

%Attach springs to nodes 65 and 35
%Global positions of springs
rsp1 = [0;0;-0.5];
rsp2 = [0;0;0.5];
nodeEnd1 = 65;
nodeEnd2 = 35;
nodeMid = 50;
t = zeros(nstep+1,1);

disp('Starting integration ...')
prog = 0;
for i=1:nstep
    t(i+1) = i*h;
    
    % Predictor step
    cs = c(:,i)+h*cd(:,i)+(1/2-beta)*h^2.*cdd(:,i);
    cds = cd(:,i)+(1-gamma)*h.*cdd(:,i);
    %Extract flexible parts
    cfsbar = B*cs(7:end);
    
    %Calculate transformation matrix from prediction
    [A,G] = TransformMat(cs(4:6));
    
    F = Fgrav.*100; 
    
    %Find global position of nodes 65 and 35
    r1 = cs(1:3) + A*xbar(nodeEnd1*3-2:nodeEnd1*3) + A*cfsbar(nodeEnd1*3-2:nodeEnd1*3);
    r2 = cs(1:3) + A*xbar(nodeEnd2*3-2:nodeEnd2*3) + A*cfsbar(nodeEnd2*3-2:nodeEnd2*3);
    l1 = r1-rsp1;
    l2 = r2-rsp2;
    u1 = l1./sqrt(l1.'*l1);
    u2 = l2./sqrt(l2.'*l2);
    F(nodeEnd1*3-2:nodeEnd1*3) = F(nodeEnd1*3-2:nodeEnd1*3) - k1.*l1;%k1*norm(l1,2)*u1;
    F(nodeEnd2*3-2:nodeEnd2*3) = F(nodeEnd2*3-2:nodeEnd2*3) - k2.*l2;%*norm(l2,2)*u2;
    
%     F(nodeMid*3-1) = F(nodeMid*3-1) - 100000;
    
    [Mhat,Chat,Khat,Qv,Qa] = buildEOM(M,C,K,cs(4:6),cds(4:6),xbar,B*cs(7:end),B*cds(7:end),F,B);
    
    %Apply moment to body
%     Qa(6) = Qa(6) + 1000;

    
    S = Mhat + h*gamma*Chat + h^2*beta*Khat;
    
    %Calculate global position of node
    
    RHS = Qa+Qv;
    cdd(:,i+1) = S\(RHS-Chat*cds-Khat*cs);
    c(:,i+1) = cs + h^2*beta.*cdd(:,i+1);
    cd(:,i+1) = cds + h*gamma.*cdd(:,i+1);
    [Amat,Gmat] = TransformMat(c(4:6,i+1));
    omega_hist(:,i+1) = Gmat*cd(4:6,i+1);
    
    %Write progess
    if (i/nstep*100-10>=prog)
        prog = i/nstep*100;
        fprintf("Progess: %.1f%%\n",prog)
    end
    
end
%
fprintf("Reconstructing full solution . . .\n")
writeTimeSeriesFull(Nodes,xbar,c,t,B)
fprintf("Done!\n")