%% ���
clear;                                                                      % ������б���
close all;                                                                  % ��ͼ
clc;                                                                        % ����
%%
fileName = './data/mdvrpTWData0052.txt';
% ֮ǰ��·��
sequenceOfRoute = [51,39,41,17,46,16,33,51,52,30,15,26,38,49,18,25,51,29,44,14,52,52,19,31,24,45,50,36,51,35,13,8,37,52,5,20,7,12,11,9,52,1,52,47,4,40,42,43,28,27,3,32,51,22,34,2,48,6,10,23,21,51];
T = 55;                                                                     % �ͻ�����ʱ�䴰��ʱ��
[model] = initModel2(fileName, T, sequenceOfRoute);

[individual] = model.initIndividual(model);
[individual] = model.repairIndividual(individual, model);

[individualFitness] = model.getIndividualFitness(individual, model)
model.printIndividual(individual, model);
model.showIndividual(individual, model);


[individualIntegrity] = model.getIndividualIntegrity(individual, model);
[vehiclePathTable] = model.getVehiclePathTable(individualIntegrity, model);
[vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);


% 
% [vehiclePathTable1] = model.getVehiclePathTable(sequenceOfRoute, model);
% [vehiclePathTable2] = model.getVehiclePathTable(individual, model);
% % sequenceOfRoute = model.sequenceOfRoute;
% % [vehiclePathTable] = model.getVehiclePathTable(sequenceOfRoute, model);
% % [vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
% % [arriveTime, waitingTime] = model.getArriveTime(vehiclePathTable, model);           % ��ʼж��ʱ�䡢�ȴ�ʱ��





