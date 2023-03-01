%% Slip Angle Simulator

function [SlipAngles,Betamax] = SteerAngleSim(SteerAngle,Beta,Velocity,Radius,SlipCarParameters)
    % Unit Conversions
    Wheelbaseft = Wheelbase/12;
    FTrackWidthft = FTrackWidth/12;

    % Turning Radius (ft)
    TurnRadius = Wheelbaseft/tand(SWAngle);
    
    % R&L Steering Angle for 100% Ackermann
    AckSteerAngleR = atand(Wheelbaseft/(TurnRadius - FTrackWidthft/2));
    AckSteerAngleL = atand(Wheelbaseft/(TurnRadius + FTrackWidthft/2));
    
    % Differences
    DiffR = AckSteerAngleR - SWAngle;
    DiffL = SWAngle - AckSteerAngleL;
    
    % Final Steering Angles
    SteerAngleR = SWAngle + Ackermann*DiffL - FToe(1,2);
    SteerAngleL = SWAngle - Ackermann*DiffR + FToe(1,1);
    
    SteerAngles = [SteerAngleL, SteerAngleR];
end
