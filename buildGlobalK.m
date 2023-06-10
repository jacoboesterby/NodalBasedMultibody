function Khat = buildGlobalK(K,Pr)
    Khat = zeros(6+size(Pr,2),6+size(Pr,2));
    Khat(7:end,7:end) = Pr.'*K*Pr;
end
