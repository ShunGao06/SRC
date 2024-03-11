% -------------------------------------------------------------------------
% 蚁群算法（ACO）求解
% @作者：冰中呆
% @邮箱：1209805090@qq.com
% @时间：2023.12.27
% -------------------------------------------------------------------------
%% 清空
clear;                                                                      % 清除所有变量
close all;                                                                  % 清图
clc;                                                                        % 清屏
%% 参数配置
addpath(genpath('.\'));                                                     % 将当前文件夹下的所有文件夹都包括进调用函数的目录
% rng(0,'twister');
populationSize = 50;                                                       % 种群规模
maxGeneration = 1000;                                                      % 最大进化代数
Alpha = 1;                                                                 	% 信息素重要程度参数              
Beta = 2;                                                                  	% 启发式因子重要程度参数
Rho = 0.2;                                                                 	% 信息素蒸发系数
Q = 100;                                                                   	% 信息素增加强度系数


fileName = './data/mdvrpTWData0052.txt';                                    % 数据集
[model] = initModel1(fileName);                                             % 问题定义

%% 初始化
distanceMat = model.distanceMat;
Eta = 1 ./ distanceMat;                                                     % Eta为启发因子,这里设为距离的倒数
numOfDecVariables = model.numOfDecVariables;                                % 决策变量维度
pheromoneMat = ones(numOfDecVariables, numOfDecVariables);                 	% pheromone为信息素矩阵

bestIndividualSet = zeros(maxGeneration, numOfDecVariables);                % 每代最优个体集合
bestFitnessSet = zeros(maxGeneration, 1);                                   % 每代最高适应度集合
avgFitnessSet = zeros(maxGeneration, 1);                                    % 每代平均适应度集合

%% 进化
for i = 1 : maxGeneration       
    population = getPopulationOfAco(populationSize, numOfDecVariables, pheromoneMat, Eta, Alpha, Beta, model);
    population = repairOperation(population, model);                       	% 修复种群
    if i >= 2
        population(1,:) = bestIndividualSet(i-1,:);                         % 精英选择
    end
    
    popFitness = getFitness(population, model);                             % 计算种群适应度
    pheromoneMat = updatePheromoneMat(pheromoneMat, population, -popFitness, Rho, Q);       % 更新信息素矩阵
    
    
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


bestFitnessSetAco = bestFitnessSet;
save('.\result\bestFitnessSetAco.mat', 'bestFitnessSetAco');

