


clear all, clc, close all,


curDir = pwd;
idcs   = strfind(curDir,'\');
rootDir = curDir(1:idcs(end)-1);
gprDir = strcat(rootDir, '\','gpr Generated Files');

media = '5-Dry Sand Cylinder_10-30_2-6';


fprintf('Media Folder Inspected: %s\n',media)

mediaFolder = [gprDir, '\', media];
scnFolders = dir(mediaFolder);
fprintf('There are %d Sceen Subfolders to inspect.\n',length(scnFolders)-2)

for i = 3:length(scnFolders)
    fprintf('%s\n',scnFolders(i).name)
end

fileCount = 0;

for i = 3:length(scnFolders)
    
    outFolder = [mediaFolder, '\', scnFolders(i).name]; 
    outFiles = dir([outFolder, '\', '*.out']);
    
    fprintf('\nFolder: %s\n',scnFolders(i).name)
    fprintf('.out file count: %d\n',length(outFiles))
    pause(0.2)
%     for j = 1:length(outFiles)
%         
%         fprintf('File processed: %s\n',outFiles(j).name)
%         pause(0.2)
%         
%     end

    fileCount = fileCount + length(outFiles);
end

fprintf('\nTotal .out file count: %d\n',fileCount)