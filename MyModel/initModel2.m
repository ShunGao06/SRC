function [model] = initModel2(fileName1, fileName2, fileName3)
	[data] = load(fileName1);                                                   % ǰnumOfCustomer�����û����꣬ʣ���Ϊ��Ӧ��������
    model.numOfPoints = size(data, 1);
    model.numOfSupplyCentre = 4;                                                % ��Ӧ��������

    model.numOfCustomer = model.numOfPoints - model.numOfSupplyCentre;          % ���������
    model.coordinateOfSupplyCentre = data(model.numOfCustomer + 1: end, 1: 3);	% ��Ӧ��������
    
    model.coordinateOfCustomer = data(1: model.numOfCustomer, 1: 3);            % ���������
    model.demandOfCustomer = data(1: model.numOfCustomer, 4);                   % ���������
    model.timeOfService = data(:, 5);                                           % ����ʱ�䣬min
    model.TW = data(1: model.numOfCustomer, 6: 7);                              % ����ʱ�䴰��min
    
    model.Altitude = readMap(fileName2) / 40;                                   % �߳�����
    model.threats = load(fileName3);
    model.threats = [];
    model.droneSize = 1;                                                        % ���˻��ߴ�
    model.stepSize = 3;                                                         % ����
    
    
    model.numOfVehicle = 6;                                                     % ÿ����Ӧ�������˻���
    model.costOfEachVehicle = zeros(1, model.numOfVehicle) + 300;               % ÿ�����Ĺ̶��ɱ���Ԫ
	model.capacityOfEachVehicle = zeros(1, model.numOfVehicle) + 500;           % ÿ����������,kg
    model.maxDistanceOfEachVehicle = zeros(1, model.numOfVehicle) + 800;        % ÿ�����������ʻ����,km
    
    model.speedOfEachVehicle = zeros(1, model.numOfVehicle) + 5;                % ÿ�������ٶ�,km/min
    model.costOfUnitKm = zeros(1, model.numOfVehicle) + 1;                      % ÿ�����ĵ�λ����ɱ�,Ԫ/km
    
    model.p1 = 0.1;                                                            % ʱ�䴰�絽�ͷ�,Ԫ/min
    model.p2 = 10;                                                              % ʱ�䴰�ٵ��ͷ�,Ԫ/min
    model.penaltyFactor = 10 ^ 8;                                               % ���ػ򳬾�ͷ�����
    model.numOfObjs = 2;                                                        % Ŀ����
    
    % �����������
    model.distanceMat = getDistanceMat(model.coordinateOfCustomer, model.coordinateOfSupplyCentre);
    % ���߱���ά��
    model.numOfDecVariables = model.numOfCustomer + model.numOfSupplyCentre * model.numOfVehicle;
    
    model.initIndividual = @initIndividual;                                     % ��ʼ������
    model.repairIndividual = @repairIndividual;                                 % �޸�����
    model.getIndividualFitness = @getIndividualFitness;                         % ���������Ӧ��
    model.printIndividual = @printIndividual;                                   % ��ӡ���
    model.showIndividual = @showIndividual;                                     % ������ӻ�
    
    model.getVehiclePathTable = @getVehiclePathTable;
    model.getVehiclePathDistanceTable = @getVehiclePathDistanceTable;
    model.getArriveTime = @getArriveTime;
    model.getOverload = @getOverload;
    model.getDistance = @getDistance;
    model.getOverTime = @getOverTime;
    
	model.getCost1 = @getCost1;
    model.getCost2 = @getCost2;
    model.getCost3 = @getCost3;
	model.getCost3 = @getCost3;
    model.getAllCost = @getAllCost;
    model.getIndividualObjs = @getIndividualObjs;
    
    
	model.drawEnvironment = @drawEnvironment;
    model.drawPoints = @drawPoints;
    model.showPath = @showPath;
end

function drawEnvironment(model)
    Altitude = model.Altitude;
    threats = model.threats;    
    drawMap3D(Altitude);
    pSet = [];
    for i = 1: size(threats, 1)
        p = drawThreat(threats(i, :));
        pSet(i) = p;
    end
%     legend(pSet, {'�״�', '����', '����', '����'});
end

