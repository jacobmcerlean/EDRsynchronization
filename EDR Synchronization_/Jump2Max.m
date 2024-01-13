function R = Jump2Max(ecg, R, smp)


% column vector
ecg = ecg(:);

for i = 1:length(R)
   [~, id] = max(ecg(max(1, R(i)-smp):min(length(ecg), R(i)+smp)));
   R(i) = max(1, R(i)-smp) + id - 1;
end

% debug
R = unique(R);


end

