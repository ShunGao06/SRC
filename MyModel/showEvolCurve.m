function showEvolCurve(startI, endI, bestFitnessSet, avgFitnessSet)
% 展示种群进化曲线
    scope = startI: endI;
    plot(scope, bestFitnessSet(scope)', (scope), avgFitnessSet(scope)', 'LineWidth', 2);
    
%     plot(scope, bestFitnessSet(scope)', (scope), bestFitnessSet(scope)', 'LineWidth', 2);
    title('Population Evolution Curve', 'Fontsize', 20);
%     legend('Best Fitness', 'Average Fitness');
    xlabel('The Number Of Generations', 'Fontsize', 15);
    ylabel('Total Cost', 'Fontsize', 15);
    grid on;
    drawnow;
end

