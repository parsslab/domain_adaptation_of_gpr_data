
function [descriptor, fInRec] = create_single_desc(feature, xUpLeft, yUpLeft)


% xUpLeft = 35;
% yUpLeft = 80;
xWindSize = 16;
yWindSize = 16;

yRec = 20;
xRec = 13;

descriptor = [];
fInRec = cell(yRec,xRec);

for yDim = 1:yRec
    for xDim = 1:xRec
        fInRec{yDim, xDim} = sWindow(xUpLeft+(xDim-1)*xWindSize,...
                              yUpLeft+(yDim-1)*yWindSize,...
                              xWindSize,yWindSize,feature);
        
         [feats_4 numSIFT] = size(fInRec{yDim, xDim});
        descriptor = [descriptor; numSIFT];
    end;
end;
                          

end
%==========================================================================
%--------------------------------------------------------------------------

 function[fInRec] = sWindow(xUpLeft,yUpLeft,xWindSize,yWindSize,f)

%figure(1)
hold on;

% xUpLeft = 150;
% yUpLeft = 0;
% xWindSize = 70;
% yWindSize = 200;
%--------------------------------------------------------------
% Aþaðýdaki komut commentlendi.
%--------------------------------------------------------------
% rectangle(...
%             'Position',[xUpLeft yUpLeft xWindSize yWindSize],...
%             'EdgeColor','r'...
%              );
         
% yCoord = f(1,:);
% [ySorted yInds] = sort(y);
% siftSorted = f(:,ySorted);
% 
% siftInRec = 
% 
% for xDim = 

siftInRec = [];

numFeats = size(f(1,:),2);
for i = 1:numFeats
    xCoord = f(1,i);
    yCoord = f(2,i); 
    if xCoord > xUpLeft && xCoord < xUpLeft + xWindSize
    	if yCoord > yUpLeft && yCoord < yUpLeft + yWindSize
            siftInRec = [siftInRec i]; 
        end
    end
end

fInRec = f(:,siftInRec);
%scatter(f(1,siftInRec),f(2,siftInRec),'y')
%--------------------------------------------------------------
% Aþaðýdaki komut commentlendi.
%--------------------------------------------------------------
%scatter(fInRec(1,:),fInRec(2,:),'y');                         
                          
 end

