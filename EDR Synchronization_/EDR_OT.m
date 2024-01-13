function OTD = EDR_OT(u, X)
%EDR_OT Optimal transport distance between spectrograms of respiratory signals.
%  Calculuates the spectrograms and then the 1-Wasserstein distance between
%  their normalized columns (viewed as pdfs).  Freqency range:  Hz.
%   u   : respiratory signal
%   X   : EDR signal
%   
%   References:
%
%   1. I. Daubechies, Y. Wang, and H. T. Wu, 
%      "ConceFT: Concentration of frequency and time via a multitapered 
%       synchrosqueezing transform," Philosophical Transactions A, 2016.
%   2. I. Alikhani, K. Noponen, A. Hautala, R. Ammann, and T. Seppänen, 
%      "Spectral Data Fusion for Robust Ecg-Derived Respiration with 
%      Experiments in Different Physical Activity Levels," HEALTHINF, pp. 88–95, 2017.

u = u(:); 
X = X(:); 

g = any(isnan([u, X]), 2);
u(g) = [];
X(g) = [];

% parameters
Fs = 10;
hlength = 200;
hf = 2;
gamma = 0.03;
hop = 1;
n = 300;
lf = 0.01;
ths = 1;

% time-frequency representation
Cu = deShape_Jb(u, Fs, hlength, hf, gamma, hop, n, lf, ths);
CX = deShape_Jb(X, Fs, hlength, hf, gamma, hop, n, lf, ths);

% spectrogram
Cu = abs(Cu.^2);
CX = abs(CX.^2);

% pdf
Cu = Cu ./ sum(Cu, 1);
CX = CX ./ sum(CX, 1);

% cdf
Cu = cumsum(Cu, 1);
CX = cumsum(CX, 1);

% L1 distance (integral)
OTD = mean(abs(Cu - CX), 1);

% average over time
OTD = mean(OTD);


end

