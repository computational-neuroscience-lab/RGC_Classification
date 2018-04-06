close all
clear

loadDataset

experiments = unique([cellsTable.experiment]);
barMeans = [];
barSTD = [];

for e = experiments
i = [cellsTable.experiment] == e;
barMeans = [barMeans, mean([cellsTable(i).barsQI])];
barSTD = [barSTD, std([cellsTable(i).barsQI])];
end

bar(barMeans)
hold on
errorbar(barMeans, barSTD);
ylabel("barsQI");
xlabel('Exps');
xticks(1:length(experiments));
xticklabels(experiments);

