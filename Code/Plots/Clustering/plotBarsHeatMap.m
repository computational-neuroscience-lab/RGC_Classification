function plotBarsHeatMap(typeId)

experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
loadDataset()

indices = classIndexes(typeId);

traces = zeros(sum(indices), 110);

i_traces = 1;
for index = find(indices)
    
    experimentFolder = cellsTable(index).experiment;
    n = cellsTable(index).N;

    if cellsTable(index).eulerQT

        load(getBarsStimulus(char(experimentFolder)));

        expPath = strcat(experimentPath, experimentFolder, relativeFolderPath);
        load(strcat(expPath, "barResponses"), 'avgBarResponsesNotNorm');
        load(strcat(expPath, "dirSelectivity"), 'dsAngle');

        load(strcat(expPath, "eulerResponses"), 'peakEuler');
        load(strcat(expPath, "barResponses"), 'peaksBars');
        peak = max(peakEuler(n), peaksBars(n));

        d = mod(round(dsAngle(n) / (pi/4)), 8) + 1;
        trace = avgBarResponsesNotNorm(n, :, d) / peak;
        w = 59 - round(timeOffset_OffCells * freqCalciumImaging);
        round((timeOffset_OffCells - timeOffset_OnCells) * freqCalciumImaging)
        l = size(trace, 2);
        traces(i_traces, w+1:w+l) = trace;
        i_traces = i_traces + 1;
    end
    
end

imagesc(traces(1:i_traces-1, 15:90));
hold on

colormap jet
colorbar
axis off
title("Moving Bars");

