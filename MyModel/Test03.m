%% 清空
clear;                                                                      % 清除所有变量
close all;                                                                  % 清图
clc;                                                                        % 清屏
%%
fileName1 = './data/newData050.txt';
fileName2 =  './data/liancheng.dem';
fileName3 = './data/threats004.txt';

[model] = initModel2(fileName1, fileName2, fileName3);

[individual] = model.initIndividual(model)
[individual] = model.repairIndividual(individual, model)
[individualFitness] = model.getIndividualFitness(individual, model)
model.printIndividual(individual, model)
[objs] = model.getObjs(individual, model)


model.showIndividual(individual, model)
% pointIds = [50 2 3 4 5 50];
% 
% 
% model.drawEnvironment(model);
% model.drawPoints(model);
% pathOfSmoothArray = model.showPath(pointIds, model);
