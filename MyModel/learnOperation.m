function [newIndividual] = learnOperation(individual, goalIndividual, j)
    numOfDecVariables = length(individual);
    newIndividual = individual;
    
    G1 = individual(j);                                                  % �Ӹ���0�л�ȡ��j������λ�ϵĻ���gene
    index = find(goalIndividual == G1);                                      % �Ӹ���1���ҵ�����gene����λ��
	index = index(randperm(length(index), 1));                              % ���indexΪ���,���ȡһ��
    if index < numOfDecVariables                                            % ��ȡ����gene����λ��
        index = index + 1;                                                  % �Ҳ��λ��
    else
        index = index - 1;                                                  % ����λ��
    end
    G2 = goalIndividual(index);                                              % ��֮ǰ����gene���ڵĻ���ע���ʱ��gene�ѱ����£�
    index = find(individual == G2);                                      % �ڵ�i�����壨��������壩���ҵ�����gene����λ��
    rJ = index(randperm(length(index), 1));                              % ���indexΪ���,���ȡһ��
    if j < rJ
        newIndividual(j + 1: rJ) = individual(rJ: -1: j + 1);
    else
        newIndividual(rJ: j - 1) = individual(j - 1: -1: rJ);
    end
end

