function plotEulerHeat(typeId)

load(getEulerStimulus)
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
loadDataset()

indices = classIndexes(typeId);

traces = [];
for index = find(indices)
    
    experimentFolder = cellsTable(index).experiment;
    n = cellsTable(index).N;
    if cellsTable(index).eulerQT
        expPath = strcat(experimentPath, experimentFolder, relativeFolderPath);
        load(strcat(expPath, "eulerResponses"), 'eulerAvgResponseNotNorm');
        load(strcat(expPath, "eulerResponses"), 'peakEuler');
        load(strcat(expPath, "barResponses"), 'peaksBars');
        peak = max(peakEuler(n), peaksBars(n));
        trace = eulerAvgResponseNotNorm(n, :) / peak;        
        traces = [traces; trace]; 
    end
end

imagesc(traces);
hold on

stimSteps = cumsum(responseTimeSequence) * freqCalciumImaging;
y1=get(gca,'ylim');
for dt = stimSteps(1:end-1)
    plot([dt dt],y1, 'k-.', 'LineWidth', 2);
end
hold off

colormap jet
colorbar
axis off
title("Full Field Chirp");

