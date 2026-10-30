function multracePlot(traceData,figNumber,sampleRate)
% multracePlot(traceData, figNumber, sampleRate)
%
% Plots several traces in one figure, stacked vertically with an offset
% so each one can be seen separately. The x axis is time in seconds.
%
% Inputs:
%   traceData: data, one trace per row [nTraces x nSamples]                [double]
%   figNumber: number of the figure to plot in                             [double]
%   sampleRate: sample rate of the data, in Hz                             [double]
%
% Outputs: none
%
% Example:
%   multracePlot(randn(8, 1000), 1, 1000);
%
% Dependencies: wfig (utilities_matlab)
%
% Version history:
%   v0.1  2023      First version (multrace_plot)
%   v0.2  Oct 2026  Renamed to multracePlot; camelCase variables
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience

% initializing plotting data %%%%%%
plotData = zeros(size(traceData));
plotData(1,:) = traceData(1,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adding offsets to visualize each line separately %%%%%%%%%%%%%%%%%%%%
maxVals = max(traceData,[],2); % offsets of each line
for iline = 2:size(traceData,1)
    plotData(iline,:) = traceData(iline,:) + 1.1*sum(maxVals(1:iline-1)); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plotting and formating the figure %%%%%%%%%
wfig(figNumber)
plot((1:size(plotData,2))/sampleRate,plotData','color',0.4 * ones(1,3)); 
axis tight
set(gca,'TickDir','out','YColor','w');
box off; xlabel 'Time [s]'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%