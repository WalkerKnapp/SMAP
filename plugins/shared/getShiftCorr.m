function [dx,dy,abg]=getShiftCorr(im1,im2,ploton,maxshift,subpixel,winfit)
if nargin<3
    ploton=false;
end
if nargin <4
    maxshift=2500;
end
if nargin<5
    subpixel=true;
end
if nargin<6
    winfit=3;
end

% facs=1; %global resize factor for smaller pixel sizes
 filtersize=1.5;
%  winfit=3;
 s=size(im1);

 nFFT=2^ceil(log2(max(s)));
 maxdisplacement=round(min(min(maxshift,nFFT/2-winfit),nFFT/2-winfit));
displace=[0 0];
% maxdisplacement=max(maxdisplacement/facs,2*filtersize+1)
% pixrec=1*facs;
% sx=512/facs;sy=512/facs;
% nFFT=1024/facs;




im1=im1-mean(im1(:));
im2=im2-mean(im2(:));
s1=sum(im1(:).^2);
s2=sum(im2(:).^2);
% im1=myhist2(pos1(:,2),pos1(:,3),pixrec, pixrec,[0 sx],[0 sy]);
% im2=myhist2(pos2(:,2)-displace(1),pos2(:,3)-displace(2),pixrec, pixrec,[0 sx],[0 sy]);

Fout1=fft2(im1,nFFT,nFFT);
Fout2=fft2(im2,nFFT,nFFT);
Fcc=fftshift(ifft2(Fout1.*conj(Fout2),nFFT,nFFT));
Fccsmall=Fcc(nFFT/2-maxdisplacement+2:nFFT/2+maxdisplacement,nFFT/2-maxdisplacement+2:nFFT/2+maxdisplacement);

%filter 
h=fspecial('gaussian',15,filtersize);
% Fccfilt=imfilter(Fccsmall,h);

Fccfilt=Fccsmall;

[maxcc,ind]=max(Fccfilt(:));
[x,y]=ind2sub(size(Fccfilt),ind);
try
Fcccut=Fccsmall(x-winfit:x+winfit,y-winfit:y+winfit);

catch err
    figure(555)
    imagesc(Fccsmall)
    disp('Maximum on edge:increase Max shift (correlation)')
end
if subpixel
fitp=my2Dgaussfit(Fcccut);
% dx=fitp(:,1)+x-maxdisplacement-displace(1);
% dy=fitp(:,2)+y-maxdisplacement-displace(2);
dx=fitp(:,1)+x-maxdisplacement-winfit-1-displace(1);
dy=fitp(:,2)+y-maxdisplacement-winfit-1-displace(2);
abg=fitp(:,3)+fitp(:,4);
else
    
    dx=x-maxdisplacement-displace(1);
    dy=y-maxdisplacement-displace(2);
    fitp=[0 0];
    abg=maxcc;
end
doplot=true;
axplot=ploton;
if (islogical(ploton)||isnumeric(ploton)) 
    if ploton
        axplot=gca;
    else
        doplot=false;
    end 
end
if doplot
% 
% % figure(1)
ap=axplot.Parent;
ax2=axes(ap);
% figure(f);
subplot(1,2,1,axplot)
imagesc(abs(Fccfilt));
hold on
plot(y,x,'ks')
hold off
axis equal
xlabel('x srpix')
ylabel('y srpix')
title('cross-correlation to find maximum')


subplot(1,2,2,ax2)
imagesc(abs(Fcccut));
hold on
plot(fitp(:,2),fitp(:,1),'ks')
hold off
axis equal
xlabel('x srpix')
ylabel('y srpix')
title('zoom in cross-correlation to fit maximum')
end
abg=abg/sqrt(s1*s2);
