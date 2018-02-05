function autoFocus(VidObj, Zmotor,StepSize)
% AUTOFOCUS command
%


% TODO add preallocation
z = [];
C = [];
pause(0.5);
curImage = getsnapshot(VidObj);
curImage = curImage(:,:,3);

output = serialCom.writeToSerial(Zmotor,'C');
z(1)= str2double(output(3:end));

C(1) = camera.contrastMetric(curImage);
options =  fitoptions('gauss1');
set(options, 'lower', [0,0,1],'upper',[20,8000, 
% Move +z distance and take image
[~,posErr] = serialCom.stepMove(Zmotor,StepSize);
if posErr
    error('Limit switch activated');
end
pause(0.1)
curImage = getsnapshot(VidObj);
curImage = curImage(:,:,3);

output = serialCom.writeToSerial(Zmotor,'C');
z(2)= str2double(output(3:end));
C(2) = camera.contrastMetric(curImage);

[~,posErr] = serialCom.stepMove(Zmotor,StepSize);
if posErr
    error('Limit switch activated');
end
pause(0.1)
curImage = getsnapshot(VidObj);
curImage = curImage(:,:,3);

output = serialCom.writeToSerial(Zmotor,'C');
z(3)= str2double(output(3:end));
C(3) = camera.contrastMetric(curImage);

% Compute slope
P = polyfit(z,C,1); % Slope is P(1)

if (P(1)>0) % If slope is positive
    % Move +z distance and take image
    [~,posErr] =serialCom.stepMove(Zmotor,StepSize);
    if posErr
        error('Limit switch activated');
    end
    pause(0.1)
    curImage = getsnapshot(VidObj);
    curImage = curImage(:,:,3);
    
    output = serialCom.writeToSerial(Zmotor,'C');
    z(4)= str2double(output(3:end));
    C(4) = camera.contrastMetric(curImage);
    
    P = polyfit(z,C,2);
    zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)

        isPeak = false;

    % while last measure location is less than z value of polynomial peak
    while (z(end) < zPeak) || ~isPeak
        % Move +x distance and take image
        [~,posErr] =serialCom.stepMove(Zmotor,StepSize);
        if posErr
            error('Limit switch activated');
        end
        pause(0.1)
        curImage = getsnapshot(VidObj);
        curImage = curImage(:,:,3);
        
        output = serialCom.writeToSerial(Zmotor,'C');
        z(end +1) = str2double(output(3:end));
        C(end+1) = camera.contrastMetric(curImage); %TODO prealocate array
        P = polyfit(z,C,2);
        zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
        
        if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
            isPeak = true;
        else
            isPeak = false;
        end
        
    end
else
    % Move -2*(z distance) and take image
    [~,posErr] =serialCom.stepMove(Zmotor,-StepSize*3);
    if posErr
        error('Limit switch activated');
    end
    pause(0.5)
    curImage = getsnapshot(VidObj);
    curImage = curImage(:,:,3);
    
    output = serialCom.writeToSerial(Zmotor,'C');
    z(4)= str2double(output(3:end));
    C(4) = camera.contrastMetric(curImage);
    P = polyfit(z,C,2);
    zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
    
    isPeak = false;
    
    % while last measurement location is greater than x value of polynomial peak
    while (z(end) > zPeak) || ~isPeak
        % Move -x distance and take image
        [~,posErr] = serialCom.stepMove(Zmotor,-StepSize);
        if posErr
            error('Limit switch activated');
        end
        pause(0.1)
        curImage = getsnapshot(VidObj);
        curImage = curImage(:,:,3);
        output = serialCom.writeToSerial(Zmotor,'C');
        
        z(end+1)= str2double(output(3:end));%TODO preallocate array
        C(end+1) = camera.contrastMetric(curImage);
        P = polyfit(z,C,2);
        zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
        if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
            isPeak = true;
        else
            isPeak = false;
        end
    end
end

% Goto z location corresponding to polynomial peak
% Move (zPeak-zend) steps
% focusPosition = zPeak;
% Show focued image
output = serialCom.writeToSerial(Zmotor,'C');
curPos = str2double(output(3:end));
if abs(zPeak-curPos) >2
    serialCom.stepMove(Zmotor, zPeak-curPos);
end
pause(0.1)
figure(3);
scatter(z,C);
figure(2);
% figure(2);
%
% zfit = min(z):1:max(z);
%
% Cpoly = P(1)*zfit.^2 + P(2)*zfit + P(3);
% plot(zfit,Cpoly,'b')
% hold on
% plot(z,C,'r')
% hold off

end