clear all; close all; clc;

% parameters
a=0.0075;  %m
b =0.015;
Cr=2070;  %N
Mass=1.08 + 0.515; % slider + crank link mass
k=1;
p=90;
omega=p*2*pi/60; %rad/sec
Cr=2070;  %N
i=1;
for alpha = 0 : 1: 360
    res1 = alpha_C(alpha);
    t(i)= alpha;
    time(i)=deg2rad(alpha)/omega;
    p1(i)= res1.pos1;
    v1(i)= res1.vel1;
    a1(i)= res1.acc1;
    da=res1.vel1;
    dda=res1.acc1;

    x=a*cos(deg2rad(res1.pos1))+k*sqrt(b^2-a^2*sin(deg2rad(res1.pos1))^2);
    sb=-a/b*sin(deg2rad(res1.pos1));
    cb=(x-a*cos(deg2rad(res1.pos1)))/b;

            %speed
    db=-da*a*cos(deg2rad(alpha))/(b*cb);
    dx=-da*a*(sin(deg2rad(alpha))*cb-cos(deg2rad(alpha))*sb)/cb;
    
 
        %acceleration
    ddx=(-dda*a*(sin(deg2rad(alpha))*cb-cos(deg2rad(alpha))*sb)-da^2*a*(cos(deg2rad(alpha))*cb+sin(deg2rad(alpha))*sb)-db^2*b)/cb;    
    ris.acc=ddx;
%------------------------ torque calculation required by motor -----------    
    if(alpha>=190 && alpha<=225)
           Crs=(Cr*dx + Mass*ddx*dx)/da;
    else
        Crs=(Mass*ddx*dx)/da;
    end
%-------------------------------------------------------------------------

    s_alpha(i)=alpha;
    s_x(i)=x;
    s_dx(i)=dx;
    s_ddx(i)=ddx;
    s_Crs(i)=Crs;
%-------------------------------------------------------------------------
    app(i)=ddx*Crs;
    i=i+1;
end    

%-------------------------- Motor Sizing ---------------------------------------
crsq=rms(s_Crs);
dwrq=rms(s_ddx);
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
wmax=max(s_dx);
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
mm=8;
tt=1;

Cm=s_Crs*red(tt).tau + mot(mm).J*s_ddx/red(tt).tau;

figure;
plot(s_dx*60/(2*pi),Cm, 'k','Linewidth',1);grid;
hold on
line('XData',[0 2000 2000],...
    'YData',[4.8 4.8  0],...
    'linestyle','-','linewidth',2,'color','g');
line('XData',[0 2000 2000],...
     'YData',[14.3 14.3 0],...
     'linestyle','-','linewidth',2,'color','r');
line('XData',[mean(s_dx)*60/(2*pi) rms(s_dx)*60/(2*pi)],...
     'YData',[rms(Cm) rms(Cm)],...
     'linestyle','-','linewidth',2,'color','b');


figure;
subplot(3,1,1);plot(t,p1,'r','LineWidth',2);grid;ylabel('alpha');
subplot(3,1,2);plot(t,v1,'b','LineWidth',2);grid;ylabel('alpha dot'); 
subplot(3,1,3);plot(t,a1,'k','LineWidth',2);grid;ylabel('alpha double dot'); 

figure;
subplot(4,1,1);plot(t,s_x,'r','LineWidth',2);grid; title('Position');
subplot(4,1,2);plot(t,s_dx,'b','LineWidth',2);grid; title('Speed');
subplot(4,1,3);plot(t,s_ddx,'k','LineWidth',2);grid; title('Acceleration');
subplot(4,1,4);plot(t,s_Crs,'r','LineWidth',2);grid; title('torque');

figure;
subplot(4,1,1);plot(t,s_x,'r','LineWidth',2);grid;title('Position');
subplot(4,1,2);plot(t,s_dx,'b','LineWidth',2);grid; title('Speed');
subplot(4,1,3);plot(t,s_ddx,'k','LineWidth',2);grid; title('Acceleration');
subplot(4,1,4);plot(t,Cm,'r','LineWidth',2);grid; title('torque');

figure;
plot(v1,s_Crs,'r','LineWidth',2);grid;xlabel('Speed');ylabel('torque')
