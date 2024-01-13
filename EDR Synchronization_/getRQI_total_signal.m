function [RQI]  = getRQI_total_signal(signal)

% Returns Respiratory Quality Index (RQI) value for a signal
%               
%   Input:
%       signal          : respiratory signal (EDR or hardware)

%   Output:
%       RQI:            : RQI value of signal
%
%   References:
%   [1] D. Birrenkott, "Respiratory Quality Index Design and Validation 
%       for ECG and PPG Derived Respiratory Data," 
%       University of Oxford Report for transfer of Status, 2015.

%remove nan values
signal = signal(~isnan(signal));

%detrends the signal
%in practice, this didn't seem to affect RQI too much
signal = detrend(signal);       
                  
%signal length in seconds: 
fs = 10;
n = length(signal);
sec = length(signal)/fs;
    
%create 3rd order bandpass butterworth filter
%filter to respiratory range .1-.75Hz
[b,a] = butter(3, [.1 .75]/(fs/2));
        
%Apply the filter after throwing away a few beginning and
% ending values to avoid delta-shift error when filtering.
% throwing away these values should have neglible
%effect on power spectrum.
filt_signal= filtfilt(b, a, signal(4:end-4));
                          
%fast Fourier transform of signal
Fsignal = fft(filt_signal);
                
%frequency  array
f = (0:n-8)*(1/sec);
f = reshape(f,n-7,1);

%power array
power = abs(Fsignal).^2/n;  
                               
%find max power in respiratory range and its associated frequency, Mm
resp_range = power(floor(.1*sec):ceil(.75*sec));
max_power = max(resp_range);
Mm = find(resp_range ==max_power);
% calculate maximum peak area (MPA) 
% defined as the sum of the three largest continuous set of values
% around largest value Mm on respiratory frequency 
% band of .1-.75Hz.
% Mm(1) to take location of first peak if there are more
% than 1.

index = floor(.1*sec + Mm(1) - 1);
MPA = power(index) + power(index-1) + power(index + 1);
        
% calculate total respiratory range (TRA), sum of all power values within
% respiratory range of .1Hz-.75Hz
TRA = sum(resp_range);

%FFT-RQI from [1] is ratio of MPA to TRA
RQI_val = MPA/TRA;

%assign RQI value into RQIs cell array
RQI = [RQI_val];

end
        
        
