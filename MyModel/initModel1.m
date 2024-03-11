function [model] = initModel1(fileName)
	[data] = load(fileName);                                                % 前numOfCustomer个是用户坐标，剩余的为供应中心坐标
    model.numOfPoints = size(data, 1);
    model.numOfSupplyCentre = 4;                                                % 供应中心数量

    model.numOfCustomer = model.numOfPoints - model.numOfSupplyCentre;          % 客户数量
    model.coordinateOfSupplyCentre = data(model.numOfCustomer + 1: end, 1: 3);	% 供应中心坐标
    
    model.coordinateOfCustomer = data(1: model.numOfCustomer, 1: 3);            % 客户坐标
    model.demandOfCustomer = data(1: model.numOfCustomer, 4);                   % 客户需求
    model.timeOfService = data(:, 5);                                           % 服务时间，min
    model.TW = data(1: model.numOfCustomer, 6: 7);                              % 客户时间窗，min
    
    model.numOfVehicle = 6;                                                     % 每个供应中心车辆数
    model.costOfEachVehicle = zeros(1, model.numOfVehicle) + 300;               % 每辆车的固定成本，元
	model.capacityOfEachVehicle = zeros(1, model.numOfVehicle) + 500;           % 每辆车的容量,kg
    model.maxDistanceOfEachVehicle = zeros(1, model.numOfVehicle) + 200;        % 每辆车的最大行驶距离,km
    
    model.speedOfEachVehicle = zeros(1, model.numOfVehicle) + 2;                % 每辆车的速度,km/min
    model.costOfUnitKm = zeros(1, model.numOfVehicle) + 1;                      % 每辆车的单位运输成本,元/km
    
    model.p1 = 0.1;                                                            % 时间窗早到惩罚,元/min
    model.p2 = 10;                                                              % 时间窗迟到惩罚,元/min
    model.penaltyFactor = 10 ^ 8;                                               % 超载或超距惩罚因子
    model.numOfObjs = 2;                                                        % 目标数
    
    % 任意两点距离
    model.distanceMat = getDistanceMat(model.coordinateOfCustomer, model.coordinateOfSupplyCentre);
    % 决策变量维度
    model.numOfDecVariables = model.numOfCustomer + model.numOfSupplyCentre * model.numOfVehicle;
    
    
    model.initIndividual = @initIndividual;                                     % 初始化个体
    model.repairIndividual = @repairIndividual;                                 % 修复个体
    model.getIndividualFitness = @getIndividualFitness;                         % 计算个体适应度
    model.printIndividual = @printIndividual;                                   % 打印结果
    model.showIndividual = @showIndividual;                                     % 个体可视化
    
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
end

%% 计算两点距离
function [distanceMat] = getDistanceMat(coordinateOfCustomer, coordinateOfSupplyCentre)
    coordinate = [coordinateOfCustomer; coordinateOfSupplyCentre];          % 前numOfCustomer个是用户坐标，剩余的为供应中心坐标
    num = size(coordinate, 1);                                              % 坐标数量
    distanceMat = zeros(num, num);
    for i = 1 : num
        for j = 1 : num
            coordI = coordinate(i, :);                                      % 坐标i坐标
            coordJ = coordinate(j, :);                                      % 坐标j坐标
            distanceMat(i, j) = LpNorm(coordI, coordJ, 2) / 2;              % 计算坐标i和坐标j的欧氏距离
        end
    end
end

function [disMat] = LpNorm(vector1, vector2, p)
% Lp范数，广义上的距离
% p=1时，为曼哈顿距离；p=2时，欧氏距离；
% 例：vector1 = [0 0]; vector2 = [3 4]; p = 2;              输出：disMat = [5];
%     vector1 = [0 0; 2 2]; vector2 = [3 4; 1 1]; p = 1;	输出：disMat = [7;2];
    N = size(vector1, 1);
    disMat = zeros(N, 1);
    for i = 1 : N
        v1 = vector1(i, :);
        v2 = vector2(i, :);
        disMat(i) = sum(abs(v1 - v2).^p).^(1./p);    
    end
end

%% 初始化个体
function [individual] = initIndividual(model)
	numOfCustomer = model.numOfCustomer;                                    % 客户数量
    numOfSupplyCentre = model.numOfSupplyCentre;                            % 供应中心数量
    numOfVehicle = model.numOfVehicle;                                      % 每个供应中心汽车数量

    temp = meshgrid(1:numOfSupplyCentre,1:numOfVehicle) + numOfCustomer;
    temp = reshape(temp,[1,numOfSupplyCentre * numOfVehicle]);
    sequence = [1 : numOfCustomer, temp];
    individual = sequence(randperm(length(sequence)));
end

