function [MicPos MaxFreqLimit MinFreqLimit EstiAng] = Array_Geometry(M)
type = input('Array Geometry (1:ULA, 2:UCA, 3:Respeaker):');
c=343;
switch type
    case 1 %ULA
        d=input('Spacing (m):');
        MicPos_x = -0.5*(M-1)*d:d:0.5*(M-1)*d;
        MicPos_y = zeros(1,M);
        MaxFreqLimit=c/(2*d);
        MinFreqLimit=c/((M-1)*d);
        EstiAng=0:1:180;
    case 2 %UCA
        Radius = input('Radius (m):');
        theta = 360/M;
        MicPos_x = cosd(0:theta:theta*(M-1))*Radius; 
        MicPos_y = sind(0:theta:theta*(M-1))*Radius;
        d = sqrt((MicPos_x(2)-MicPos_x(1))^2+(MicPos_y(2)-MicPos_y(1))^2);
        MaxFreqLimit = c/(2*d);
        MinFreqLimit = c/(2*Radius);
        EstiAng = 0:1:359;
    case 3 % Reaspker
        Radius = input('Radius (m):');
        theta = 360 / (M - 1);
        MicPos_x = cosd(0:theta:theta*(M - 2)) * Radius;
        MicPos_x(1, M) = 0;
        MicPos_y = sind(0:theta:theta*(M - 2)) * Radius;
        MicPos_y(1, M) = 0;
        d = sqrt((MicPos_x(2)-MicPos_x(1))^2 + (MicPos_y(2)-MicPos_y(1))^2);
        MaxFreqLimit = c/(2*d);
        MinFreqLimit = c/(2*Radius);
        EstiAng = 0:1:359;
end
MicPos = [MicPos_x ; MicPos_y];
% figure;plot(MicPos_x,MicPos_y,'*');
% title('Array Geometry');xlabel('x(m)');ylabel('y(m)');