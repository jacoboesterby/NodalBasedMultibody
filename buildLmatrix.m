function L = buildLmatrix(phi,xbar,cfbar)
    Phit = repmat(eye(3,3),[length(xbar)/3,1]);
    rfbar = xbar + cfbar; 
    rfbartilde = skew_symmetric(rfbar);
    [A,G] = TransformMat(phi);
%     Abd = spalloc(length(xbar),length(xbar),9*length(xbar)/3);
    
    %Create block diagonal skew symmetric matrix
    A_Cell = repmat({A},1,length(xbar)/3);
    Abd = blkdiag(A_Cell{:});
    %Build sparse block diagonal matrix
%     for i=1:length(xbar)/3
%         k = ones(9,1).*i*3-[2;1;0;2;1;0;2;1;0];
%         j = ones(9,1)*i*3-[2;2;2;1;1;1;0;0;0];
%         block = sparse(k,j,A(:),length(xbar),length(xbar),9);
%         Abd = Abd + block;
%     end
    L = [Phit,-Abd*rfbartilde*G,Abd];
end