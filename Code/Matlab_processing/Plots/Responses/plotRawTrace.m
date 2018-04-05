function plotRawTrace(expID, nCell, stimType)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
dataPath = strcat(experimentsPath, expID, dataRelativePath);
dataSetPath = strcat('/', stimType, '/patterns');

if strcmp(stimType, 'EulerStim')
    foPath = strcat(experimentsPath, expID, '/traces/f0.mat');
    load(foPath, 'F0', 'F0_means_On_Trace');
end
if strcmp(stimType, 'MovingBars')
    load('/home/fran_tr/AllOptical/VisualStimulations/MovingBars_30s3r.mat');
    resampledRepBin = durationSingleBar * freqCalciumImaging;
end

try
    traces = hdf5read(dataPath, dataSetPath);
    trace = traces(nCell,:);
    
    [~, length] = size(traces);
    plot(trace, 'b');
   
    
    if strcmp(stimType, 'EulerStim')
        hold on
        f0Plot = plot(F0_means_On_Trace(nCell,:), 'r-.');
        hold off
        legend([f0Plot], {'F0'}); 
    end
    
    if strcmp(stimType, 'MovingBars')
        hold on
        nBins = -1;
                
        offset_OFF_CELLS = round(timeOffset_OffCells * freqCalciumImaging);
        offset_ON_CELLS = round(timeOffset_OnCells * freqCalciumImaging);
        ts_init = init_delay * freqCalciumImaging;
        
        for i = (ts_init + offset_OFF_CELLS): resampledRepBin : length
            y1=get(gca,'ylim');
            plot([i i],y1, 'r-.');
            nBins = nBins + 1;
        end
        for i = (ts_init + offset_ON_CELLS): resampledRepBin : length
            y1=get(gca,'ylim');
            plot([i i],y1, 'g--');
        end
        hold off
        nBins
    end
  
    xlim([0 length])
    
catch
    fprintf('WARNING: %s trace UNAVAILABLE for experiment %s\n', stimType, expID);
end
set(gca,'xtick',[])
set(gca,'ytick',[])
title(strcat("Raw ", stimType, " Trace"))



