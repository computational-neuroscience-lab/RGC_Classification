function [isON, isOFF] = onOffCellTyping(trace, onCliff_ts, offCliff_ts, dSteps_forward, dSteps_back)

ratio = 4.5;

onBefore_ts = onCliff_ts - dSteps_back;
onAfter_ts = onCliff_ts + dSteps_forward;

offBefore_ts = offCliff_ts - dSteps_back;
offAfter_ts = offCliff_ts + dSteps_forward;

baseline_ON_std = std(trace(:, onBefore_ts : onCliff_ts), 0, 2);
baseline_ON_mean = mean(trace(:, onBefore_ts : onCliff_ts), 2);
threshold_ON = baseline_ON_mean + ratio * baseline_ON_std;

baseline_OFF_std = std(trace(:, offBefore_ts : offCliff_ts), 0, 2);
baseline_OFF_mean = mean(trace(:, offBefore_ts : offCliff_ts), 2);
threshold_OFF = baseline_OFF_mean + ratio * baseline_OFF_std;

maxON = max(trace(:, onCliff_ts + 1 : onAfter_ts), [], 2);
maxOFF = max(trace(:, offCliff_ts + 1 : offAfter_ts), [], 2);

isON = maxON > threshold_ON;
isOFF = maxOFF > threshold_OFF;