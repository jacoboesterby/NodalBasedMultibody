function Fspring = Spring(rspring,c,phi,xbar,cfbar,k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SpringForce %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates the spring force resulting from the global
% position of dofs given in xbar and cfbar
% Inputs:       rsping  : Global position vector of the undeformed spring
%               c       : Global position of the rigid body reference frame
%               xbar    : Undeformed dof spatial positions
%               cfbar   : Local displacements of dofs
%               phi     : Bryant angles
%               k       : Spring uniform stiffness
%
% Output:       Fspring : 3x1 vector containing resulting forces in global coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculate rotation matrix A from Bryan Angles
[A,~] = TransformMat(phi);

%Calculate global position of nodal point
r = c + A*xbar + A*cfbar;
%Calculate spring deformation vector
l = r-rspring;
% u = l1./sqrt(l1.'*l1);
%Calculate spring force
Fspring = - k.*l;

end