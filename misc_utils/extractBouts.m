function boutList = extractBouts(eventTimes, minInterval, varargin)
% boutList = extractBouts(eventTimes, minInterval, minDuration)
%
% Groups event times into bouts: consecutive events closer than
% minInterval belong to the same bout. Bouts shorter than minDuration can
% be removed.
%
% Inputs:
%   eventTimes: event times, sorted (row vector)                           [double]
%   minInterval: minimum time between bouts, same units as eventTimes      [double]
%   minDuration: minimum bout duration (optional, default: keep all)       [double]
%
% Outputs:
%   boutList: one row per bout, with variables                             [table]
%     boutStart: time of the first event of the bout                       [double]
%     boutEnd: time of the last event of the bout                          [double]
%     duration: boutEnd - boutStart                                        [double]
%     triggCount: number of events in the bout                             [double]
%
% Example:
%   boutList = extractBouts([0.1 0.3 0.4 5 5.2 9], 1, 0.1);
%
% Dependencies: none
%
% Version history:
%   v0.1  Sep 2026  First version (in behavior_medpc)
%   v0.2  Oct 2026  Moved to utilities_matlab
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience


if length(varargin) > 1
    errorMsg = sprintf('\n--> Too many inputs <--\n');
    error(errorMsg)
end

diffTime    = [minInterval + 1 diff(eventTimes)] > minInterval;
boutStart   = eventTimes(diffTime);
boutEnd     = eventTimes([diffTime(2:end) true]);
duration    = boutEnd - boutStart;
triggCount  = diff(find([diffTime true]));

boutList = table(boutStart',boutEnd',duration',triggCount',...
    'VariableNames',{'boutStart','boutEnd','duration','triggCount'});

if nargin == 3
    minDuration = varargin{1};
    shortBouts = boutList.duration < minDuration;
    boutList(shortBouts,:) = [];
end
