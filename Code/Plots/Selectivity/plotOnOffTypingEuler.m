function plotOnOffTypingEuler(expID, idCell)

% TODO: these parameters are the same of parseEulerResponses, 
% and should not be hardcoded
dSteps_forward = 50;
dSteps_back = 10;
ratio = 4.5;

load(getEulerStimulus)

tSteps = cumsum(responseTimeSequence);
onCliff_ts = round(tSteps(1) * freqImaging);
offCliff_ts = round(tSteps(2) * freqImaging);

experimentsPath = strcat(projectPath(), '/Experiments/');
eulerRelativePath = '/traces/eulerResponses.mat';
eulerPath = strcat(experimentsPath, expID, eulerRelativePath);
load(eulerPath, 'eulerNormResponses');

traceEuler = median(eulerNormResponses(idCell, :, :), 3);
lengthEuler = round(tSteps(3) * freqImaging);

onBefore_ts = onCliff_ts - dSteps_back;
onAfter_ts = onCliff_ts + dSteps_forward;

offBefore_ts = offCliff_ts - dSteps_back;
offAfter_ts = offCliff_ts + dSteps_forward;

baseline_ON_std = std(traceEuler(:, onBefore_ts : onCliff_ts), 0, 2);
baseline_ON_mean = mean(traceEuler(:, onBefore_ts : onCliff_ts), 2);
threshold_ON = baseline_ON_mean + ratio * baseline_ON_std;

baseline_OFF_std = std(traceEuler(:, offBefore_ts : offCliff_ts), 0, 2);
baseline_OFF_mean = mean(traceEuler(:, offBefore_ts : offCliff_ts), 2);
threshold_OFF = baseline_OFF_mean + ratio * baseline_OFF_std;

plot(traceEuler)
hold on
y1=get(gca,'ylim');

plot([onCliff_ts onCliff_ts],y1, 'g-.');
plot([onBefore_ts onBefore_ts],y1, 'g-.');
p1 = plot([onCliff_ts onAfter_ts],[threshold_ON, threshold_ON], 'g-.', 'DisplayName', "On threshold");

plot([offCliff_ts, offCliff_ts],y1, 'r-.');
plot([offBefore_ts, offBefore_ts],y1, 'r-.');
p2 = plot([offCliff_ts offAfter_ts],[threshold_OFF, threshold_OFF], 'r-.', 'DisplayName', "Off threshold");

hold off

xlim([0 lengthEuler])
xticks([0, onCliff_ts, offCliff_ts, lengthEuler]);
legend([p1, p2]);
title('Euler On Off Thresholds')