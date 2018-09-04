clear
loadDataset()
load('holo_ds.mat')

indices = [];
for i=1:numel(holo_ds)
    indices = [indices, find(and([cellsTable.N] == holo_ds{i}.N, [cellsTable.experiment] == holo_ds{i}.experiment))];
end
indices = indices(2:end);
% 
% indices = find(classIndexes("OFF.DS"));
% indices = indices(indices~=988);


load(getEulerStimulus)
experimentPath = strcat(projectPath, '/Experiments/');
relativeFolderPath = '/traces/';
loadDataset()

traces_euler = [];
i_traces = 1;
for index = indices
    
    experimentFolder = cellsTable(index).experiment;
    n = cellsTable(index).N;

    load(getBarsStimulus(char(experimentFolder)));
   
    expPath = strcat(experimentPath, experimentFolder, relativeFolderPath);
    load(strcat(expPath, "eulerResponses"), 'eulerAvgResponseNotNorm');        
    load(strcat(expPath, "barResponses"), 'avgBarResponsesNotNorm');
    load(strcat(expPath, "dirSelectivity"), 'dsAngle');
        
    trace_euler = eulerAvgResponseNotNorm(n, :);        
    
    d = mod(round(dsAngle(n) / (pi/4)), 8) + 1;
    trace_bars = avgBarResponsesNotNorm(n, :, d);
    
    stdTot = std([trace_euler, trace_bars]);
    maxRow = max(max(trace_bars), max(trace_euler));

    trace_euler = trace_euler / maxRow;    
    trace_bars = trace_bars / maxRow;

    traces_euler = [traces_euler; trace_euler]; 

    w = 59 - round(timeOffset_OffCells * freqCalciumImaging);
    l = size(trace_bars, 2);
    traces_bars(i_traces, w+1:w+l) = trace_bars;
    
    i_traces = i_traces + 1;
end
traces_bars = traces_bars(1:i_traces-1, :);

% sort by peaks
stimSteps = cumsum(responseTimeSequence) * freqCalciumImaging;
off1 = round(stimSteps(4));
off2 = round(stimSteps(4) + (stimSteps(5) - stimSteps(4))/1);
traces_off = traces_euler(:, off1:off2);
[sorted, sortIndices] = sort(max(traces_off, [], 2));


figure
imagesc(traces_euler(sortIndices, :));
hold on

y1=get(gca,'ylim');
for dt = stimSteps(1:end-1)
    plot([dt dt],y1, 'k-.', 'LineWidth', 2);
end
hold off

colormap jet
axis off
title("Full Field Chirp");

figure
imagesc(traces_bars(sortIndices, :));
hold on

y1=get(gca,'ylim');
plot([29 29],y1, 'k-.', 'LineWidth', 2);
plot([59 59],y1, 'k-.', 'LineWidth', 2);

xlim([15, 90])
colormap jet
axis off
title("Moving Bars");



% figure
% subplot(1,2,1);
% plot(traces_euler.');
% hold on
% 
% y1=get(gca,'ylim');
% for dt = stimSteps(1:end-1)
%     plot([dt dt],y1, 'k-.', 'LineWidth', 2);
% end
% title("Full Field Chirp");
% 
% subplot(1,2,2);
% plot(traces_bars.');
% hold on
% 
% y1=get(gca,'ylim');
% plot([29 29],y1, 'k-.', 'LineWidth', 2);
% plot([59 59],y1, 'k-.', 'LineWidth', 2);
% 
% title("Moving Bars");