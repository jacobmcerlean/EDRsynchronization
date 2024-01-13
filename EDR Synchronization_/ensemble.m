function U = ensemble(synch_signals)


% description:
%   Ensembling method that can combine any number of EDR estimates.
%   A matrix is formed with the time-lagged representations of signals,
%   whose dominant left eigenvector represents the most phase-aligned
%   signal to the EDR estimates.

%
% input: 
%           matrix of phase-synchronized signals:        synch_signals

% output:
%           ensemble signal:                             U




S = synch_signals;

%number of signals
num_sigs = size(S, 2);

%buffer
lag = 10;
Bf = [];

for i = 1:num_sigs
    Bf = [Bf, buffer(S(:,i), lag, lag-1)'];
end

% Bf must be a double matrix
Bf = double(Bf);

% combine
y = all(~isnan(Bf), 2);
U = nan(size(S(:,1)));
[U(y, :), ~, ~] = svds(Bf(y, :), 1);
