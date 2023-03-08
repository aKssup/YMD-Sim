%% Longitudinal Load Transfer Test

clc

%% Adding Paths

% Adding Vehicle Parameters
currentFolder = pwd;
addpath([currentFolder, filesep, '1-Input Functions']);
vehicleObj = TREV2Parameters();

% Adding Additional Sims
addpath([currentFolder, filesep, '2-Setup Sims and Calcs', filesep, 'Simulators']);

%% Inputs

% Input Car Parameters
Weight = vehicleObj.TotalWeight();
StaticWeights = vehicleObj.staticWeights();
TrackWidth = vehicleObj.TrackWidth();
a = vehicleObj.FrontAxleToCoG();
L = vehicleObj.Wheelbase();
CoGh = vehicleObj.CoGHeight();
TireRadius = vehicleObj.TireRadius();

K_s = vehicleObj.K_s();
K_ARB = vehicleObj.K_ARB();
MR_s = vehicleObj.MR_s();
MR_ARB = vehicleObj.MR_ARB();

K_t = [548 548; 548 548]; %lbf/in 
mux = 1.5;

% Input Test Braking Force (lbf)
DriverForce = 100;

BrakeParameters = [1.45;1;3.131;0.3;4;1.45;1;1.5708;0.3;2;0.9375;0.69029;7;4.13;0.5];

%% Calculations

% Stiffnesses (lbf/in)
[K_w,K_r,K_roll] = StiffnessSim(K_s,K_ARB,K_t,MR_s,MR_ARB,TrackWidth);

% Braking Forces (lb)
[Fx,Ax,BF] = BrakingSim(DriverForce,Weight,StaticWeights,mux,L,CoGh,TireRadius,BrakeParameters);

% Load Transfer (lb)
[Fz,LoLT,Accelmax] = LoLTSim(Weight,StaticWeights,mux,Ax,L,CoGh,a);

% Tire Limit (g's)
TL_F = BF(1,:)/(Fz(1,1)+Fz(1,2));
TL_R = BF(2,:)/(Fz(2,1)+Fz(2,2));
    
TL = [TL_F;TL_R];

% Wheel Displacement (in) (neg -> loaded (bump), pos -> unloaded (droop))
Z = [K_r(1,1)*(LoLT/2), K_r(1,2)*(LoLT/2);
    -K_r(2,1)*(LoLT/2), -K_r(2,2)*(LoLT/2)];

for i = 1:2
    for j = 1:2
        if(Z(i,j) < -1)
            Z(i,j) = -1;
        end
        if(Z(i,j) > 1)
            Z(i,j) = 1;
        end
    end
end

disp('Fx: ');
disp(Fx);
disp('Fz: ');
disp(Fz);
disp('Longitudinal Acceleration: ');
disp(Ax);
disp('Wheel Displacement: ');
disp(Z);
disp('Tire Limits: ');
disp(TL);