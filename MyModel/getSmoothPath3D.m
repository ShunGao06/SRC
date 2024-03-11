function [pathOfSmooth] = getSmoothPath3D(path)
% Æ½»¬Â·Ïß
    t = 1: size(path, 1);
    tt = 1: 0.01: size(path, 1);
    xx = abs(spline(t, path(:, 1)', tt));
    yy = abs(spline(t, path(:, 2)', tt));
    zz = abs(spline(t, path(:, 3)', tt));
    pathOfSmooth = ([xx', yy', zz']);
end

