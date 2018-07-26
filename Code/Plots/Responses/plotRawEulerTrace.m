function plotRawEulerTrace(expID, nCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
dataPath = strcat(experimentsPath, expID, dataRelativePath);
dataSetPath = '/EulerStim/patterns';
foPath = strcat(experimentsPath, expID, '/traces/f0.mat');

try
    traces = hdf5read(dataPath, dataSetPath);
    trace = traces(nCell,:);
    load(foPath, 'F0', 'F0_means_On_Trace');  
catch
    fprintf('WARNING: %s trace UNAVAILABLE for experiment %s\n', stimType, expID);
    return
end

[~, length] = size(traces);
plot(trace, 'b');

hold on
f0Plot = plot(F0_means_On_Trace(nCell,:), 'r-.');
hold off
legend([f0Plot], {'F0'}); 

xlim([0 length])
set(gca,'xtick',[])
set(gca,'ytick',[])
title(strcat("Raw Euler Trace"))



