function [path, rrTree] = getPathByRrt3D(Altitude, threats, droneSize, stepSize, startPoint, endPoint)
%     rng('default');
    mapSize = size(Altitude);
    threshold = stepSize;                                                       % �������ֵ���ӽ��Ľڵ㱻��Ϊ������ͬ
    maxFailedAttempts = 10000;                                                  % ����������
    rrTree = double([startPoint -1]);                                           % rrT������ʾ�ڵ�͸�����Ϊ��
    failedAttempts = 0;
    maxH = max(Altitude(:)) - 5;
    pathFound = false;
    numOfTime = 0;
    while failedAttempts <= maxFailedAttempts
        numOfTime = numOfTime + 1;
%         fprintf('%d\n', numOfTime);
        if rand <= 0.5
            rXY = round(rand(1, 2) .* (mapSize - [1 1]) + [1 1]);                                 % �ڵ�ͼ��Χ���������һ����
            minH = Altitude(rXY(1), rXY(2));
            rH = rand() * (maxH - minH) + minH + droneSize;
            rPoint = [rXY rH];
%             fprintf('%d\t%d\t%d\n', round(rPoint(1)), round(rPoint(2)), round(rPoint(3)));
        else
            rPoint = endPoint;                                                  % ���յ�ΪĿ�꣬ʹ������ƫ��Ŀ��
        end
%         fprintf('%d %.2f %.2f %.2f\n', failedAttempts, rPoint(1), rPoint(2), rPoint(3));
        
        distanceArray = getDistance(rrTree(:, 1: 3), rPoint);
        [A, I] = min(distanceArray ,[], 1);                                     % ѡ��rrT������ӽ�rPoint�Ľڵ�
        closestNode = rrTree(I(1), 1: 3);                                       % �����
        L = getDistance([0 0 0], rPoint - closestNode);
        newPoint = floor(closestNode + stepSize / L * (rPoint - closestNode));
        if newPoint(1) < 1 || newPoint(1) > mapSize(1) || newPoint(2) < 1 || newPoint(2) > mapSize(2)
            failedAttempts = failedAttempts + 1;
            continue;
        end
        if checkPath(closestNode, newPoint, Altitude, threats, droneSize) == 0        % ��������ڵ����µ����չ�Ƿ����
            failedAttempts = failedAttempts + 1;
            continue;
        end
        if getDistance(newPoint, endPoint) < threshold                     % ����µ���Ŀ���ܽ�
            if checkPath(newPoint, endPoint, Altitude, threats, droneSize) == 1
                rrTree = [rrTree; newPoint I(1)];
                pathFound = true;
                break;
            end
        end
        distanceArray = getDistance(rrTree(:, 1: 3), newPoint);
        [A, I2] = min(distanceArray,[],1);
        if getDistance(newPoint, rrTree(I2(1), 1: 3)) < threshold / 2      % ����½ڵ��Ƿ��Ѿ�����������(�����С�Ͳ�����)
            failedAttempts = failedAttempts + 1;
            continue;
        end 
        rrTree = [rrTree; newPoint I(1)];                                   % �����½ڵ�
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

