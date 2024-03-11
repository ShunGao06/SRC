function [p] = drawThreat(threat)
    colorsOfThreat = {'r', 'g', 'b', 'y'};
    x0 = threat(1);
    y0 = threat(2);
    z0 = threat(3);
    r = threat(4);
    typeOfThreat = threat(5);
    [x, y, z] = sphere;
    x = r * x + x0;
    y = r * y + y0;
    z = r * z + z0;
    for i = 1: size(z, 1)
        for j = 1 : size(z, 2)
            if z(i, j) <= 0
                z(i, j) = 0;
            end
        end
    end
    color = colorsOfThreat{typeOfThreat};
    p = surf(x, y, z ,'facecolor', color, 'faceAlpha', 0.5);
    set(p, 'FaceColor', color, 'faceAlpha', 0.5);
    
    grid on;
end

