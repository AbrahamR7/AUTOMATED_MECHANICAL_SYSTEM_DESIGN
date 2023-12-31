close all; clear all; clc;

%-------------------------- Load Parameters ------------------------------
p=60;
omega=p*2*pi/60; %rad/sec
R=0.0125;        %m
Cr=2070;         %force needed to cut material
Jtot=(480 + 215)*10^-6; % Nut + Screw inertia
Mass=0.57;       %kg
g=9.8;           %m/s^2
%-------------------------------------------------------------------------
i=1;
for x = 0: 0.01: 360
    res3 = MC_03(x);
    t(i)= x;
    time(i)=deg2rad(x)/omega;
    p(i)= res3.pos;
    p3(i)= res3.pos/R;
    v3(i)= res3.vel/R*omega;
    a3(i)= res3.acc/R*omega^2;
%------------------------ torque calculation required by motor -----------    
    if(v3(i)>0)
        if(x>=190 && x<=225)
           Crs(i)=Cr+Jtot*a3(i) ;
        else
            Crs(i)=Jtot*a3(i); 
        end    
    elseif(v3(i)<0)
        Crs(i)=-Jtot*a3(i);
    else
        Crs(i)=0;
    end
%-------------------------------------------------------------------------
    app(i)=a3(i)*Crs(i);
    i=i+1;
end

%-------------------------- Motor Sizing ---------------------------------------
crsq=rms(Crs);
dwrq=rms(a3);
dwCm=mean(app);
beta=2*(dwrq*crsq+dwCm);
Catalog;

figure;
for i=1:length(mot)
plot(i,mot(i).alfa,'o','LineWidth',2);grid; title('Sizing');
hold on
end

line('Xdata',[0 length(mot)+1],...
    'YData',[beta beta],...
    'linestyle','-','LineWidth',2,'color','r');
grid;
%-------------------------- Reducer Sizing ---------------------------------------
wmax=max(v3);
for i=1:length(mot)
    if(mot(i).alfa > beta)
        tau(i).p=wmax/mot(i).wm;
        tau(i).t_max=(sqrt(mot(i).J)*(sqrt(mot(i).alfa-beta+ 4*dwrq*crsq)...
            +sqrt(mot(i).alfa-beta)))/(2*crsq);
        tau(i).t_min=(sqrt(mot(i).J)*(sqrt(mot(i).alfa-beta+ 4*dwrq*crsq)...
            -sqrt(mot(i).alfa-beta)))/(2*crsq);
        tau(i).t_opt=sqrt(mot(i).J*dwrq/crsq);
    else
        tau(i).p=0;
        tau(i).t_max=0;
        tau(i).t_min=0;
        tau(i).t_opt=0;
    end
end
ii=1:length(mot);
 tau_min=[tau(:).t_min];
 tau_opt=[tau(:).t_opt];
 tau_max=[tau(:).t_max];
 tau_p=[tau(:).p];
 
 hold off;
 figure
 semilogy(ii,tau_min,'v',...
     ii,tau_opt, 'o',...
     ii, tau_max,'^',...
     ii, tau_p ,'h', 'Linewidth',2,'Markersize',5);
 hold on;
 for i=1:length(red)
     semilogy(i:0.01:length(mot), red(i).tau, '.');
     hold on;
 end
 grid
%-------------------------- Check Phase ---------------------------------------
mm=3;
tt=3;

Cm=Crs*red(tt).tau + mot(mm).J*a3/red(tt).tau;
figure;
subplot(4,1,1);plot(time,p3,'r','LineWidth',2);grid; title('Position');
subplot(4,1,2);plot(time,v3,'b','LineWidth',2);grid; title('Speed');
subplot(4,1,3);plot(time,a3,'k','LineWidth',2);grid; title('Acceleration');
subplot(4,1,4);plot(time,Cm,'r','LineWidth',2);grid; title('torque');

figure;
plot(v3*60/(2*pi),Cm, 'k','Linewidth',1);grid;
hold on
line('XData',[0 2000 2000],...
    'YData',[95.5 95.5  0],...
    'linestyle','-','linewidth',2,'color','g');
line('XData',[0 2000 2000],...
     'YData',[286 286 0],...
     'linestyle','-','linewidth',2,'color','r');
line('XData',[mean(v3)*60/(2*pi) rms(v3)*60/(2*pi)],...
     'YData',[rms(Cm) rms(Cm)],...
     'linestyle','-','linewidth',2,'color','b');


