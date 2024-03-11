function [flag] = checkPath(point1, point2, Altitude, threats, droneSize)
    [flag] = checkMap(point1, point2, Altitude, droneSize);
    if flag == 1
        [flag] = checkThreats(point1, point2, threats, droneSize);
    end
end

function [flag] = checkMap(point1, point2, Altitude, droneSize)
    numOfNodes = round(max(abs(point1 - point2))) + 1;
    pathX = linspace(point1(1), point2(1), numOfNodes)';
    pathY = linspace(point1(2), point2(2), numOfNodes)';
    pathZ = linspace(point1(3), point2(3), numOfNodes)';
    path = [pathX pathY pathZ];
    flag = 1;
    for i = 1: size(path, 1)
        x1 = floor(path(i, 1));
        x2 = ceil(path(i, 1));
        y1 = floor(path(i, 2));
        y2 = ceil(path(i, 2));
        z = path(i, 3) - droneSize;
        if z < Altitude(x1, y1) || z < Altitude(x1, y2) || z < Altitude(x2, y1) || z < Altitude(x2, y2)
            flag = 0;
            break;
        end
    end
end

function [flag] = checkThreats(point1, point2, threats, droneSize)
    flag = 1;
    for i = 1: size(threats, 1)
        threat = threats(i, :);
        threatX = threat(1);
        threatY = threat(2);
        threatZ = threat(3);
        threatR = threat(4);
        % 计算点到段之间的最小距离
        dist = distP2S([threatX threatY threatZ], point1, point2);
        if dist < (threatR + droneSize)                             % 碰撞
            flag = 0;
            break;
        end
    end
end


