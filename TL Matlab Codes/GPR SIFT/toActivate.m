

curDir = pwd;
idcs   = strfind(curDir,'\');
rootDir = curDir(1:idcs(end)-1);
vlFeatpath = strcat(rootDir, '\vlfeat-0.9.20-bin\vlfeat-0.9.20\toolbox\vl_setup');
run (vlFeatpath)

vl_version verbose



% ~\vlfeat-0.9.20-bin\vlfeat-0.9.20\toolbox
% klasörü üçerisinde kullanýlan src dosyalarý mevcut.  