%% 修复个体
function [newIndividual] = repairIndividual(individual, model)
    numOfCustomer = model.numOfCustomer;                                    % 客户数量
    newIndividual = individual;
    centreIndex = find(individual > numOfCustomer);                         % 查询供应中心所在序列位置
    t = centreIndex(1);
    temp = newIndividual(1);
    newIndividual(1) = newIndividual(t);
    newIndividual(t) = temp;                                                % 起点必须为供应中心
end

%% 显示个体,路径可视化
function showIndividual(individual, model)
    [vehiclePathTable] = model.getVehiclePathTable(individual, model);
    [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
    
    numOfCustomer = model.numOfCustomer;                                    % 客户数量
    coordinateOfCustomer = model.coordinateOfCustomer;                      % 客户坐标
    coordinateOfSupplyCentre = model.coordinateOfSupplyCentre;              % 供应中心坐标

    coordinate = [coordinateOfCustomer; coordinateOfSupplyCentre];          % 前numOfCustomer个是用户坐标，剩余的为供应中心坐标
    xCoord = coordinate(:, 1);
    yCoord = coordinate(:, 2);
    zCoord = coordinate(:, 3);
    hold on;
    
    [numOfVehicle, numOfSupplyCentre] = size(vehiclePathTable);
    for j = 1: numOfSupplyCentre
        k = 0;
        for i = 1: numOfVehicle
            pathOfVehicle = vehiclePathTable{i, j};
            if length(pathOfVehicle) > 2
                k = k + 1;
                fprintf('供应点%d 车辆路线%d 距离%.2f： %s\n', j, k, vehiclePathDistanceTable(i, j), num2str(pathOfVehicle));
            end
            plot3(xCoord(pathOfVehicle),yCoord(pathOfVehicle),zCoord(pathOfVehicle),'-o','LineWidth',1,'MarkerSize',3,'MarkerFaceColor','white');
        end
    end
    
	for i = 1 : size(coordinate,1)
        text(xCoord(i), yCoord(i), zCoord(i), ['   ' num2str(i)], 'FontSize', 8);
	end
    
    for i = numOfCustomer + 1 : length(xCoord)
        plot3(xCoord(i), yCoord(i), zCoord(i), '*r','MarkerSize',20,'LineWidth',2);           % *供货点
    end
    title('Path', 'Fontsize', 20);
    drawnow;
    view([60 45]);
    hold off;
end

%% 获取每个供应中心每辆车的路线 行代表车辆 列代表供应中心
function [vehiclePathTable] = getVehiclePathTable(individual, model)
    numOfCustomer = model.numOfCustomer;                                    % 客户数量
    numOfVehicle = model.numOfVehicle;
    numOfSupplyCentre = model.numOfSupplyCentre;

    vehiclePathTable = cell(numOfVehicle, numOfSupplyCentre);              % 每个供应中心每辆车的路线
    vehicleNumTable = zeros(1, numOfSupplyCentre);
    centreIndex = find(individual > numOfCustomer);                         % 查询供应中心所在序列位置
    centreIndexEnd = [centreIndex(2 : end) - 1 , length(individual)];
    lengthOfPathArray = centreIndexEnd - centreIndex;                       % 每条路线的长度
    startPointOfVehicleArray = individual(centreIndex);                     % 每辆车的起点

    for i = 1 : length(lengthOfPathArray)
        k = startPointOfVehicleArray(i) - numOfCustomer;                    % 起点信息
        vehicleNumTable(k) = vehicleNumTable(k) + 1;
        startI = centreIndex(i);
        endI = centreIndexEnd(i);
        pathOfVehicle = [individual(startI : endI) individual(startI)];     % 车辆的路线
        vehiclePathTable{vehicleNumTable(k), k} = pathOfVehicle;
    end
end

% 每个供应中心每辆车的行驶距离、发车状态、负载量、服务时长
function [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = getVehiclePathDistanceTable(vehiclePathTable, model)
    vehiclePathDistanceTable = zeros(size(vehiclePathTable));               % 每个供应中心每辆车的行驶距离
    vehicleStateTable = zeros(size(vehiclePathTable));                      % 每个供应中心每辆车的发车状态
    vehicleLoadTable = zeros(size(vehiclePathTable));                       % 每个供应中心每辆车的负载量
    vehicleServiceTimeTable = zeros(size(vehiclePathTable));                % 每个供应中心每辆车的服务时长
    vehicleDrivingTimeTable = zeros(size(vehiclePathTable));                % 每个供应中心每辆车的行驶时长
    
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

% 获取每个地点到达的时间、等待时间
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


%% 计算路线距离
function [pathDistance] = getPathDistance(path, model)
    pathDistance = 0;  
    for i = 1: length(path) - 1
        city1 = path(i);
        city2 = path(i + 1);
        dis = model.distanceMat(city1, city2);                              % 两点间的距离
        pathDistance = pathDistance + dis;                                  % 总路程，越小越好
    end
end

% 路线负载
function [pathLoad] = getPathLoad(path, model)
    demandOfCustomer = model.demandOfCustomer;
    pathLoad = 0;  
    for i = 2: length(path) - 1
        customerId = path(i);
        pathLoad = pathLoad + demandOfCustomer(customerId);
    end
end

% 路线卸货时间
function [pathServiceTime] = getPathServiceTime(path, model)
    timeOfService = model.timeOfService;
    pathServiceTime = 0;  
    for i = 2: length(path) - 1
        customerId = path(i);
        pathServiceTime = pathServiceTime + timeOfService(customerId);
    end
end

% 时间窗滑动，计算一条路线中到达客户时间/运输时间 等待时间
function [timeOfPath, waitingT] = getTimeOfPathNew(pathOfVehicle, speed, model)
    TW = model.TW;                                                          % 客户时间窗
    timeOfService = model.timeOfService;                                    % 客户服务时间
    
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

% 获取超载量
function [overload] = getOverload(vehicleLoadTable, model)
    capacityOfEachVehicleTable = repmat(model.capacityOfEachVehicle', 1, model.numOfSupplyCentre);
    overload = sum((vehicleLoadTable - capacityOfEachVehicleTable) .* (vehicleLoadTable > capacityOfEachVehicleTable), 'all');
end

% 获取超距量
function [overDistance] = getOverDistance(vehiclePathDistanceTable, model)
    distanceOfEachVehicleTable = repmat(model.maxDistanceOfEachVehicle', 1, model.numOfSupplyCentre);
    overDistance = sum((vehiclePathDistanceTable - distanceOfEachVehicleTable) .* (vehiclePathDistanceTable > distanceOfEachVehicleTable), 'all');
end

% 获取总超时
function [overTime] = getOverTime(arriveTime, model)
    LT = model.TW(:, 2);
    overTime = sum((arriveTime - LT) .* (arriveTime > LT), 'all');
end

% 固定成本C1
function [Cost1] = getCost1(vehicleStateTable, model)
    costOfEachVehicleTable = repmat(model.costOfEachVehicle', 1, model.numOfSupplyCentre);
    Cost1 = sum(vehicleStateTable .* costOfEachVehicleTable, 'all');
end

% 运输成本C2
function [Cost2] = getCost2(vehiclePathDistanceTable, model)
    costOfUnitKmTable = repmat(model.costOfUnitKm', 1, model.numOfSupplyCentre);
    Cost2 = sum(vehiclePathDistanceTable .* costOfUnitKmTable, 'all');
end

% 早到等待成本C3
function [Cost3] = getCost3(waitingTime, model)
    Cost3 = sum(waitingTime) * model.p1;
end

% 计算全部成本
function [Cost1, Cost2, Cost3, overload, overDistance, overTime] = getAllCost(individual, model)
    [vehiclePathTable] = model.getVehiclePathTable(individual, model);
    [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
    [arriveTime, waitingTime] = model.getArriveTime(vehiclePathTable, model);           % 开始卸货时间、等待时间
    [overTime] = model.getOverTime(arriveTime, model);                                  % 总超时
    [overload] = model.getOverload(vehicleLoadTable, model);                            % 超载量
    [overDistance] = getOverDistance(vehiclePathDistanceTable, model);                  % 超距量
    
    [Cost1] = model.getCost1(vehicleStateTable, model);                                 % 固定成本C1
    [Cost2] = model.getCost2(vehiclePathDistanceTable, model);                          % 运输成本C2
    [Cost3] = model.getCost3(waitingTime, model);                                       % 早到等待成本C3
end

function [objs] = getIndividualObjs(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = getAllCost(individual, model);
    f1 = Cost1 + Cost2 + (overload + overDistance) * model.penaltyFactor;
    f2 = Cost3 + overTime * model.p2 + (overload + overDistance) * model.penaltyFactor;
    objs = [f1 f2];
end

% 计算个体适应度
function [individualFitness] = getIndividualFitness(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = model.getAllCost(individual, model);
    individualFitness = - Cost1 * 1 - Cost2 - Cost3 * 0 - (overload + overDistance) * model.penaltyFactor - overTime * model.p2 * 0;
end

function printIndividual(individual, model)
    [Cost1, Cost2, Cost3, overload, overDistance, overTime] = model.getAllCost(individual, model);
    individualFitness = - Cost1 - Cost2 - Cost3 - (overload + overDistance) * model.penaltyFactor - overTime * model.p2;
    fprintf('超载量：%.2f 总超距：%.2f 总超时：%.2f 固定成本C1:%.2f 运输成本C2:%.2f 早到等待成本C3:%.2f 总成本:%.2f\n', overload, overDistance, overTime, Cost1, Cost2, Cost3, -individualFitness);
end


