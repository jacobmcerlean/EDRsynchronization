function SX = synchEDR(X)

% Phase-synchronizae a collection of EDR signals using the Graph
% Connection Laplacian (GCL). Pairwise phase deviations are esimated
% by considering the Hilbert transforms of pairs of signals.
% These pairwise deviations are entered into a Hermitian matrix,
% whose dominant eigenvector estimates global phase deviations.
% EDR signals are then phase aligned, up to a simultaneous phase
% deviation of all signals.

%inputs
%       matrix of individual EDR estimates to phase synchronize:     X


%output
%       matrix of phase-synchronized EDR estimates :                 SX


%form Graph Connection Laplacian matrix 
GCL = ones(size(X, 2)) ;

%remove nan values
tmp = all(~isnan(X), 2);
X = X(tmp, :) ;


%number of EDR estimates to align
num_est = size(X, 2);

for j = 1: num_est

    %EDR estimate signal j
    sig_j = X(:, j) ;

    for k = j+1: num_est
        
            %EDR estimate signal k
              sig_k = X(:, k) ;
              
              %pairwise phase deviation of signals: a
              a = hilbert(sig_k)' * hilbert(sig_j) ;
              a = a./norm(a) ;
               
              %enter pairwise phase deviation into Hermitian matrix GCL
              GCL(j, k) = a;
              GCL(k, j) = conj(a) ;
    end
end

%eigendecompose GCL
[u, l] = eig(GCL) ;

%global phase  deviation approximated by top eigenvector u
u = conj(u) ;

%phase-synchronize the EDR estimate signals

SX = [];

for signal_index = 1:num_est
    SX(:, signal_index) = real(hilbert(X(:, signal_index)) * u(1,end)) ;
end



end