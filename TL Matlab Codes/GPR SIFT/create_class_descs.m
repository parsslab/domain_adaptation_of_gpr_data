
clc,clear all, close all

% =========================================================================
% User Defined paramaters section
% =========================================================================


curDir = pwd;
idcs   = strfind(curDir,'\');
rootDir = curDir(1:idcs(end)-1);
gprDir = strcat(rootDir, '\','gpr Generated Files');

media = '1-Dry Sand Tube_10-30_2-6';

descFileName = 'DST';

subFolder = 'Noise_13';

mean = 0;
var = 0.13; %0.05


% =========================================================================
% Folder inspection section
% =========================================================================
fprintf('\nMedia Folder Inspected: %s\n\n',media)
fprintf('Descriptor file Name: %s_d\n\n',descFileName)

mediaFolder = [gprDir, '\', media];
scnFolders = dir(mediaFolder);
fprintf('There are %d Sceen Subfolders to inspect.\n\n',length(scnFolders)-2)

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
fprintf('------------------------------') 
fprintf('\nTotal .out file count: %d\n',fileCount)
fprintf('------------------------------\n') 


termAfter = input('Enter out-file count to process>>');

if termAfter ~= 0
% =========================================================================
% Folder process section
% =========================================================================
fprintf('\nCreating Descriptors...\n');
desc = [];

% fprintf('Media Folder processed: %s\n',media)

% mediaFolder = [gprDir, '\', media];
% scnFolders = dir(mediaFolder);
% fprintf('There are %d Sceen Subfolders to process.\n\n',length(scnFolders)-2)
% 
% for idFold = 3:length(scnFolders)
%     fprintf('%s\n',scnFolders(idFold).name)
% end

fbreak = 0;
outCount = 0;

tic

for idFold = 3:length(scnFolders)
    
    outFolder = [mediaFolder, '\', scnFolders(idFold).name]; 
    outFiles = dir([outFolder, '\', '*.out']);
    
    fprintf('\nFolder processed: %s\n',scnFolders(idFold).name)
    fprintf('--------------------------------------------\n')
    
    for idOut = 1:length(outFiles)
        
        outCount = outCount + 1;
        fprintf('%s: %d\n',outFiles(idOut).name, outCount)
        % pause(0.2)
        
        imgCode = outFiles(idOut).name;
        imgPath = outFolder;
                
        for jy = 1:3
            for jx = 1:3
                
                close all
                [gprImg] = read_gpr_img(imgCode, imgPath);

                [feature] = find_SIFT(gprImg, 'addnoise', 'gaussian', mean, var);

                xUpLeft = 19 + (jx-1)*16;
                yUpLeft = 64 + (jy-1)*16;
                [descriptor, fInRec] = create_single_desc(feature, xUpLeft, yUpLeft);

                % pause(0.1)
                desc = [desc, descriptor];
                fprintf('%d-%d...',jy,jx);
                % if mod(i,25) == 0
                % fprintf('\n');
                % end
            end
        end
        fprintf('\n\n');
        if outCount == termAfter
            fbreak = 1;
            break
        end
        
    end
    
    if fbreak == 1
        break
    end
    
end
time = toc;
fprintf('Total out files processed: %d\n',outCount)
fprintf('Total descriptors created: %d\n',outCount*9)
fprintf('Total time elapsed: %d:%.0f\n',fix(time/60), mod(time,60))

if strcmp(descFileName, 'Clutter')
    cltIndx = randperm(termAfter*9);
    cltIndxDiv = round(termAfter*9*0.8);
    desc1 = desc(:,cltIndx(1:cltIndxDiv));
    desc2 = desc(:,cltIndx(cltIndxDiv+1:termAfter*9));
    file=['Descriptors/', subFolder, '/', descFileName,'1', '_d.mat']
    save(file,'desc1')
    file=['Descriptors/', subFolder, '/', descFileName,'2', '_d.mat']
    save(file,'desc2')
else
    file=['Descriptors/', subFolder, '/', descFileName,'_d.mat']
    save(file,'desc')
end

else
fprintf('No files processed\n')    
end

% load('srcDesc.mat')



    
    
    
    
    
    




