%% 清空
clear;                                                                      % 清除所有变量
close all;                                                                  % 清图
clc;                                                                        % 清屏
%%
fileName = './data/mdvrpTWData0052.txt';
[model] = initModel1(fileName);

[individual] = model.initIndividual(model);
[individual] = model.repairIndividual(individual, model);
% model.showIndividual(individual, model);

[vehiclePathTable] = model.getVehiclePathTable(individual, model);
[vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);

[Cost1, Cost2, Cost3, Cost4, overload, overTime] = model.getAllCost(individual, model)







