% Example implementation of EDR synchronization algorithm,
% in cluding RQI screening, phase-synchronization, and ensembling,
% as well as evaluation of EDR signals by gamma-score, optimal transporrt
% distance, and estimated average respiratory rate metrics.

%load ecg segment and specify its sampling rate:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%enter path to .edf file
path = '';
ecg = edfread([path],  'SelectedSignals',["Sig9 ECG I"]);
ecg = timetable2table(ecg);
ecg = ecg{:,2};
ecg = vertcat(ecg{:}) ;

 % start and finish time in seconds for 2 min segment
 signal_length = 2;
 start = 2000;
 finish = start - 1 + signal_length * 60;

%sampling rate
Fs = 200

%cut ecg segment
 ecg_seg = ecg((start - 1) * Fs + 1:finish * Fs);




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load reference signal
ref = edfread([path], 'SelectedSignals',["Sig14 Airflow"]);
ref = timetable2table(ref);
ref = ref{:,2};
ref = vertcat(ref{:}) ;
ref_seg = ref((start - 1) * 100 + 1:finish * 100);

%resample reference signal to 10Hz from 100Hz
ref_seg = resample(ref_seg, 10, 100);


%apply lowpass filtered reference signal at 10Hz to 1.5 Hz

ref_seg = lowpass(ref_seg, .15, 10);

%%%%%

%preprocess ecg segment and obtain R,Q,S peaks and beats arrays
[prep_ecg, Q,R,S, B] = preprocess_ecg(ecg_seg, Fs);

%form individual EDR estimates
T = tradEDR(prep_ecg, R, S);
DM = dmEDR(prep_ecg, B,R,1); 
[Up, Dwn, Rang] = qrsEDR(prep_ecg,Q, R, S, B)

%set RQI threshhold between 0 and 1. Value of 0 does not screen for RQI.
RQIthresh = .2

%compute RQIs for individual EDR estimates
T_RQI = getRQI_total_signal(T)
DM_RQI = getRQI_total_signal(DM)
Rang_RQI = getRQI_total_signal(Rang)

%initialize array to hold EDR estimates to be ensembled
ToEns = [];

%include only the EDR estimates above threshold for ensemble.
if T_RQI > RQIthresh
    ToEns = [ToEns T];
end
if DM_RQI > RQIthresh
    ToEns = [ToEns DM'];
end
if Rang_RQI > RQIthresh 
    ToEns = [ToEns Rang'];
end

%if quality EDR estimates non-empty, synchronize and ensemble.
if isempty(ToEns)
    disp("No signals above RQI threshhold.")
else
   %phase-synchronize the signals
   S =  synchEDR(ToEns);

   %ensemble the phase-synchronized signals
   U = ensemble(S);
end

%plot signals


%evaluate accuracy metrics for individual EDR signals with respect to reference
%gamma and earr range 0 to 100, with a higher score indicating greater accuracy
%otd ranges 0 to 1, with a lower score indicating greater accuracy

[T_gamma, ~, T_otd, T_earr] = EDR_Regression(ref_seg, T(~isnan(T)));
[DM_gamma, ~, DM_otd, DM_earr] = EDR_Regression(ref_seg, DM(~isnan(DM))');
[Rang_gamma, ~, Rang_otd, Rang_earr] = EDR_Regression(ref_seg, Rang(~isnan(Rang))');

%evaluate accuracy metrics for ensembled EDR signal with respect to reference
[ens_gamma, ~, ens_otd, ens_earr] = EDR_Regression(ref_seg, U);


