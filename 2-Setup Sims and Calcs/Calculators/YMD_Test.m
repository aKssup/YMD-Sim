%% YMD Test
% Credit - LJ Hamilton

close all
clearvars
clc

%% Adding Paths

% Adding Vehicle Parameters
currentFolder = pwd;
addpath([currentFolder, filesep, '1-Input Functions']);
vehicleObj = TREV2Parameters();

% Adding Tire Models
addpath([currentFolder, filesep, '1-Input Functions', filesep, 'Tire Modeling']);

% Adding Additional Sims
addpath([currentFolder, filesep, '2-Setup Sims and Calcs', filesep, 'Simulators']);

%% Tire Modeling

%Input tire filenames
filename.FrontTire = 'A1965run17.mat';
filename.RearTire = 'A1965run17.mat';
[trainingDataFront,tire.IDfront] = createLatTrngData2(filename.FrontTire);
[trainingDataRear,tire.IDrear] = createLatTrngData2(filename.RearTire);

% Front tires
disp([tire.IDfront, ', Front Tire Model is being trained.  Standby...'])
t1 = tic;
[model.FxFront, validationRMSE.FxFront] = Trainer_Fx(trainingDataFront);
[model.FyFront, validationRMSE.FyFront] = Trainer_Fy(trainingDataFront);
[model.MzFront, validationRMSE.MzFront] = Trainer_Mz(trainingDataFront);
toc(t1)

disp('Training completed')

% Rear tires
disp([tire.IDrear, ', Rear Tire Model is being trained.  Standby...'])
t1 = tic;
[model.FxRear, validationRMSE.FxRear] = Trainer_Fx(trainingDataRear);
[model.FyRear, validationRMSE.FyRear] = Trainer_Fy(trainingDataRear);
[model.MzRear, validationRMSE.MzRear] = Trainer_Mz(trainingDataRear);
toc(t1)

disp('Training completed')

%% Inputs

% Input Car Parameters
VehicleWeight = vehicleObj.TotalWeight();
StaticWeights = vehicleObj.staticWeights();
FrontPercent = vehicleObj.FrontPercent();
RearPercent = vehicleObj.RearPercent();
a = vehicleObj.FrontAxleToCoG();
b = vehicleObj.CoGToRearAxle();
L = vehicleObj.Wheelbase();
TrackWidth = vehicleObj.TrackWidth();
FTrackWidth = TrackWidth(1,:);
CoGh = vehicleObj.CoGHeight();
TireRadius = vehicleObj.TireRadius();
Z_r = vehicleObj.Zr;
CoGhZr = vehicleObj.CoGhZr();
CoGh_RA = vehicleObj.CoGhRA();

% Input Aero Parameters
liftFactor = vehicleObj.liftFactor();

% Input Alignment and Tuning Parameters
K_s = vehicleObj.K_s();
K_ARB = vehicleObj.K_ARB();
MR_s = vehicleObj.MR_s();
MR_ARB = vehicleObj.MR_ARB();
Ackermann = vehicleObj.Ackermann();
Toe = vehicleObj.Toe();
FToe = Toe(1,:);
Camber = vehicleObj.Camber();
TirePressure = vehicleObj.TirePressure();

K_t = [548 548; 548 548];%lbf/in 

% Input Test Cornering Parameters
Radius = 348; %in (neg -> Left, pos -> Right)
Velocity = linspace(0,35,70); %mph

% Input Steering Wheel Angle, CoG Slip Angle
SWAngle = 0; %deg (L = neg, R = pos)
Beta = 0; %CoG slip angle (deg) (neg -> Right, pos -> Left)

SlipCarParameters = [a; b; TrackWidth(1,:); TrackWidth(2,:)];
 
%% Code

% Stiffnesses (lbf/in)
[K_w,K_r,K_roll] = StiffnessSim(K_s,K_ARB,K_t,MR_s,MR_ARB,TrackWidth);

% Steering Angles (deg)
SteerAngles = SteerAngleSim(SWAngle,L,FTrackWidth,Ackermann,FToe);

% Slip Angles (deg) & Load Transfer (lb)
for i = 1:70
    [SlipAngles(:,:,i),LatAccelG(:,:,i),Betamax(:,:,i),YawVelo(:,:,i),LateralVelo(:,:,i)] = SlipAngleSim(SteerAngles,Beta,Velocity(:,i),Radius,SlipCarParameters);
    
    [Fz(:,:,i),LLT(:,:,i),LLT_D(:,:,i),R_g(:,:,i),Roll_Angle(:,:,i)] = LLTSim(K_roll,VehicleWeight,StaticWeights,LatAccelG(:,:,i),TrackWidth,CoGh_RA,Z_r,a,b,L);
    
    % Wheel Displacement (in) (neg -> loaded (bump), pos -> unloaded (droop))
    Z(:,:,i) = [(tan(deg2rad(Roll_Angle(:,:,i))).*(TrackWidth(1,:)/2)), -(tan(deg2rad(Roll_Angle(:,:,i))).*(TrackWidth(1,:)/2));
        (tan(deg2rad(Roll_Angle(:,:,i))).*(TrackWidth(2,:)/2)), -(tan(deg2rad(Roll_Angle(:,:,i))).*(TrackWidth(2,:)/2))];

    for j = 1:2
        for k = 1:2
            if(Z(j,k,i) < -1)
                Z(j,k,i) = -1;
            end
            if(Z(j,k,i) > 1)
                Z(j,k,i) = 1;
            end
        end
    end
    
    disp('Velocity: ');
    disp(Velocity(:,i));
    disp('Gs: ');
    disp(LatAccelG(:,:,i));
    disp('Roll Angle: ');
    disp(Roll_Angle(:,:,i));
    disp('Wheel Displacement: ');
    disp(Z(:,:,i));
    disp('Slip Angles: ');
    disp(SlipAngles(:,:,i));
    disp('Camber: ');
    disp(Camber);
    disp('Fz: ');
    disp(Fz(:,:,i));
    disp('Tire Pressure: ');
    disp(TirePressure);
end

%[Fx,Fy,Mz] = findTireFM(model,tire)