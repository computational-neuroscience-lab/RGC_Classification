close all
clear

loadDataset

experiments = unique([cellsTable.experiment]);
barMeans = [];
barSTD = [];

% Check Bars QI among different experiments 
% (as some have different number of repetitions)
for e = experiments
    try
    i = [cellsTable.experiment] == e;
    barMeans = [barMeans, mean([cellsTable(i).barsQI])];
    barSTD = [barSTD, std([cellsTable(i).barsQI])];

    figure;
    cdfplot([cellsTable(i).barsQI]);
    title(e);
    xlabel("cumProbDist");
    ylabel("barsQI");
    catch
        continue
    end
end

bar(barMeans)
hold on
errorbar(barMeans, barSTD);
ylabel("barsQI");
xlabel('Exps');
xticks(1:length(experiments));
xticklabels(experiments);

