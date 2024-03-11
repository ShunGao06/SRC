function [Altitude] = readMap(fileName)
    file = fopen(fileName, 'r');
    frame = fgetl(file);
    % 读取本例未使用的几行数据
    fgetl(file);
    fgetl(file);
    fgetl(file);
    fgetl(file);
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    X0 = str2double(S(1));
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    Y0 = str2double(S(1));
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    DX = str2double(S(1));
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    DY = str2double(S(1));
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    Row = str2double(S(1));
    line = fgetl(file);
    S = regexp(line, ':+', 'split');
    Col = str2double(S(1));
    %读取本例不需要的数据行
    fgetl(file);
    %开始读取数据
    Altitude = zeros(Row,Col);
    for i = 1:Row
        line = fgetl(file);
        if line == -1
            continue;
        else
            S = regexp(line, '\s+', 'split');
            Altitude(i,1:Col) = str2double(S(1:Col))';
        end
    end

    minH = min(min(Altitude));
    deletH = max(max(Altitude)) - minH;
    Altitude = Altitude - minH;
    Altitude = ceil(Altitude/deletH * 2000);
    Altitude = flip(Altitude,1);
end

