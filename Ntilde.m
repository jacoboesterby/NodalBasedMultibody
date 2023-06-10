function skew_vn=Ntilde(c,Nn)
    dim=3;
    for i=1:Nn
      skew_vn((i-1)*dim+1:i*dim,1:3)=tilde(c((i-1)*dim+1:i*dim));
    end 
end

% if dim=2 or dim=1 this is not working; add ifs!!!!