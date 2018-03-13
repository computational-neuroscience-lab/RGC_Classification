function lengthX = plotAvgEulerResponse(expID, nCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/eulerResponses.mat';
dataPath = strcat(experimentsPath, expID, dataRelativePath);

load(dataPath, 'eulerAvgResponse', 'qualityIndex');
trace = eulerAvgResponse(nCell,:);
plot(trace);

[~, lengthX] = size(eulerAvgResponse);
lengthY = max(abs(eulerAvgResponse(nCell,:))) * 1.2;

% plot also the threshold used for On-Off classification
load('/home/fran_tr/AllOptical/VisualStimulations/EulerExperimentalParameters.mat');
    
dt0_init = 1;
dt0_end = round(eulerDt * eulerImagingFreq);

dt1_init = dt0_end + 1;
dt1_end = round((eulerDt + eulerLowStimTime - eulerHighStimTime) * eulerImagingFreq);

dt2_init = dt1_end + 1;
dt2_end = round((eulerDt + eulerMidStimTime - eulerHighStimTime) * eulerImagingFreq);

stdBaseLine = std(trace(dt0_init : dt0_end), 0, 2);
threshold = 4.5 * stdBaseLine;
thresholdPlot = ones(lengthX, 1) * threshold;

hold on
plot(thresholdPlot, 'r:');
y1=get(gca,'ylim');
plot([dt0_end dt0_end],y1, 'r-.');
plot([dt1_end dt1_end],y1, 'r-.');
plot([dt2_end dt2_end],y1, 'r-.');
hold off

xlim([0 lengthX])
ylim([-lengthY +lengthY])

title(strcat('Normalized Euler Response (QI = ', num2str(qualityIndex(nCell)), ')'));