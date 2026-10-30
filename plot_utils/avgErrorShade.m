function outPrint = avgErrorShade(cfg)
% out = avgErrorShade(cfg)
%
% Plots the mean of several traces as a line and their dispersion (SEM,
% 95% confidence interval or SD) as a shaded area, in the current axes.
%
% Inputs:
%   cfg: configuration struct with fields, or only the ydata matrix         [struct/double]
%     ydata: data, one trace per row [nObservations x nSamples]             [double]
%     xdata: x axis values (optional, default: sample number)              [double]
%     errRef: 'sem', 'ci' (95% confidence interval) or 'std'               [char]
%       (optional, default: 'sem')
%     color: line and shade color, as in MATLAB (optional, default: 'k')   [char/double]
%     alpha: shade transparency (optional, default: 0.4)                   [double]
%
% Outputs:
%   out: struct with fields (only if requested)                            [struct]
%     avg: mean of each sample                                             [double]
%     err: error of each sample, as set by errRef                          [double]
%     handle: handles of the shade (err) and the mean line (avg)           [struct]
%
% Example:
%   cfg = []; cfg.xdata = 0:0.1:2; cfg.ydata = randn(20, 21);
%   cfg.errRef = 'ci'; cfg.color = 'r';
%   out = avgErrorShade(cfg);
%
% Dependencies: Statistics and Machine Learning Toolbox (tinv, for 'ci')
%
% Version history:
%   v0.1  Mar 2026  First version (avg_err_shade)
%   v0.2  Mar 2026  SEM computation updated
%   v0.3  Oct 2026  Renamed to avgErrorShade; camelCase fields (errRef);
%                   'std' option; fixed degrees of freedom of 'ci'
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience

% if the input is a matrix
if ~isstruct(cfg)
    yData = cfg;
    cfg = [];
    cfg.ydata = yData;
end
nValid = sum(~isnan(cfg.ydata),1);

% check defaults %
cfg = checkCfg(cfg);

% compute average and standard deviation
out.avg = mean(cfg.ydata,1,'omitnan');
out.avg = out.avg(:).';

% adjust error to request if necessary
out.err = std(cfg.ydata,[],1,"omitnan");
switch cfg.errRef
    case 'sem'
        out.err = out.err./sqrt(nValid);
    case 'ci'
        out.err = out.err./sqrt(nValid);
        ts = tinv(0.975,nValid - 1);
        out.err = ts .* out.err;
    case 'std'
        % standard deviation, already computed
    otherwise
        error('Invalid errRef: %s. Use ''sem'', ''ci'' or ''std''',cfg.errRef)
end
out.err = out.err(:).';

% set x_axis for plotting
if ~isempty(cfg.xdata)
    xVector = [cfg.xdata(:).' fliplr(cfg.xdata(:).')];
else
    xVector = [1:length(out.avg) length(out.avg):-1:1];
end

% plot error (shade) and average
out.handle.err = fill(xVector,[out.avg - out.err fliplr(out.avg + out.err)],...
    cfg.color,'FaceAlpha',cfg.alpha,'EdgeAlpha',0.1);
hold on
out.handle.avg = plot(xVector(1:length(out.avg)),out.avg,...
    'color',cfg.color,...
    'LineWidth',1);

if nargout > 0
    outPrint = out;
end


% check (and set) input defaults
function cfg = checkCfg(cfg)

if ~isfield(cfg,'ydata')
    error('Input must have at least the data')
end

if ~isfield(cfg,'xdata')
    cfg.xdata = [];
end

if ~isfield(cfg,'errRef')
    cfg.errRef = 'sem';
end

if ~isfield(cfg,'color')
    cfg.color = 'k';
end

if ~isfield(cfg,'alpha')
    cfg.alpha = 0.4;
end
