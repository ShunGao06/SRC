function showRrt3D(path, rrTree, Altitude, threats)
    startPoint = path(1, :);
    endPoint = path(end, :);
    drawMap3D(Altitude);
    for i = 1: size(threats, 1)
        drawThreat(threats(i, :));
    end
    plot3(startPoint(1), startPoint(2), startPoint(3), 'ro', 'MarkerSize', 4, 'LineWidth', 4);
    plot3(endPoint(1), endPoint(2), endPoint(3), 'gp', 'MarkerSize', 4, 'LineWidth',4);
    for i = 2: size(rrTree, 1)
        p1 = rrTree(rrTree(i, 4), 1: 3);
        p2 = rrTree(i, 1: 3);
        line([p1(1); p2(1)], [p1(2); p2(2)], [p1(3); p2(3)], 'LineWidth', 2);
%         getframe; 
    end
    line(path(:, 1), path(:, 2), path(:, 3), 'LineWidth', 2, 'Color', 'r');
end

