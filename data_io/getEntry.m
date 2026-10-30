function [selEntry,requestConfig] = getEntry(entryList,varargin)
% [selEntry, requestConfig] = getEntry(entryList, varargin)
%
% Selects the entries (rows) of a table or struct array that match a
% request. Each requested field is compared with a contrast: 'equal'
% (default), 'lower', 'higher' or 'range'. Non-numeric fields are always
% compared with 'equal'. Requested fields missing from entryList are
% ignored with a warning.
%
% Inputs:
%   entryList: entries to select from (e.g. the trials from getTrials)    [table/struct]
%   varargin: the request, in one of these forms:
%     name-value pairs: field name and accepted value(s), all compared     [char, any]
%       with 'equal'
%     request struct: one field per requested field, with the value(s)     [struct]
%       to compare, plus the optional field
%       contrast: one field per requested field with 'equal', 'lower',     [struct]
%         'higher' or 'range' (default: 'equal'). 'range' takes [min max]
%         and includes both limits
%     request table: converted with table2struct                           [table]
%
% Outputs:
%   selEntry: selected entries, same type as entryList                      [table/struct]
%   requestConfig: the request as applied, with fields                     [struct]
%     contrast: contrast used for each requested field                     [struct]
%     entryLine: indices of the selected entries in entryList              [double]
%     ignored: requested fields not found in entryList (only if any)       [cell]
%
% Example:
%   itiTrials = getEntry(trialStruct.trials, 'interval', 'iti');
%   request = []; request.count = [5 15]; request.contrast.count = 'range';
%   [trials, requestConfig] = getEntry(trialStruct.trials, request);
%
% Dependencies: none
%
% Version history:
%   v0.1  Aug 2026  First version
%   v0.2  Aug 2026  Request as struct with contrasts; second output requestConfig
%   v0.3  Sep 2026  'equal' accepts several values; request as table
%   v0.4  Oct 2026  'range' includes its limits (>= and <=)
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience

% check minimum number of input arguments
if nargin < 2
    error('Not enough input arguments')
end

% check input list
if istable(entryList)
    structFlag = false;
elseif isstruct(entryList)
    structFlag = true;
    entryList = struct2table(entryList);
else
    error('Input data should be a table or indexed struct')
end

% entryList features
nEntries = height(entryList);
numEntry = varfun(@isnumeric,entryList,'OutputFormat','uniform');

ogRequest = varargin;
if isstruct(ogRequest{1})
    requestConfig = ogRequest{1};
elseif istable(ogRequest{1})
    requestConfig = table2struct(ogRequest{1});
else
    requestConfig = setRequest(ogRequest);
end

% fields/variables from the input structure/table
validFields = entryList.Properties.VariableNames;

% select valid fields from the request, check contrasts
requestConfig = checkRequest(requestConfig,validFields);

% select data from each variable
requestVar = setdiff(fieldnames(requestConfig),{'contrast','ignored'});

nVars = length(requestVar);
varFlags = false(nEntries,nVars);
for ivar = 1:nVars
    requestLabel = requestVar{ivar};
    requestValue = requestConfig.(requestLabel);
    varData = entryList.(requestLabel);
    varNum = ismember(validFields,requestLabel);
    if numEntry(varNum)
        switch requestConfig.contrast.(requestLabel)
            case 'lower'
                varFlags(:,ivar) = varData < requestValue;
            case 'higher'
                varFlags(:,ivar) = varData > requestValue;
            case 'equal'
                varFlags(:,ivar) = ismember(varData,requestValue);
            case 'range'
                varFlags(:,ivar) = varData >= requestValue(1) & ...
                    varData <= requestValue(2);
        end
    else
        varFlags(:,ivar) = ismember(varData,requestValue);
    end
end

if ~isempty(varFlags)
    pickFlags = all(varFlags,2); % entries that fully match the request
else
    pickFlags = false(nEntries,1);
end
requestConfig.entryLine = find(pickFlags);

selEntry = entryList(pickFlags,:);
if structFlag
    selEntry = table2struct(selEntry);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function requestConfig = setRequest(ogRequest)

requestFields = ogRequest(1:2:end);
requestValues = ogRequest(2:2:end);

if all(cellfun(@ischar,requestFields))
    for irequest = 1:length(requestFields)
        requestConfig.(requestFields{irequest}) = requestValues{irequest};
        requestConfig.contrast.(requestFields{irequest}) = 'equal';
    end
else
    %errormsg
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function requestConfig = checkRequest(requestConfig,validFields)

% checkContrast checks and sets the default contrast value ('equal') for 
% all requested fields

requestFields = setdiff(fieldnames(requestConfig),'contrast');
invalidFields = setdiff(requestFields,validFields);
if ~isempty(invalidFields)
    warning(['The following requested fields are not in the entry list'...
        ' and were ignored: \n%s\n'],...
        strjoin(invalidFields, '\n'));
    requestFields = setdiff(requestFields,invalidFields);
    requestConfig = rmfield(requestConfig,invalidFields);
    requestConfig.ignored = invalidFields;
end

% set the default empty contrast definition if needed
if ~isfield(requestConfig,'contrast')
    requestConfig.contrast = [];
end

for irequest = 1:length(requestFields)
    if ~isfield(requestConfig.contrast,requestFields{irequest})
        requestConfig.contrast.(requestFields{irequest}) = 'equal';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%