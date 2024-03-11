function [PopObj] = getMultipleFitness(population, model)
% ������Ⱥ��Ӧ��
    populationSize = size(population, 1);
    
    PopObj = [];
    
    
    for i = 1: populationSize
        individual = population(i, :);
        [objs] = model.getIndividualObjs(individual, model);
        PopObj = [PopObj; objs];
    end
end

