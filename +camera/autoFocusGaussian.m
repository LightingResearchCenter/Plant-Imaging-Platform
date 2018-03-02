function autoFocusGaussian(VidObj, Zmotor,StepSize)
% AUTOFOCUS command
%


% TODO add preallocation
z = [];
C = [];
drawnow;

if VidObj == -1
    ok = D850_driver_v1('open');
    ok = D850_driver_v1('live_on');
    curImage = D850_driver_v1('live_get');
    var = onCleanup(@clean);
else
    curImage = getsnapshot(VidObj);
end
curImage = curImage(:,:,3);
options =  fitoptions('gauss1');
set(options, 'lower', [0,0,1],'upper',[20,8000, 1000]);
output = serialCom.writeToSerial(Zmotor,'C');
z(1)= str2double(output(3:end));

C(1) = camera.contrastMetric(curImage);

% Move +z distance and take image
[~,posErr] = serialCom.stepMove(Zmotor,StepSize);
if posErr
    error('motor errored');
end
drawnow;
if VidObj == -1
    curImage = D850_driver_v1('live_get');
else
    curImage = getsnapshot(VidObj);
end
figure(4);
imshow(curImage);
curImage = curImage(:,:,3);
output = serialCom.writeToSerial(Zmotor,'C');
z(2)= str2double(output(3:end));
C(2) = camera.contrastMetric(curImage);
figure(4);
[~,posErr] = serialCom.stepMove(Zmotor,StepSize);
if posErr
    error('Limit switch activated');
end
drawnow;
if VidObj == -1
    curImage = D850_driver_v1('live_get');
else
    curImage = getsnapshot(VidObj);
end
figure(4);
imshow(curImage);
curImage = curImage(:,:,3);
output = serialCom.writeToSerial(Zmotor,'C');
z(3)= str2double(output(3:end));
C(3) = camera.contrastMetric(curImage);
Cg = C-min(C);
sortedZC = sortrows([z;Cg]',1);
% Compute slope
P = polyfit(sortedZC(1,:),sortedZC(2,:),1); % Slope is P(1)

if (P(1)>0) % If slope is positive
    % Move +z distance and take image
    [~,posErr] =serialCom.stepMove(Zmotor,StepSize);
    if posErr
        error('Limit switch activated');
    end
    dirMove = 1;
else
    [~,posErr] =serialCom.stepMove(Zmotor,-StepSize);
    if posErr
        error('Limit switch activated');
    end
    dirMove = -1;
end
drawnow;
if VidObj == -1
    curImage = D850_driver_v1('live_get');
else
    curImage = getsnapshot(VidObj);
end
figure(4);
imshow(curImage);
curImage = curImage(:,:,3);
output = serialCom.writeToSerial(Zmotor,'C');
z(4)= str2double(output(3:end));
C(4) = camera.contrastMetric(curImage);
tic;
Cg = C-min(C);
fitobject = fit(z',Cg','gauss1',options);
G = coeffvalues(fitobject);
zPeak = G(2);
toc
disp(length(z));
isPeak = false;
peakcounter = 0;
% while last measure location is less than z value of polynomial peak
while  ~isPeak
    % Move +x distance and take image
    if ((zPeak>min(z)) && (zPeak<max(z)))
        peakcounter =  peakcounter+1;
        if peakcounter >=5
            isPeak = true;
        else
            isPeak = false;
        end
        % add ispeak counter
    else
        isPeak = false;
        peakcounter = 0;
    end
    output = serialCom.writeToSerial(Zmotor,'C');
    tempZ = str2double(output(3:end));
    mult = 1;
    while any(tempZ+(dirMove*StepSize*mult)==z)
        mult=mult+1;
    end
    [~,posErr] =serialCom.stepMove(Zmotor,dirMove*StepSize*mult);
    if posErr
        error('Limit switch activated');
    end
    output = serialCom.writeToSerial(Zmotor,'C');
    tempZ = str2double(output(3:end));
%     while any(tempZ==z)
%         [~,posErr] =serialCom.stepMove(Zmotor,dirMove*StepSize);
%         if posErr
%             error('Limit switch activated');
%         end
%         output = serialCom.writeToSerial(Zmotor,'C');
%         tempZ = str2double(output(3:end));
%     end
    
    drawnow;
    if VidObj == -1
        curImage = D850_driver_v1('live_get');
    else
        curImage = getsnapshot(VidObj);
    end
    figure(4);
    imshow(curImage);
    curImage = curImage(:,:,3);
    
    figure(3);
    scatter(z,C);
    z(end +1) = tempZ;
    C(end+1) = camera.contrastMetric(curImage); %TODO prealocate array
    Cg = C-min(C);
    sortedZC = sortrows([z;Cg]',1);
    
    try
        fitobject = fit(sortedZC(:,1),sortedZC(:,2),'gauss1',options);
        G = coeffvalues(fitobject);
        zPeak = G(2);
    catch
    end
    
    zfit = (min(z):1:max(z))';
    Cfit = G(1)*exp(-((zfit-G(2))./G(3)).^2) + min(C);
    hold on
    plot(zfit,Cfit,'r-');
    hold off
    
    sortedZC = sortrows([z;Cg]',1);
    
    
    if mean(sortedZC(1:2,2))>mean(sortedZC(end-1:end,2))
        dirMove = -1;
    else
        dirMove=1;
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
figure(3);
scatter(z,C);
zfit = (min(z):1:max(z))';
Cfit = G(1)*exp(-((zfit-G(2))./G(3)).^2) + min(C);
hold on
plot(zfit,Cfit,'r-');
hold off
drawnow;
if VidObj == -1
    disp(max(C)-min(C))
    img =D850_driver_v1('live_get');
    figure(4);
    imshow(img);
    ok = D850_driver_v1('live_off');
    ok = D850_driver_v1('close');
end
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

function clean
try
    D850_driver_v1('live_off');
catch
end
D850_driver_v1('close');
end