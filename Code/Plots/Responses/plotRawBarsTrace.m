function plotRawBarsTrace(expID, nCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
dataPath = strcat(experimentsPath, expID, dataRelativePath);
dataSetPath = '/MovingBars/patterns';

try
    tracesType = h5readatt(dataPath, dataSetPath, 'subtype');
    traces = hdf5read(dataPath, dataSetPath);
    trace = traces(nCell,:);
    
    if strcmp(tracesType, '')
        stimulusMat = '/VisualStimulations/MovingBars.mat';
    else
        stimulusMat = strcat('/VisualStimulations/MovingBars_', tracesType, '.mat');
    end
    load(strcat(projectPath(), stimulusMat));
catch
    fprintf('WARNING: bars trace UNAVAILABLE for experiment %s\n', expID);
    return
end
    
[~, length] = size(traces);
plot(trace, 'b');

hold on    
offset_OFF_CELLS = round(timeOffset_OffCells * freqCalciumImaging);
offset_ON_CELLS = round(timeOffset_OnCells * freqCalciumImaging);
ts_init = init_delay * freqCalciumImaging;

resampledRepBin = durationSingleBar * freqCalciumImaging;
for i = (ts_init + offset_OFF_CELLS): resampledRepBin : length
    y1=get(gca,'ylim');
    plot([i i],y1, 'r-.');
end
for i = (ts_init + offset_ON_CELLS): resampledRepBin : length
    y1=get(gca,'ylim');
    plot([i i],y1, 'g--');
end
for i = ts_init : resampledRepBin : length
    y1=get(gca,'ylim');
    plot([i i],y1, 'k:');
end
hold off

xlim([0 length])
set(gca,'xtick',[])
set(gca,'ytick',[])
title(strcat("Raw Bars Trace"))



