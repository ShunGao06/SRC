classdef MOACO < ALGORITHM
% <multi> <real/integer/label/binary/permutation> <constrained/none>


    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Alpha = 1;                                                                 	% 信息素重要程度参数              
            Beta = 2;                                                                  	% 启发式因子重要程度参数
            Rho = 0.2;                                                                 	% 信息素蒸发系数
            Q = 100;                                                                   	% 信息素增加强度系数
            
            populationSize = Problem.N;
            numOfDecVariables = Problem.D;
            model = Problem.model;
            distanceMat = model.distanceMat;
            Eta = 1 ./ distanceMat;                                                     % Eta为启发因子,这里设为距离的倒数
            pheromoneMat = ones(numOfDecVariables, numOfDecVariables);                 	% pheromone为信息素矩阵
            
            populationDec = getPopulationOfAco(populationSize, numOfDecVariables, pheromoneMat, Eta, Alpha, Beta, model);
            [populationDec] = repairOperation(populationDec, model);                % 修复种群，防止越界
            Population = Problem.Evaluation(populationDec);
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);

            maxGeneration = round(Problem.maxFE / Problem.N);
            %% Optimization
            while Algorithm.NotTerminated(Population)
                offspringDec = getPopulationOfAco(populationSize, numOfDecVariables, pheromoneMat, Eta, Alpha, Beta, model);
                offspringDec = repairOperation(offspringDec, model);                       	% 修复种群
                Offspring = Problem.Evaluation(offspringDec);
                popObjs = Offspring.objs;
                w1 = rand(size(popObjs, 1), 1);
                w2 = 1 - w1;
                popFitness = sum([w1, w2] .* popObjs, 2);
                pheromoneMat = updatePheromoneMat(pheromoneMat, offspringDec, popFitness, Rho, Q);       % 更新信息素矩阵
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
            end
        end
    end
end