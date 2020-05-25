function [zpos,dz]=finddisplacementZ2(cr,ct,xb,yb,zb,window,plotaxis)
if nargin<7
    plotaxis=[];
end
if nargin<6||isempty(window)
    window=[];
end


[~,sindr]=sort(cr(:,1));
[~,sindt]=sort(ct(:,1));
x1r=1;x1t=1;
ccc=zeros(1,length(zb)*2-3);
for k=1:length(xb)-1
   x2r=x1r;x2t=x1t;
   while(cr(sindr(x2r),1)<xb(k+1))&&x2r<length(sindr)
       x2r=x2r+1;
   end
   while(ct(sindt(x2t),1)<xb(k+1))&&x2t<length(sindt)
       x2t=x2t+1;
   end
 
   zrh=cr(sindr(x1r:x2r-1),3);
   zth=ct(sindt(x1t:x2t-1),3);
   yrh=cr(sindr(x1r:x2r-1),2);
   yth=ct(sindt(x1t:x2t-1),2);
   
   for l=1:length(yb)-1
       indr=yrh>yb(l) & yrh<=yb(l+1);
       indt=yth>yb(l) & yth<=yb(l+1);
 
       hr=histcounts(zrh(indr),zb);
       ht=histcounts(zth(indt),zb);
       hr=hr-mean(hr);
       ht=ht-mean(ht);
       ch=conv(hr,ht(end:-1:1),'full');
       ccc=ccc+ch;
   end
   x1r=x2r;x1t=x2t; 
end
midp=(size(ccc,2)+1)/2;
cccm=ccc;
cccm(midp)=0;
[mc,ind]=max(cccm);

if isempty(window)
    dh=find(ccc(ind:end)<mc/2,1,'first');
    dh=max(3,round(dh/2));
else
    dh=window;
end
zc=(-length(hr)+1:length(hr)-1)*(zb(2)-zb(1));

inrange=ind-dh:ind+dh;
inrange(zc(inrange)==0)=[];

zred=zc(inrange);
[zpos,fp,dz]=mypeakfit(zc(inrange),ccc(inrange));

indplot=max(1,ind-3*dh):min(ind+3*dh,length(zc));

if ~isempty(plotaxis) 
  plot(plotaxis,zc(indplot),ccc(indplot),'x')
    plotaxis.NextPlot='add';
    plot(plotaxis,zred,fp(zred),'r');
    plotaxis.NextPlot='replace';
    title(plotaxis,['dz (mean): ' num2str(mean(cr(:,3))-mean(ct(:,3)),2) ', cc: ' num2str(zpos,2) ' \pm ' num2str(dz,2)])

end


