clear all
%====== Control parameters ==========%
%Use full or CMS reduced structure
CMSRed = true;
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


%% Craig bampton reduction
if CMSRed
    %Define "boundary nodes" as nodes on left end, right end and disc nodes
    %     Sb =
    %     Nodes(Nodes(:,4)<-0.21|Nodes(:,4)>0.21|(Nodes(:,4)>-0.012&Nodes(:,4)<0.01),:);%Applies for the rotor file
    
    
    Sb = Nodes(Nodes(:,4)<-0.4|Nodes(:,4) == 0 | Nodes(:,4) > 0.4,:);%Applies to the bar file
    SI = Nodes(setdiff(Nodes(:,1),Sb(:,1)),:);
    
    if VisMod
        figure
        subplot(1,2,1)
        plot3(Sb(:,2),Sb(:,3),Sb(:,4),'.','markersize',20,'color','green','displayname','Boundary nodes')
        hold on
        
        plot3(SI(:,2),SI(:,3),SI(:,4),'.','markersize',20,'color','blue','displayname','Internal nodes')
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        axis equal
        subplot(1,2,2)
        plot3(Nodes(:,2),Nodes(:,3),Nodes(:,4),'.','markersize',20)
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        axis equal
    end
    
    % [~,Phi] = eigs(K,M,10,'smallestabs');
    % fnat = sqrt(diag(Phi))./(2*pi);
    
    %Convert node sets to dofs
    SIdof = node2dof(SI(:,1));
    Sbdof = node2dof(Sb(:,1));
    % Boundary condition on interface dofs
    %Not needed when boundary nodes do not serve as interface between two
    %reduces structures
    %     for i=1:length(Sbdof)
    %         K(Sbdof(i),:) = 0;
    %         K(:,Sbdof(i)) = 0;
    %         K(Sbdof(i),Sbdof(i)) = 1;
    %     end
    
    %Calculate static condensation of internal dofs
    Psi1 = -K(SIdof,SIdof)\K(SIdof,Sbdof);
    %     [temp1,~] = eigs(K(S1dof,S1dof),M(S1dof,S1dof),40,'smallestabs');
    
    %Proportional damping (Later build modal damping matrix!)
    fprintf('Create modal damping matrix instead of proportional!\n')
    C = (1e-4.*M  + 1e-4.*K).*0;

    
    %Construct sub-matrices KBB, KII, KBI, KIB, MBB, MII, MBI, MIB
    KBB = K(Sbdof,Sbdof);
    KII = K(SIdof,SIdof);
    KBI = K(Sbdof,SIdof);
    KIB = K(SIdof,Sbdof);
    
    MBB = M(Sbdof,Sbdof);
    MII = M(SIdof,SIdof);
    MBI = M(Sbdof,SIdof);
    MIB = M(SIdof,Sbdof);
    
    CBB = C(Sbdof,Sbdof);
    CII = C(SIdof,SIdof);
    CBI = C(Sbdof,SIdof);
    CIB = C(SIdof,Sbdof);
    
    %When there are boundary dofs, there are no rigid body modes that
    %should be treated separately
    %Calculate dynamic modes
    dynmodes = 20;
    [XI,Lambda] = eigs(KII,MII,dynmodes,'smallestabs');
    %Calculate mode shape normalization matrix
    
    %Calculate mass normalized mode shapes
    mr = transpose(XI)*MII*XI;
    XIbar = XI*mr^(-1/2);
    
    %Construct reduction matrix
    Psi = [eye(length(Sbdof),length(Sbdof)),zeros(length(Sbdof),size(XIbar,2));
        -KII^(-1)*KIB, XIbar];
    
    %Rearrange (R for rearranged) matrices to follow reduction scheme (x = [X_b;X_I])
    KR = [KBB,KBI;
          KIB,KII];
    
    MR = [MBB,MBI;
          MIB,MII];
      
    CR = [CBB,CBI;
          CIB,CII];
    
    %Build reduced matrices using transformation matrix
    Ktilde = transpose(Psi)*KR*Psi;
    Mtilde = transpose(Psi)*MR*Psi;
    Ctilde = transpose(Psi)*CR*Psi;
    
    %Calculate second eigenvalue problem
    [Phi,Lambda] = eig(Ktilde,Mtilde);
    %ascending order
    [Lam,order] = sort(diag(Lambda));
    Phi = Phi(:,order);
    %Discard rigid body modes
    Phi= Phi(:,7:end);
    %"Mass" normalize
    mr = transpose(Phi)*(Psi.'*M*Psi)*Phi;
    Phibar = Phi*mr^(-1/2);
    %Construct final reduction matrix
    Psi = Psi*Phibar;
    
    
    %Build matrix using (6.184 in Rixen)
    
    KBBtilde = KBB-KBI*KII^(-1)*KIB;
    MBBtilde = MBB-MBI*KII^(-1)*KIB-KBI*KII^(-1)*MIB+KBI*KII^(-1)*MII*KII^(-1)*KIB;
    MBtilde = transpose(XIbar)*(MIB-MII*KII^(-1)*KIB);
    
    
    Ktilde1 = [KBBtilde,zeros(length(Sbdof),size(Lambda,2));
        zeros(size(Lambda,1),length(Sbdof)),Lambda];
    Mtilde1 = [MBBtilde,MBtilde.';
        MBtilde,eye(size(MBtilde,1),size(MBtilde,1))];
    
    %Both methods are equivalent!
    %Create reduction matrix Psi from n modes excluding rigid body modes
    %     [Psi,Lambda] = eigs(K,M,10,'smallestabs');
    %     Psi = Psi(:,7:end);
    %Create dof- and node map to convert between reduced set and full set
    [~,nodeG2R] = sort([Sb(:,1);SI(:,1)]);
    [~,dofG2R]  = sort([Sbdof;SIdof]);
    % Create map between global and rearranged set
    [~,nodeR2G] = sort(nodeG2R);
    [~,dofR2G]  = sort(dofG2R);
end
%%

% Build rbm to flex dofs transforamtion matrix Phi_t. Eq (12)
Phit = repmat(eye(3,3),[size(Nodes,1),1]);
%Build block diagonal identity matrix Ibd
Ibd = eye(3*size(Nodes,1));


% Create vector containing dof reference position (Constant)
%Rearrange nodes to contain same order as the CB reduced set
NodesR         = Nodes(nodeR2G,:);
xbar           = zeros(3*size(Nodes,1),1);
xbarR          = zeros(3*size(Nodes,1),1);

%Original set
xbar(1:3:end)  = Nodes(:,2); %x-positions
xbar(2:3:end)  = Nodes(:,3); %y-positions
xbar(3:3:end)  = Nodes(:,4); %z-positions
%Rearranged set
xbarR(1:3:end) = NodesR(:,2);
xbarR(2:3:end) = NodesR(:,3);
xbarR(3:3:end) = NodesR(:,4);


%Newmark integration scheme
h     = 1e-4;
gamma = 1/2;
beta  = 1/4;
nstep = 10000;

%Allocate time history deformation matrix
cdd = zeros(6+size(Psi,2),nstep);
cd  = zeros(6+size(Psi,2),nstep);
c    = zeros(6+size(Psi,2),nstep);
cf   = zeros(size(Psi,2),nstep);

%Initial parameters

r0           = [0,0,0].';
% p0           = [cos(0),0,0,sin(0)].'; %Euler parameters
phi0         = [0,0,0].';
omega_bar0   = [0,0,0].';
%Convert angulat velocity to bryant angle derivatives
phi_dot0     = omega2phi_dot(phi0)*omega_bar0;
rd0          = [0,0,0].'; %No initial velocity
eta0         = Psi\zeros(size(M,2),1); %No initial deformation
eta_dot0     = Psi\zeros(size(M,2),1); %No initial deformation velocity
c(:,1)       = [r0;phi0;eta0];
cd(:,1) = [rd0;phi_dot0;eta_dot0];

% Apply gravitational pull
Fgrav = zeros(size(K,1),1);
% grav = zeros(size(M,1),1);
% grav(2:3:end) = -9.82;
% FF = M*grav;
%Read gravity nodal force from file (To avoid needing to do integration)
forceFile = readmatrix('SoftBar_LOAD1.txt');%(This containes nodal indices and their respective force)
Fgrav(forceFile(:,1)) = forceFile(:,2);
% F = zeros(length(xbar),1);
FR = Fgrav(dofR2G); %Rearranged global force vector
%Add initial force
% F(50*3-1) = -100;

[Mhat,Chat,Khat,Qv,Qa] = buildEOMModal(MR,CR,KR,Psi,phi0,phi_dot0,xbarR,eta0,eta_dot0,FR);
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
rsp11 = [-0.1;0;-0.5];
rsp12 = [0.1;0;-0.5];
rsp21 = [-0.1;0;0.5];
rsp22 = [0.1;0;0.5];
nodeEnd11 = 32;
nodeEnd12 = 98;
nodeEnd21 = 2;
nodeEnd22 = 68;

%Nodes
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
    cfsbarR = Psi*cs(7:end);
    
    %Calculate transformation matrix from prediction
    [A,G] = TransformMat(cs(4:6));
    FR = Fgrav(dofR2G);
    %%%%%%%%%%%%%%%%%%%%%%%% Two springs at end %%%%%%%%%%%%%%%%%%%%%%%%%%%
%         r11 = cs(1:3) + A*xbar(nodeEnd11*3-2:nodeEnd11*3) + A*cfsbar(nodeEnd11*3-2:nodeEnd11*3);
%         r12 = cs(1:3) + A*xbar(nodeEnd12*3-2:nodeEnd12*3) + A*cfsbar(nodeEnd12*3-2:nodeEnd12*3);
%         r21 = cs(1:3) + A*xbar(nodeEnd21*3-2:nodeEnd21*3) + A*cfsbar(nodeEnd21*3-2:nodeEnd21*3);
%         r22 = cs(1:3) + A*xbar(nodeEnd22*3-2:nodeEnd22*3) + A*cfsbar(nodeEnd22*3-2:nodeEnd22*3);
%         l11 = r11-rsp11;
%         l12 = r12-rsp12;
%         l21 = r21-rsp21;
%         l22 = r22-rsp22;
%         u11 = l11./sqrt(l11.'*l11);
%         u12 = l12./sqrt(l12.'*l12);
%         u21 = l21./sqrt(l21.'*l21);
%         u22 = l22./sqrt(l22.'*l22);
%         F(nodeEnd11*3-2:nodeEnd11*3) = F(nodeEnd11*3-2:nodeEnd11*3) - k1*norm(l11,2)*u11;
%         F(nodeEnd12*3-2:nodeEnd12*3) = F(nodeEnd12*3-2:nodeEnd12*3) - k1*norm(l12,2)*u12;
%         F(nodeEnd21*3-2:nodeEnd21*3) = F(nodeEnd21*3-2:nodeEnd21*3) - k2*norm(l21,2)*u21;
%         F(nodeEnd22*3-2:nodeEnd22*3) = F(nodeEnd22*3-2:nodeEnd22*3) - k2*norm(l22,2)*u22;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%% One spring at end %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                  xbar(dofs) = xbarR(dofG2R(dofs))                   %
    %                   xbarR     = xbar(dofR2G)                          %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    r1 = cs(1:3) + A*xbarR(dofG2R(nodeEnd1*3-2:nodeEnd1*3)) + A*cfsbarR(dofG2R(nodeEnd1*3-2:nodeEnd1*3));
    r2 = cs(1:3) + A*xbarR(dofG2R(nodeEnd2*3-2:nodeEnd2*3)) + A*cfsbarR(dofG2R(nodeEnd2*3-2:nodeEnd2*3));
    l1 = r1-rsp1;
    l2 = r2-rsp2;
    u1 = l1./sqrt(l1.'*l1);
    u2 = l2./sqrt(l2.'*l2);
    FR(dofG2R(nodeEnd1*3-2:nodeEnd1*3)) = FR(dofG2R(nodeEnd1*3-2:nodeEnd1*3)) - k1.*l1;%k1*norm(l1,2)*u1;
    FR(dofG2R(nodeEnd2*3-2:nodeEnd2*3)) = FR(dofG2R(nodeEnd2*3-2:nodeEnd2*3)) - k2.*l2;%*norm(l2,2)*u2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       FR = F(dofG2R)                                %
    %                        F = FR(dofR2G)                               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Dampers
    %     cds(1:3) + 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     FR(dofG2R(nodeMid*3-1))             = FR(dofG2R(nodeMid*3-1)) + 1000*cos(Omega*t(i+1));
    
    [Mhat,Chat,Khat,Qv,Qa] = buildEOMModal(MR,CR,KR,Psi,cd(4:6),cds(4:6),xbarR,cs(7:end),cds(7:end),FR);
%     Qa(6) = Qa(6) + 0.8;
    
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
fprintf("Reconstructing full solution . . .\n")
writeTimeSeriesModal(Nodes,xbar,c,t,Psi,dofG2R);
fprintf("Done!\n")

