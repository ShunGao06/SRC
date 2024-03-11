function [pathOfLonger] = getLongerPath(path, goalNumOfPathNodes)
    pathOfLonger = path;
    distanceArray = zeros(size(pathOfLonger, 1) - 1, 1);
    for i = 1: size(pathOfLonger, 1) - 1
        distanceArray(i) = distanceCost(pathOfLonger(i, :), pathOfLonger(i + 1, :));
    end

    for i = 1: goalNumOfPathNodes - size(pathOfLonger, 1)
        [maxDis, I] = max(distanceArray);
        p1 = pathOfLonger(I, :);
        p2 = pathOfLonger(I + 1, :);
        newP = (p1 + p2) / 2;
        pathOfLonger = [pathOfLonger(1: I, :); newP; pathOfLonger(I + 1: end, :)];
        d = maxDis / 2;
        distanceArray(I) = d;
        distanceArray = [distanceArray(1: I); d; distanceArray(I + 1: end)];
    end
end

