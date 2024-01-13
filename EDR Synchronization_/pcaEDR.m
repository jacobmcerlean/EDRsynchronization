function P = pcaEDR(ecg,beats,R, k)

%inputs
%       pre-processed ECG signal at 1000Hz        : ecg
%           beat array                            : beats
%           R peak array                          : R
%           embedding dimension                   : k

%output
%   PCA EDR estimates: P

%PCA
[~, P] = pca(beats, 'centered', false, 'NumComponents', k);

%interpolate at 10 Hz

time = 1/10:1/10:length(ecg)/1000;
P= standardize(interp1(R/1000, P, time, 'pchip', nan));