function drawPoints(model)
    hold on;
    pSet(2) = plot3(model.coordinateOfCustomer(:, 1), model.coordinateOfCustomer(:,2), model.coordinateOfCustomer(:,3), 'bo', 'MarkerSize', 3, 'LineWidth', 3);
    pSet(1) = plot3(model.coordinateOfSupplyCentre(:, 1), model.coordinateOfSupplyCentre(:,2), model.coordinateOfSupplyCentre(:,3), 'r^','MarkerSize', 4, 'LineWidth', 3);
    for i = 1 : size(model.coordinateOfCustomer, 1)
        text(model.coordinateOfCustomer(i, 1), model.coordinateOfCustomer(i, 2), model.coordinateOfCustomer(i, 3), ['   ' num2str(i)], 'FontSize', 8);
    end
    for i = 1 : size(model.coordinateOfSupplyCentre, 1)
        text(model.coordinateOfSupplyCentre(i, 1), model.coordinateOfSupplyCentre(i, 2), model.coordinateOfSupplyCentre(i, 3), ['   ' num2str(i + size(model.coordinateOfCustomer, 1))], 'FontSize', 8);
    end
%     legend(pSet, {'���', '�����'});
end

function [pathOfSmoothArray] = showPath(pointIds, model)
    points = [model.coordinateOfCustomer; model.coordinateOfSupplyCentre];
    pointSet = points(pointIds, :);
    [pathOfSmoothArray] = getPath(pointSet, model);
    distanceArray = zeros(1, length(pathOfSmoothArray) - 1);
    path = [];
    for i = 1: length(pathOfSmoothArray)
        pathOfSmooth = pathOfSmoothArray{i};
        path = [path; pathOfSmooth];
        [pathDistance] = getPathDistance2(pathOfSmooth);
        distanceArray(i) = pathDistance;
%         fprintf('%d-%d·�����룺%.2f\n', i, i + 1, pathDistance);
    end
    plot3(path(:, 1), path(:, 2), path(:, 3),'-o','LineWidth',1,'MarkerSize',1,'MarkerFaceColor','white');
end

function [pathOfSmoothArray] = getPath(pointSet, model)
    Altitude = model.Altitude;
    threats = model.threats;
    droneSize = model.droneSize;                                            % ���˻��ߴ�
    stepSize = model.stepSize;                                              % ����
    numOfPoints = size(pointSet, 1);
    
    pathArray = cell(1, numOfPoints - 1);
    pathOfSmoothArray = cell(1, numOfPoints - 1);
    for i = 1: numOfPoints - 1
        startPoint = pointSet(i, :);
        endPoint = pointSet(i + 1, :);
        [path, rrTree] = getPathByRrt3D(Altitude, threats, droneSize, stepSize, startPoint, endPoint);
        [pathOfShorter] = getShorterPath3D(path, droneSize, Altitude, threats);     % ���̺��·��
        [pathOfLonger] = getLongerPath(pathOfShorter, 20);
        pathOfSmooth = getSmoothPath3D(pathOfLonger);
        pathArray{i} = pathOfShorter;
        pathOfSmoothArray{i} = pathOfSmooth;
    end
end

function [disMat] = LpNorm(vector1, vector2, p)
% Lp�����������ϵľ���
% p=1ʱ��Ϊ�����پ��룻p=2ʱ��ŷ�Ͼ��룻
% ����vector1 = [0 0]; vector2 = [3 4]; p = 2;              �����disMat = [5];
%     vector1 = [0 0; 2 2]; vector2 = [3 4; 1 1]; p = 1;	�����disMat = [7;2];
    N = size(vector1, 1);
    disMat = zeros(N, 1);
    for i = 1 : N
        v1 = vector1(i, :);
        v2 = vector2(i, :);
        disMat(i) = sum(abs(v1 - v2).^p).^(1./p);    
    end
end

function [pathDistance] = getPathDistance2(path)
    pathDistance = 0;
    for i = 1: size(path, 1) - 1
        startPoint = path(i, :);
        endPoint = path(i + 1, :);
        pathDistance = pathDistance + LpNorm(startPoint, endPoint, 2);
    end
end

