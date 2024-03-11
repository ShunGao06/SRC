function [newPopulation] = evolvePopulationSPBO(j, population, popFitness)
	populationSize = size(population, 1);
    [~, I] = max(popFitness);
    bestIndividual = population(I, :);
    newPopulation = population;
    
    ratioOfStudentNum = [2 1 1];                                            % 改进2，好学生、普通学生、差学生人数比例
    rT = cumsum(ratioOfStudentNum) / sum(ratioOfStudentNum);
    
    [~, index] = sort(popFitness, 'descend');
    population = population(index, :);

    
    for i = 1: populationSize    
        if I == i
            % Best Student                    
            newPopulation(i, :) = disturbOperationStrong(bestIndividual, j);
        elseif i/populationSize <= rT(1)
            % Good Student
            newPopulation(i, :) = learnOperation(population(i, :), bestIndividual, j);
        elseif i/populationSize <= rT(2)
            % Average Student
            rI = randperm(populationSize, 1);
            newPopulation(i, :) = learnOperation(population(i, :), population(rI, :), j);
        else
            % Students who improves randomly
            newPopulation(i, :) = disturbOperationWeak(population(i, :), j);
        end
    end
end

