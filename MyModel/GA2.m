%%
clear;                                                                      % ������б���
close all;                                                                  % ��ͼ
clc;                                                                        % ����
%% ��������
addpath(genpath('.\'));                                                     % ����ǰ�ļ����µ������ļ��ж����������ú�����Ŀ¼
% rng(0,'twister');
populationSize = 50;                                                        % ��Ⱥ��ģ
maxGeneration = 1000;                                                       % ����������
crossoverRate = 0.6;                                                        % �������
mutationRate = 0.01;                                                        % �������

%% ģ��1
fileName1 = './data/newData050.txt';
fileName2 =  './data/liancheng.dem';
fileName3 = './data/threats004.txt';

[model] = initModel2(fileName1, fileName2, fileName3);
%% ��ʼ��
population = initialPopulation(populationSize, model);                      % ��ʼ����Ⱥ
[population] = repairOperation(population, model);                          % �޸���Ⱥ����ֹԽ��
popFitness = getFitness(population, model);                                 % ������Ⱥ��Ӧ��
numOfDecVariables = size(population, 2);                                    % ���߱���ά��

bestIndividualSet = zeros(maxGeneration, numOfDecVariables);                % ÿ�����Ÿ��弯��
bestFitnessSet = zeros(maxGeneration, 1);                                   % ÿ�������Ӧ�ȼ���
avgFitnessSet = zeros(maxGeneration, 1);                                    % ÿ��ƽ����Ӧ�ȼ���

%% ����
for i = 1 : maxGeneration
    newPopulation = selectionOperationOfTournament(population, popFitness);	% ѡ�����
    [newPopulation] = crossoverOperationOfTsp(newPopulation, crossoverRate);% �������
    [newPopulation] = mutationOperationOfTsp(newPopulation, mutationRate);  % �������
    
    [newPopulation] = repairOperation(newPopulation, model);                % �޸���Ⱥ����ֹԽ��
    newPopFitness = getFitness(newPopulation, model);                       % �Ӵ���Ⱥ��Ӧ��
    [population, popFitness] = eliteStrategy(population, popFitness, newPopulation, newPopFitness, 2); % ��Ӣ����
    
    [bestIndividual, bestFitness, avgFitness] = getBestIndividualAndFitness(population, popFitness);
    bestIndividualSet(i, :) = bestIndividual;                               % ��i�����Ÿ���
    bestFitnessSet(i) = bestFitness;                                        % ��i�������Ӧ��
    avgFitnessSet(i) = avgFitness;                                          % ��i����Ⱥƽ����Ӧ��
    fprintf('��%i����Ⱥ������ֵ��%f\n', i, -bestFitness);
    
    if mod(i, 1000) == 0                                                    % ÿ��100������һ��ͼ����Ϊ��ͼ���۽ϴ�
        close all; 
        subplot(1,2,1);
        showIndividual(bestIndividual, model);                              % ·�߿��ӻ�
        subplot(1,2,2);
        showEvolCurve(50, i, -bestFitnessSet, -bestFitnessSet);             % ��ʾ��������
        model.printIndividual(bestIndividual, model);
    end
end

%%
[objs] = model.getIndividualObjs(bestIndividual, model)
[vehiclePathTable] = model.getVehiclePathTable(bestIndividual, model);
[vehiclePathDistanceTable, vehicleStateTable, vehicleLoadTable, vehicleServiceTimeTable, vehicleDrivingTimeTable] = model.getVehiclePathDistanceTable(vehiclePathTable, model);
[arriveTime, waitingTime] = model.getArriveTime(vehiclePathTable, model);           % ��ʼж��ʱ�䡢�ȴ�ʱ��

arriveT = sort(arriveTime);

bestFitnessSetGa = bestFitnessSet;
save('.\result\bestFitnessSetGa.mat', 'bestFitnessSetGa');