%% �����������
function [distanceMat] = getDistanceMat(coordinateOfCustomer, coordinateOfSupplyCentre)
    coordinate = [coordinateOfCustomer; coordinateOfSupplyCentre];          % ǰnumOfCustomer�����û����꣬ʣ���Ϊ��Ӧ��������
    num = size(coordinate, 1);                                              % ��������
    distanceMat = zeros(num, num);
    for i = 1 : num
        for j = 1 : num
            coordI = coordinate(i, :);                                      % ����i����
            coordJ = coordinate(j, :);                                      % ����j����
            distanceMat(i, j) = LpNorm(coordI, coordJ, 2);                  % ��������i������j��ŷ�Ͼ���
        end
    end
end

%% ��ʼ������
function [individual] = initIndividual(model)
	numOfCustomer = model.numOfCustomer;                                    % ���������
    numOfSupplyCentre = model.numOfSupplyCentre;                            % ��Ӧ��������
    numOfVehicle = model.numOfVehicle;                                      % ÿ����Ӧ������������

    temp = meshgrid(1:numOfSupplyCentre,1:numOfVehicle) + numOfCustomer;
    temp = reshape(temp,[1,numOfSupplyCentre * numOfVehicle]);
    sequence = [1 : numOfCustomer, temp];
    individual = sequence(randperm(length(sequence)));
end

%% �޸�����
function [newIndividual] = repairIndividual(individual, model)
    numOfCustomer = model.numOfCustomer;                                    % ���������
    newIndividual = individual;
    centreIndex = find(individual > numOfCustomer);                         % ��ѯ��Ӧ������������λ��
    t = centreIndex(1);
    temp = newIndividual(1);
    newIndividual(1) = newIndividual(t);
    newIndividual(t) = temp;                                                % ������Ϊ��Ӧ����
end

