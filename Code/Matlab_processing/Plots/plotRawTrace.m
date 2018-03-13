function length = plotRawTrace(expID, nCell, stimType)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
dataPath = strcat(experimentsPath, expID, dataRelativePath);
dataSetPath = strcat('/', stimType, '/patterns');

if strcmp(stimType, 'EulerStim')
    foPath = strcat(experimentsPath, expID, '/traces/f0.mat');
    load(foPath, 'F0', 'F0_intervals_On_Trace', 'F0_means_On_Trace');
end
if strcmp(stimType, 'MovingBars')
    load('/home/fran_tr/AllOptical/VisualStimulations/BarsExperimentalParameters.mat');
    resampledRepBin = singleBarDuration * barsImagingFreq;
end

try
    traces = hdf5read(dataPath, dataSetPath);
    trace = traces(nCell,:);
    
    [~, length] = size(traces);
    plot(trace, 'b');
   
    
    if strcmp(stimType, 'EulerStim')
        hold on
        plot(F0_intervals_On_Trace(nCell,:), 'g');
        f0Plot = plot(F0_means_On_Trace(nCell,:), 'r-.');
        hold off
        legend([f0Plot], {'F0'}); 
    end
    
    if strcmp(stimType, 'MovingBars')
        hold on
        nBins = -1;
        for i = offset_OFF_CELLS: resampledRepBin : length
            y1=get(gca,'ylim');
            plot([i i],y1, 'r-.');
            nBins = nBins + 1;
        end
        for i = offset_ON_CELLS: resampledRepBin : length
            y1=get(gca,'ylim');
            plot([i i],y1, 'g--');
            nBins = nBins + 1;
        end
        hold off
    end
  
    xlim([0 length])
    
catch
    fprintf('WARNING: %s trace UNAVAILABLE for experiment %s\n', stimType, expID);
end
title(strcat('Raw ', stimType, ' Trace'))



