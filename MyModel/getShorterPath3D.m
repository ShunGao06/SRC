function [pathOfShorter] = getShorterPath3D(path, droneSize, Altitude, threats)
    pathOfShorter = path(1, :);
    p1 = pathOfShorter(end, :);
    t = 1;
    while p1(1) ~= path(end, 1) || p1(2) ~= path(end, 2) || p1(3) ~= path(end, 3)
%         disp(p1);
%         disp(path(end, :));
%         disp('****');
        if t > 5000
%             disp('****');
            pathOfShorter = [pathOfShorter; path(end, :)];
            break;
        end
        for j = size(path, 1): -1 : 1
            p2 = path(j, :);
%             fprintf('%d %d\n', j, checkPath(p1, p2, Altitude, threats, droneSize));
            if checkPath(p1, p2, Altitude, threats, droneSize) == 1
                pathOfShorter = [pathOfShorter; p2];
                p1 = pathOfShorter(end, :);
                t = t + 1;
                break;
            end
        end
    end
end





