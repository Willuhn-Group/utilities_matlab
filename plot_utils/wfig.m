function hf = wfig(varargin)
% hf = wfig(figNumber)
%
% Opens (or creates) a figure with a white background. Without input it
% opens a new figure.
%
% Inputs:
%   figNumber: number of the figure (optional, default: next free figure)  [double]
%
% Outputs:
%   hf: figure handle (only if requested)                                  [Figure]
%
% Example:
%   wfig(1); plot(1:10);
%
% Dependencies: none
%
% Version history:
%   v0.1  2022      First version
%   v0.2  Sep 2026  Returns the figure handle only when it is requested
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience

if nargin == 1
    h = figure(varargin{1});
else
    h = figure;
end
set(h,'color','w')

if nargout > 0
    hf = h;
end