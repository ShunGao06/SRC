function [population] = getPopulationOfAco(populationSize, numOfDecVariables, pheromoneMat, Eta, Alpha, Beta, model)
% ���룺��Ⱥ��ģ�����߱���ά�ȡ���Ϣ�ؾ����������ӡ���Ϣ����Ҫ�̶Ȳ���������ʽ������Ҫ�̶Ȳ���
    population = zeros(populationSize, numOfDecVariables);
    individual = model.initIndividual(model);
    citySet = sort(individual);
    
    proOfVisitingMat = zeros(numOfDecVariables, numOfDecVariables);
    for i = 1 :numOfDecVariables
        I = citySet(i);
        for j = 1 : numOfDecVariables
            J = citySet(j);
            proOfVisitingMat(I, J) = (pheromoneMat(I, J) ^ Alpha) * (Eta(I, J) ^ Beta);
        end
    end
    

    for i = 1 : populationSize
        startCity = individual(mod(i, numOfDecVariables) + 1);
        population(i, :) = getIndividual(startCity, citySet, proOfVisitingMat);
    end
    
end

function [individual] = getIndividual(startCity, citySet, proOfVisitingMat)
    numOfDecVariables = length(citySet);
    individual = zeros(1, numOfDecVariables);
    individual(1) = startCity;
    
    index = find(citySet == startCity);
    index = index(1);
    visiting = [citySet(1:index - 1) citySet(index + 1 : end)];             % �����ʵĳ���
    
    for i = 2 : numOfDecVariables
        n = numOfDecVariables - i + 1;                                      % �����ʵĳ�����Ŀ
        proOfVisiting = zeros(1, n);                                        % �����ʳ��е�ѡ����ʷֲ�
        city = individual(i - 1);                                           % ��ǰ����
        for k = 1 : n                                                       % �����ѡ���еĸ��ʷֲ�
            proOfVisiting(k) = proOfVisitingMat(city, visiting(k));
        end
        proOfVisiting = proOfVisiting / sum(proOfVisiting);
        % ������ԭ��ѡȡ��һ������
        proCum = cumsum(proOfVisiting);
        select = find(proCum >= rand, 1);                                   % ���̶�
        if isempty(select)
            select = randperm(n);
        end
        visited = visiting(select(1));                                      % ѡ�еĳ���
        individual(i) = visited;
        
        index = find(visiting == visited);
        index = index(1);                                                   % ���п����ظ�
        visiting = [visiting(1:index - 1) visiting(index + 1 : end)];       % ʣ������ʵĳ���
    end

end





