
function show_desc(fInRec, xUpLeft, yUpLeft)


figure(10); hold on;

% xUpLeft = 35;
% yUpLeft = 80;
xWindSize = 16;
yWindSize = 16;

yRec = 20;
xRec = 13;


for yDim = 1:yRec
    for xDim = 1:xRec;
        aCell = fInRec{yDim,xDim};
        [feats_4 numSIFT] = size(aCell);
        sWindow(xUpLeft+(xDim-1)*xWindSize,...
                    yUpLeft+(yDim-1)*yWindSize,...
                    xWindSize,yWindSize, numSIFT);
                
    end;
end;
                          

end
%==========================================================================
%--------------------------------------------------------------------------

function[h] = calcHistogram_v1_2(fInRec)

figure
orients = fInRec(4,:)*180/pi;
orients = mod(orients,180);
h = histogram(orients);

h.BinLimits = [0 179];
h.NumBins = 18;
%line([90 90], [0 60], 'Color','r','LineWidth',1)
end
%--------------------------------------------------------------------------

function sWindow(xUpLeft,yUpLeft,xWindSize,yWindSize, numSIFT)




rectangle(...
            'Position',[xUpLeft yUpLeft xWindSize yWindSize],...
            'EdgeColor','g'...
             );

% [4feats numSIFT] = size(aCell);        
         
line([xUpLeft+xWindSize/2 xUpLeft+xWindSize/2],[yUpLeft+yWindSize-2 yUpLeft+yWindSize-numSIFT*1-2 ],'linewidth',5, 'Color', 'y')   
         
         
                         
                          
 end

