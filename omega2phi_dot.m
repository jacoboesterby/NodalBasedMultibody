function Ginv = omega2phi_dot(phi)

Ginv = 1/cos(phi(2))*[cos(phi(3)),             -sin(phi(3)),            0;
                      sin(phi(3))*cos(phi(2)), cos(phi(3))*cos(phi(2)), 0; 
                      -cos(phi(3))*sin(phi(2)),sin(phi(3))*sin(phi(2)), cos(phi(2))];
end