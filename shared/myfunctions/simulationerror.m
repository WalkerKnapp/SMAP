function simulationerror(locgt,locfit,whicherr,searchradius)

% pixelsize=100
if ~isfield(locgt,'x'), locgt.x=locgt.xnm; end
if ~isfield(locfit,'x'), locfit.x=locfit.xnm; end
if ~isfield(locgt,'y'), locgt.x=locgt.ynm; end
if ~isfield(locfit,'y'), locfit.x=locfit.ynm; end
if ~isfield(locgt,'z'), locgt.x=locgt.znm; end
if ~isfield(locfit,'z'), locfit.x=locfit.znm; end




if nargin<4 || isempty(searchradius)
    searchradius=200;
end

[iAa,iBa,nA,nB,nseen]=matchlocsall(locgt,locfit,0,0,searchradius(1));
totallocs=length(locgt.x);
falsepositives=length(nB);
falsenegatives=length(nA);
matched=length(iAa);

dz=locgt.z(iAa)-locfit.z(iBa);
indinz=abs(dz)<searchradius(end);
dz=dz(indinz);
dx=locgt.x(iAa(indinz))-locfit.x(iBa(indinz));
dy=locgt.y(iAa(indinz))-locfit.y(iBa(indinz));


% if nargin<3 || isempty(psf)
%     % test if errors are transferred
%     [lp,errphot]=Mortensen(locgt.phot(iAa(indinz)),locgt.bg(iAa(indinz)),150, pixelsize,0);
% %     crlb=1000./sqrt(locgt.phot(iAa(indinz))); %
%     dxr=dx./lp; %xeems to be closer to 1
%     dyr=dy./lp;
%     dzr=dz./lp/3; 
% else    
%     crlb=psf.crlb(locgt.phot(iAa(indinz)),locgt.bg(iAa(indinz)),-locgt.z(iAa(indinz)));
%     dxr=dx./sqrt(crlb(:,2))/pixelsize; %xeems to be closer to 1
%     dyr=dy./sqrt(crlb(:,1))/pixelsize;
%     dzr=dz./sqrt(crlb(:,5));
% end

%errors for normalization
switch whicherr 
    case 1
        locerr=locgt;
        inderr=iAa;
    case 2
        locerr=locfit;
        inderr=iBa;
    otherwise
        disp('third argument should be 1 if error is taken from first argument, 2 if error is in second')
end
if ~isfield(locerr,'xerr')
    if isfield(locerr,'xnmerr')
        locerr.xerr=locerr.xnmerr;
    elseif isfield(locerr,'locprecnm')
        locerr.xerr=locerr.locprecnm;
    else
        locerr.xerr=Mortensen(locgt.phot,locgt.bg,150,100,0);
        disp('error in x estimated using Mortensen');
    end
end
if ~isfield(locerr,'yerr')
    if isfield(locerr,'ynmerr')
        locerr.yerr=locerr.ynmerr;
    elseif isfield(locerr,'locprecnm')
        locerr.yerr=locerr.locprecnm;
    else
        locerr.yerr=Mortensen(locgt.phot,locgt.bg,150,100,0);
        disp('error in y estimated using Mortensen');
    end
end
if ~isfield(locerr,'zerr')
    if isfield(locerr,'znmerr')
        locerr.zerr=locerr.znmerr;
    elseif isfield(locerr,'locprecznm')
        locerr.zerr=locerr.locprecznm;
    else
        locerr.zerr=Mortensen(locgt.phot,locgt.bg,150,100,0)*3;
        disp('error in z estimated using Mortensen');
    end
end


    
figure(188);
subplot(3,4,1)
fitx=fithistr(dx,1);
xlabel('dx')
subplot(3,4,2)
fity=fithistr(dy,1);
xlabel('dy')
subplot(3,4,3)
fitz=fithistr(dz,5);
xlabel('dz')

%renormalized
dxr=(dx-fitx.b1)./locerr.xerr(inderr(indinz));
dyr=(dy-fity.b1)./locerr.yerr(inderr(indinz));
dzr=(dz-fitz.b1)./locerr.zerr(inderr(indinz));
subplot(3,4,5)
fithistr(dxr,0.2)
xlabel('dx/sqrt(CRLBx)')
subplot(3,4,6)
fithistr(dyr,0.2)
xlabel('dy/sqrt(CRLBy)')
subplot(3,4,7)
fithistr(dzr,0.2)
xlabel('dz/sqrt(CRLBz)')

