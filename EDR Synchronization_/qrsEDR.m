function [upEDR, downEDR, angEDR] = qrsEDR(ecg, Q,R, S, B)



%input:
%       pre-processed ECG signal        : ecg
%       Q peak array                    : Q
%       R peak array                    : R
%       S peak array                    : S
%       beat array                      : B

%output: 
%       upward slope EDR estimate       : upEDR
%       downward slope EDR estimate     : downEDR
%       R-angle EDR estimate            : angEDR

%References
% [1] E. Pueyo, L. Sornmo and P. Laguna. 
% “QRS Slopes for Detection and  haracterization of Myocardial Ischemia,” 
% IEEE Transactions on Biomedical Engineering,
% vol. 55 no. 2, pp. 468-477, 2008.

% [2] J. Lázaro, A. Alcaine, D. Romero, E. Gil, P. Laguna, E. Pueyo, et al. 
% "Electrocardiogram derived respiratory rate from QRS slopes and R-wave angle," 
% Ann Biomed Eng, vol. 42, no.10, pp. 2072-83, 2014. 

% [3] S. Kontaxis, J. Lazaro, V. D. A. Corino, F. Sandberg, R. Bailon, 
% P. Laguna, et al. "ECG-Derived Respiratory Rate in Atrial Fibrillation," 
% IEEE Transactions on Biomedical Engineering, vol. 67 no. 3, pp. 905-914, 2020.
%

%initialized EDR estimate arrays
upEDR = [];
downEDR = [];
angEDR = [];


%number of QRS complexes
num_complexes = length(R);


%%implement the upward slope EDR UW


    %enumerate the pairs of R_i, Q_i for i = 1,...,num_complexes
    for i = 1: num_complexes

    %for each i: 
 

        %obtain indices for 
        R_ind = R(i);
        Q_ind = Q(i);

        %extract ecg segment
        segment = ecg(Q_ind:R_ind);

        %slope magnitudes
        slope_mags = abs(segment(2:end) - segment(1:end-1));

        %over all Q_i < j < R_i, do the following:
        %find the max |l'(j)| = |edr(j+1)- edr(j)|
        [~, max_index] = max(slope_mags);


        %find 8ms window of ecg around j. 
        window = ecg(Q_ind + max_index - 4: Q_ind + max_index + 4);

        %fit line to ecg using 8ms window around l*(j) to obtain slope
        time = uint32(1):uint32(9);
        time = cast(time, 'single');
   
        c = polyfit(time, window,1);

        %use slope as estimate for signal :)
        slope = c(1);
        upEDR  = [upEDR slope];
    end






%%construct the downward slope EDR estimate

    %enumerate the pairs of R_i, S_i (R_i < S_i) 
    % for i =1,...,num_complexes
    for i = 1: num_complexes

    %for each i: 
        
        %obtain indices for 
        R_ind = R(i);
        S_ind = S(i);

        %extract ecg segment
        segment = ecg(R_ind:S_ind);

        %slope magnitudes
        slope_mags = abs(segment(2:end) - segment(1:end-1));

        %over all R_i < j < S_i, do the following:
        %find the max |l'(j)| = |edr(j+1)- edr(j)|
        [~, max_index] = max(slope_mags);

        %find 8ms window of ecg around j. 
        window = ecg(R_ind + max_index - 4: R_ind + max_index + 4);

        %fit line to ecg using 8ms window around l*(j) to obtain slope
        time = uint32(1):uint32(9);
        time = cast(time, 'single');
        c = polyfit(time, window,1);

        %use slope as estimate for signal :)
        slope = c(1);
        downEDR  = [downEDR slope];
    end


%construct R-angle EDR estimate

for i =1:length(upEDR)
    u = upEDR(i);
    d = downEDR(i);
    angEDR(i) = atan(abs(u-d)/(1 + u*d));
end

time = 1/10:1/10:length(ecg)/1000;
upEDR= standardize(interp1(R/1000, upEDR, time, 'pchip', nan));
downEDR= standardize(interp1(R/1000, downEDR, time, 'pchip', nan));
angEDR= standardize(interp1(R/1000, angEDR, time, 'pchip', nan));


end
