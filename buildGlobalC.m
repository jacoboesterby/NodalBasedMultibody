function Chat = buildGlobalC(C,Pr)

Chat = zeros(6+size(Pr,2),6+size(Pr,2));
Chat(7:end,7:end) = Pr.'*C*Pr;
end