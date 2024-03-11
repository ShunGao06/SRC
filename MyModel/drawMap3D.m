function drawMap3D(Altitude)
    [x, y] = meshgrid(1: size(Altitude, 1), 1: size(Altitude, 2));
    surf(x, y, Altitude');
    cmap = demcmap(Altitude, 256);
    [~, ~] = mkdir('texture');
    Zscaled = Altitude .* (size(cmap, 1) - 1) ./ max(Altitude(:));
    imwrite(rot90(Zscaled), cmap, 'data/sanfrancisco_elev.png');
    h = findobj('Type', 'surface');
    set(h, 'Facecolor', 'texturemap');
    colormap(cmap);
    shading interp;
    hold on;
    axis([0 size(Altitude, 1) 0 size(Altitude, 2) 0 50]);
    daspect([1 1 1]);
    view(-215, 30);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end

