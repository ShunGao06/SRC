function [path, rrTree] = getPathByRrt3D(Altitude, threats, droneSize, stepSize, startPoint, endPoint)
%     rng('default');
    mapSize = size(Altitude);
    threshold = stepSize;                                                       % 比这个阈值更接近的节点被视为几乎相同
    maxFailedAttempts = 10000;                                                  % 最大迭代次数
    rrTree = double([startPoint -1]);                                           % rrT以起点表示节点和父索引为根
    failedAttempts = 0;
    maxH = max(Altitude(:)) - 5;
    pathFound = false;
    numOfTime = 0;
    while failedAttempts <= maxFailedAttempts
        numOfTime = numOfTime + 1;
%         fprintf('%d\n', numOfTime);
        if rand <= 0.5
            rXY = round(rand(1, 2) .* (mapSize - [1 1]) + [1 1]);                                 % 在地图范围内随机产生一个点
            minH = Altitude(rXY(1), rXY(2));
            rH = rand() * (maxH - minH) + minH + droneSize;
            rPoint = [rXY rH];
%             fprintf('%d\t%d\t%d\n', round(rPoint(1)), round(rPoint(2)), round(rPoint(3)));
        else
            rPoint = endPoint;                                                  % 以终点为目标，使树生成偏向目标
        end
%         fprintf('%d %.2f %.2f %.2f\n', failedAttempts, rPoint(1), rPoint(2), rPoint(3));
        
        distanceArray = getDistance(rrTree(:, 1: 3), rPoint);
        [A, I] = min(distanceArray ,[], 1);                                     % 选择rrT树中最接近rPoint的节点
        closestNode = rrTree(I(1), 1: 3);                                       % 最近点
        L = getDistance([0 0 0], rPoint - closestNode);
        newPoint = floor(closestNode + stepSize / L * (rPoint - closestNode));
        if newPoint(1) < 1 || newPoint(1) > mapSize(1) || newPoint(2) < 1 || newPoint(2) > mapSize(2)
            failedAttempts = failedAttempts + 1;
            continue;
        end
        if checkPath(closestNode, newPoint, Altitude, threats, droneSize) == 0        % 树中最近节点向新点的扩展是否可行
            failedAttempts = failedAttempts + 1;
            continue;
        end
        if getDistance(newPoint, endPoint) < threshold                     % 如果新点离目标点很近
            if checkPath(newPoint, endPoint, Altitude, threats, droneSize) == 1
                rrTree = [rrTree; newPoint I(1)];
                pathFound = true;
                break;
            end
        end
        distanceArray = getDistance(rrTree(:, 1: 3), newPoint);
        [A, I2] = min(distanceArray,[],1);
        if getDistance(newPoint, rrTree(I2(1), 1: 3)) < threshold / 2      % 检查新节点是否已经存在于树中(距离过小就不放入)
            failedAttempts = failedAttempts + 1;
            continue;
        end 
        rrTree = [rrTree; newPoint I(1)];                                   % 加入新节点
        failedAttempts = 0;
    end

    if pathFound
        rrTree = [rrTree; endPoint size(rrTree, 1)];
    end

    path = endPoint;
    prev = I(1);
    while prev > 0
%         fprintf('***\n');
        path = [rrTree(prev, 1: 3); path];
        prev = rrTree(prev, 4);
    end
end

