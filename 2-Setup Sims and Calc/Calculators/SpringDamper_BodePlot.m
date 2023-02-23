%% Spring and Damper w/ Bode Plot Calc

% This calculator uses the car's parameters to calculate various key
% values to determine the vadility of a given spring/shock setup

clc

%% Adding Paths

% Adding VehicleParameters
addpath("Terps Racing/1-Input Functions");
%   Creating a VehicleParameters Object
vehicleObj = VehicleParameters();

%% Inputs

% Input Car Parameters (Matrix)
Weights = vehicleObj.staticWeights();

% Tire Stiffness for Fronts and Rears
K_tF = 548; %lb/in
K_tR = 548; %lb/in

% Input Test Spring Stiffness and Motion Ratios + Damper Settings
K_sF = 200; %lb/in
K_sR = 250; %lb/in
K_ARBF = 0; %lb/in
K_ARBR = 0; %lb/in

MRsF = 0.5;
MRsR = 0.5;
MR_ARBF = 0.5;
MR_ARBR = 0.5;

DampC_L = [150 150; 150 150]; %(lb-s)/in
DampC_H = [150 150; 150 150]; %(lb-s)/in

%% Calculations

% Stiffnesses

K_wF = (K_sF*(MRsF)^2)+(K_ARBF*(MR_ARBF)^2);
K_wR = (K_sR*(MRsR)^2)+(K_ARBR*(MR_ARBR)^2);

K_rF = (K_tF*K_wF)/(K_tF+K_wF);
K_rR = (K_tR*K_wR)/(K_tR+K_wR);

% Natural Frequency

NF = [(1/(2*pi))*(sqrt((K_sF*(MRsF)^2)/Weights(1,1))),(1/(2*pi))*(sqrt((K_sF*(MRsF)^2)/Weights(1,2)));
    (1/(2*pi))*(sqrt((K_sR*(MRsR)^2)/Weights(2,1))),(1/(2*pi))*(sqrt((K_sR*(MRsR)^2)/Weights(2,2)))];
disp('Natural Frequency (Hz) = ');
disp(NF);

% Natural Frequency Range - Rear
NF10 = 1.1.*NF(1,:);
NF20 = 1.2.*NF(1,:);

disp('Rear Natural Frequency F:10% (Hz) = ');
disp(NF10);
disp('Rear Natural Frequency F:20% (Hz) = ');
disp(NF20);

% Critical Damping

CD = [2*(sqrt((K_sF*(MRsF)^2)*Weights(1,1))),2*(sqrt((K_sF*(MRsF)^2)*Weights(1,2)));
    2*(sqrt((K_sR*(MRsR)^2)*Weights(2,1))),2*(sqrt((K_sR*(MRsR)^2)*Weights(2,2)))];
% (lb-in)/s

% Damping Ratio

DR_L = [DampC_L(1,1)/CD(1,1) DampC_L(1,2)/CD(1,2); DampC_L(2,1)/CD(2,1) DampC_L(2,2)/CD(2,2)];
DR_H = [DampC_H(1,1)/CD(1,1) DampC_H(1,2)/CD(1,2); DampC_H(2,1)/CD(2,1) DampC_H(2,2)/CD(2,2)];
disp('Damping Ratio - Low = ');
disp(DR_L);
disp('Damping Ratio - High = ');
disp(DR_H);

% Damped Natural Frequency

DNF_L = [(1/(2*pi))*sqrt(K_rF/Weights(1,1))*sqrt(1-DR_L(1,1)^2) (1/(2*pi))*sqrt(K_rF/Weights(1,2))*sqrt(1-DR_L(1,2)^2);
    (1/(2*pi))*sqrt(K_rR/Weights(2,1))*sqrt(1-DR_L(2,1)^2) (1/(2*pi))*sqrt(K_rR/Weights(2,2))*sqrt(1-DR_L(2,2)^2)];
DNF_H = [(1/(2*pi))*sqrt(K_rF/Weights(1,1))*sqrt(1-DR_H(1,1)^2) (1/(2*pi))*sqrt(K_rF/Weights(1,2))*sqrt(1-DR_H(1,2)^2);
    (1/(2*pi))*sqrt(K_rR/Weights(2,1))*sqrt(1-DR_H(2,1)^2) (1/(2*pi))*sqrt(K_rR/Weights(2,2))*sqrt(1-DR_H(2,2)^2)];
disp('Damped Natural Frequency - Low (Hz)= ');
disp(DNF_L);
disp('Damped Natural Frequency - High (Hz)= ');
disp(DNF_H);


%% Bode Plots

%FL
syms
Gs_FLLow = tf([1],[1 2*DR_L(1,1)*NF(1,1) NF(1,1)^2]);
Gs_FLHigh = tf([1],[1 2*DR_H(1,1)*NF(1,1) NF(1,1)^2]);

%FR
Gs_FRLow = tf([1],[1 2*DR_L(1,2)*NF(1,2) NF(1,2)^2]);
Gs_FRHigh = tf([1],[1 2*DR_H(1,2)*NF(1,2) NF(1,2)^2]);

%RL
Gs_RLLow = tf([1],[1 2*DR_L(2,1)*NF(2,1) NF(2,1)^2]);
Gs_RLHigh = tf([1],[1 2*DR_H(2,1)*NF(2,1) NF(2,1)^2]);

%RR
Gs_RRLow = tf([1],[1 2*DR_L(2,2)*NF(2,2) NF(2,2)^2]);
Gs_RRHigh = tf([1],[1 2*DR_H(2,2)*NF(2,2) NF(2,2)^2]);

figure('Name','Bode Plot - Low Damper Settings');
bode(Gs_FLLow,'r-*',Gs_FRLow,'r-o',Gs_RLLow,'b-*',Gs_RRLow,'b-o');
legend(' FL',' FR',' RL',' RR','Location','eastoutside')

figure('Name','Bode Plot - High Damper Settings');
bode(Gs_FLHigh,'r-*',Gs_FRHigh,'r-o',Gs_RLHigh,'b-*',Gs_RRHigh,'b-o');
legend(' FL',' FR',' RL',' RR','Location','eastoutside')

