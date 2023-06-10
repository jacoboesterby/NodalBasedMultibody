function [Amat,Gmat] = TransformMat(phi)
%This function builds the transformation matrix from euler parameters
% Amat = 2.*[p(1)^2+p(2)^2-1/2,p(2)*p(3)-p(1)*p(4),  p(2)*p(4)+p(1)*p(3);
%            p(2)*p(3)+p(1)*p(4),  p(1)^2+p(3)^2-1/2,p(3)*p(4)-p(1)*p(2);
%            p(2)*p(4)-p(1)*p(3),  p(3)*p(4)+p(1)*p(2),  p(1)^2+p(4)^2-1/2];

%From bryant angles (A.5 in Nikravesh)
Amat = [cos(phi(2))*cos(phi(3)),                                     -cos(phi(2))*sin(phi(3)),                                    sin(phi(2));
        cos(phi(1))*sin(phi(3))+sin(phi(1))*sin(phi(2))*cos(phi(3)), cos(phi(1))*cos(phi(3))-sin(phi(1))*sin(phi(2))*sin(phi(3)), -sin(phi(1))*cos(phi(2));
        sin(phi(1))*sin(phi(3))-cos(phi(1))*sin(phi(2))*cos(phi(3)), sin(phi(1))*cos(phi(3))+cos(phi(1))*sin(phi(2))*sin(phi(3)), cos(phi(1))*cos(phi(2))];

%Construct linear relation between bryant time derivatives and local
%angular velocity omega = G*phi_dot (From (A.7) in Nikravesh)
Gmat = [cos(phi(1))*cos(phi(3)),   sin(phi(3)), 0;
        -cos(phi(2))*sin(phi(3)),  cos(phi(3)), 0;
        sin(phi(2)),               0,           1];
end
