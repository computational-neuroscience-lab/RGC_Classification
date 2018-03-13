function isOff = onOffCellTyping(eulerAvgResponse)

load(strcat(projectPath(), '/VisualStimulations/EulerExperimentalParameters.mat'));
     
dt0_init = 1;
dt0_end = round(eulerDt * eulerImagingFreq);

dt1_init = dt0_end + 1;
dt1_end = round((eulerDt + eulerLowStimTime - eulerHighStimTime) * eulerImagingFreq);

dt2_init = dt1_end + 1;
dt2_end = round((eulerDt + eulerMidStimTime - eulerHighStimTime) * eulerImagingFreq);

stdBaseLine = std(eulerAvgResponse(:, dt0_init : dt0_end), 0, 2);
threshold = 4.5 * stdBaseLine;

maxDuringStep = max(eulerAvgResponse(:, dt1_init : dt1_end), [], 2);
maxAfterStep = max(eulerAvgResponse(:, dt2_init : dt2_end), [], 2);

isOff =  and((maxDuringStep < threshold), (maxAfterStep > threshold));