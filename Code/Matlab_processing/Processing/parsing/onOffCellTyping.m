function [isON, isOFF] = onOffCellTyping(eulerAvgResponse)

load(strcat(projectPath(), '/VisualStimulations/EulerStim.mat'));
dts = round(cumsum(responseTimeSequence) * freqCalciumImaging);     

t0_end = dts(1);
t0_final = t0_end - 10;

tStep_init = t0_end + 1;
tStep_mid = tStep_init + 50;
tStep_end = dts(2);
tStep_final = tStep_end - 10;

tCliff_init = tStep_end + 1;
tCliff_mid = tCliff_init + 50;

baseline_ON_std = std(eulerAvgResponse(:, t0_final : t0_end), 0, 2);
baseline_ON_mean = mean(eulerAvgResponse(:, t0_final : t0_end), 2);
threshold_ON = baseline_ON_mean + 4.5 * baseline_ON_std;

baseline_OFF_std = std(eulerAvgResponse(:, tStep_final : tStep_end), 0, 2);
baseline_OFF_mean = mean(eulerAvgResponse(:, tStep_final : tStep_end), 2);
threshold_OFF = baseline_OFF_mean + 4.5 * baseline_OFF_std;

maxON = max(eulerAvgResponse(:, tStep_init : tStep_mid), [], 2);
maxOFF = max(eulerAvgResponse(:, tCliff_init : tCliff_mid), [], 2);

isON = maxON > threshold_ON;
isOFF = maxOFF > threshold_OFF;