function avgSTD = plotAvgResponse(logicalIndices)

load(getDatasetMat, 'tracesMat');

setResponses = tracesMat(logicalIndices, :);
avgResponse = mean(setResponses, 1);
stdResponse = std(setResponses, [], 1);
upSTD = avgResponse + stdResponse / 2;
downSTD = avgResponse - stdResponse / 2;
avgSTD = mean(stdResponse);

x = 1:length(avgResponse);
x2 = [x, fliplr(x)];
inBetween = [upSTD, fliplr(downSTD)];
fill(x2, inBetween, [0.75, 0.75, 0.75]);
 hold on

[~, lengthX] = size(setResponses);
lengthY = 1.5;

% plot the stimuli time sequence
simtulusParamsPath = strcat(projectPath(), '/VisualStimulations/EulerStim.mat');
load(simtulusParamsPath, 'responseTimeSequence', 'freqCalciumImaging');
 
stimSteps = cumsum(responseTimeSequence) * freqCalciumImaging;
zeroPlot = zeros(lengthX, 1);
plot(zeroPlot, 'k-.');
y1=get(gca,'ylim');

for dt = stimSteps(1:end-1)
    plot([dt dt],y1, 'k-.');
end
plot(avgResponse, 'r', 'LineWidth', 3)
hold off

xlim([0 lengthX])
ylim([-lengthY +lengthY])

yticks([-1 0 1])
xticks(cumsum(responseTimeSequence(1:end-1)) * freqCalciumImaging);
xticklabels(cumsum(responseTimeSequence(1:end-1)));
