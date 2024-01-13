function [ Fresp ] = estimateRespFreq(fs, volume_or_flow,pars,varargin )
% Estimates respiratory frequency from volume or flow sinal by finding the
% peak in the spectrogram with a range pars.Tresp_range_breathsMin
%
% INPUTS:
% fs = sampling frequency
% volume_or_flow =  respiratory volume or flow signal
% pars.Tresp_range_breathsMin = range in breaths per Min were to look for the peak
%
% OUTPUTS:
% Fresp = respiratory frequency
%
% VARARGIN
% 'plot' = plot details on the 4 different steps 
%

% Process parameters  %
plotflag='';
n = 0;
while n < length(varargin)
	n = n + 1;
	if strcmp(varargin{n}, 'plot')
		plotflag = 'plot';	
	end
end

%default parameters
if isempty(pars)
	%default for children 
	pars.Tresp_range_breathsMin = [6 50];%find first resp rate between 6 and 50 breaths per minute
end

volume_or_flow=detrend(volume_or_flow);
	
% ESTIMATE REPIRATION PERIOD
% estimate resp period copied from  segmentAdvance( ipF_d(ixWin{w}), fs_d, 'step1only' ,'Step1window',1,'plot' );
w_pwelch = round(fs*1*60); %1 min
%if the window is lower than 1 min; set the pwelch window to maximun possible
if length(volume_or_flow)<w_pwelch w_pwelch = length(volume_or_flow); end
[P,F]=pwelch(volume_or_flow,hanning(w_pwelch),round(w_pwelch/3),1024*8,fs);%window
%find range
P(find(F<pars.Tresp_range_breathsMin(1)/60 | F>pars.Tresp_range_breathsMin(2)/60))=0;%find peak between A and B breaths per minute
[~,mix]=max(P);
Fresp = F(mix);



if strcmp(plotflag,'plot')
	 figure;
	%first round
	plot(F,20*log10(P));
	hold on 
	xlim([pars.Tresp_range_breathsMin(1)/60 pars.Tresp_range_breathsMin(2)/60])
	plot(F(mix),20*log10(P(mix)),'o')
	grid on
    title(['Fresp = ' num2str(Fresp)]);
	
end

%MIT License

%Copyright (c) 2019 javier-gracia-tabuenca

%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:

%The above copyright notice and this permission notice shall be included in all
%copies or substantial portions of the Software.

%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%SOFTWARE.
	