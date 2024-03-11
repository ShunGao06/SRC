function [newPopulation] = repairOperation(population, model)
% 修复违反约束个体
    newPopulation = zeros(size(population));
    populationSize = size(population, 1);
    for i = 1 : populationSize
        individual = population(i, :);
        newPopulation(i, :) = model.repairIndividual(individual, model);
    end
end

