function [newPopulation] = mutationOperationOfTsp(population, mutationRate)
% ��Ⱥ�������
    populationSize = size(population, 1);
    newPopulation = zeros(size(population));
    for i = 1 : populationSize
        individual = population(i, :);
        newPopulation(i, :) = mutateIndividual(individual, mutationRate);
    end

end

%% ������죬ÿ������λ��mutationRate�������������λ����
function [individual] = mutateIndividual(individual, mutationRate)
    n = length(individual);
    for i = 1: n
        if rand() < mutationRate
            r0 = i;                                                         % ��i,jλ����
            r1 = round(rand() * (n-1) + 1);                                 % ����һ��1-n��������
            s = sort([r0 r1]);                                              % ����ʹr0<r1
            r0 = s(1);
            r1 = s(2);
            individual(r0:r1) = individual(r1:-1:r0);                      	% r0-r1��Ԫ�ص���
        end
    end
end

