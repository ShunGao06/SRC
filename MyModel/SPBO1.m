
%% 清空
clear;                                                                      % 清除所有变量
close all;                                                                  % 清图
clc;                                                                        % 清屏
%% 参数配置
addpath(genpath('.\'));                                                     % 将当前文件夹下的所有文件夹都包括进调用函数的目录
rng(0,'twister');
populationSize = 50;                                                        % 种群规模
maxGeneration = 1000;                                                        % 最大进化代数

fileName = './data/data0052.txt';                                    % 数据集
[model] = initModel1(fileName);                                             % 问题定义

%% 初始化
population = initialPopulation(populationSize, model);                      % 初始化种群
population = repairOperation(population, model);                            % 修复种群
popFitness = getFitness(population, model);                                 % 计算种群适应度
numOfDecVariables = size(population, 2);                                    % 决策变量维度

bestIndividualSet = zeros(maxGeneration, numOfDecVariables);                % 每代最优个体集合
bestFitnessSet = zeros(maxGeneration, 1);                                   % 每代最高适应度集合
avgFitnessSet = zeros(maxGeneration, 1);                                    % 每代平均适应度集合

for t = 1:maxGeneration
    for j = 1: numOfDecVariables
        [newPopulation] = evolvePopulationSPBO(j, population, popFitness);
        newPopulation = repairOperation(newPopulation, model);          	% 修复种群
        newPopFitness = getFitness(newPopulation, model);                   % 计算种群适应度
        [population, popFitness] = eliteStrategy(population, popFitness, newPopulation, newPopFitness, 3);
    end

    [bestIndividual, bestFitness, avgFitness] = getBestIndividualAndFitness(population, popFitness);
    avgFitnessSet(t) = avgFitness;       
    bestFitnessSet(t) = bestFitness;
    bestIndividualSet(t, :) = bestIndividual;
    fprintf('第%i代种群的最优值：%.3f\n', t, -bestFitness);
    if mod(t, 100) == 0
        close all; 
        subplot(1,2,1);
        showIndividual(bestIndividual, model);                              % 路线可视化
        subplot(1,2,2);
        showEvolCurve(10, t, -bestFitnessSet, -avgFitnessSet);              % 显示进化曲线
        model.printIndividual(bestIndividual, model);
    end
end

bestFitnessSetSpbo = bestFitnessSet;
save('./result/bestFitnessSetSpbo.mat', 'bestFitnessSetSpbo');