 function [RA, RB] = BeatMatch(RA, RB, N)

 %description: match peaks from two arrays of R-peaks from same ecg signal


 %inputs
 %          RA - first R peak array
 %          RA - second R peak array
 %          ecg - ecg signal


 %outputs
 %          RA - matched R peak array A
 %          RB - matched R peak array B


        
        gp = 150; % 150 ms at 1000 Hz
        
        AMap = nan(length(RA), 1);
        BMap = nan(length(RB), 1);
        
        CurrentB = 1;
        CurrentA = 1;
        
        RA = [RA(:); inf];
        RB = [RB(:); inf];
        
        while RB(CurrentB) <= N || RA(CurrentA) <= N
            if RA(CurrentA) < RB(CurrentB) % t precedes T, case 1
                if abs(RB(CurrentB) - RA(CurrentA)) < abs(RB(CurrentB) - RA(CurrentA + 1)) && abs(RB(CurrentB) - RA(CurrentA)) <= gp % case i
                    BMap(CurrentB) = CurrentA; % match
                    AMap(CurrentA) = CurrentB;
                    CurrentB = CurrentB + 1; % next reference
                    CurrentA = CurrentA + 1; % next prediction
                else % case ii
                    CurrentA = CurrentA + 1; % next prediction
                end
            else % t does not precede T, case 2
                if abs(RA(CurrentA) - RB(CurrentB)) < abs(RA(CurrentA) - RB(CurrentB + 1)) && abs(RA(CurrentA) - RB(CurrentB)) <= gp % case i
                    BMap(CurrentB) = CurrentA; % match
                    AMap(CurrentA) = CurrentB;
                    CurrentB = CurrentB + 1; % next reference
                    CurrentA = CurrentA + 1; % next prediction
                else % case ii
                    CurrentB = CurrentB + 1;
                end
            end
        end
        
        RA = RA(BMap(~isnan(BMap)));
        RB = RB(AMap(~isnan(AMap)));
        
    end