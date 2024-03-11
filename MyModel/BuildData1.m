%% X Y 需求量 服务时间 ET LT
numOfPoints = 52;                                                           % 点的数目（多个需求点+多个供应点）

coordOfPoints = rand(numOfPoints, 3) * (100 - 0) + 0;                       % 随机生成坐标
demandOfPoints = rand(numOfPoints, 1) * (100 - 0) + 1;                      % 随机生成需求量
TOfService = round(rand(numOfPoints, 1) * (3 - 1) + 1);                     % 服务时间

% 随机生成时间窗
ET = round(rand(numOfPoints, 1) * (60 - 30) + 30);                          % ET
LT = ET + round(rand(numOfPoints, 1) * (60 - 30) + 30);                     % LT
% 客户属性
attr = [coordOfPoints demandOfPoints TOfService ET LT];


%% 保存成文件
fileName1 = sprintf('./Data/mdvrpTWData%04d.txt', numOfPoints);
fid1 = fopen(fileName1, 'w');
for i = 1 : numOfPoints
	fprintf(fid1,'%.2f\t%.2f\t%.2f\t%.2f\t%d\t%d\t%d\n', attr(i, 1), attr(i, 2), attr(i, 3), attr(i, 4), attr(i, 5), attr(i, 6), attr(i, 7));
end
fclose(fid1);

