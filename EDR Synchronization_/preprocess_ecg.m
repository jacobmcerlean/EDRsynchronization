function [prep_ecg, Q, R, S, B] = preprocess_ecg(ecg, Fs)

%inputs:
%           unprocessed ECG signal      : ecg
%           sampling rate               : Fs

%outputs: 
%           preprocessed ECG at 1000 Hz : prep_ECG
%           R peaks array               : R 
%           Q peaks array               : Q 
%           S peaks array               : S
%           beats array                 : B


%resample ECG signal to 1000 Hz
ecg = resample(ecg, 1000, Fs);

%negative signal to track
neg_ecg = -ecg;


% detect R peaks with two detection algorithms
R1 = HRCFTG(ecg, 1000);
R2 = HRCFTG_d(ecg, 1000);

neg_R1 = HRCFTG(neg_ecg, 1000);
neg_R2 = HRCFTG_d(neg_ecg, 1000);

% preprocess ecg
[b, a] = butter(3, 40 / 500);
ecg = filtfilt(b, a, ecg);
ecg = ecg - movmedian(ecg, 200);

[neg_b, neg_a] =  butter(3, 40 / 500);
neg_ecg = filtfilt(neg_b, neg_a, neg_ecg);
neg_ecg = neg_ecg - movmedian(neg_ecg, 200);

% shift peaks to maxima
R1 = Jump2Max(ecg, R1, 40);
R2 = Jump2Max(ecg, R2, 40);

neg_R1 = Jump2Max(neg_ecg, neg_R1, 40);
neg_R2 = Jump2Max(neg_ecg, neg_R2, 40);

% match peaks
[R1, R2] = BeatMatch(R1, R2, length(ecg));

[neg_R1, neg_R2] = BeatMatch(neg_R1, neg_R2, length(ecg));

% detect S peaks
S1 = nan(size(R1));
range = 60; % ms
for i = 1:length(R1)
    try [~, S1(i)] = min(ecg(R1(i)+1:R1(i)+range));
        S1(i) = S1(i) + R1(i);
    catch
    end
end

neg_S1 = nan(size(R1));
range = 60; % ms
for i = 1:length(R1)
    try [~, neg_S1(i)] = min(neg_ecg(neg_R1(i)+1:neg_R1(i)+range));
        neg_S1(i) = neg_S1(i) + neg_R1(i);
    catch
    end
end

% remove peaks that are too close to edge of signal
id = R1 > 150 & R1 < length(ecg) - 150;
S1 = S1(id);
R1 = R1(id);


neg_id = neg_R1 > 150 & neg_R1 < length(ecg) - 150;
neg_S1 = neg_S1(neg_id);
neg_R1 = neg_R1(neg_id);

%flip signal if its orientation has been reversed



med_R_peak = median(ecg(R1));
neg_med_R_peak = median(neg_ecg(neg_R1));

med_ecg = median(ecg);
neg_med_ecg = median(neg_ecg);

spread = med_R_peak - med_ecg;
neg_spread = neg_med_R_peak - neg_med_ecg;

if neg_spread > spread
    %disp("flip ecg signal")
    ecg = neg_ecg;
    R1 = neg_R1;
    S1 = neg_S1;

end




%find Q peaks: lowest observation within 50ms preceding R peak
Q1 =[];
for index = 1:length(R1)
    peak_index = R1(index);
    [~, Q_index]= min(ecg(peak_index - 50:peak_index-1));
    Q_index = Q_index + peak_index -51;
    Q1 = [Q1 Q_index];
end




% splice beats
l = 30;
r = 60;
B1 = nan(length(R1), l + r + 1);
for i = 1:length(R1)
    B1(i, :) = ecg(R1(i) - l:R1(i) + r);
end

prep_ecg = ecg;
R = R1;
S = S1;
Q = Q1;
B = B1;

end