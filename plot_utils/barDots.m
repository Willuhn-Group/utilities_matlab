function [hBar,hDots] = barDots(data,cfg)
% [hBar, hDots] = barDots(data, cfg)
%
% Plots one bar per column of data (mean), with error bars and the
% individual data points jittered around each bar. Paired data can be
% joined with lines.
%
% Inputs:
%   data: data, one column per bar [nObservations x nBars]                 [double]
%   cfg: configuration struct with fields (all optional)                    [struct]
%     position: x position of each bar (default: 1:nBars)                  [double]
%     barColor: bar color (default: 'k')                                   [char/double]
%     BarWidth: bar width (default: 0.8)                                   [double]
%     transparency: bar transparency (default: 0.5)                        [double]
%     error: true for SEM, false for SD error bars (default: true)         [logical]
%     dots: 'on' or 'off' to show the data points (default: 'on')          [char]
%     dotColor: color of the data points (default: 'k')                    [char/double]
%     dotSize: marker size of the data points (default: 3)                 [double]
%     maxJitter: maximum jitter of the points around the bar (default: 0.5) [double]
%     paired: true to join the points of each row with lines (default: false) [logical]
%
% Outputs:
%   hBar: bar handle                                                       [Bar]
%   hDots: data point handle(s), one per row if paired                     [Line]
%
% Example:
%   cfg = []; cfg.paired = true; cfg.barColor = [0.6 0.6 0.6];
%   [hBar, hDots] = barDots(randn(10, 2) + [1 2], cfg);
%
% Dependencies: none
%
% Version history:
%   v0.1  2023      First version
%   v0.2  Oct 2026  Added to utilities_matlab
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience


cfg = checkCfg(data,cfg);

localBar = plotBars(cfg,data);
localBar.FaceAlpha = cfg.transparency;
localBar.BarWidth = cfg.BarWidth;

if strcmp(cfg.dots,'on')
    localDots = plotDots(cfg,data);
end
hold off; box off

if nargout == 1
    hBar = localBar;
elseif nargout == 2
    hBar = localBar;
    hDots = localDots;
end

end

function hbar = plotBars(cfg,data)
hbar = bar(cfg.position,mean(data,'omitnan'),'facecolor',cfg.barColor);
errorBars = std(data,[],'omitnan');
if isfield(cfg,'error')   
    if cfg.error
        errorBars = errorBars/sqrt(size(data,1));
    end
end
hold on
errorbar(cfg.position,mean(data,'omitnan'),errorBars,'.k');
end


function hdots = plotDots(cfg,data)
% define the x coordinate of each data point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xDots = [];
for ibar = cfg.position
    dotJitter = ibar - cfg.maxJitter + 2*cfg.maxJitter*rand(size(data,1),1);
    xDots = cat(1,xDots,dotJitter);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg.paired
    xDots = reshape(xDots,size(data));
    nDots = size(data,1);
    hdots = nan(1,nDots);
    for idot = 1:nDots
        hdots(idot) = plot(xDots(idot,:),data(idot,:),'o-',...
            'markersize',cfg.dotSize, ...
            'Color', 0.75 * ones(1,3),...
            'MarkerFaceColor',cfg.dotColor,...
            'MarkerEdgeColor',cfg.dotColor);
    end
else
    hdots = plot(xDots,data(:),'o',...
        'markersize',cfg.dotSize, ...
        'Color', 0.75 * ones(1,3),...
        'MarkerFaceColor',cfg.dotColor, ...
        'MarkerEdgeColor',cfg.dotColor);
end

end

function cfg = checkCfg(data,cfg)

if ~isfield(cfg,'error')
    cfg.error = true;
end

if ~isfield(cfg,'dots')
    cfg.dots = 'on';
end

if ~isfield(cfg,'dotSize')
    cfg.dotSize = 3;
end

if ~isfield(cfg,'position')
    cfg.position = 1:size(data,2);
end

if ~isfield(cfg,'BarWidth')
    cfg.BarWidth = 0.8;
end

if ~isfield(cfg,'paired')
    cfg.paired = false;
end

if ~isfield(cfg,'maxJitter')
    cfg.maxJitter = 0.5;
end

if ~isfield(cfg,'transparency')
    cfg.transparency = 0.5;
end

if ~isfield(cfg,'dotColor')
    cfg.dotColor = 'k';
end

if ~isfield(cfg,'barColor')
    cfg.barColor = 'k';
end

end