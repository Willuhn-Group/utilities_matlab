function [selEntry,requestConfig] = getEntry(entryList,varargin)

% [selEntry,entryLine] = getEntry(entryList,varargin)
%
% pick_files function lists files from the ref_files (output of the proj_organigram function)
%
%   Inputs:
%     ref_files: output of the proj_organigram function                     [struct]
%                Note: However, this function shuould work to select
%                specific lines of any structure.
%     field_name
%     field_value: selecting criteria for field_name. 
%          
%   Outputs:
%     out_files: Output struct containing the same fiels as ref_files
%       name: file name
%       folder: file folder
%       file_path: full file path
%       + one field per level following the name con cfg.level_name input
%
% Sergio Conde-Ocazionez, August 2024. 
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.

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