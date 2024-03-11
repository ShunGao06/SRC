%%
clear;                                                                      % 清除所有变量
close all;                                                                  % 清图
clc;                                                                        % 清屏
%% 参数配置
addpath(genpath('.\'));                                                     % 将当前文件夹下的所有文件夹都包括进调用函数的目录
% rng(0,'twister');
populationSize = 50;                                                        % 种群规模
maxGeneration = 1000;                                                       % 最大进化代数
crossoverRate = 0.6;                                                        % 交叉概率
mutationRate = 0.01;                                                        % 变异概率

%% 模型1
fileName1 = './data/newData050.txt';
fileName2 =  './data/liancheng.dem';
fileName3 = './data/threats004.txt';

[model] = initModel2(fileName1, fileName2, fileName3);
%% 初始化
population = initialPopulation(populationSize, model);                      % 初始化种群
[population] = repairOperation(population, model);                          % 修复种群，防止越界
popFitness = getFitness(population, model);                                 % 计算种群适应度
numOfDecVariables = size(population, 2);                                    % 决策变量维度

bestIndividualSet = zeros(maxGeneration, numOfDecVariables);                % 每代最优个体集合
bestFitnessSet = zeros(maxGeneration, 1);                                   % 每代最高适应度集合
avgFitnessSet = zeros(maxGeneration, 1);                                    % 每代平均适应度集合

%% 进化
for i = 1 : maxGeneration
    newPopulation = selectionOperationOfTournament(population, popFitness);	% 选择操作
    [newPopulation] = crossoverOperationOfTsp(newPopulation, crossoverRate);% 交叉操作
    [newPopulation] = mutationOperationOfTsp(newPopulation, mutationRate);  % 变异操作
    
    [newPopulation] = repairOperation(newPopulation, model);                % 修复种群，防止越界
    newPopFitness = getFitness(newPopulation, model);                       % 子代种群适应度
    [population, popFitness] = eliteStrategy(population, popFitness, newPopulation, newPopFitness, 2); % 精英策略
    
    [bestIndividual, bestFitness, avgFitness] = getBestIndividualAndFitness(population, popFitness);
    bestIndividualSet(i, :) = bestIndividual;                               % 第i代最优个体
    bestFitnessSet(i) = bestFitness;                                        % 第i代最高适应度
    avgFitnessSet(i) = avgFitness;                                          % 第i代种群平均适应度
    fprintf('第%i代种群的最优值：%f\n', i, -bestFitness);
    
    if mod(i, 1000) == 0                                                    % 每隔100代绘制一幅图，因为绘图代价较大
        close all; 
        subplot(1,2,1);
        showIndividual(bestIndividual, model);                              % 路线可视化
        subplot(1,2,2);
        showEvolCurve(50, i, -bestFitnessSet, -bestFitnessSet);             % 显示进化曲线
        model.printIndividual(bestIndividual, model);
    end
end

%%
[objs] = model.getIndividualObjs(bestIndividual, model)
[vehiclePathTable] = model.getVehiclePathTable(bestIndividual, model);
[vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
[arriveTime, waitingTime] = model.getArriveTime(vehiclePathTable, model);           % 开始卸货时间、等待时间

arriveT = sort(arriveTime);

bestFitnessSetGa = bestFitnessSet;
save('.\result\bestFitnessSetGa.mat', 'bestFitnessSetGa');





