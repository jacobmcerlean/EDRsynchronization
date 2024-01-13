function E = dmEDR(ecg, beats, R, k)


%description: 
% Diffusion map based algorithm for EDR signal is implemented.
%
% References:
% 1.    R. R. Coifman and S. Lafon, "Diffusion maps," 
%       Applied and Computational Harmonic Analysis, 
%       vol. 21, no. 1, pp. 5-30, 2006/07/01/ 2006, 
%       doi:https://doi.org/10.1016/j.acha.2006.04.006
%
% 2.    Y.-T. Lin, J. Malik and H.-T. Wu.
%       "Wave-shape oscillatory model for nonstationary periodic time series analysis," 
%       Foundations of Data Science, 
%       vol. 3 no. 2, pp. 99-131, 2021
%
%inputs
%       pre-processed ECG signal at 1000Hz        : ecg
%           beat array                            : beats
%           R peak array                          : R
%           embedding dimension                   : k

%output
%   diffusion map EDR estimates: dmEDR

        dd = pdist2(beats, beats, 'squaredeuclidean');
        sigma = median(dd, 2);
        W = exp(-dd ./ sigma);
        W = (W + W')/2; % symmetrize
        D = sum(W, 2); % alpha normalize
        W = bsxfun(@rdivide, bsxfun(@rdivide, W, D), transpose(D));
        D = sqrt(sum(W, 2));
        W = bsxfun(@rdivide, bsxfun(@rdivide, W, D), transpose(D));
        [E, L] = eigs((W + W') / 2, k + 1, 'lm');
        E = bsxfun(@rdivide, E(:, 2:end), D);
        E = E * L(2:end, 2:end);
        time = 1/10:1/10:length(ecg)/1000;
        E= standardize(interp1(R/1000, E, time, 'pchip', nan));
end