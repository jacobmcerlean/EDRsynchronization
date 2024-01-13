function T = tradEDR(ecg, R, S)


%input:
%       pre-processed ECG signal at 1000Hz        : ecg
%       R peak array                              : R
%       S peak array                              : S

%output: 
%       traditional EDR estimate        : T

%build traditional EDR estimate
T = ecg(R) - ecg(S);

%interpolate at 10Hz

time = 1/10:1/10:length(ecg)/1000;

T = standardize(interp1(R/1000, T, time, 'pchip', nan)');








    