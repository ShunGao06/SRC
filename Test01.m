%% 2目标
load('.\data\NSGAII\NSGAII_myObj_M2_D70_1.mat');
Population1 = result{end, end};
X1 = result{end, end}.decs;
Y1 = result{end, end}.objs;
M1 = metric.IGD;

weight = [0.2 0.4];             % 权重
yOfWeight = Y1 * weight';       % 目标函数加权求和

% load('.\data\MOACO\MOACO_myObj_M2_D51_1.mat');
% X2 = result{end, end}.decs;
% Y2 = result{end, end}.objs;
% M2 = metric.IGD;


figure;
hold on;
varargin1 = {'o','MarkerSize',8,'Marker','o','Markerfacecolor',[.7 .7 .7],'Markeredgecolor',[.4 .4 .4]};
plot(Y1(:,1),Y1(:,2),varargin1{:});



%% 
figure;
% fileName = 'mdvrpTWData0052.txt';                                    % 数据集
% [model] = initModel1(fileName);                                             % 问题定义
fileName1 = 'newData050.txt';
fileName2 =  'liancheng.dem';
fileName3 = 'threats004.txt';
[model] = initModel2(fileName1, fileName2, fileName3);

individual = X1(10, :);                                                               % 选择一个个体
model.showIndividual(individual, model);
model.printIndividual(individual, model);

