function lengthX = plotAvgEulerResponse(expID, nCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
simtulusParamsPath = strcat(projectPath(), '/VisualStimulations/EulerStim.mat');
dataRelativePath = '/traces/eulerResponses.mat';
dataPath = strcat(experimentsPath, expID, dataRelativePath);

% plot the trace
load(dataPath, 'eulerAvgResponse', 'qualityIndexEuler');
trace = eulerAvgResponse(nCell,:);
plot(trace, 'LineWidth', 1.2);
hold on

[~, lengthX] = size(eulerAvgResponse);
lengthY = 1.2;

% plot the stimuli time sequence
load(simtulusParamsPath, 'responseTimeSequence', 'freqCalciumImaging');
 
stimSteps = cumsum(responseTimeSequence) * freqCalciumImaging;
zeroPlot = zeros(lengthX, 1);
plot(zeroPlot, 'k:');
y1=get(gca,'ylim');

for dt = stimSteps(1:end-1)
    plot([dt dt],y1, 'k-.');
end
hold off

xlim([0 lengthX])
ylim([-lengthY +lengthY])

yticks([-1 0 1])
xticks(cumsum(responseTimeSequence(1:end-1)) * freqCalciumImaging);
xticklabels(cumsum(responseTimeSequence(1:end-1)));


title(strcat('Normalized Euler Response (QI = ', num2str(qualityIndexEuler(nCell)), ')'));