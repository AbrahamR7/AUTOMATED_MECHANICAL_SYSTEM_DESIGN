function ris=alpha_C(alpha)
%-------------------------- parameters ------------------------------------
alpha_r=75; %deg
alpha_con=360;
a1=145; a2=225; a3=235 ; a4=295; a5=360; 
in=[0 a1 a2 a3 a4 a5];
%---------------------------- dwell ---------------------------------------
if(alpha>= in(1) && alpha <= in(2)) 
    da=(in(2)-in(1));
    alpha_ad=(alpha-in(1))/da;
    ris.pos=0;
    ris.vel=0.0000001;
    ris.acc=0;
    ris.pos1=0;
    ris.vel1=0.0000001;
    ris.acc1=0;
%---------------------------- rise ----------------------------------------    
elseif(alpha>=in(2) && alpha<=in(3))
    da=(in(3)-in(2));
    alpha_ad=(alpha-in(2))/da;
    out=McmModified_trapezoidal(alpha_ad);      %Modified_trapezoidal motion curve
    ris.pos=alpha_r*out.pos;
    ris.vel=alpha_r/deg2rad(da)*out.vel;
    ris.acc=alpha_r/(deg2rad(da))^2*out.acc;
    ris.pos1=(alpha_con/2)*out.pos;
    ris.vel1=(alpha_con/2)/deg2rad(da)*out.vel;
    ris.acc1=(alpha_con/2)/(deg2rad(da))^2*out.acc;
%---------------------------- dwell ---------------------------------------    
elseif(alpha>=in(3) && alpha<=in(4))
    da=(in(4)-in(3));
    alpha_ad=(alpha-in(3))/da;
    ris.pos=alpha_r;
    ris.vel=0.0000001;
    ris.acc=0;
    ris.pos1=(alpha_con/2);
    ris.vel1=0.0000001;
    ris.acc1=0;    
%---------------------------- fall ---------------------------------------      
elseif(alpha>=in(4) && alpha<=in(5))
    da=(in(5)-in(4));
    alpha_ad=(alpha-in(4))/da;
    out=McmModified_trapezoidal(alpha_ad);       %Modified_trapezoidal motion curve
    ris.pos=alpha_r-alpha_r*out.pos;
    ris.vel=-alpha_r/deg2rad(da)*out.vel;
    ris.acc=-alpha_r/(deg2rad(da))^2*out.acc; 
    ris.pos1=(alpha_con/2)*out.pos+180;
    ris.vel1=(alpha_con/2)/deg2rad(da)*out.vel;
    ris.acc1=(alpha_con/2)/(deg2rad(da))^2*out.acc;
%---------------------------- dwell ---------------------------------------      
elseif(alpha>=in(5) && alpha<=in(6)) 
    da=(in(6)-in(5));
    alpha_ad=(alpha-in(5))/da;
    ris.pos=0;
    ris.vel=0.0000001;
    ris.acc=0;   
    ris.pos1=0;
    ris.vel1=0.0000001;
    ris.acc1=0;    
%--------------------------------------------------------------------------      
else
    da=0;
    alpha_ad=0;
    ris.pos=0;
    ris.vel=0;
    ris.acc=0;
    ris.pos1=0;
    ris.vel1=0.0000001;
    ris.acc1=0;    
end
end
