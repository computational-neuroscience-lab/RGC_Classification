function plotOnOffTypingBars(expID, idCell)

% TODO: these parameters are the same of parseBarsResponses, 
% and should not be hardcoded
dSteps_forward = 20;
dSteps_back = 5;
ratio = 4.5;

load(getBarsStimulus(expID))
offCliff_ts = round(timeOffset_OffCells * freqCalciumImaging);
onCliff_ts = round(timeOffset_OnCells * freqCalciumImaging);

experimentsPath = strcat(projectPath(), '/Experiments/');
barsRelativePath = '/traces/barResponses.mat';
eulerRelativePath = '/traces/eulerResponses.mat';
barsPath = strcat(experimentsPath, expID, barsRelativePath);

load(barsPath, 'barsResponses');

traceBars = median(barsResponses(idCell, :, :), 3);
lengthBars = size(traceBars, 2);

onBefore_ts = onCliff_ts - dSteps_back;
onAfter_ts = onCliff_ts + dSteps_forward;

offBefore_ts = offCliff_ts - dSteps_back;
offAfter_ts = offCliff_ts + dSteps_forward;

baseline_ON_std = std(traceBars(:, onBefore_ts : onCliff_ts), 0, 2);
baseline_ON_mean = mean(traceBars(:, onBefore_ts : onCliff_ts), 2);
threshold_ON = baseline_ON_mean + ratio * baseline_ON_std;

baseline_OFF_std = std(traceBars(:, offBefore_ts : offCliff_ts), 0, 2);
baseline_OFF_mean = mean(traceBars(:, offBefore_ts : offCliff_ts), 2);
threshold_OFF = baseline_OFF_mean + ratio * baseline_OFF_std;

plot(traceBars)
hold on
y1=get(gca,'ylim');

plot([onCliff_ts onCliff_ts],y1, 'g-.');
plot([onBefore_ts onBefore_ts],y1, 'g-.');
p1 = plot([onCliff_ts onAfter_ts],[threshold_ON, threshold_ON], 'g-.', 'DisplayName', "On threshold");

plot([offCliff_ts, offCliff_ts],y1, 'r-.');
plot([offBefore_ts, offBefore_ts],y1, 'r-.');
p2 = plot([offCliff_ts offAfter_ts],[threshold_OFF, threshold_OFF], 'r-.', 'DisplayName', "Off threshold");

hold off

xlim([0 lengthBars])
xticks([0, onCliff_ts, offCliff_ts, lengthBars]);
legend([p1, p2]);
title('Bars ON Off Thresholds')