subplot(3,4,10)
hold off
histogram(locfit.bg(iBa))
hold on
histogram(locgt.bg(iAa))
xlabel('bg')
% hold off
% dscatter(locgt.bg(iAa),locfit.bg(iBa))
% hold on
% plot([min(locgt.bg(iAa)),max(locgt.bg(iAa))],[min(locgt.bg(iAa)),max(locgt.bg(iAa))],'m')
% % ,'.',locgt.z(iAa),locgt.z(iAa),'k')
% xlabel('bg gt')
% ylabel('bg fit')

subplot(3,4,11)
hold off
dscatter(locgt.z(iAa),locfit.z(iBa))
hold on
plot([min(locgt.z(iAa)),max(locgt.z(iAa))],[min(locgt.z(iAa)),max(locgt.z(iAa))],'m')
% ,'.',locgt.z(iAa),locgt.z(iAa),'k')
xlabel('z gt')
ylabel('z fit')

subplot(3,4,12);

hold off
dscatter(locgt.phot(iAa),locfit.phot(iBa))
hold on
plot([min(locgt.phot(iAa)),max(locgt.phot(iAa))],[min(locgt.phot(iAa)),max(locgt.phot(iAa))],'m')
xlabel('phot gt')
ylabel('phpt fit')
ylim([0 1.7*max(locgt.phot(iAa))])

%matchlocs in defined region
% false pos, false neg
% matched: histogram dx/crlbx dy/crlby dz/crlbz
% std of these quantities vs phot, vs z
subplot(3,4,9);
hold off
plot(locfit.x,locfit.y,'.',locgt.x,locgt.y,'.')
ff='%2.0f';
title(['fpos: ' num2str(falsepositives/totallocs*100,ff), '%, fneg: ' num2str(falsenegatives/totallocs*100,ff) '%'])


end

function fitp2=fithistr(de,dn)
ff='%1.1f';
ff2='%1.2f';
qq=quantile(de,[0.002 0.998]);
n=floor(qq(1)):dn:ceil(qq(end));
hold off
histogram(de,n);
hn=histcounts(de,n);
nf=n(1:end-1)+(n(2)-n(1))/2;
fitp=fit(double(nf'),double(hn'),'gauss1');
ss=fitp.c1/sqrt(2);

% try fitting with second gauss
mp=find(nf>fitp.b1,1,'first');
dn2=ceil(2*ss/dn);
n2=(mp-dn2:mp+dn2)';

% fitp2=fit(nf(n2)',hn(n2)','gauss2','StartPoint',[fitp.a1,fitp.b1,fitp.c1,fitp.a1/10,fitp.b1,fitp.c1*10]);
fitp2=fit(double(nf(n2)'),double(hn(n2)'),'gauss1','StartPoint',[fitp.a1,fitp.b1,fitp.c1]);

hold on
plot(nf,fitp(nf),'g')
plot(nf(n2),fitp2(nf(n2)),'r')

fituse=fitp;
ss2=fituse.c1/sqrt(2);
ingauss=fituse.a1*sqrt(pi)*fituse.c1/length(de)/dn;
% de=de(abs(de)<3);
title([num2str(mean(de),2) '±' num2str(std(de),ff) ', fit: ' num2str(fituse.b1,ff) '±' num2str(ss2,ff2) ', in Gauss ' num2str(ingauss*100,'%2.0f') '%'])
xlim([-5*ss 5*ss])
axh=gca;
text(5*ss/3,axh.YLim(2)*0.9,[ '\sigma=' num2str(ss2,ff2)],'FontSize',18)
t2=text(5*ss/3*1.4,axh.YLim(2)*0.8,[num2str(ingauss*100,'%2.0f') '%'],'FontSize',18);
end


function [lp,errphot]=Mortensen(N,Bg,PSF, pixel,cmosn)
b=sqrt(Bg+cmosn^2);

PSFa=sqrt(PSF^2+pixel^2/12);
v=PSFa^2./N.*(16/9+8*pi*PSFa^2*b.^2./N/pixel^2);
lp=sqrt(v);


s_a=PSF/pixel; %sigmapsf/pixelsize
tau=2*pi*(Bg)*(s_a^2+1/12)./N;
errphot=N.*(1+4*tau+sqrt(tau./(14*(1+2*tau)))); %This is Thompson...
end