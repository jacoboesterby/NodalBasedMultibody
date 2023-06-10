t = 1:size(c,2);

%Recreate nodal positions
figure
hold on
step = 10;
x = zeros(99,length(t(1:step:end)));
y = zeros(99,length(t(1:step:end)));
z = zeros(99,length(t(1:step:end)));

for i=1:length(t(1:step:end))
    [A,G] = TransformMat(c(4:6,i));
    A_Cell = repmat({A},1,length(xbar)/3);
    Abd = blkdiag(A_Cell{:});
    cf = Abd*(Psi*c(7:end,i)).*5;
    xglob = Abd*xbar;
    x(:,i) = c(1,i) + xglob(1:3:end) + cf(1:3:end) - (c(1,1) + xbar(1:3:end));
    y(:,i) = c(2,i) + xglob(2:3:end) + cf(2:3:end) - (c(2,1) + xbar(2:3:end));
    z(:,i) = c(3,i) + xglob(3:3:end) + cf(3:3:end) - (c(3,1) + xbar(3:3:end));
    
    clf
    xx = c(1,i) + xglob(1:3:end) + cf(1:3:end);
    yy = c(2,i) + xglob(2:3:end) + cf(2:3:end);
    zz = c(3,i) + xglob(3:3:end) + cf(3:3:end);
    plot3(xx,zz,yy,'.','markersize',15,'color','b')
    axis([-0.2,0.2,-0.7,0.7,-0.3,0.3])
    xlabel('X')
    ylabel('Z')
    zlabel('Y')
    view(-90,0)
    drawnow
    pause(0.1)
end

%%
dlmwrite('NDt.txt',t(1:step:end))
dlmwrite('NDx.txt',x)
dlmwrite('NDy.txt',y)
dlmwrite('NDz.txt',z)