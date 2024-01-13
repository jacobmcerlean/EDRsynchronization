function [value, lag, OTD, avg_freq_score] = EDR_Regression(u, X)
%EDR_METRIC Summary of this function goes here
%   Returns the gamma-score (value) of the EDR estimate X with 
%   respect to the reference signal u. It is defined as 100* the maximum
%   Pearson correlation coefficient of the reference signal compared to 
%   among a discrete set of uniformly phase-shifted versions of X (up to 
%   max lag) in each direction. Also calls for OTD and average frequency
%   scores.   



% References
% 1. D. Widjaja, C. Varon, A. Dorado, J. Suykens, and S. Van Huffel, 
% "Application of Kernel Principal Component Analysis for Single-Lead-Ecg-Derived 
% Respiration," 
% IEEE Transactions on Biomedical Engineering, vol. 59, no. 4, pp. IEEE: 1169–76, 201


% sampling rate
Fs = 10;
LEN = min(length(u), length(X)) ;
u = u(1:LEN);
X = X(1:LEN, :);
max_lag = 20;
u = u(:);
result = zeros(2*max_lag+1, 1);
for lag = -max_lag:max_lag
        phase = lag/max_lag*pi/2;
        X_trans = real(exp(1j*phase)*hilbert(X));
        lm = fitlm(X_trans, u);
        result(lag+max_lag+1) = sqrt(lm.Rsquared.Ordinary);
end
[value, lag] = max(result);
lag = lag - 1 - max_lag;
phase = lag/max_lag*pi/2;
X_trans = real(exp(1j*phase)*hilbert(X));

%obtain OT score
OTD = EDR_OT(u, X_trans);

%normalize gamma score
value =  100*value;

%average frequency accuracy metric
ref_af = estimateRespFreq(Fs, u, []);
edr_af = estimateRespFreq(Fs, X,[]);
avg_freq_score = 100*(1 - abs(ref_af-edr_af)/edr_af);

end

