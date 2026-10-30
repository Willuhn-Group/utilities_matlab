function fileList = projectFiles(cfg)
% fileList = projectFiles(cfg)
%
% Lists the files of a project that follow a folder structure (one folder
% level per item in cfg.levelName) and a file naming pattern, and labels
% each file with the name of its folder at every level.
%
% Inputs:
%   cfg: configuration struct with fields                                  [struct]
%     mainPath: main project folder                                         [char]
%     levelName: name of each folder level, used as output field names      [cell]
%     folderCode: folder pattern of each level, as accepted by dir          [cell]
%       (e.g. 'rat*'), one per level
%     fileCode: file name pattern (e.g. '*.mat'). If empty, all files of     [char]
%       each folder are listed
%
% Outputs:
%   fileList: one element per file, with fields                            [struct]
%     name: file name                                                       [char]
%     folder: file folder                                                   [char]
%     filePath: full file path                                              [char]
%     <levelName>: one field per level, with the folder name at that level  [char]
%
% Example:
%   cfg = []; cfg.mainPath = 'D:\myProject';
%   cfg.levelName = {'rat','session'}; cfg.folderCode = {'rat*','day*'};
%   cfg.fileCode = '*.mat';
%   fileList = projectFiles(cfg);
%
% Dependencies: none
%
% Version history:
%   v1.0  Apr 2023  First version (proj_organigram)
%   v2.0  Aug 2026  Renamed to projectFiles; camelCase cfg fields
%   v2.1  Sep 2026  Output field file_path renamed to filePath
%
% Author(s): Sergio Conde-Ocazionez
% Neuromodulation & Behavior Laboratory, Netherlands Institute for Neuroscience


% defining the search path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
catPath = cfg.mainPath;                                       % main project folder 
for ilevel = 1:length(cfg.levelName)
    catPath = cat(2,catPath,['\' cfg.folderCode{ilevel}]); % concatenate all levels 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if there is a string code for the file names %%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(cfg.fileCode)
    catPath = cat(2,catPath,['\' cfg.fileCode]); % add to search path
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allFiles = dir(catPath); % all files matching the configuration 

mainLength = length(cfg.mainPath);                                    % main project folder str length 
fileList = struct([]);                                                 % output structure initialization

for ifile = 1:length(allFiles)
    
    % create string references to extract level names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bslash = strfind(allFiles(ifile).folder,'\');                                  % backslash positions 
    refPos = [bslash(bslash >= mainLength) length(allFiles(ifile).folder) + 1];  % add final reference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % fill output structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ilevel = 1:length(cfg.folderCode)
        fileList(ifile).name = allFiles(ifile).name;                                      % file name
        fileList(ifile).folder = allFiles(ifile).folder;                                  % file folder
        fileList(ifile).filePath = [allFiles(ifile).folder '\' fileList(ifile).name];   % full file path
        fileList(ifile).(cfg.levelName{ilevel}) = ...
            allFiles(ifile).folder(refPos(ilevel) + 1 : refPos(ilevel + 1) - 1);         % level name
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end