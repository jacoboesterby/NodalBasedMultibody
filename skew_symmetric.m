function r_tilde = skew_symmetric(r)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function computes the skew_symmetric matrix of either vector r or
%matrix r. If dim(r) = nx1, then r_tilde = [r_tilde1,r_tilde2,...].'
%If dim(r) = nxm, then r_tilde = [r_tilde(:,1),r_tilde(:,2,...]
%Input:        r: Vector or matrix top compute skew symmetric matrix from
%Output:       r_tilde: Resulting skew symmetric matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(r,2)==1
    %Build matrix of skew symmetric matrices r_tilde =
    %[r1_tilde;r2_tilde;...]
    r_tilde = zeros(size(r,1),3);
    r_tilde(2:3:end,1) =  r(3:3:end);
    r_tilde(3:3:end,1) = -r(2:3:end);
    r_tilde(1:3:end,2) = -r(3:3:end);
    r_tilde(3:3:end,2) =  r(1:3:end);
    r_tilde(1:3:end,3) =  r(2:3:end);
    r_tilde(2:3:end,3) = -r(1:3:end);
else
    r_tilde = zeros(size(r,1),3*size(r,2));
    for i=1:size(r,2)
        r_tilde(2:3:end,i*3-2) =  r(3:3:end,i);
        r_tilde(3:3:end,i*3-2) = -r(2:3:end,i);
        r_tilde(1:3:end,i*3-1) = -r(3:3:end,i);
        r_tilde(3:3:end,i*3-1) =  r(1:3:end,i);
        r_tilde(1:3:end,i*3)   =  r(2:3:end,i);
        r_tilde(2:3:end,i*3)   = -r(1:3:end,i);
    end
end