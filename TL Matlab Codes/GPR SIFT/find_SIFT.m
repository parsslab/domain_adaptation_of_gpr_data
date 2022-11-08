
function [f] = find_SIFT(gprData, varargin)

% clear all;
% close all;
% clc;

doFilter = 'n';
imgType = 'none';
nType = 'none';
mean = 0;
var = 0;

nVarargs = length(varargin);
% nVarargs = nargin - 1;

for i=1:nVarargs
    if (strcmp(varargin{i},'addnoise'))
        nType = varargin{i+1};
        mean = varargin{i+2};
        var = varargin{i+3};
    elseif (strcmp(varargin{i},'filter'))
        doFilter = varargin{i+1};
    end

end



gpr = double(gprData);
%--------------------------------------------------------------------------

%gpr = dataNormalize(gpr);

repCol = 40;
[numRow, numCol] = size(gpr);
gprEnlarged = [];

for i = 1:numCol
    colRepeated = repmat(gpr(:,i),1,repCol);
    gprEnlarged = [gprEnlarged, colRepeated];
end

gprImg_d = imresize(gprEnlarged,0.25);
% figure
% imshow(gprImg,[]);
% figure
% imshow(uint8(gprImg));
%--------------------------------------------------------------------------

step = 10;
overlap = 1;
 
%gprWhite = distWhiten(gprImg);
%gprWhite_d = gprImg_d;
gprWhite_d = binWhiten(gprImg_d, step, overlap);
gprWhite_d = dataNormalize(gprWhite_d);
gprWhite_u = uint8(gprWhite_d);

% figure
% imshow(gprWhite,[]);
% figure
% imshow(gprWhite);

if strcmp(doFilter,'y')
    fsize=[5 5]; 
    sigma=2; 
    type='gaussian';
    gprFiltered_u = filterImage(gprWhite_u, fsize, sigma, type);
else
    gprFiltered_u = gprWhite_u;
end

%figure(10)
%imshow(gprFiltered_u);
% imshow(gprFiltered_u);
% hold on;

gprData = gprFiltered_u;

if (strcmp(nType,'gaussian'))
    m = mean;
    v = var;
    J = imnoise(gprFiltered_u,'gaussian',m,v);

    % v = double(gprFiltered_u)./10000;
    % J = imnoise(gprFiltered_u,'localvar',v);

    %  J = imnoise(gprFiltered_u,'poisson');

    % d = 0.02;
    % J = imnoise(gprFiltered_u,'salt & pepper',d);

    % v = 0.01;
    % J = imnoise(gprFiltered_u,'speckle',v);
elseif (strcmp(nType,'none'))
    J = gprFiltered_u;
end

figure(10), imshow(J)

figure(2), imshow(J)

figure, imshow(J)
hold on;

gprFiltered_u = J;

gprFiltered_s = single(gprFiltered_u);

peak_thresh = [0 0.1 0.15 0.2 0.3 0.4 0.5 0.7 0.9 1.2 1.5];
edge_thresh = [2 3 5 7 10 12 20 500];
[f,d] = vl_sift(gprFiltered_s, 'PeakThresh', peak_thresh(9),'edgethresh', edge_thresh(6)) ;
% [f,d] = vl_sift(gprFiltered, 'PeakThresh', peak_thresh(9),'edgethresh', edge_thresh(6)) ;
%f(4,:)=pi/2; 
% h1 = vl_plotframe(f(:,sel));
h1 = vl_plotframe(f(:,:));
set(h1,'color','b','linewidth',1);

end
%==========================================================================

function [x] = distWhiten(xx)

[ydim, xdim] = size(xx);
for i = 1:ydim
    x(i,:) = xx(i,:) * (i*i);%i;%sqrt(i);
end

end

%--------------------------------------------------------------------------

function [dataNormal] = dataNormalize(data)
dataShifted = data-min(min(data));
%dataShifted = dataShifted + 0;
maxRate = max(max(dataShifted))/255;
dataNormal = fix(dataShifted/maxRate);
end

%--------------------------------------------------------------------------

function [imgFiltered] = filterImage(img, fsize, sigma, type)
G = fspecial(type,fsize,sigma);
imgFiltered = imfilter(img,G,'same');
end

%--------------------------------------------------------------------------

function [imgWhite] = binWhiten(img, step, overlap)
img1 = [];
img2 = [];

binCount = fix(size(img,1)/step);

for (i = 1:binCount)

    binImg = img(step*(i-1)+1:step*i,:);

    [delta Q] =size(binImg);

    mean_bin = mean(mean(binImg));
    var_bin = sum(sum((binImg-mean_bin).* (binImg-mean_bin)))/(delta*Q);
    std_dev_bin = var_bin^(1/2);
    norm_bin = (binImg-mean_bin)/std_dev_bin;

    img1 = [img1 ;norm_bin];

end

if (overlap == 1)
    for (i = 1:(binCount-1))

        binImg = img(step*(i-1)+1+step/2:step*i+step/2,:);

        [delta Q] =size(binImg);

        mean_bin = mean(mean(binImg));
        var_bin = sum(sum((binImg-mean_bin).* (binImg-mean_bin)))/(delta*Q);
        std_dev_bin = var_bin^(1/2);
        norm_bin = (binImg-mean_bin)/std_dev_bin;

        img2 = [img2 ;norm_bin];

    end

    imgWhite = (img1(step/2+1:end-step/2,:)+img2)/2;
else
    imgWhite = img1;
end

end

%--------------------------------------------------------------------------

function [normalized_b] = rowWhiten(img)
% mean_b = mean(img,2);
% mean_b_mat = repmat(mean_b,1,Q);
% sigma_b = (b-mean_b_mat)*(b-mean_b_mat)';
% sigma_b = sigma_b/(Q-1);
% variances = diag(sigma_b);
% std_dev = variances.^(1/2);
% std_dev_mat = repmat(std_dev,1,Q);
% normalized_b = (b-mean_b_mat)./ std_dev_mat;
end

