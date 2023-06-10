function dofs = node2dof(nodenr)
dofs = zeros(length(nodenr)*3,1);
for i=1:length(nodenr)
    dofs(i*3-2:i*3) = (nodenr(i)*3-2):(nodenr(i)*3);
end
end