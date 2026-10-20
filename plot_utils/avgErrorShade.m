function outPrint = avgErrorShade(cfg)

% avgErrorShade function plots the mean trace and shadow dispersion 
% 
% Inputs
%   cfg.xdata:  x axis data values. If empty xdata = sample number of ydata.
%   cfg.ydata:  y axis data values. Can be either a 2D matrix [nobservations x  nsamples] 
%           or a struct containing mean_data and std_vectors.
%   cfg.err_flag: can be 'sem' (standard error fo the mean; 'ci' (95%
%                 confidence interval) or 'std' (standard deviation)
%   cfg.color: color definition same as Matlab's
%   cfg.alpha:  transparency level
%
% Outputs
%
%   out: struct containing the following fields
%     avg: average data
%     err: error data
%     handle: average and error plots handles 
%       
%   Sergio Conde, 2026. NIN. Willuhn's Lab. 

% if nargin == 2
%   x_data = var1, ydata = var2
% end

% if the input is a matrix
if ~isstruct(cfg)
    ydata = cfg;
    cfg = [];
    cfg.ydata = ydata;
end
nvalid = sum(~isnan(cfg.ydata),1);

% check defaults %
 cfg = checkCfg(cfg);

% compute average and standard deviation
out.avg = mean(cfg.ydata,1,'omitnan');

out.avg = out.avg(:).';

% adjust error to request if necessary
out.err  = std(cfg.ydata,[],1,"omitnan");
switch cfg.err_ref
    case 'sem'
        out.err = out.err./sqrt(nvalid);
    case 'ci'
        out.err = out.err./sqrt(nvalid);
        ts = tinv(0.975,length(out.avg) - 1);
        out.err = ts * out.err;
end
out.err = out.err(:).';

% set x_axis for plotting
if ~isempty(cfg.xdata)
    x_vector = [cfg.xdata fliplr(cfg.xdata)];
else
    x_vector = [1:length(out.avg) length(out.avg):-1:1];
end

% plot error (shade) and average
out.handle.err = fill(x_vector,[out.avg - out.err fliplr(out.avg + out.err)],...
    cfg.color,'FaceAlpha',cfg.alpha,'EdgeAlpha',0.1);
hold on
out.handle.avg = plot(x_vector(1:length(out.avg)),out.avg,...
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

if ~isfield(cfg,'err_ref')
    cfg.err_ref = 'sem';
end

if ~isfield(cfg,'color')
    cfg.color = 'k';
end

if ~isfield(cfg,'alpha')
    cfg.alpha = 0.4;
end
