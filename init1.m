clear 
clc
close all


%% define model parameters 
g=10;
m=1;
c=0.5;
L=1;




%Initial conditions
theta0      = 6*pi/180;
thetadot0   = 0;



%Open the Simulink model
open('Models.slx');
%run sim
sim('Models.slx');


