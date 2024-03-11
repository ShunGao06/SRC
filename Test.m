cd(fileparts(mfilename('fullpath')));
addpath(genpath(cd));

N = 50;                                                                     % 种群规模
maxFE = N * 500;                                                            % 最大评估次数
% platemo('algorithm', @MOACO, 'N', N, 'problem', @myObj, 'maxFE', maxFE, 'save', 10);    % 出结果数据
platemo('algorithm', @NSGAII, 'N', N, 'problem', @myObj, 'maxFE', maxFE, 'save', 10);





% platemo('algorithm', @NSGAII, 'N', N, 'problem', @myObj, 'maxFE', maxFE);  % 出图

