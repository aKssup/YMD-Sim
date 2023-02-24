%% LLT Test

%% Adding Paths

% Adding Vehicle Parameters
currentFolder = pwd;
addpath([currentFolder, filesep, '1-Input Functions']);
vehicleObj = VehicleParameters();

% Adding StiffnessSim & LLTSim
addpath([currentFolder, filesep, '2-Setup Sims and Calcs', filesep, 'Simulators']);

%% Inputs

% Input Car Parameters
Weight = vehicleObj.TotalWeight();
TrackWidth = [vehicleObj.FrontTrackWidth(); vehicleObj.RearTrackWidth()];
Z_r = [vehicleObj.RollAxisF();vehicleObj.RollAxisR()];
a = vehicleObj.FrontAxleToCoG();
b = vehicleObj.CoGToRearAxle();
L = vehicleObj.WheelBase();

K_s = vehicleObj.K_s();
K_ARB = vehicleObj.K_ARB();
MR_s = vehicleObj.MR_s();
MR_ARB = vehicleObj.MR_ARB();

K_t = [548 548; 548 548];%lbf/in 

CoGhRA = 7.03608;
Ay = 1.5;

%% Calculations

% Stiffnesses (lbf/in)
[K_w,K_r,K_roll] = StiffnessSim(K_s,K_ARB,K_t,MR_s,MR_ARB,TrackWidth);

[LLT,LLT_D] = LLTSim(K_roll,Weight,Ay,TrackWidth,CoGhRA,Z_r,a,b,L);

disp(LLT);
disp(LLT_D);