%% ��ʾ����,·�����ӻ�
function showIndividual(individual, model)
    [vehiclePathTable] = model.getVehiclePathTable(individual, model);
    [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
   
    hold on;
    model.drawEnvironment(model);
    model.drawPoints(model);
    [numOfVehicle, numOfSupplyCentre] = size(vehiclePathTable);
    for j = 1: numOfSupplyCentre
        k = 0;
        for i = 1: numOfVehicle
            pathOfVehicle = vehiclePathTable{i, j};
            if length(pathOfVehicle) > 2
                k = k + 1;
                fprintf('��Ӧ��%d ���˻�·��%d ����%.2f�� %s\n', j, k, vehiclePathDistanceTable(i, j), num2str(pathOfVehicle));
                pathOfSmoothArray = model.showPath(pathOfVehicle, model);
            end
        end
    end
    hold off;
end

%% ��ȡÿ����Ӧ����ÿ������·�� �д������˻� �д���Ӧ����
function [vehiclePathTable] = getVehiclePathTable(individual, model)
    numOfCustomer = model.numOfCustomer;                                    % ���������
    numOfVehicle = model.numOfVehicle;
    numOfSupplyCentre = model.numOfSupplyCentre;

    vehiclePathTable = cell(numOfVehicle, numOfSupplyCentre);              % ÿ����Ӧ����ÿ������·��
    vehicleNumTable = zeros(1, numOfSupplyCentre);
    centreIndex = find(individual > numOfCustomer);                         % ��ѯ��Ӧ������������λ��
    centreIndexEnd = [centreIndex(2 : end) - 1 , length(individual)];
    lengthOfPathArray = centreIndexEnd - centreIndex;                       % ÿ��·�ߵĳ���
    startPointOfVehicleArray = individual(centreIndex);                     % ÿ���������

    for i = 1 : length(lengthOfPathArray)
        k = startPointOfVehicleArray(i) - numOfCustomer;                    % �����Ϣ
        vehicleNumTable(k) = vehicleNumTable(k) + 1;
        startI = centreIndex(i);
        endI = centreIndexEnd(i);
        pathOfVehicle = [individual(startI : endI) individual(startI)];     % ���˻���·��
        vehiclePathTable{vehicleNumTable(k), k} = pathOfVehicle;
    end
end

% ÿ����Ӧ����ÿ��������ʻ���롢����״̬��������������ʱ��
function [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = getVehiclePathDistanceTable(vehiclePathTable, model)
    vehiclePathDistanceTable = zeros(size(vehiclePathTable));               % ÿ����Ӧ����ÿ��������ʻ����
    vehicleStateTable = zeros(size(vehiclePathTable));                      % ÿ����Ӧ����ÿ�����ķ���״̬
    vehicleLoadTable = zeros(size(vehiclePathTable));                       % ÿ����Ӧ����ÿ�����ĸ�����
    vehicleServiceTimeTable = zeros(size(vehiclePathTable));                % ÿ����Ӧ����ÿ�����ķ���ʱ��
    vehicleDrivingTimeTable = zeros(size(vehiclePathTable));                % ÿ����Ӧ����ÿ��������ʻʱ��
    
    [numOfVehicle, numOfSupplyCentre] = size(vehiclePathTable);
    for j = 1: numOfSupplyCentre
        for i = 1: numOfVehicle
            path = vehiclePathTable{i, j};
            vehicleLoadTable(i, j) = getPathLoad(path, model);
            vehicleServiceTimeTable(i, j) = getPathServiceTime(path, model);
            [pathDistance] = getPathDistance(path, model);
            vehiclePathDistanceTable(i, j) = pathDistance;
            vehicleStateTable(i, j) = pathDistance > 0;
            vehicleDrivingTimeTable(i, j) = pathDistance / model.speedOfEachVehicle(i);
        end
    end
end

% ��ȡÿ���ص㵽���ʱ�䡢�ȴ�ʱ��
function [arriveTime, waitingTime] = getArriveTime(vehiclePathTable, model)
    speedOfEachVehicleTable = repmat(model.speedOfEachVehicle', 1, model.numOfSupplyCentre);
    
    [numOfVehicle, numOfSupplyCentre] = size(vehiclePathTable);
    arriveTime = zeros(size(model.distanceMat, 1), 1);
    waitingTime = zeros(size(model.distanceMat, 1), 1);
    for j = 1: numOfSupplyCentre
        for i = 1: numOfVehicle
            pathOfVehicle = vehiclePathTable{i, j};
            speed = speedOfEachVehicleTable(i, j);
            [timeOfPath, waitingT] = getTimeOfPathNew(pathOfVehicle, speed, model);
            arriveTime(pathOfVehicle) = timeOfPath;
            waitingTime(pathOfVehicle) = waitingT;
        end
    end
    arriveTime = arriveTime(1: model.numOfCustomer);
    waitingTime = waitingTime(1: model.numOfCustomer);
end


%% ����·�߾���
function [pathDistance] = getPathDistance(path, model)
    pathDistance = 0;  
    for i = 1: length(path) - 1
        city1 = path(i);
        city2 = path(i + 1);
        dis = model.distanceMat(city1, city2);                              % �����ľ���
        pathDistance = pathDistance + dis;                                  % ��·�̣�ԽСԽ��
    end
end

% ·�߸���
function [pathLoad] = getPathLoad(path, model)
    demandOfCustomer = model.demandOfCustomer;
    pathLoad = 0;  
    for i = 2: length(path) - 1
        customerId = path(i);
        pathLoad = pathLoad + demandOfCustomer(customerId);
    end
end

% ·��ж��ʱ��
function [pathServiceTime] = getPathServiceTime(path, model)
    timeOfService = model.timeOfService;
    pathServiceTime = 0;  
    for i = 2: length(path) - 1
        customerId = path(i);
        pathServiceTime = pathServiceTime + timeOfService(customerId);
    end
end

% ʱ�䴰����������һ��·���е��������ʱ��/����ʱ�� �ȴ�ʱ��
function [timeOfPath, waitingT] = getTimeOfPathNew(pathOfVehicle, speed, model)
    TW = model.TW;                                                          % �����ʱ�䴰
    timeOfService = model.timeOfService;                                    % ��������ʱ��
    
    distanceMat = model.distanceMat;
    timeOfPath = zeros(1, length(pathOfVehicle));
    waitingT = zeros(1, length(pathOfVehicle));
    if length(pathOfVehicle) > 2
        idOfFirstCustomer = pathOfVehicle(2);
        timeOfPath(1) = TW(idOfFirstCustomer, 1) - distanceMat(pathOfVehicle(1), pathOfVehicle(2)) / speed;
    end
    for i = 2: length(pathOfVehicle)
        timeOfPath(i) = timeOfPath(i-1) + distanceMat(pathOfVehicle(i-1), pathOfVehicle(i)) / speed + timeOfService(pathOfVehicle(i-1));
        if i < length(pathOfVehicle)
            if timeOfPath(i) < TW(pathOfVehicle(i), 1)
                waitingT(i) = TW(pathOfVehicle(i), 1) - timeOfPath(i);
                timeOfPath(i) = TW(pathOfVehicle(i), 1);
            end
        end
    end
end

% ��ȡ������
function [overload] = getOverload(vehicleLoadTable, model)
    capacityOfEachVehicleTable = repmat(model.capacityOfEachVehicle', 1, model.numOfSupplyCentre);
    overload = sum((vehicleLoadTable - capacityOfEachVehicleTable) .* (vehicleLoadTable > capacityOfEachVehicleTable), 'all');
end

% ��ȡ������
function [overDistance] = getOverDistance(vehiclePathDistanceTable, model)
    distanceOfEachVehicleTable = repmat(model.maxDistanceOfEachVehicle', 1, model.numOfSupplyCentre);
    overDistance = sum((vehiclePathDistanceTable - distanceOfEachVehicleTable) .* (vehiclePathDistanceTable > distanceOfEachVehicleTable), 'all');
end

% ��ȡ�ܳ�ʱ
function [overTime] = getOverTime(arriveTime, model)
    LT = model.TW(:, 2);
    overTime = sum((arriveTime - LT) .* (arriveTime > LT), 'all');
end

% �̶��ɱ�C1
function [Cost1] = getCost1(vehicleStateTable, model)
    costOfEachVehicleTable = repmat(model.costOfEachVehicle', 1, model.numOfSupplyCentre);
    Cost1 = sum(vehicleStateTable .* costOfEachVehicleTable, 'all');
end

% ����ɱ�C2
function [Cost2] = getCost2(vehiclePathDistanceTable, model)
    costOfUnitKmTable = repmat(model.costOfUnitKm', 1, model.numOfSupplyCentre);
    Cost2 = sum(vehiclePathDistanceTable .* costOfUnitKmTable, 'all');
end

% �絽�ȴ��ɱ�C3
function [Cost3] = getCost3(waitingTime, model)
    Cost3 = sum(waitingTime) * model.p1;
end

% ����ȫ���ɱ�
function [Cost1, Cost2, Cost3, overload, overDistance, overTime] = getAllCost(individual, model)
    [vehiclePathTable] = model.getVehiclePathTable(individual, model);
    [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
    [arriveTime, waitingTime] = model.getArriveTime(vehiclePathTable, model);           % ��ʼж��ʱ�䡢�ȴ�ʱ��
    [overTime] = model.getOverTime(arriveTime, model);                                  % �ܳ�ʱ
    [overload] = model.getOverload(vehicleLoadTable, model);                            % ������
    [overDistance] = getOverDistance(vehiclePathDistanceTable, model);                  % ������
    
    [Cost1] = model.getCost1(vehicleStateTable, model);                                 % �̶��ɱ�C1
    [Cost2] = model.getCost2(vehiclePathDistanceTable, model);                          % ����ɱ�C2
    [Cost3] = model.getCost3(waitingTime, model);                                       % �絽�ȴ��ɱ�C3
end

function [objs] = getIndividualObjs(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = getAllCost(individual, model);
    f1 = Cost1 + Cost2 + (overload + overDistance) * model.penaltyFactor;
    f2 = Cost3 + overTime * model.p2 + (overload + overDistance) * model.penaltyFactor;
    objs = [f1 f2];
end

% ���������Ӧ��
function [individualFitness] = getIndividualFitness(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = model.getAllCost(individual, model);
    individualFitness = - Cost1 * 1 - Cost2 - Cost3 * 0 - (overload + overDistance) * model.penaltyFactor - overTime * model.p2 * 0;
end

function printIndividual(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = model.getAllCost(individual, model);
    individualFitness = - Cost1 - Cost2 - Cost3 - (overload + overDistance) * model.penaltyFactor - overTime * model.p2;
    fprintf('��������%.2f �ܳ��ࣺ%.2f �ܳ�ʱ��%.2f �̶��ɱ�C1:%.2f ����ɱ�C2:%.2f �絽�ȴ��ɱ�C3:%.2f �ܳɱ�:%.2f\n', overload, overDistance, overTime, Cost1, Cost2, Cost3, -individualFitness);
end



